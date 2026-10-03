import {
  Controller,
  Post,
  Get,
  Param,
  Body,
  UseGuards,
  Request,
  Res,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Response } from 'express';
import { AgreementsService } from './agreements.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('agreements')
@Controller('agreements')
@UseGuards(JwtAuthGuard)
export class AgreementsController {
  constructor(private readonly agreementsService: AgreementsService) {}

  @Post('generate')
  async generateAgreement(
    @Request() req,
    @Body()
    body: {
      propertyId: string;
      tenantId: string;
      rent: number;
      deposit: number;
      startDate: string;
      endDate: string;
      noticePeriodDays?: number;
      termsText?: string;
    },
  ) {
    return this.agreementsService.generateAgreement(
      body.propertyId,
      req.user.userId,
      body.tenantId,
      {
        rent: body.rent,
        deposit: body.deposit,
        startDate: new Date(body.startDate),
        endDate: new Date(body.endDate),
        noticePeriodDays: body.noticePeriodDays,
        termsText: body.termsText,
      },
    );
  }

  @Get()
  async getUserAgreements(@Request() req) {
    return this.agreementsService.getUserAgreements(req.user.userId);
  }

  @Get(':id')
  async getAgreement(@Request() req, @Param('id') id: string) {
    return this.agreementsService.getAgreement(id, req.user.userId);
  }

  @Post(':id/sign')
  async signAgreement(
    @Request() req,
    @Param('id') id: string,
    @Body() body: { signatureData: string },
  ) {
    return this.agreementsService.signAgreement(
      id,
      req.user.userId,
      body.signatureData,
    );
  }

  @Get(':id/pdf')
  async downloadPDF(
    @Request() req,
    @Param('id') id: string,
    @Res() res: Response,
  ) {
    const pdfBuffer = await this.agreementsService.generatePDF(
      id,
      req.user.userId,
    );

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename=agreement-${id}.pdf`,
      'Content-Length': pdfBuffer.length,
    });

    res.send(pdfBuffer);
  }
}
