import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/call.dart';

class IncomingCallData {
  final String callId;
  final CallUser caller;
  final CallProperty? property;
  final String roomName;
  final String receiverToken;
  final String livekitUrl;

  IncomingCallData({
    required this.callId,
    required this.caller,
    this.property,
    required this.roomName,
    required this.receiverToken,
    required this.livekitUrl,
  });

  factory IncomingCallData.fromJson(Map<String, dynamic> json) {
    return IncomingCallData(
      callId: json['callId'] as String,
      caller: CallUser.fromJson(json['caller'] as Map<String, dynamic>),
      property: json['property'] != null 
          ? CallProperty.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      roomName: json['roomName'] as String,
      receiverToken: json['receiverToken'] as String,
      livekitUrl: json['livekitUrl'] as String,
    );
  }
}

class CallSocketService {
  IO.Socket? _socket;
  final _incomingCallController = StreamController<IncomingCallData>.broadcast();
  final _callAcceptedController = StreamController<String>.broadcast();
  final _callRejectedController = StreamController<String>.broadcast();
  final _callEndedController = StreamController<String>.broadcast();

  Stream<IncomingCallData> get incomingCallStream => _incomingCallController.stream;
  Stream<String> get callAcceptedStream => _callAcceptedController.stream;
  Stream<String> get callRejectedStream => _callRejectedController.stream;
  Stream<String> get callEndedStream => _callEndedController.stream;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String userId, {String baseUrl = 'http://localhost:5001'}) {
    if (_socket?.connected == true) {
      return;
    }

    _socket = IO.io(
      '$baseUrl/calls',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to call socket');
      _socket!.emit('register', {'userId': userId});
    });

    _socket!.on('incoming-call', (data) {
      print('Incoming call received: $data');
      try {
        final callData = IncomingCallData.fromJson(data as Map<String, dynamic>);
        _incomingCallController.add(callData);
      } catch (e) {
        print('Error parsing incoming call: $e');
      }
    });

    _socket!.on('call-accepted', (data) {
      print('Call accepted: $data');
      _callAcceptedController.add(data['callId'] as String);
    });

    _socket!.on('call-rejected', (data) {
      print('Call rejected: $data');
      _callRejectedController.add(data['callId'] as String);
    });

    _socket!.on('call-ended', (data) {
      print('Call ended: $data');
      _callEndedController.add(data['callId'] as String);
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from call socket');
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });
  }

  void emitCallInitiated({
    required String receiverId,
    required String callId,
    required CallUser caller,
    CallProperty? property,
    required String roomName,
    required String receiverToken,
    required String livekitUrl,
  }) {
    _socket?.emit('call-initiated', {
      'receiverId': receiverId,
      'callId': callId,
      'caller': {
        'id': caller.id,
        'name': caller.name,
        'email': caller.email,
      },
      if (property != null)
        'property': {
          'id': property.id,
          'title': property.title,
          'address': property.address,
        },
      'roomName': roomName,
      'receiverToken': receiverToken,
      'livekitUrl': livekitUrl,
    });
  }

  void emitCallAccepted(String callId, String callerId) {
    _socket?.emit('call-accepted', {
      'callId': callId,
      'callerId': callerId,
    });
  }

  void emitCallRejected(String callId, String callerId) {
    _socket?.emit('call-rejected', {
      'callId': callId,
      'callerId': callerId,
    });
  }

  void emitCallEnded(String callId, String otherUserId) {
    _socket?.emit('call-ended', {
      'callId': callId,
      'otherUserId': otherUserId,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _incomingCallController.close();
    _callAcceptedController.close();
    _callRejectedController.close();
    _callEndedController.close();
  }
}
