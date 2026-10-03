import { Module } from '@nestjs/common';
import { CallsController } from './calls.controller';
import { CallsService } from './calls.service';
import { PrismaService } from '../common/prisma/prisma.service';
import { CallsGateway } from './calls.gateway';

@Module({
  controllers: [CallsController],
  providers: [CallsService, PrismaService, CallsGateway],
  exports: [CallsService],
})
export class CallsModule {}
