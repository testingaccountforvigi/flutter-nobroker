import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('premium')
@Controller('premium')
export class PremiumController {}
