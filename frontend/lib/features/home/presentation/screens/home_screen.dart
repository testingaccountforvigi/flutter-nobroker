import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../features/auth/presentation/auth_provider.dart';
import '../../../../features/properties/data/properties_repository.dart';
import '../../../../features/properties/presentation/screens/property_details_screen.dart';
import '../../../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../../../features/inquiries/presentation/screens/my_inquiries_screen.dart';
import 'package:intl/intl.dart';

final propertiesProvider = FutureProvider.autoDispose((ref) async {
  final repository = PropertiesRepository();
  return repository.searchProperties();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(propertiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoBroker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              _showProfileMenu(context, ref);
            },
          ),
        ],
      ),
      body: propertiesAsync.when(
        data: (data) {
          final properties = data['properties'] as List;
          if (properties.isEmpty) {
            return const Center(
              child: Text('No properties found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(propertiesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return _PropertyCard(property: property);
              },
            ),
          );
        },
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
                  ref.invalidate(propertiesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_work),
              title: const Text('Owner Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_answer),
              title: const Text('My Inquiries'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyInquiriesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authStateProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;

  const _PropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    final coverPhoto = (property['photos'] as List?)?.isNotEmpty == true
        ? property['photos'][0]['url']
        : null;
    
    final price = property['price'];
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PropertyDetailsScreen(propertyId: property['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (coverPhoto != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: coverPhoto,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price & Premium badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currency.format(price),
                        style: AppTypography.priceSmall,
                      ),
                      if (property['isPremium'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.premium.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: AppTypography.captionSmall.copyWith(
                              color: AppColors.premium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Title
                  Text(
                    property['title'],
                    style: AppTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property['locality']}, ${property['city']}',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Details
                  Row(
                    children: [
                      _DetailChip(
                        icon: Icons.bed,
                        label: '${property['bedrooms']} BHK',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _DetailChip(
                        icon: Icons.bathtub_outlined,
                        label: '${property['bathrooms']} Bath',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _DetailChip(
                        icon: Icons.square_foot,
                        label: '${property['areaSqFt']} sqft',
                      ),
                    ],
                  ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.captionSmall,
          ),
        ],
      ),
    );
  }
}
