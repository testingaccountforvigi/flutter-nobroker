import 'package:dio/dio.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/stats');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch stats';
    }
  }

  Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/users',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch users';
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await _dio.get('/admin/users/$id');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch user';
    }
  }

  Future<void> suspendUser(String id) async {
    try {
      await _dio.post('/admin/users/$id/suspend');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to suspend user';
    }
  }

  Future<Map<String, dynamic>> getProperties({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page.toString(), 'limit': limit.toString()};
      if (status != null) params['status'] = status;
      
      final response = await _dio.get('/admin/properties', queryParameters: params);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch properties';
    }
  }

  Future<void> flagProperty(String id, String reason) async {
    try {
      await _dio.post('/admin/properties/$id/flag', data: {'reason': reason});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to flag property';
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await _dio.delete('/admin/properties/$id');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete property';
    }
  }

  Future<Map<String, dynamic>> getReports({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/admin/reports',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch reports';
    }
  }

  Future<void> resolveReport(String id, String action) async {
    try {
      await _dio.patch('/admin/reports/$id/resolve', data: {'action': action});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to resolve report';
    }
  }
}
