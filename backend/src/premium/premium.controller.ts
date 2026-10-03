import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PremiumService } from './premium.service';

@ApiTags('premium')
@Controller('premium')
export class PremiumController {
  constructor(private readonly premiumService: PremiumService) {}

  @Get('packages')
  @ApiOperation({ summary: 'Get premium packages' })
  getPremiumPackages() {
    return this.premiumService.getPremiumPackages();
  }

  @Post('orders')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create premium order' })
  createPremiumOrder(@Request() req, @Body() data: any) {
    return this.premiumService.createPremiumOrder(req.user.userId, data.propertyId, data);
  }

  @Get('orders')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my premium orders' })
  getMyPremiumOrders(@Request() req) {
    return this.premiumService.getMyPremiumOrders(req.user.userId);
  }

  @Post('orders/:id/pay')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Process mock payment' })
  processMockPayment(@Param('id') id: string, @Request() req) {
    return this.premiumService.processMockPayment(id, req.user.userId);
  }
}
