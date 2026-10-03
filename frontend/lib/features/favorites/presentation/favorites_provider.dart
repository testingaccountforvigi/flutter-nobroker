import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(DioClient());
});

final favoritesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.getMyFavorites();
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, propertyId) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  return repository.isFavorite(propertyId);
});
