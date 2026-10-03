import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/premium_repository.dart';
import '../../../core/network/dio_client.dart';

final premiumRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return PremiumRepository(dio);
});

final premiumPackagesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(premiumRepositoryProvider);
  return repository.getPackages();
});

class PremiumUpgradeScreen extends ConsumerWidget {
  final String propertyId;
  final String propertyTitle;

  const PremiumUpgradeScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(premiumPackagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
      ),
      body: packagesAsync.when(
        data: (packages) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accent.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 48),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Go Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'For: $propertyTitle',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // Benefits
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Premium Benefits', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.md),
                    _BenefitItem(
                      icon: Icons.trending_up,
                      title: 'Top of Search Results',
                      description: 'Your property appears first in search',
                    ),
                    _BenefitItem(
                      icon: Icons.verified,
                      title: 'Premium Badge',
                      description: 'Stand out with a verified premium badge',
                    ),
                    _BenefitItem(
                      icon: Icons.visibility,
                      title: 'More Visibility',
                      description: 'Get 5-10x more views from interested buyers',
                    ),
                    _BenefitItem(
                      icon: Icons.speed,
                      title: 'Faster Rental/Sale',
                      description: 'Premium properties rent/sell 3x faster',
                    ),
                    _BenefitItem(
                      icon: Icons.support_agent,
                      title: 'Priority Support',
                      description: 'Get dedicated support for your listing',
                    ),
                  ],
                ),
              ),

              // Packages
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose Your Plan', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.md),
                    ...packages.map((package) => _PackageCard(
                      package: package,
                      propertyId: propertyId,
                      onUpgraded: () => Navigator.pop(context, true),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                text: 'Retry',
                onPressed: () => ref.refresh(premiumPackagesProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> package;
  final String propertyId;
  final VoidCallback onUpgraded;

  const _PackageCard({
    required this.package,
    required this.propertyId,
    required this.onUpgraded,
  });

  @override
  ConsumerState<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends ConsumerState<_PackageCard> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isRecommended = widget.package['recommended'] == true;
    final name = widget.package['name'] as String;
    final duration = widget.package['duration'] as int;
    final price = widget.package['price'] as int;
    final features = widget.package['features'] as List;
    final savings = widget.package['savings'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: isRecommended ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? BorderSide(color: AppColors.accent, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Text(
                '⭐ RECOMMENDED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$duration days',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        if (savings != null)
                          Text(
                            savings,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, 
                        color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature as String,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _upgradeToPremium,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended 
                        ? AppColors.accent 
                        : Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Upgrade Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _upgradeToPremium() async {
    setState(() => _isProcessing = true);

    try {
      final repository = ref.read(premiumRepositoryProvider);
      
      // Create order
      final order = await repository.createOrder(
        widget.propertyId,
        {
          'amount': widget.package['price'],
          'duration': widget.package['duration'],
        },
      );

      // Process mock payment
      await repository.processMockPayment(order['id']);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 8),
                const Text('Success!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your property has been upgraded to Premium!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Package:'),
                          Text(
                            widget.package['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Duration:'),
                          Text(
                            '${widget.package['duration']} days',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount Paid:'),
                          Text(
                            '₹${widget.package['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Your property will now appear at the top of search results and get maximum visibility!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  widget.onUpgraded(); // Close premium screen
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
