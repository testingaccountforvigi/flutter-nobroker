import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// Mock notifications provider
final notificationsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  // Simulate API call
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    {
      'id': '1',
      'type': 'INQUIRY',
      'title': 'New Inquiry Received',
      'body': 'Someone is interested in your property "Luxury 3BHK Apartment"',
      'readAt': null,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': '2',
      'type': 'VERIFICATION',
      'title': 'Verification Approved',
      'body': 'Your verification request has been approved. You are now a verified owner!',
      'readAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': '3',
      'type': 'PREMIUM',
      'title': 'Premium Listing Activated',
      'body': 'Your property has been upgraded to Premium and will appear at the top of search results.',
      'readAt': DateTime.now().toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': '4',
      'type': 'REMINDER',
      'title': 'Rent Payment Due',
      'body': 'Your rent payment of ₹25,000 is due on Nov 1, 2024',
      'readAt': null,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
  ];
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: AppSpacing.md),
                  Text('No notifications yet', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'We\'ll notify you about important updates',
                    style: AppTypography.body.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final unread = notifications.where((n) => n['readAt'] == null).toList();
          final read = notifications.where((n) => n['readAt'] != null).toList();

          return ListView(
            children: [
              if (unread.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Text('Unread', style: AppTypography.h3),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${unread.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...unread.map((notification) => _NotificationCard(
                  notification: notification,
                  isUnread: true,
                  onTap: () => _markAsRead(context, ref, notification['id']),
                )),
              ],
              if (unread.isNotEmpty && read.isNotEmpty)
                const Divider(height: AppSpacing.lg, thickness: 8),
              if (read.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('Earlier', style: AppTypography.h3),
                ),
                ...read.map((notification) => _NotificationCard(
                  notification: notification,
                  isUnread: false,
                  onTap: () {},
                )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _markAsRead(BuildContext context, WidgetRef ref, String id) {
    // Mark notification as read
    ref.invalidate(notificationsProvider);
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isUnread;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = notification['type'] as String;
    final createdAt = DateTime.parse(notification['createdAt']);
    final timeAgo = _getTimeAgo(createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      color: isUnread ? AppColors.accent.withOpacity(0.05) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(type),
                  color: _getIconColor(type),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['body'],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'INQUIRY':
        return Icons.email;
      case 'CALL':
        return Icons.phone;
      case 'VISIT':
        return Icons.calendar_today;
      case 'AGREEMENT':
        return Icons.description;
      case 'REMINDER':
        return Icons.notifications_active;
      case 'VERIFICATION':
        return Icons.verified_user;
      case 'PREMIUM':
        return Icons.star;
      case 'SYSTEM':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'INQUIRY':
        return Colors.blue;
      case 'CALL':
        return Colors.green;
      case 'VISIT':
        return Colors.purple;
      case 'AGREEMENT':
        return Colors.orange;
      case 'REMINDER':
        return Colors.red;
      case 'VERIFICATION':
        return Colors.teal;
      case 'PREMIUM':
        return AppColors.accent;
      case 'SYSTEM':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }
}
