import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('calls')
@Controller('calls')
export class CallsController {}
