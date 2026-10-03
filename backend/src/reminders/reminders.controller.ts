import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RemindersService } from './reminders.service';

@ApiTags('reminders')
@Controller('reminders')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RemindersController {
  constructor(private readonly remindersService: RemindersService) {}

  @Post()
  @ApiOperation({ summary: 'Create reminder' })
  createReminder(@Request() req, @Body() data: any) {
    return this.remindersService.createReminder(req.user.userId, data);
  }

  @Get()
  @ApiOperation({ summary: 'Get my reminders' })
  getMyReminders(@Request() req, @Query('completed') completed?: string) {
    const completedBool = completed === 'true' ? true : completed === 'false' ? false : undefined;
    return this.remindersService.getMyReminders(req.user.userId, completedBool);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get reminder by ID' })
  getReminderById(@Param('id') id: string, @Request() req) {
    return this.remindersService.getReminderById(id, req.user.userId);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update reminder' })
  updateReminder(@Param('id') id: string, @Request() req, @Body() data: any) {
    return this.remindersService.updateReminder(id, req.user.userId, data);
  }

  @Patch(':id/complete')
  @ApiOperation({ summary: 'Mark reminder as completed' })
  markAsCompleted(@Param('id') id: string, @Request() req) {
    return this.remindersService.markAsCompleted(id, req.user.userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete reminder' })
  deleteReminder(@Param('id') id: string, @Request() req) {
    return this.remindersService.deleteReminder(id, req.user.userId);
  }
}
