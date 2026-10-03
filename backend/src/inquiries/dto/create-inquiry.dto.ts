import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CreateInquiryDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  message: string;
}
