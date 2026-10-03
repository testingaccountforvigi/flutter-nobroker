import { Module } from '@nestjs/common';
import { MoversController } from './movers.controller';
import { MoversService } from './movers.service';
import { PrismaModule } from '../common/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [MoversController],
  providers: [MoversService],
  exports: [MoversService],
})
export class MoversModule {}
