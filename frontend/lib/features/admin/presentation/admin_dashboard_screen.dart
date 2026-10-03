import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/admin_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../verification/data/verification_repository.dart';

final adminRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return AdminRepository(dio);
});

final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getDashboardStats();
});

final pendingVerificationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final repository = VerificationRepository(dio);
  return repository.getPendingVerifications();
});

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Verifications'),
            Tab(text: 'Users'),
            Tab(text: 'Properties'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(),
          _VerificationsTab(),
          _UsersTab(),
          _PropertiesTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      data: (stats) => RefreshIndicator(
        onRefresh: () async => ref.refresh(adminStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Platform Statistics', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.md),
            
            // Key Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'Total Users',
                  value: '${stats['totalUsers'] ?? 0}',
                  icon: Icons.people,
                  color: Colors.blue,
                  subtitle: '+${stats['newUsers7Days'] ?? 0} this week',
                ),
                _StatCard(
                  title: 'Total Properties',
                  value: '${stats['totalProperties'] ?? 0}',
                  icon: Icons.home,
                  color: Colors.green,
                  subtitle: '${stats['activeProperties'] ?? 0} active',
                ),
                _StatCard(
                  title: 'Pending Verifications',
                  value: '${stats['pendingVerifications'] ?? 0}',
                  icon: Icons.verified_user,
                  color: Colors.orange,
                  subtitle: 'Need review',
                ),
                _StatCard(
                  title: 'Today\'s Inquiries',
                  value: '${stats['todayInquiries'] ?? 0}',
                  icon: Icons.email,
                  color: Colors.purple,
                  subtitle: 'New contacts',
                ),
                _StatCard(
                  title: 'Premium Properties',
                  value: '${stats['premiumProperties'] ?? 0}',
                  icon: Icons.star,
                  color: AppColors.accent,
                  subtitle: 'Active premium',
                ),
                _StatCard(
                  title: 'Views (30 days)',
                  value: '${stats['views30Days'] ?? 0}',
                  icon: Icons.visibility,
                  color: Colors.teal,
                  subtitle: 'Property views',
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Quick Actions
            Text('Quick Actions', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            _QuickActionButton(
              icon: Icons.verified_user,
              label: 'Review Verifications',
              onTap: () => DefaultTabController.of(context).animateTo(1),
            ),
            _QuickActionButton(
              icon: Icons.people,
              label: 'Manage Users',
              onTap: () => DefaultTabController.of(context).animateTo(2),
            ),
            _QuickActionButton(
              icon: Icons.home,
              label: 'Moderate Properties',
              onTap: () => DefaultTabController.of(context).animateTo(3),
            ),
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
              onPressed: () => ref.refresh(adminStatsProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withOpacity(0.1),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _VerificationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationsAsync = ref.watch(pendingVerificationsProvider);

    return verificationsAsync.when(
      data: (verifications) {
        if (verifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: AppSpacing.md),
                Text('No pending verifications', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: verifications.length,
          itemBuilder: (context, index) {
            final request = verifications[index];
            return _VerificationRequestCard(request: request);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class _VerificationRequestCard extends ConsumerWidget {
  final Map<String, dynamic> request;

  const _VerificationRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = request['user'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text(user['name'][0].toUpperCase()),
            ),
            title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['email']),
                const SizedBox(height: 4),
                Text(
                  'Document: ${request['documentType']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveVerification(context, ref, request['id']),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectVerification(context, ref, request['id']),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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

  Future<void> _approveVerification(BuildContext context, WidgetRef ref, String requestId) async {
    try {
      final dio = ref.read(dioProvider);
      final repository = VerificationRepository(dio);
      await repository.approveVerification(requestId);
      ref.invalidate(pendingVerificationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification approved'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectVerification(BuildContext context, WidgetRef ref, String requestId) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Enter reason...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        final dio = ref.read(dioProvider);
        final repository = VerificationRepository(dio);
        await repository.rejectVerification(requestId, reasonController.text);
        ref.invalidate(pendingVerificationsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification rejected')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

class _UsersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey),
          SizedBox(height: AppSpacing.md),
          Text('User Management', style: TextStyle(fontSize: 18)),
          SizedBox(height: AppSpacing.sm),
          Text(
            'View and manage all users',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PropertiesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: Colors.grey),
          SizedBox(height: AppSpacing.md),
          Text('Property Moderation', style: TextStyle(fontSize: 18)),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Review and moderate property listings',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
