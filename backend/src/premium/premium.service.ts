import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class PremiumService {
  constructor(private prisma: PrismaService) {}

  async createPremiumOrder(userId: string, propertyId: string, data: any) {
    // Verify property ownership
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
    });

    if (!property) {
      throw new NotFoundException('Property not found');
    }

    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only upgrade your own properties');
    }

    if (property.isPremium) {
      throw new BadRequestException('Property is already premium');
    }

    // Create premium order
    return this.prisma.premiumOrder.create({
      data: {
        userId,
        propertyId,
        amount: data.amount,
        durationDays: data.duration,
        status: 'PENDING',
      },
      include: {
        property: {
          select: {
            id: true,
            title: true,
          },
        },
      },
    });
  }

  async getMyPremiumOrders(userId: string) {
    return this.prisma.premiumOrder.findMany({
      where: { userId },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            isPremium: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async processMockPayment(orderId: string, userId: string) {
    const order = await this.prisma.premiumOrder.findUnique({
      where: { id: orderId },
      include: {
        property: true,
      },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    if (order.status !== 'PENDING') {
      throw new BadRequestException('Order already processed');
    }

    // Mock payment processing - always succeeds
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + order.durationDays);

    const activatedAt = new Date();

    // Update order
    const updatedOrder = await this.prisma.premiumOrder.update({
      where: { id: orderId },
      data: {
        status: 'COMPLETED',
        activatedAt,
        expiresAt,
      },
    });

    // Upgrade property to premium
    await this.prisma.property.update({
      where: { id: order.propertyId },
      data: {
        isPremium: true,
        premiumUntil: expiresAt,
      },
    });

    return updatedOrder;
  }

  async getPremiumPackages() {
    return [
      {
        id: 'basic',
        name: 'Basic Premium',
        duration: 30,
        price: 499,
        features: [
          'Top listing for 30 days',
          'Premium badge',
          '3x more visibility',
          'Priority support',
        ],
      },
      {
        id: 'standard',
        name: 'Standard Premium',
        duration: 90,
        price: 1299,
        features: [
          'Top listing for 90 days',
          'Premium badge',
          '5x more visibility',
          'Priority support',
          'Featured in search results',
        ],
        savings: '₹198 saved',
        recommended: true,
      },
      {
        id: 'premium',
        name: 'Premium Plus',
        duration: 180,
        price: 2399,
        features: [
          'Top listing for 180 days',
          'Premium badge',
          '10x more visibility',
          '24/7 Priority support',
          'Featured in search results',
          'Social media promotion',
        ],
        savings: '₹582 saved',
      },
    ];
  }

  async checkExpiredPremiumListings() {
    const now = new Date();
    const expired = await this.prisma.property.findMany({
      where: {
        isPremium: true,
        premiumUntil: {
          lte: now,
        },
      },
    });

    for (const property of expired) {
      await this.prisma.property.update({
        where: { id: property.id },
        data: { isPremium: false },
      });
    }

    return expired.length;
  }
}
