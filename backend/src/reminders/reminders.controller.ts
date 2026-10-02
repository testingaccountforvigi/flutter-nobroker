import { Controller } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('reminders')
@Controller('reminders')
export class RemindersController {}
