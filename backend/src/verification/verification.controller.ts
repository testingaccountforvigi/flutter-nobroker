import { Controller, Get, Post, Patch, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { VerificationService } from './verification.service';

@ApiTags('verification')
@Controller('verification')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class VerificationController {
  constructor(private readonly verificationService: VerificationService) {}

  @Post()
  @ApiOperation({ summary: 'Create verification request' })
  createVerificationRequest(@Request() req, @Body() data: any) {
    return this.verificationService.createVerificationRequest(req.user.userId, data);
  }

  @Get('my-requests')
  @ApiOperation({ summary: 'Get my verification requests' })
  getMyVerificationRequests(@Request() req) {
    return this.verificationService.getMyVerificationRequests(req.user.userId);
  }

  @Get('pending')
  @UseGuards(RolesGuard)
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Get pending verifications (Admin only)' })
  getPendingVerifications() {
    return this.verificationService.getPendingVerifications();
  }

  @Patch(':id/approve')
  @UseGuards(RolesGuard)
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Approve verification (Admin only)' })
  approveVerification(@Param('id') id: string, @Request() req) {
    return this.verificationService.approveVerification(id, req.user.userId);
  }

  @Patch(':id/reject')
  @UseGuards(RolesGuard)
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Reject verification (Admin only)' })
  rejectVerification(@Param('id') id: string, @Body() data: { reason: string }, @Request() req) {
    return this.verificationService.rejectVerification(id, req.user.userId, data.reason);
  }
}
