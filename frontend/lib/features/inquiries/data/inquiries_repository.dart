import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class InquiriesRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> createInquiry({
    required String propertyId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/inquiries',
        data: {
          'propertyId': propertyId,
          'message': message,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to send inquiry';
    }
  }

  Future<List<dynamic>> getMyInquiries() async {
    try {
      final response = await _dio.get('/inquiries/my-inquiries');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load inquiries';
    }
  }

  Future<List<dynamic>> getOwnerLeads() async {
    try {
      final response = await _dio.get('/inquiries/leads');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load leads';
    }
  }

  Future<Map<String, dynamic>> updateInquiryStatus(
    String inquiryId,
    String status,
  ) async {
    try {
      final response = await _dio.patch(
        '/inquiries/$inquiryId/status',
        data: {'status': status},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update inquiry status';
    }
  }
}
