import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsEnum, IsString, IsNumber, IsBoolean, Min } from 'class-validator';
import { PropertyPurpose, PropertyType, FurnishingType } from '@prisma/client';
import { Type } from 'class-transformer';

export class SearchPropertiesDto {
  @ApiProperty({ required: false, enum: PropertyPurpose })
  @IsOptional()
  @IsEnum(PropertyPurpose)
  purpose?: PropertyPurpose;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  locality?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  minPrice?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  maxPrice?: number;

  @ApiProperty({ required: false, enum: PropertyType })
  @IsOptional()
  @IsEnum(PropertyType)
  type?: PropertyType;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  bedrooms?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  bathrooms?: number;

  @ApiProperty({ required: false, enum: FurnishingType })
  @IsOptional()
  @IsEnum(FurnishingType)
  furnishing?: FurnishingType;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  verifiedOwner?: boolean;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  premium?: boolean;

  @ApiProperty({ required: false, default: 'recommended' })
  @IsOptional()
  @IsString()
  sortBy?: 'recommended' | 'newest' | 'priceAsc' | 'priceDesc';

  @ApiProperty({ required: false, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number;

  @ApiProperty({ required: false, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  limit?: number;
}
