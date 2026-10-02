import { Module } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { PrismaModule } from './common/prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PropertiesModule } from './properties/properties.module';
import { FavoritesModule } from './favorites/favorites.module';
import { InquiriesModule } from './inquiries/inquiries.module';
import { CallsModule } from './calls/calls.module';
import { VerificationModule } from './verification/verification.module';
import { AgreementsModule } from './agreements/agreements.module';
import { MoversModule } from './movers/movers.module';
import { RemindersModule } from './reminders/reminders.module';
import { PremiumModule } from './premium/premium.module';
import { AdminModule } from './admin/admin.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: 60000, // 1 minute
        limit: 100, // 100 requests per minute
      },
    ]),
    
    // Core modules
    PrismaModule,
    
    // Feature modules
    AuthModule,
    UsersModule,
    PropertiesModule,
    FavoritesModule,
    InquiriesModule,
    CallsModule,
    VerificationModule,
    AgreementsModule,
    MoversModule,
    RemindersModule,
    PremiumModule,
    AdminModule,
    HealthModule,
  ],
})
export class AppModule {}
