import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../properties/data/properties_repository.dart';
import '../../../properties/presentation/screens/property_details_screen.dart';
import '../../../properties/presentation/screens/create_property_screen.dart';
import '../../../inquiries/data/inquiries_repository.dart';

final ownerPropertiesProvider = FutureProvider.autoDispose((ref) async {
  final repository = PropertiesRepository();
  return repository.getMyProperties();
});

final ownerLeadsProvider = FutureProvider.autoDispose((ref) async {
  final repository = InquiriesRepository();
  return repository.getOwnerLeads();
});

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Owner Dashboard',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Properties'),
            Tab(text: 'Leads'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPropertiesTab(),
          _buildLeadsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePropertyScreen(),
            ),
          );
          if (result == true) {
            ref.invalidate(ownerPropertiesProvider);
          }
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final propertiesAsync = ref.watch(ownerPropertiesProvider);
    final leadsAsync = ref.watch(ownerLeadsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ownerPropertiesProvider);
        ref.invalidate(ownerLeadsProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Stats', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Properties',
                    propertiesAsync.when(
                      data: (properties) => properties.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.home,
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatCard(
                    'Active Leads',
                    leadsAsync.when(
                      data: (leads) => leads.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Icons.people,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: propertiesAsync.when(
                    data: (properties) {
                      final activeCount = properties
                          .where((p) => p['status'] == 'ACTIVE')
                          .length;
                      return _buildStatCard(
                        'Active Listings',
                        activeCount.toString(),
                        Icons.check_circle,
                        Colors.blue,
                      );
                    },
                    loading: () => _buildStatCard(
                      'Active Listings',
                      '...',
                      Icons.check_circle,
                      Colors.blue,
                    ),
                    error: (_, __) => _buildStatCard(
                      'Active Listings',
                      '0',
                      Icons.check_circle,
                      Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: leadsAsync.when(
                    data: (leads) {
                      final newLeads = leads
                          .where((l) => l['status'] == 'PENDING')
                          .length;
                      return _buildStatCard(
                        'New Leads',
                        newLeads.toString(),
                        Icons.notifications_active,
                        AppColors.warning,
                      );
                    },
                    loading: () => _buildStatCard(
                      'New Leads',
                      '...',
                      Icons.notifications_active,
                      AppColors.warning,
                    ),
                    error: (_, __) => _buildStatCard(
                      'New Leads',
                      '0',
                      Icons.notifications_active,
                      AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Recent Leads', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            leadsAsync.when(
              data: (leads) {
                if (leads.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('No leads yet'),
                    ),
                  );
                }
                return Column(
                  children: leads.take(3).map((lead) {
                    return _buildLeadCard(lead);
                  }).toList(),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(ownerLeadsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTypography.h2.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesTab() {
    final propertiesAsync = ref.watch(ownerPropertiesProvider);

    return propertiesAsync.when(
      data: (properties) {
        if (properties.isEmpty) {
          return const EmptyState(
            icon: Icons.home_work,
            title: 'No Properties',
            message: 'Add your first property to get started',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ownerPropertiesProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: properties.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final property = properties[index] as Map<String, dynamic>;
              return _buildPropertyCard(property);
            },
          ),
        );
      },
      loading: () => const LoadingIndicator(message: 'Loading properties...'),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(ownerPropertiesProvider),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final photos = property['photos'] as List<dynamic>? ?? [];
    final coverPhoto = photos.isNotEmpty ? photos[0]['url'] as String : null;
    final status = property['status'] as String;
    final isPremium = property['isPremium'] as bool? ?? false;

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    Color statusColor;
    String statusText;
    switch (status) {
      case 'ACTIVE':
        statusColor = AppColors.success;
        statusText = 'Active';
        break;
      case 'DRAFT':
        statusColor = AppColors.textSecondary;
        statusText = 'Draft';
        break;
      case 'PAUSED':
        statusColor = AppColors.warning;
        statusText = 'Paused';
        break;
      case 'RENTED':
        statusColor = Colors.blue;
        statusText = 'Rented';
        break;
      case 'SOLD':
        statusColor = Colors.purple;
        statusText = 'Sold';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

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
            // Image with status badge
            Stack(
              children: [
                if (coverPhoto != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusMd),
                    ),
                    child: Image.network(
                      coverPhoto,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.home,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.home,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      statusText,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title'] ?? 'Untitled Property',
                    style: AppTypography.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    currencyFormat.format(property['price']),
                    style: AppTypography.price.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property['locality']}, ${property['city']}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: status == 'ACTIVE' ? 'Pause' : 'Activate',
                          variant: ButtonVariant.outlined,
                          size: ButtonSize.small,
                          onPressed: () async {
                            await _togglePropertyStatus(property);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: CustomButton(
                          text: 'Edit',
                          size: ButtonSize.small,
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreatePropertyScreen(
                                  propertyId: property['id'],
                                ),
                              ),
                            );
                            if (result == true) {
                              ref.invalidate(ownerPropertiesProvider);
                            }
                          },
                        ),
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

  Future<void> _togglePropertyStatus(Map<String, dynamic> property) async {
    try {
      final repository = PropertiesRepository();
      final propertyId = property['id'] as String;
      final currentStatus = property['status'] as String;

      if (currentStatus == 'ACTIVE') {
        await repository.pauseProperty(propertyId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property paused')),
          );
        }
      } else {
        await repository.publishProperty(propertyId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property activated')),
          );
        }
      }

      ref.invalidate(ownerPropertiesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildLeadsTab() {
    final leadsAsync = ref.watch(ownerLeadsProvider);

    return leadsAsync.when(
      data: (leads) {
        if (leads.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No Leads',
            message: 'Leads from interested buyers will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ownerLeadsProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: leads.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final lead = leads[index] as Map<String, dynamic>;
              return _buildLeadCard(lead);
            },
          ),
        );
      },
      loading: () => const LoadingIndicator(message: 'Loading leads...'),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(ownerLeadsProvider),
      ),
    );
  }

  Widget _buildLeadCard(Map<String, dynamic> lead) {
    final property = lead['property'] as Map<String, dynamic>?;
    final user = lead['user'] as Map<String, dynamic>?;
    final status = lead['status'] as String;
    final createdAt = DateTime.parse(lead['createdAt'] as String);

    Color statusColor;
    switch (status) {
      case 'PENDING':
        statusColor = AppColors.warning;
        break;
      case 'CONTACTED':
        statusColor = Colors.blue;
        break;
      case 'SCHEDULED':
        statusColor = AppColors.accent;
        break;
      case 'CLOSED':
        statusColor = AppColors.success;
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent.withOpacity(0.1),
                  child: Text(
                    user?['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                    style: AppTypography.h4.copyWith(color: AppColors.accent),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?['name'] ?? 'Unknown User',
                        style: AppTypography.h4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        property?['title'] ?? 'Property',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    status,
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              lead['message'] ?? 'No message',
              style: AppTypography.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Received ${_formatDate(createdAt)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Call',
                    variant: ButtonVariant.outlined,
                    size: ButtonSize.small,
                    icon: const Icon(Icons.phone, size: 18),
                    onPressed: () {
                      // Navigate to calling screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling feature coming soon')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: CustomButton(
                    text: 'Update Status',
                    size: ButtonSize.small,
                    onPressed: () {
                      _showUpdateStatusDialog(lead);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  void _showUpdateStatusDialog(Map<String, dynamic> lead) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Lead Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(lead, 'CONTACTED', 'Contacted'),
            _buildStatusOption(lead, 'SCHEDULED', 'Visit Scheduled'),
            _buildStatusOption(lead, 'CLOSED', 'Closed'),
            _buildStatusOption(lead, 'REJECTED', 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(Map<String, dynamic> lead, String status, String label) {
    return ListTile(
      title: Text(label),
      onTap: () async {
        Navigator.pop(context);
        try {
          final repository = InquiriesRepository();
          await repository.updateInquiryStatus(lead['id'], status);
          ref.invalidate(ownerLeadsProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Status updated to $label')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
    );
  }
}
