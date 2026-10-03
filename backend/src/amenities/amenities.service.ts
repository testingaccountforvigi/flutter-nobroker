import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class AmenitiesService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.amenity.findMany({
      orderBy: {
        name: 'asc',
      },
    });
  }
}
