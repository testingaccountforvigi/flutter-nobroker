import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/properties_repository.dart';
import '../../widgets/contact_owner_dialog.dart';
import '../../../favorites/data/favorites_repository.dart';
import 'package:intl/intl.dart';

final propertyDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final repository = PropertiesRepository();
  return repository.getPropertyDetails(id);
});

final propertyFavoritesRepoProvider = Provider((ref) {
  return FavoritesRepository(DioClient());
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, propertyId) async {
  final repository = ref.watch(propertyFavoritesRepoProvider);
  try {
    return await repository.isFavorite(propertyId);
  } catch (e) {
    return false;
  }
});

final toggleFavoriteProvider = StateNotifierProvider<ToggleFavoriteNotifier, AsyncValue<void>>((ref) {
  return ToggleFavoriteNotifier(ref);
});

class ToggleFavoriteNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  
  ToggleFavoriteNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> toggle(String propertyId, bool currentlyFavorite) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(propertyFavoritesRepoProvider);
      
      if (currentlyFavorite) {
        await repository.removeFavorite(propertyId);
      } else {
        await repository.addFavorite(propertyId);
      }
      
      // Refresh the favorite status
      ref.invalidate(isFavoriteProvider(propertyId));
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

class PropertyDetailsScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyDetailsProvider(propertyId));

    return Scaffold(
      body: propertyAsync.when(
        data: (property) => _buildPropertyDetails(context, property),
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.lg),
              Text(error.toString()),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () {
                  ref.invalidate(propertyDetailsProvider(propertyId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: propertyAsync.when(
        data: (property) => _buildBottomBar(context, ref, property),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, Map<String, dynamic> property) {
    final isFavoriteAsync = ref.watch(isFavoriteProvider(propertyId));
    final owner = property['owner'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Contact Owner',
                onPressed: owner != null
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) => ContactOwnerDialog(
                            ownerId: owner['id'] as String,
                            ownerName: owner['name'] as String,
                            ownerEmail: owner['email'] as String,
                            propertyId: propertyId,
                          ),
                        );
                      }
                    : null,
                fullWidth: true,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            isFavoriteAsync.when(
              data: (isFavorite) => IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.primary : null,
                ),
                onPressed: () {
                  ref.read(toggleFavoriteProvider.notifier).toggle(
                        propertyId,
                        isFavorite,
                      );
                },
                style: IconButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              loading: () => IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: null,
                style: IconButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  ref.invalidate(isFavoriteProvider(propertyId));
                },
                style: IconButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(BuildContext context, Map<String, dynamic> property) {
    final photos = property['photos'] as List? ?? [];
    final amenities = property['amenities'] as List? ?? [];
    final price = property['price'];
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return CustomScrollView(
      slivers: [
        // App bar with image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: photos.isNotEmpty
                ? PageView.builder(
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: photos[index]['url'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                      );
                    },
                  )
                : Container(color: AppColors.surfaceVariant),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price & Verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currency.format(price),
                      style: AppTypography.price,
                    ),
                    if (property['isVerifiedOwnerSnapshot'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.verified.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.verified),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 16, color: AppColors.verified),
                            const SizedBox(width: 4),
                            Text(
                              'VERIFIED',
                              style: AppTypography.captionSmall.copyWith(
                                color: AppColors.verified,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Title
                Text(
                  property['title'],
                  style: AppTypography.h2,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property['address']}, ${property['locality']}, ${property['city']}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // Key details
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _InfoTile(
                      icon: Icons.bed,
                      label: 'Bedrooms',
                      value: '${property['bedrooms']}',
                    ),
                    _InfoTile(
                      icon: Icons.bathtub_outlined,
                      label: 'Bathrooms',
                      value: '${property['bathrooms']}',
                    ),
                    _InfoTile(
                      icon: Icons.square_foot,
                      label: 'Area',
                      value: '${property['areaSqFt']} sqft',
                    ),
                    _InfoTile(
                      icon: Icons.deck,
                      label: 'Balconies',
                      value: '${property['balconies']}',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // Description
                Text(
                  'Description',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  property['description'],
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                // Amenities
                if (amenities.isNotEmpty) ...[
                  Text(
                    'Amenities',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: amenities.map((amenity) {
                      return Chip(
                        avatar: Text(amenity['amenity']['icon'] ?? ''),
                        label: Text(amenity['amenity']['name']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                // Owner info
                Text(
                  'Owner',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(property['owner']['name']),
                    subtitle: Text(property['owner']['email']),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                // Add bottom padding for the bottom navigation bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2 - 6,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.caption,
          ),
          Text(
            value,
            style: AppTypography.h4,
          ),
        ],
      ),
    );
  }
}
