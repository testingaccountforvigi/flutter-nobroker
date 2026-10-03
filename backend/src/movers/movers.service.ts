import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class MoversService {
  constructor(private prisma: PrismaService) {}

  async getAllMovers() {
    return this.prisma.mover.findMany({
      where: { isActive: true },
      orderBy: { rating: 'desc' },
    });
  }

  async getMoverById(id: string) {
    const mover = await this.prisma.mover.findUnique({
      where: { id },
    });

    if (!mover) {
      throw new NotFoundException('Mover not found');
    }

    return mover;
  }

  async createMovingRequest(userId: string, data: any) {
    return this.prisma.movingRequest.create({
      data: {
        userId,
        origin: data.origin,
        destination: data.destination,
        moveDate: new Date(data.moveDate),
        propertySize: data.propertySize,
        notes: data.notes,
        status: 'PENDING',
        items: {
          create: data.items?.map((item: any) => ({
            name: item.name,
            quantity: item.quantity,
            notes: item.notes,
          })) || [],
        },
      },
      include: {
        items: true,
      },
    });
  }

  async getMyMovingRequests(userId: string) {
    return this.prisma.movingRequest.findMany({
      where: { userId },
      include: {
        items: true,
        quotes: {
          include: {
            mover: true,
          },
          orderBy: {
            price: 'asc',
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getMovingRequestById(id: string, userId: string) {
    const request = await this.prisma.movingRequest.findUnique({
      where: { id },
      include: {
        items: true,
        quotes: {
          include: {
            mover: true,
          },
          orderBy: {
            price: 'asc',
          },
        },
        bookings: {
          include: {
            mover: true,
          },
        },
      },
    });

    if (!request) {
      throw new NotFoundException('Moving request not found');
    }

    if (request.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return request;
  }

  async submitQuote(moverId: string, requestId: string, data: any) {
    const request = await this.prisma.movingRequest.findUnique({
      where: { id: requestId },
    });

    if (!request) {
      throw new NotFoundException('Moving request not found');
    }

    return this.prisma.moverQuote.create({
      data: {
        moverId,
        movingRequestId: requestId,
        price: data.price,
        estimatedHours: data.estimatedHours,
        inclusions: data.inclusions,
        status: 'SENT',
      },
      include: {
        mover: true,
      },
    });
  }

  async acceptQuote(quoteId: string, userId: string) {
    const quote = await this.prisma.moverQuote.findUnique({
      where: { id: quoteId },
      include: {
        movingRequest: true,
        mover: true,
      },
    });

    if (!quote) {
      throw new NotFoundException('Quote not found');
    }

    if (quote.movingRequest.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    // Create booking
    const booking = await this.prisma.moverBooking.create({
      data: {
        movingRequestId: quote.movingRequestId,
        moverId: quote.moverId,
        quoteId: quote.id,
        scheduledAt: quote.movingRequest.moveDate,
        status: 'CONFIRMED',
      },
      include: {
        mover: true,
        movingRequest: {
          include: {
            items: true,
          },
        },
      },
    });

    // Update quote status
    await this.prisma.moverQuote.update({
      where: { id: quoteId },
      data: { status: 'ACCEPTED' },
    });

    // Update request status
    await this.prisma.movingRequest.update({
      where: { id: quote.movingRequestId },
      data: { status: 'BOOKED' },
    });

    // Reject other quotes
    await this.prisma.moverQuote.updateMany({
      where: {
        movingRequestId: quote.movingRequestId,
        id: { not: quoteId },
        status: 'SENT',
      },
      data: { status: 'REJECTED' },
    });

    return booking;
  }

  async completeBooking(bookingId: string, userId: string) {
    const booking = await this.prisma.moverBooking.findUnique({
      where: { id: bookingId },
      include: {
        movingRequest: true,
      },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.movingRequest.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return this.prisma.moverBooking.update({
      where: { id: bookingId },
      data: {
        status: 'COMPLETED',
      },
    });
  }

  async rateBooking(bookingId: string, userId: string, rating: number, review: string) {
    const booking = await this.prisma.moverBooking.findUnique({
      where: { id: bookingId },
      include: {
        movingRequest: true,
        mover: true,
      },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.movingRequest.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    // Store rating and review in MovingRequest as notes
    await this.prisma.movingRequest.update({
      where: { id: booking.movingRequestId },
      data: {
        notes: `Rating: ${rating}/5\nReview: ${review}`,
      },
    });

    // Update mover average rating
    const bookings = await this.prisma.moverBooking.findMany({
      where: {
        moverId: booking.moverId,
        status: 'COMPLETED',
      },
      include: {
        movingRequest: true,
      },
    });

    // Count completed bookings as positive ratings
    const reviewCount = bookings.length;
    
    await this.prisma.mover.update({
      where: { id: booking.moverId },
      data: { 
        rating: rating,
        reviewCount: reviewCount,
      },
    });

    return booking;
  }
}
