import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsEnum, IsNumber, IsOptional, IsDateString, IsArray, Min } from 'class-validator';
import { PropertyPurpose, PropertyType, FurnishingType } from '@prisma/client';

export class CreatePropertyDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({ enum: PropertyPurpose })
  @IsEnum(PropertyPurpose)
  purpose: PropertyPurpose;

  @ApiProperty({ enum: PropertyType })
  @IsEnum(PropertyType)
  type: PropertyType;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  address: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  locality: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  city: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  state: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  postalCode: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  latitude?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  longitude?: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  price: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  securityDeposit?: number;

  @ApiProperty()
  @IsNumber()
  @Min(1)
  areaSqFt: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  bedrooms: number;

  @ApiProperty()
  @IsNumber()
  @Min(1)
  bathrooms: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  balconies: number;

  @ApiProperty({ enum: FurnishingType })
  @IsEnum(FurnishingType)
  furnishing: FurnishingType;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  floor?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsNumber()
  totalFloors?: number;

  @ApiProperty()
  @IsDateString()
  availableFrom: string;

  @ApiProperty({ required: false, type: [String] })
  @IsOptional()
  @IsArray()
  amenityIds?: string[];
}
