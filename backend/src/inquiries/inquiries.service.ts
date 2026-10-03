import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { InquiryStatus } from '@prisma/client';

@Injectable()
export class InquiriesService {
  constructor(private prisma: PrismaService) {}

  async create(seekerId: string, propertyId: string, message: string) {
    const property = await this.prisma.property.findUnique({
      where: { id: propertyId },
      select: { ownerId: true },
    });

    if (!property) {
      throw new NotFoundException('Property not found');
    }

    return this.prisma.inquiry.create({
      data: {
        seekerId,
        ownerId: property.ownerId,
        propertyId,
        message,
        status: InquiryStatus.NEW,
      },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            photos: { where: { isCover: true }, take: 1 },
          },
        },
        seeker: { select: { id: true, name: true, email: true } },
      },
    });
  }

  async getMyInquiries(userId: string) {
    return this.prisma.inquiry.findMany({
      where: { seekerId: userId },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            address: true,
            photos: { where: { isCover: true }, take: 1 },
          },
        },
        owner: { select: { id: true, name: true, email: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getOwnerLeads(ownerId: string) {
    return this.prisma.inquiry.findMany({
      where: { ownerId },
      include: {
        property: {
          select: {
            id: true,
            title: true,
            photos: { where: { isCover: true }, take: 1 },
          },
        },
        seeker: { select: { id: true, name: true, email: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateStatus(inquiryId: string, userId: string, status: InquiryStatus) {
    const inquiry = await this.prisma.inquiry.findUnique({
      where: { id: inquiryId },
    });

    if (!inquiry || inquiry.ownerId !== userId) {
      throw new NotFoundException('Inquiry not found');
    }

    return this.prisma.inquiry.update({
      where: { id: inquiryId },
      data: { status },
    });
  }
}
