import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class FavoritesRepository {
  final DioClient _dioClient;

  FavoritesRepository(this._dioClient);

  Future<List<Map<String, dynamic>>> getMyFavorites() async {
    try {
      final response = await _dioClient.dio.get('/favorites');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch favorites';
    }
  }

  Future<void> addFavorite(String propertyId) async {
    try {
      await _dioClient.dio.post(
        '/favorites',
        data: {'propertyId': propertyId},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to add favorite';
    }
  }

  Future<void> removeFavorite(String propertyId) async {
    try {
      await _dioClient.dio.delete('/favorites/$propertyId');
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to remove favorite';
    }
  }

  Future<bool> isFavorite(String propertyId) async {
    try {
      final response = await _dioClient.dio.get('/favorites/$propertyId/check');
      return response.data['isFavorite'] ?? false;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to check favorite status';
    }
  }
}
