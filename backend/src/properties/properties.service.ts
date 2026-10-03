import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { SearchPropertiesDto } from './dto/search-properties.dto';
import { PropertyStatus, Prisma } from '@prisma/client';

@Injectable()
export class PropertiesService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, createPropertyDto: CreatePropertyDto) {
    const { amenityIds, ...propertyData } = createPropertyDto;

    const property = await this.prisma.property.create({
      data: {
        ...propertyData,
        ownerId: userId,
        status: PropertyStatus.DRAFT,
        availableFrom: new Date(propertyData.availableFrom),
        amenities: amenityIds
          ? {
              create: amenityIds.map((amenityId) => ({
                amenity: { connect: { id: amenityId } },
              })),
            }
          : undefined,
      },
      include: {
        photos: true,
        amenities: { include: { amenity: true } },
        owner: { select: { id: true, name: true, email: true } },
      },
    });

    return property;
  }

  async search(searchDto: SearchPropertiesDto) {
    const {
      purpose,
      city,
      locality,
      minPrice,
      maxPrice,
      type,
      bedrooms,
      bathrooms,
      furnishing,
      verifiedOwner,
      premium,
      sortBy = 'recommended',
      page = 1,
      limit = 20,
    } = searchDto;

    const where: Prisma.PropertyWhereInput = {
      status: PropertyStatus.PUBLISHED,
      ...(purpose && { purpose }),
      ...(city && { city: { contains: city, mode: 'insensitive' } }),
      ...(locality && { locality: { contains: locality, mode: 'insensitive' } }),
      ...(minPrice && { price: { gte: minPrice } }),
      ...(maxPrice && { price: { lte: maxPrice } }),
      ...(type && { type }),
      ...(bedrooms && { bedrooms: { gte: bedrooms } }),
      ...(bathrooms && { bathrooms: { gte: bathrooms } }),
      ...(furnishing && { furnishing }),
      ...(verifiedOwner && { isVerifiedOwnerSnapshot: true }),
      ...(premium && { isPremium: true, premiumUntil: { gt: new Date() } }),
    };

    const orderBy = this.getOrderBy(sortBy);

    const [properties, total] = await Promise.all([
      this.prisma.property.findMany({
        where,
        include: {
          photos: { where: { isCover: true }, take: 1 },
          amenities: { include: { amenity: { select: { name: true, icon: true } } }, take: 5 },
          owner: { select: { id: true, name: true } },
          _count: { select: { favorites: true, inquiries: true } },
        },
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.property.count({ where }),
    ]);

    return {
      properties,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string, userId?: string) {
    const property = await this.prisma.property.findUnique({
      where: { id },
      include: {
        photos: { orderBy: { sortOrder: 'asc' } },
        floorPlan: true,
        amenities: { include: { amenity: true } },
        owner: { select: { id: true, name: true, email: true, avatarUrl: true } },
        _count: { select: { favorites: true, inquiries: true, views: true } },
      },
    });

    if (!property) {
      throw new NotFoundException('Property not found');
    }

    // Track view
    if (userId && userId !== property.ownerId) {
      await this.prisma.propertyView.create({
        data: { propertyId: id, userId },
      }).catch(() => {}); // Ignore duplicate view errors
    }

    return property;
  }

  async update(id: string, userId: string, updateDto: Partial<CreatePropertyDto>) {
    const property = await this.findOne(id);

    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own properties');
    }

    const { amenityIds, ...updateData } = updateDto;

    return this.prisma.property.update({
      where: { id },
      data: {
        ...updateData,
        ...(updateData.availableFrom && { availableFrom: new Date(updateData.availableFrom) }),
        ...(amenityIds && {
          amenities: {
            deleteMany: {},
            create: amenityIds.map((amenityId) => ({
              amenity: { connect: { id: amenityId } },
            })),
          },
        }),
      },
      include: {
        photos: true,
        amenities: { include: { amenity: true } },
      },
    });
  }

  async delete(id: string, userId: string) {
    const property = await this.findOne(id);

    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only delete your own properties');
    }

    await this.prisma.property.delete({ where: { id } });
    return { message: 'Property deleted successfully' };
  }

  async updateStatus(id: string, userId: string, status: PropertyStatus) {
    const property = await this.findOne(id);

    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own properties');
    }

    return this.prisma.property.update({
      where: { id },
      data: { status },
    });
  }

  async getOwnerProperties(userId: string) {
    return this.prisma.property.findMany({
      where: { ownerId: userId },
      include: {
        photos: { where: { isCover: true }, take: 1 },
        _count: { select: { inquiries: true, favorites: true, views: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async addPhoto(propertyId: string, userId: string, photoData: any) {
    const property = await this.findOne(propertyId);

    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only add photos to your own properties');
    }

    return this.prisma.propertyPhoto.create({
      data: {
        ...photoData,
        propertyId,
      },
    });
  }

  async deletePhoto(propertyId: string, photoId: string, userId: string) {
    const property = await this.findOne(propertyId);

    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only delete photos from your own properties');
    }

    await this.prisma.propertyPhoto.delete({ where: { id: photoId } });
    return { message: 'Photo deleted successfully' };
  }

  async getSimilarProperties(id: string, limit = 4) {
    const property = await this.findOne(id);

    return this.prisma.property.findMany({
      where: {
        id: { not: id },
        status: PropertyStatus.PUBLISHED,
        purpose: property.purpose,
        city: property.city,
        bedrooms: { gte: property.bedrooms - 1, lte: property.bedrooms + 1 },
        price: { gte: property.price * 0.8, lte: property.price * 1.2 },
      },
      include: {
        photos: { where: { isCover: true }, take: 1 },
        owner: { select: { id: true, name: true } },
      },
      take: limit,
    });
  }

  private getOrderBy(sortBy: string): Prisma.PropertyOrderByWithRelationInput[] {
    switch (sortBy) {
      case 'newest':
        return [{ createdAt: 'desc' }];
      case 'priceAsc':
        return [{ price: 'asc' }];
      case 'priceDesc':
        return [{ price: 'desc' }];
      case 'recommended':
      default:
        return [{ isPremium: 'desc' }, { createdAt: 'desc' }];
    }
  }
}
