import { Controller, Get, Post, Delete, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('favorites')
@Controller('favorites')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FavoritesController {
  constructor(private favoritesService: FavoritesService) {}

  @Get()
  @ApiOperation({ summary: 'Get my favorites' })
  async getMyFavorites(@Request() req) {
    return this.favoritesService.getMyFavorites(req.user.userId);
  }

  @Post(':propertyId')
  @ApiOperation({ summary: 'Add to favorites' })
  async addFavorite(@Param('propertyId') propertyId: string, @Request() req) {
    return this.favoritesService.addFavorite(req.user.userId, propertyId);
  }

  @Delete(':propertyId')
  @ApiOperation({ summary: 'Remove from favorites' })
  async removeFavorite(@Param('propertyId') propertyId: string, @Request() req) {
    return this.favoritesService.removeFavorite(req.user.userId, propertyId);
  }

  @Get(':propertyId/check')
  @ApiOperation({ summary: 'Check if property is favorited' })
  async isFavorite(@Param('propertyId') propertyId: string, @Request() req) {
    return this.favoritesService.isFavorite(req.user.userId, propertyId);
  }
}
