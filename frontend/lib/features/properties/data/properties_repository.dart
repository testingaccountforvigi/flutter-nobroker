import 'package:dio/dio.dart';
import 'dart:io';
import '../../../core/network/dio_client.dart';

class PropertiesRepository {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> searchProperties({
    String? purpose,
    String? city,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/properties',
        queryParameters: {
          if (purpose != null) 'purpose': purpose,
          if (city != null) 'city': city,
          'page': page,
          'limit': limit,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load properties';
    }
  }

  Future<Map<String, dynamic>> getPropertyDetails(String id) async {
    try {
      final response = await _dio.get('/properties/$id');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load property details';
    }
  }

  Future<List<dynamic>> getMyProperties() async {
    try {
      final response = await _dio.get('/users/me/properties');
      return response.data as List;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load your properties';
    }
  }

  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> propertyData) async {
    try {
      final response = await _dio.post('/properties', data: propertyData);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create property';
    }
  }

  Future<Map<String, dynamic>> updateProperty(String id, Map<String, dynamic> propertyData) async {
    try {
      final response = await _dio.patch('/properties/$id', data: propertyData);
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update property';
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await _dio.delete('/properties/$id');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete property';
    }
  }

  Future<Map<String, dynamic>> uploadPropertyPhoto(String propertyId, File photoFile) async {
    try {
      final fileName = photoFile.path.split('/').last;
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/properties/$propertyId/photos',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to upload photo';
    }
  }

  Future<void> deletePropertyPhoto(String propertyId, String photoId) async {
    try {
      await _dio.delete('/properties/$propertyId/photos/$photoId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete photo';
    }
  }

  Future<List<Map<String, dynamic>>> getAmenities() async {
    try {
      final response = await _dio.get('/amenities');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to load amenities';
    }
  }

  Future<void> publishProperty(String id) async {
    try {
      await _dio.post('/properties/$id/publish');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to publish property';
    }
  }

  Future<void> pauseProperty(String id) async {
    try {
      await _dio.post('/properties/$id/pause');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to pause property';
    }
  }
}
