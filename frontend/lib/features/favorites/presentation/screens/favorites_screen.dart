import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../properties/presentation/screens/property_details_screen.dart';
import '../favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              message: 'Properties you favorite will appear here',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritesProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final property = favorite['property'] as Map<String, dynamic>;
                return _FavoriteCard(
                  favorite: favorite,
                  property: property,
                  onRemove: () async {
                    try {
                      final repository = ref.read(favoritesRepositoryProvider);
                      await repository.removeFavorite(property['id']);
                      ref.invalidate(favoritesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from favorites'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading favorites...'),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final Map<String, dynamic> property;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.favorite,
    required this.property,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final photos = property['photos'] as List<dynamic>? ?? [];
    final coverPhoto = photos.isNotEmpty ? photos[0]['url'] as String : null;
    final amenities = property['amenities'] as List<dynamic>? ?? [];
    final isPremium = property['isPremium'] as bool? ?? false;

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(propertyId: property['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMd),
                  ),
                  child: coverPhoto != null
                      ? Image.network(
                          coverPhoto,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.home,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.home,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                // Premium Badge
                if (isPremium)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.premium,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Premium',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Remove Favorite Button
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: InkWell(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    currencyFormat.format(property['price']),
                    style: AppTypography.price,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Title
                  Text(
                    property['title'] ?? 'Untitled Property',
                    style: AppTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '${property['locality']}, ${property['city']}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Property Details
                  Row(
                    children: [
                      _DetailChip(
                        icon: Icons.bed_outlined,
                        label: '${property['bedrooms']} BHK',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _DetailChip(
                        icon: Icons.bathtub_outlined,
                        label: '${property['bathrooms']} Bath',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _DetailChip(
                        icon: Icons.square_foot_outlined,
                        label: '${property['builtUpArea']} sq.ft',
                      ),
                    ],
                  ),
                  if (amenities.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Amenities: ${amenities.take(3).map((a) => a['amenity']['name']).join(', ')}${amenities.length > 3 ? '...' : ''}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
