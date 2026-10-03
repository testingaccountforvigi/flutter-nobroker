import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import PDFDocument from 'pdfkit';
import { Readable } from 'stream';

@Injectable()
export class AgreementsService {
  constructor(private prisma: PrismaService) {}

  async generateAgreement(
    propertyId: string,
    ownerId: string,
    tenantId: string,
    data: {
      rent: number;
      deposit: number;
      startDate: Date;
      endDate: Date;
      noticePeriodDays?: number;
      termsText?: string;
    },
  ) {
    // Get property and user details
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      include: {
        owner: {
          select: { id: true, name: true, email: true },
        },
      },
    });

    const tenant = await this.prisma.user.findUnique({
      where: { id: tenantId },
      select: { id: true, name: true, email: true },
    });

    if (!property || !tenant) {
      throw new Error('Property or tenant not found');
    }

    if (property.ownerId !== ownerId) {
      throw new Error('Unauthorized');
    }

    // Create agreement record
    const agreement = await this.prisma.agreement.create({
      data: {
        propertyId,
        ownerId,
        tenantId,
        rent: data.rent,
        deposit: data.deposit,
        startDate: data.startDate,
        endDate: data.endDate,
        noticePeriodDays: data.noticePeriodDays || 30,
        termsText: data.termsText || this.getDefaultTerms(),
        status: 'DRAFT',
      },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            address: true,
            city: true,
            state: true,
          },
        },
        owner: {
          select: { id: true, name: true, email: true },
        },
        tenant: {
          select: { id: true, name: true, email: true },
        },
      },
    });

    return agreement;
  }

  async getAgreement(agreementId: string, userId: string) {
    const agreement = await this.prisma.agreement.findUnique({
      where: { id: agreementId },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            address: true,
            city: true,
            state: true,
          },
        },
        owner: {
          select: { id: true, name: true, email: true },
        },
        tenant: {
          select: { id: true, name: true, email: true },
        },
        signatures: true,
      },
    });

    if (!agreement) {
      throw new Error('Agreement not found');
    }

    if (agreement.ownerId !== userId && agreement.tenantId !== userId) {
      throw new Error('Unauthorized');
    }

    return agreement;
  }

  async signAgreement(agreementId: string, userId: string, signatureData: string) {
    const agreement = await this.prisma.agreement.findUnique({
      where: { id: agreementId },
      include: { signatures: true },
    });

    if (!agreement) {
      throw new Error('Agreement not found');
    }

    if (agreement.ownerId !== userId && agreement.tenantId !== userId) {
      throw new Error('Unauthorized');
    }

    // Check if user already signed
    const existingSignature = agreement.signatures.find(
      (sig) => sig.userId === userId,
    );

    if (existingSignature) {
      throw new Error('Already signed');
    }

    // Create signature
    await this.prisma.agreementSignature.create({
      data: {
        agreementId,
        userId,
        signatureData,
      },
    });

    // Check if both parties have signed
    const allSignatures = await this.prisma.agreementSignature.findMany({
      where: { agreementId },
    });

    const ownerSigned = allSignatures.some((sig) => sig.userId === agreement.ownerId);
    const tenantSigned = allSignatures.some((sig) => sig.userId === agreement.tenantId);

    // If both signed, mark as completed
    if (ownerSigned && tenantSigned) {
      await this.prisma.agreement.update({
        where: { id: agreementId },
        data: { status: 'COMPLETED' },
      });
    }

    return this.getAgreement(agreementId, userId);
  }

  async generatePDF(agreementId: string, userId: string): Promise<Buffer> {
    const agreement = await this.getAgreement(agreementId, userId);

    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ margin: 50 });
      const buffers: Buffer[] = [];

      doc.on('data', buffers.push.bind(buffers));
      doc.on('end', () => resolve(Buffer.concat(buffers)));
      doc.on('error', reject);

      // Header
      doc
        .fontSize(20)
        .text('RENTAL AGREEMENT', { align: 'center' })
        .moveDown();

      // Agreement details
      doc
        .fontSize(12)
        .text(`Agreement ID: ${agreement.id}`)
        .text(`Date: ${new Date().toLocaleDateString()}`)
        .moveDown();

      // Parties
      doc
        .fontSize(14)
        .text('PARTIES', { underline: true })
        .moveDown(0.5);

      doc
        .fontSize(11)
        .text(`Owner: ${agreement.owner.name}`)
        .text(`Email: ${agreement.owner.email}`)
        .moveDown();

      doc
        .text(`Tenant: ${agreement.tenant.name}`)
        .text(`Email: ${agreement.tenant.email}`)
        .moveDown();

      // Property details
      doc
        .fontSize(14)
        .text('PROPERTY DETAILS', { underline: true })
        .moveDown(0.5);

      doc
        .fontSize(11)
        .text(`Property: ${agreement.property.title}`)
        .text(`Address: ${agreement.property.address}`)
        .text(`City: ${agreement.property.city}, ${agreement.property.state}`)
        .moveDown();

      // Financial terms
      doc
        .fontSize(14)
        .text('FINANCIAL TERMS', { underline: true })
        .moveDown(0.5);

      doc
        .fontSize(11)
        .text(`Monthly Rent: ₹${agreement.rent.toLocaleString()}`)
        .text(`Security Deposit: ₹${agreement.deposit.toLocaleString()}`)
        .text(`Notice Period: ${agreement.noticePeriodDays} days`)
        .moveDown();

      // Duration
      doc
        .fontSize(14)
        .text('DURATION', { underline: true })
        .moveDown(0.5);

      doc
        .fontSize(11)
        .text(`Start Date: ${new Date(agreement.startDate).toLocaleDateString()}`)
        .text(`End Date: ${new Date(agreement.endDate).toLocaleDateString()}`)
        .moveDown();

      // Terms and conditions
      doc
        .fontSize(14)
        .text('TERMS AND CONDITIONS', { underline: true })
        .moveDown(0.5);

      doc
        .fontSize(10)
        .text(agreement.termsText || '', { align: 'justify' })
        .moveDown();

      // Signatures
      if (agreement.signatures.length > 0) {
        doc
          .fontSize(14)
          .text('SIGNATURES', { underline: true })
          .moveDown(0.5);

        agreement.signatures.forEach((sig) => {
          const signer =
            sig.userId === agreement.ownerId ? 'Owner' : 'Tenant';
          doc
            .fontSize(11)
            .text(`${signer} signed on: ${new Date(sig.signedAt).toLocaleString()}`)
            .moveDown(0.5);
        });
      }

      doc.end();
    });
  }

  async getUserAgreements(userId: string) {
    return this.prisma.agreement.findMany({
      where: {
        OR: [{ ownerId: userId }, { tenantId: userId }],
      },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            address: true,
          },
        },
        owner: {
          select: { id: true, name: true },
        },
        tenant: {
          select: { id: true, name: true },
        },
        signatures: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  private getDefaultTerms(): string {
    return `1. RENT PAYMENT: The Tenant agrees to pay the monthly rent on or before the 5th day of each month.

2. SECURITY DEPOSIT: The security deposit shall be refunded to the Tenant within 30 days of vacating the property, subject to deductions for any damages.

3. MAINTENANCE: The Tenant shall maintain the property in good condition and report any damages immediately to the Owner.

4. UTILITIES: The Tenant shall be responsible for paying all utility bills including electricity, water, gas, and internet.

5. SUBLETTING: The Tenant shall not sublet the property without prior written consent from the Owner.

6. TERMINATION: Either party may terminate this agreement by providing 30 days written notice to the other party.

7. PROPERTY INSPECTION: The Owner reserves the right to inspect the property with 24 hours prior notice to the Tenant.

8. PETS: No pets are allowed on the property without prior written consent from the Owner.

9. MODIFICATIONS: No structural modifications shall be made to the property without the Owner's written permission.

10. GOVERNING LAW: This agreement shall be governed by the laws of India.

Both parties have read and understood all terms and conditions mentioned above and agree to comply with them.`;
  }
}
