import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('inquiries')
@Controller('inquiries')
export class InquiriesController {}
