import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String intent,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'intent': intent,
        },
      );

      // Store tokens
      await _storage.write(
        key: 'access_token',
        value: response.data['accessToken'],
      );
      await _storage.write(
        key: 'refresh_token',
        value: response.data['refreshToken'],
      );

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Registration failed';
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Store tokens
      await _storage.write(
        key: 'access_token',
        value: response.data['accessToken'],
      );
      await _storage.write(
        key: 'refresh_token',
        value: response.data['refreshToken'],
      );

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get profile';
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (e) {
      // Ignore errors
    } finally {
      await _storage.deleteAll();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
