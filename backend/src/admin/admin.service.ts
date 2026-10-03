import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  // User Management
  async getAllUsers(page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    
    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        skip,
        take: limit,
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          intent: true,
          createdAt: true,
          _count: {
            select: {
              ownedProperties: true,
              sentInquiries: true,
              favorites: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.user.count(),
    ]);

    return {
      users,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getUserById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        ownedProperties: {
          select: {
            id: true,
            title: true,
            status: true,
            price: true,
            createdAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
        sentInquiries: {
          select: {
            id: true,
            message: true,
            status: true,
            createdAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
        verificationRequest: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async suspendUser(id: string) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Cannot suspend admin users
    if (user.role === 'ADMIN') {
      throw new BadRequestException('Cannot suspend admin users');
    }

    // Deactivate all user's active properties
    await this.prisma.property.updateMany({
      where: {
        ownerId: id,
        status: 'PUBLISHED',
      },
      data: { status: 'PAUSED' },
    });

    return { message: 'User suspended and properties deactivated' };
  }

  // Property Moderation
  async getAllProperties(status?: string, page = 1, limit = 20) {
    const skip = (page - 1) * limit;
    
    const where: any = status ? { status: status as any } : {};

    const [properties, total] = await Promise.all([
      this.prisma.property.findMany({
        where,
        skip,
        take: limit,
        include: {
          owner: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          photos: {
            take: 1,
          },
          _count: {
            select: {
              inquiries: true,
              favorites: true,
              views: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.property.count({ where }),
    ]);

    return {
      properties,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async flagProperty(id: string, reason: string) {
    const property = await this.prisma.property.findUnique({ where: { id } });
    if (!property) {
      throw new NotFoundException('Property not found');
    }

    return this.prisma.property.update({
      where: { id },
      data: {
        status: 'PAUSED',
        // Store flag reason in a report
      },
    });
  }

  async deleteProperty(id: string) {
    const property = await this.prisma.property.findUnique({ where: { id } });
    if (!property) {
      throw new NotFoundException('Property not found');
    }

    await this.prisma.property.delete({ where: { id } });
    return { message: 'Property deleted successfully' };
  }

  // Dashboard Stats
  async getDashboardStats() {
    const [
      totalUsers,
      totalProperties,
      activeProperties,
      pendingVerifications,
      todayInquiries,
      premiumProperties,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.property.count(),
      this.prisma.property.count({ where: { status: 'PUBLISHED' } }),
      this.prisma.verificationRequest.count({ where: { status: 'PENDING' } }),
      this.prisma.inquiry.count({
        where: {
          createdAt: {
            gte: new Date(new Date().setHours(0, 0, 0, 0)),
          },
        },
      }),
      this.prisma.property.count({ where: { isPremium: true } }),
    ]);

    // Get user growth (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const newUsers = await this.prisma.user.count({
      where: {
        createdAt: {
          gte: sevenDaysAgo,
        },
      },
    });

    // Get property views (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const recentViews = await this.prisma.propertyView.count({
      where: {
        createdAt: {
          gte: thirtyDaysAgo,
        },
      },
    });

    return {
      totalUsers,
      totalProperties,
      activeProperties,
      pendingVerifications,
      todayInquiries,
      premiumProperties,
      newUsers7Days: newUsers,
      views30Days: recentViews,
    };
  }

  // Reports
  async getReports(page = 1, limit = 20) {
    const skip = (page - 1) * limit;

    const [reports, total] = await Promise.all([
      this.prisma.report.findMany({
        skip,
        take: limit,
        include: {
          reporter: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          property: {
            select: {
              id: true,
              title: true,
              owner: {
                select: {
                  id: true,
                  name: true,
                },
              },
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.report.count(),
    ]);

    return {
      reports,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async resolveReport(id: string, action: string) {
    const report = await this.prisma.report.findUnique({ where: { id } });
    if (!report) {
      throw new NotFoundException('Report not found');
    }

    return this.prisma.report.update({
      where: { id },
      data: {
        status: 'RESOLVED',
      },
    });
  }
}
