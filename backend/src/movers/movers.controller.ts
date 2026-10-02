import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('movers')
@Controller('movers')
export class MoversController {}
