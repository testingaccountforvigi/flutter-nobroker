import 'package:dio/dio.dart';

class MoversRepository {
  final Dio _dio;

  MoversRepository(this._dio);

  Future<List<dynamic>> getAllMovers() async {
    try {
      final response = await _dio.get('/movers');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch movers';
    }
  }

  Future<Map<String, dynamic>> getMoverById(String id) async {
    try {
      final response = await _dio.get('/movers/$id');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch mover';
    }
  }

  Future<Map<String, dynamic>> createMovingRequest(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/movers/requests', data: data);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create moving request';
    }
  }

  Future<List<dynamic>> getMyRequests() async {
    try {
      final response = await _dio.get('/movers/requests/my');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch requests';
    }
  }

  Future<Map<String, dynamic>> getRequestById(String id) async {
    try {
      final response = await _dio.get('/movers/requests/$id');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch request';
    }
  }

  Future<Map<String, dynamic>> acceptQuote(String quoteId) async {
    try {
      final response = await _dio.post('/movers/quotes/$quoteId/accept');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to accept quote';
    }
  }
}
