import { Controller, Get, Post, Patch, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { InquiriesService } from './inquiries.service';
import { CreateInquiryDto } from './dto/create-inquiry.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { InquiryStatus } from '@prisma/client';

@ApiTags('inquiries')
@Controller('inquiries')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class InquiriesController {
  constructor(private inquiriesService: InquiriesService) {}

  @Post(':propertyId')
  @ApiOperation({ summary: 'Create inquiry for property' })
  async create(
    @Param('propertyId') propertyId: string,
    @Body() createInquiryDto: CreateInquiryDto,
    @Request() req,
  ) {
    return this.inquiriesService.create(req.user.userId, propertyId, createInquiryDto.message);
  }

  @Get('my')
  @ApiOperation({ summary: 'Get my inquiries' })
  async getMyInquiries(@Request() req) {
    return this.inquiriesService.getMyInquiries(req.user.userId);
  }

  @Get('leads')
  @ApiOperation({ summary: 'Get owner leads' })
  async getOwnerLeads(@Request() req) {
    return this.inquiriesService.getOwnerLeads(req.user.userId);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update inquiry status' })
  async updateStatus(
    @Param('id') id: string,
    @Body('status') status: InquiryStatus,
    @Request() req,
  ) {
    return this.inquiriesService.updateStatus(id, req.user.userId, status);
  }
}
