import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength, IsEnum } from 'class-validator';
import { AccountIntent } from '@prisma/client';

export class RegisterDto {
  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'john@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: 'password123', minLength: 6 })
  @IsString()
  @MinLength(6)
  password: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @MinLength(6)
  confirmPassword: string;

  @ApiProperty({ 
    enum: AccountIntent, 
    example: AccountIntent.SEEKER,
    description: 'Account intent: SEEKER, OWNER, or BOTH'
  })
  @IsEnum(AccountIntent)
  intent: AccountIntent;
}
