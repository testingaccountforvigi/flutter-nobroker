import 'package:dio/dio.dart';

class VerificationRepository {
  final Dio _dio;

  VerificationRepository(this._dio);

  Future<Map<String, dynamic>> submitVerification(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/verification', data: data);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to submit verification';
    }
  }

  Future<List<dynamic>> getMyRequests() async {
    try {
      final response = await _dio.get('/verification/my-requests');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch requests';
    }
  }

  Future<List<dynamic>> getPendingVerifications() async {
    try {
      final response = await _dio.get('/verification/pending');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch pending verifications';
    }
  }

  Future<Map<String, dynamic>> approveVerification(String requestId) async {
    try {
      final response = await _dio.patch('/verification/$requestId/approve');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to approve verification';
    }
  }

  Future<Map<String, dynamic>> rejectVerification(String requestId, String reason) async {
    try {
      final response = await _dio.patch(
        '/verification/$requestId/reject',
        data: {'reason': reason},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to reject verification';
    }
  }
}
