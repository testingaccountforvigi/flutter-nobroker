import { Controller, Get, Post, Patch, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { MoversService } from './movers.service';

@ApiTags('movers')
@Controller('movers')
export class MoversController {
  constructor(private readonly moversService: MoversService) {}

  @Get()
  @ApiOperation({ summary: 'Get all movers' })
  getAllMovers() {
    return this.moversService.getAllMovers();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get mover by ID' })
  getMoverById(@Param('id') id: string) {
    return this.moversService.getMoverById(id);
  }

  @Post('requests')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create moving request' })
  createMovingRequest(@Request() req, @Body() data: any) {
    return this.moversService.createMovingRequest(req.user.userId, data);
  }

  @Get('requests/my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get my moving requests' })
  getMyMovingRequests(@Request() req) {
    return this.moversService.getMyMovingRequests(req.user.userId);
  }

  @Get('requests/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get moving request by ID' })
  getMovingRequestById(@Param('id') id: string, @Request() req) {
    return this.moversService.getMovingRequestById(id, req.user.userId);
  }

  @Post('quotes/:quoteId/accept')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Accept mover quote' })
  acceptQuote(@Param('quoteId') quoteId: string, @Request() req) {
    return this.moversService.acceptQuote(quoteId, req.user.userId);
  }

  @Patch('bookings/:id/complete')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Complete booking' })
  completeBooking(@Param('id') id: string, @Request() req) {
    return this.moversService.completeBooking(id, req.user.userId);
  }

  @Post('bookings/:id/rate')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Rate booking' })
  rateBooking(@Param('id') id: string, @Body() data: { rating: number; review: string }, @Request() req) {
    return this.moversService.rateBooking(id, req.user.userId, data.rating, data.review);
  }
}
