import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

interface UserSocket extends Socket {
  userId?: string;
}

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/calls',
})
export class CallsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private userSockets = new Map<string, string>(); // userId -> socketId

  handleConnection(client: UserSocket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: UserSocket) {
    console.log(`Client disconnected: ${client.id}`);
    if (client.userId) {
      this.userSockets.delete(client.userId);
    }
  }

  @SubscribeMessage('register')
  handleRegister(
    @ConnectedSocket() client: UserSocket,
    @MessageBody() data: { userId: string },
  ) {
    client.userId = data.userId;
    this.userSockets.set(data.userId, client.id);
    console.log(`User ${data.userId} registered with socket ${client.id}`);
    return { success: true };
  }

  @SubscribeMessage('call-initiated')
  handleCallInitiated(
    @ConnectedSocket() client: UserSocket,
    @MessageBody() data: any,
  ) {
    const receiverSocketId = this.userSockets.get(data.receiverId);
    if (receiverSocketId) {
      this.server.to(receiverSocketId).emit('incoming-call', {
        callId: data.callId,
        caller: data.caller,
        property: data.property,
        roomName: data.roomName,
        receiverToken: data.receiverToken,
        livekitUrl: data.livekitUrl,
      });
      console.log(`Sent incoming call notification to user ${data.receiverId}`);
    } else {
      console.log(`User ${data.receiverId} is not connected`);
    }
  }

  @SubscribeMessage('call-accepted')
  handleCallAccepted(
    @ConnectedSocket() client: UserSocket,
    @MessageBody() data: { callId: string; callerId: string },
  ) {
    const callerSocketId = this.userSockets.get(data.callerId);
    if (callerSocketId) {
      this.server.to(callerSocketId).emit('call-accepted', {
        callId: data.callId,
      });
    }
  }

  @SubscribeMessage('call-rejected')
  handleCallRejected(
    @ConnectedSocket() client: UserSocket,
    @MessageBody() data: { callId: string; callerId: string },
  ) {
    const callerSocketId = this.userSockets.get(data.callerId);
    if (callerSocketId) {
      this.server.to(callerSocketId).emit('call-rejected', {
        callId: data.callId,
      });
    }
  }

  @SubscribeMessage('call-ended')
  handleCallEnded(
    @ConnectedSocket() client: UserSocket,
    @MessageBody() data: { callId: string; otherUserId: string },
  ) {
    const otherSocketId = this.userSockets.get(data.otherUserId);
    if (otherSocketId) {
      this.server.to(otherSocketId).emit('call-ended', {
        callId: data.callId,
      });
    }
  }
}
