import { Module } from '@nestjs/common';
import { MoversService } from './movers.service';
import { MoversController } from './movers.controller';

@Module({
  controllers: [MoversController],
  providers: [MoversService],
  exports: [MoversService],
})
export class MoversModule {}
