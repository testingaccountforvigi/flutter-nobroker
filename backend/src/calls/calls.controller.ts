import {
  Controller,
  Post,
  Get,
  Patch,
  Param,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import { CallsService } from './calls.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('calls')
@UseGuards(JwtAuthGuard)
export class CallsController {
  constructor(private readonly callsService: CallsService) {}

  @Post('initiate')
  async initiateCall(
    @Request() req,
    @Body() body: { receiverId: string; propertyId?: string },
  ) {
    return this.callsService.initiateCall(
      req.user.userId,
      body.receiverId,
      body.propertyId,
    );
  }

  @Get('active')
  async getActiveCalls(@Request() req) {
    return this.callsService.getActiveCalls(req.user.userId);
  }

  @Get('history')
  async getCallHistory(@Request() req) {
    return this.callsService.getCallHistory(req.user.userId);
  }

  @Patch(':id/status')
  async updateCallStatus(
    @Request() req,
    @Param('id') id: string,
    @Body() body: { status: 'INITIATED' | 'RINGING' | 'ACCEPTED' | 'COMPLETED' | 'MISSED' | 'DECLINED' | 'CANCELLED' },
  ) {
    return this.callsService.updateCallStatus(id, body.status, req.user.userId);
  }
}
