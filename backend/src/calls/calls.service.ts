import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { AccessToken } from 'livekit-server-sdk';

@Injectable()
export class CallsService {
  private readonly livekitApiKey = process.env.LIVEKIT_API_KEY || 'devkey';
  private readonly livekitApiSecret = process.env.LIVEKIT_API_SECRET || 'secret';
  private readonly livekitUrl = process.env.LIVEKIT_URL || 'ws://localhost:7880';

  constructor(private prisma: PrismaService) {}

  private readonly userSelect = {
    id: true,
    name: true,
    email: true,
  };

  private readonly propertySelect = {
    id: true,
    title: true,
    address: true,
  };

  async initiateCall(callerId: string, receiverId: string, propertyId?: string) {
    // Create call record
    const call = await this.prisma.call.create({
      data: {
        callerId,
        receiverId,
        propertyId,
        roomId: `call-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        status: 'INITIATED',
        startedAt: new Date(),
      },
      include: {
        caller: {
          select: this.userSelect,
        },
        receiver: {
          select: this.userSelect,
        },
        property: {
          select: this.propertySelect,
        },
      },
    });

    // Generate LiveKit tokens
    const roomName = call.roomId;
    
    const callerToken = await this.generateToken(
      roomName,
      callerId,
      call.caller.name,
    );
    
    const receiverToken = await this.generateToken(
      roomName,
      receiverId,
      call.receiver.name,
    );

    return {
      call,
      roomName,
      callerToken,
      receiverToken,
      livekitUrl: this.livekitUrl,
    };
  }

  private async generateToken(
    roomName: string,
    identity: string,
    name: string,
  ): Promise<string> {
    const at = new AccessToken(this.livekitApiKey, this.livekitApiSecret, {
      identity,
      name,
    });

    at.addGrant({
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
    });

    return at.toJwt();
  }

  async getActiveCalls(userId: string) {
    return this.prisma.call.findMany({
      where: {
        OR: [
          { callerId: userId },
          { receiverId: userId },
        ],
        status: {
          in: ['INITIATED', 'RINGING', 'ACCEPTED'],
        },
      },
      include: {
        caller: {
          select: this.userSelect,
        },
        receiver: {
          select: this.userSelect,
        },
        property: {
          select: this.propertySelect,
        },
      },
      orderBy: { startedAt: 'desc' },
    });
  }

  async updateCallStatus(
    callId: string,
    status: 'INITIATED' | 'RINGING' | 'ACCEPTED' | 'COMPLETED' | 'MISSED' | 'DECLINED' | 'CANCELLED',
    userId: string,
  ) {
    const call = await this.prisma.call.findUnique({
      where: { id: callId },
    });

    if (!call) {
      throw new Error('Call not found');
    }

    if (call.callerId !== userId && call.receiverId !== userId) {
      throw new Error('Unauthorized');
    }

    const updateData: any = { status };

    if (status === 'COMPLETED' || status === 'MISSED' || status === 'DECLINED' || status === 'CANCELLED') {
      updateData.endedAt = new Date();
    }

    return this.prisma.call.update({
      where: { id: callId },
      data: updateData,
      include: {
        caller: {
          select: this.userSelect,
        },
        receiver: {
          select: this.userSelect,
        },
      },
    });
  }

  async getCallHistory(userId: string, limit = 50) {
    return this.prisma.call.findMany({
      where: {
        OR: [
          { callerId: userId },
          { receiverId: userId },
        ],
      },
      include: {
        caller: {
          select: this.userSelect,
        },
        receiver: {
          select: this.userSelect,
        },
        property: {
          select: this.propertySelect,
        },
      },
      orderBy: { startedAt: 'desc' },
      take: limit,
    });
  }
}
