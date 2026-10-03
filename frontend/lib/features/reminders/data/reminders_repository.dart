import 'package:dio/dio.dart';

class RemindersRepository {
  final Dio _dio;

  RemindersRepository(this._dio);

  Future<List<dynamic>> getMyReminders({bool? completed}) async {
    try {
      final params = <String, dynamic>{};
      if (completed != null) params['completed'] = completed.toString();
      final response = await _dio.get('/reminders', queryParameters: params);
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch reminders';
    }
  }

  Future<Map<String, dynamic>> createReminder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/reminders', data: data);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create reminder';
    }
  }

  Future<Map<String, dynamic>> markComplete(String id) async {
    try {
      final response = await _dio.patch('/reminders/$id/complete');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to complete reminder';
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _dio.delete('/reminders/$id');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete reminder';
    }
  }
}
