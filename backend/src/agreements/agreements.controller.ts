import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('agreements')
@Controller('agreements')
export class AgreementsController {}
