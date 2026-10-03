import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class FavoritesService {
  constructor(private prisma: PrismaService) {}

  async getMyFavorites(userId: string) {
    return this.prisma.favorite.findMany({
      where: { userId },
      include: {
        property: {
          include: {
            photos: { where: { isCover: true }, take: 1 },
            owner: { select: { id: true, name: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async addFavorite(userId: string, propertyId: string) {
    return this.prisma.favorite.create({
      data: { userId, propertyId },
    });
  }

  async removeFavorite(userId: string, propertyId: string) {
    await this.prisma.favorite.deleteMany({
      where: { userId, propertyId },
    });
    return { message: 'Removed from favorites' };
  }

  async isFavorite(userId: string, propertyId: string) {
    const favorite = await this.prisma.favorite.findFirst({
      where: { userId, propertyId },
    });
    return { isFavorite: !!favorite };
  }
}
