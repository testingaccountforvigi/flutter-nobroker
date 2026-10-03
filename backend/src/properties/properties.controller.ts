import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { PropertiesService } from './properties.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { SearchPropertiesDto } from './dto/search-properties.dto';
import { AddPhotoDto } from './dto/add-photo.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PropertyStatus } from '@prisma/client';

@ApiTags('properties')
@Controller('properties')
export class PropertiesController {
  constructor(private propertiesService: PropertiesService) {}

  @Get()
  @ApiOperation({ summary: 'Search properties' })
  @ApiResponse({ status: 200, description: 'Properties retrieved successfully' })
  async search(@Query() searchDto: SearchPropertiesDto) {
    return this.propertiesService.search(searchDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get property details' })
  @ApiResponse({ status: 200, description: 'Property retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async findOne(@Param('id') id: string, @Request() req) {
    const userId = req.user?.userId;
    return this.propertiesService.findOne(id, userId);
  }

  @Get(':id/similar')
  @ApiOperation({ summary: 'Get similar properties' })
  async getSimilar(@Param('id') id: string) {
    return this.propertiesService.getSimilarProperties(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create property' })
  @ApiResponse({ status: 201, description: 'Property created successfully' })
  async create(@Request() req, @Body() createPropertyDto: CreatePropertyDto) {
    return this.propertiesService.create(req.user.userId, createPropertyDto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update property' })
  @ApiResponse({ status: 200, description: 'Property updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async update(
    @Param('id') id: string,
    @Request() req,
    @Body() updateDto: Partial<CreatePropertyDto>,
  ) {
    return this.propertiesService.update(id, req.user.userId, updateDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete property' })
  @ApiResponse({ status: 200, description: 'Property deleted successfully' })
  async delete(@Param('id') id: string, @Request() req) {
    return this.propertiesService.delete(id, req.user.userId);
  }

  @Post(':id/publish')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Publish property' })
  async publish(@Param('id') id: string, @Request() req) {
    return this.propertiesService.updateStatus(id, req.user.userId, PropertyStatus.PUBLISHED);
  }

  @Post(':id/pause')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Pause property' })
  async pause(@Param('id') id: string, @Request() req) {
    return this.propertiesService.updateStatus(id, req.user.userId, PropertyStatus.PAUSED);
  }

  @Post(':id/photos')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add property photo' })
  async addPhoto(@Param('id') id: string, @Request() req, @Body() photoDto: AddPhotoDto) {
    return this.propertiesService.addPhoto(id, req.user.userId, photoDto);
  }

  @Delete(':id/photos/:photoId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete property photo' })
  async deletePhoto(@Param('id') id: string, @Param('photoId') photoId: string, @Request() req) {
    return this.propertiesService.deletePhoto(id, photoId, req.user.userId);
  }
}
