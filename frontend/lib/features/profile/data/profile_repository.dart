import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ProfileRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load profile';
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/users/me', data: data);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update profile';
    }
  }
}
