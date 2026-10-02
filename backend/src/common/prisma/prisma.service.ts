import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('✅ Database connected successfully');
    } catch (error) {
      this.logger.error('❌ Database connection failed:', error);
      throw error;
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log('Database disconnected');
  }

  async cleanDatabase() {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('Cannot clean database in production');
    }

    // Delete all data in reverse order of dependencies
    const models = [
      'auditLog',
      'inAppNotification',
      'report',
      'premiumOrder',
      'reminder',
      'moverBooking',
      'moverQuote',
      'movingItem',
      'movingRequest',
      'mover',
      'agreementSignature',
      'agreement',
      'verificationRequest',
      'call',
      'visitRequest',
      'inquiry',
      'propertyView',
      'favorite',
      'propertyAmenity',
      'amenity',
      'floorPlan',
      'propertyPhoto',
      'property',
      'refreshToken',
      'user',
    ];

    for (const model of models) {
      await this[model].deleteMany();
    }

    this.logger.log('Database cleaned');
  }
}
