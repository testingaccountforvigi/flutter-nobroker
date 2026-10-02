import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('properties')
@Controller('properties')
export class PropertiesController {}
