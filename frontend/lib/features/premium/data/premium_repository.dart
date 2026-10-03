import 'package:dio/dio.dart';

class PremiumRepository {
  final Dio _dio;

  PremiumRepository(this._dio);

  Future<List<dynamic>> getPackages() async {
    try {
      final response = await _dio.get('/premium/packages');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch packages';
    }
  }

  Future<Map<String, dynamic>> createOrder(String propertyId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/premium/orders',
        data: {
          'propertyId': propertyId,
          ...data,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create order';
    }
  }

  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _dio.get('/premium/orders');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch orders';
    }
  }

  Future<Map<String, dynamic>> processMockPayment(String orderId) async {
    try {
      final response = await _dio.post('/premium/orders/$orderId/pay');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Payment failed';
    }
  }
}
