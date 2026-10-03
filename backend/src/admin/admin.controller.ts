import { Controller, Get, Post, Delete, Patch, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { AdminService } from './admin.service';

@ApiTags('admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Get dashboard statistics' })
  getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  @Get('users')
  @ApiOperation({ summary: 'Get all users' })
  getAllUsers(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.adminService.getAllUsers(page, limit);
  }

  @Get('users/:id')
  @ApiOperation({ summary: 'Get user by ID' })
  getUserById(@Param('id') id: string) {
    return this.adminService.getUserById(id);
  }

  @Post('users/:id/suspend')
  @ApiOperation({ summary: 'Suspend user' })
  suspendUser(@Param('id') id: string) {
    return this.adminService.suspendUser(id);
  }

  @Get('properties')
  @ApiOperation({ summary: 'Get all properties' })
  getAllProperties(
    @Query('status') status?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.adminService.getAllProperties(status, page, limit);
  }

  @Post('properties/:id/flag')
  @ApiOperation({ summary: 'Flag property' })
  flagProperty(@Param('id') id: string, @Body() data: { reason: string }) {
    return this.adminService.flagProperty(id, data.reason);
  }

  @Delete('properties/:id')
  @ApiOperation({ summary: 'Delete property' })
  deleteProperty(@Param('id') id: string) {
    return this.adminService.deleteProperty(id);
  }

  @Get('reports')
  @ApiOperation({ summary: 'Get reports' })
  getReports(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.adminService.getReports(page, limit);
  }

  @Patch('reports/:id/resolve')
  @ApiOperation({ summary: 'Resolve report' })
  resolveReport(@Param('id') id: string, @Body() data: { action: string }) {
    return this.adminService.resolveReport(id, data.action);
  }
}
