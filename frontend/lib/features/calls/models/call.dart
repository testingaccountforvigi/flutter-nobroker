class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final String? propertyId;
  final String roomId;
  final CallStatus status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final CallUser caller;
  final CallUser receiver;
  final CallProperty? property;

  const Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    this.propertyId,
    required this.roomId,
    required this.status,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.caller,
    required this.receiver,
    this.property,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      receiverId: json['receiverId'] as String,
      propertyId: json['propertyId'] as String?,
      roomId: json['roomId'] as String,
      status: CallStatus.values.byName(json['status'] as String),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      caller: CallUser.fromJson(json['caller'] as Map<String, dynamic>),
      receiver: CallUser.fromJson(json['receiver'] as Map<String, dynamic>),
      property: json['property'] != null 
          ? CallProperty.fromJson(json['property'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CallUser {
  final String id;
  final String name;
  final String email;

  const CallUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory CallUser.fromJson(Map<String, dynamic> json) {
    return CallUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class CallProperty {
  final String id;
  final String title;
  final String address;

  const CallProperty({
    required this.id,
    required this.title,
    required this.address,
  });

  factory CallProperty.fromJson(Map<String, dynamic> json) {
    return CallProperty(
      id: json['id'] as String,
      title: json['title'] as String,
      address: json['address'] as String,
    );
  }
}

enum CallStatus {
  INITIATED,
  RINGING,
  ACCEPTED,
  MISSED,
  DECLINED,
  COMPLETED,
  CANCELLED,
}

class CallResponse {
  final Call call;
  final String roomName;
  final String callerToken;
  final String receiverToken;
  final String livekitUrl;

  const CallResponse({
    required this.call,
    required this.roomName,
    required this.callerToken,
    required this.receiverToken,
    required this.livekitUrl,
  });

  factory CallResponse.fromJson(Map<String, dynamic> json) {
    return CallResponse(
      call: Call.fromJson(json['call'] as Map<String, dynamic>),
      roomName: json['roomName'] as String,
      callerToken: json['callerToken'] as String,
      receiverToken: json['receiverToken'] as String,
      livekitUrl: json['livekitUrl'] as String,
    );
  }
}
