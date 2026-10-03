import 'package:dio/dio.dart';
import '../models/call.dart';

class CallRepository {
  final Dio dio;

  CallRepository(this.dio);

  Future<CallResponse> initiateCall({
    required String receiverId,
    String? propertyId,
  }) async {
    final response = await dio.post(
      '/calls/initiate',
      data: {
        'receiverId': receiverId,
        if (propertyId != null) 'propertyId': propertyId,
      },
    );
    return CallResponse.fromJson(response.data);
  }

  Future<List<Call>> getActiveCalls() async {
    final response = await dio.get('/calls/active');
    return (response.data as List)
        .map((json) => Call.fromJson(json))
        .toList();
  }

  Future<List<Call>> getCallHistory() async {
    final response = await dio.get('/calls/history');
    return (response.data as List)
        .map((json) => Call.fromJson(json))
        .toList();
  }

  Future<Call> updateCallStatus(String callId, CallStatus status) async {
    final response = await dio.patch(
      '/calls/$callId/status',
      data: {'status': status.name},
    );
    return Call.fromJson(response.data);
  }
}
