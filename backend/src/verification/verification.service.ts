import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class VerificationService {
  constructor(private prisma: PrismaService) {}

  async createVerificationRequest(userId: string, data: any) {
    return this.prisma.verificationRequest.create({
      data: {
        userId,
        documentType: data.documentType,
        documentUrl: data.documentUrl,
        status: 'PENDING',
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });
  }

  async getMyVerificationRequests(userId: string) {
    return this.prisma.verificationRequest.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getPendingVerifications() {
    return this.prisma.verificationRequest.findMany({
      where: { status: 'PENDING' },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  async approveVerification(requestId: string, adminId: string) {
    const request = await this.prisma.verificationRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Verification request not found');
    }

    if (request.status !== 'PENDING') {
      throw new BadRequestException('Verification request already processed');
    }

    // Update verification request
    const updated = await this.prisma.verificationRequest.update({
      where: { id: requestId },
      data: {
        status: 'APPROVED',
        reviewedAt: new Date(),
        adminNote: `Approved by admin ${adminId}`,
      },
    });

    return updated;
  }

  async rejectVerification(requestId: string, adminId: string, reason: string) {
    const request = await this.prisma.verificationRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Verification request not found');
    }

    if (request.status !== 'PENDING') {
      throw new BadRequestException('Verification request already processed');
    }

    return this.prisma.verificationRequest.update({
      where: { id: requestId },
      data: {
        status: 'REJECTED',
        adminNote: `Rejected by admin ${adminId}: ${reason}`,
        reviewedAt: new Date(),
      },
    });
  }
}
