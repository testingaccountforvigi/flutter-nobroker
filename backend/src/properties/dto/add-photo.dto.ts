import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsOptional, IsBoolean, IsNumber } from 'class-validator';

export class AddPhotoDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  url: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  roomTag?: string;

  @ApiProperty({ required: false, default: false })
  @IsOptional()
  @IsBoolean()
  isCover?: boolean;

  @ApiProperty({ required: false, default: 0 })
  @IsOptional()
  @IsNumber()
  sortOrder?: number;
}
