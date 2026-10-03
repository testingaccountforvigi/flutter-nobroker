import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class RemindersService {
  constructor(private prisma: PrismaService) {}

  async createReminder(userId: string, data: any) {
    return this.prisma.reminder.create({
      data: {
        userId,
        type: data.type,
        title: data.title,
        dueDate: new Date(data.dueDate),
        amount: data.amount,
        notes: data.notes,
        completed: false,
      },
    });
  }

  async getMyReminders(userId: string, completed?: boolean) {
    return this.prisma.reminder.findMany({
      where: {
        userId,
        ...(completed !== undefined && { completed }),
      },
      orderBy: { dueDate: 'asc' },
    });
  }

  async getReminderById(id: string, userId: string) {
    const reminder = await this.prisma.reminder.findUnique({
      where: { id },
    });

    if (!reminder) {
      throw new NotFoundException('Reminder not found');
    }

    if (reminder.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return reminder;
  }

  async updateReminder(id: string, userId: string, data: any) {
    const reminder = await this.prisma.reminder.findUnique({
      where: { id },
    });

    if (!reminder) {
      throw new NotFoundException('Reminder not found');
    }

    if (reminder.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return this.prisma.reminder.update({
      where: { id },
      data: {
        ...(data.title && { title: data.title }),
        ...(data.notes && { notes: data.notes }),
        ...(data.dueDate && { dueDate: new Date(data.dueDate) }),
        ...(data.type && { type: data.type }),
        ...(data.amount !== undefined && { amount: data.amount }),
      },
    });
  }

  async markAsCompleted(id: string, userId: string) {
    const reminder = await this.prisma.reminder.findUnique({
      where: { id },
    });

    if (!reminder) {
      throw new NotFoundException('Reminder not found');
    }

    if (reminder.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return this.prisma.reminder.update({
      where: { id },
      data: {
        completed: true,
      },
    });
  }

  async deleteReminder(id: string, userId: string) {
    const reminder = await this.prisma.reminder.findUnique({
      where: { id },
    });

    if (!reminder) {
      throw new NotFoundException('Reminder not found');
    }

    if (reminder.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return this.prisma.reminder.delete({
      where: { id },
    });
  }

  async getDueReminders() {
    const now = new Date();
    return this.prisma.reminder.findMany({
      where: {
        completed: false,
        dueDate: {
          lte: now,
        },
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
}
