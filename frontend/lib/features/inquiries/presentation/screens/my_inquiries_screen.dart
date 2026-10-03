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
import '../../data/inquiries_repository.dart';

final myInquiriesProvider = FutureProvider.autoDispose((ref) async {
  final repository = InquiriesRepository();
  return repository.getMyInquiries();
});

class MyInquiriesScreen extends ConsumerWidget {
  const MyInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiriesAsync = ref.watch(myInquiriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Inquiries',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: inquiriesAsync.when(
        data: (inquiries) {
          if (inquiries.isEmpty) {
            return const EmptyState(
              icon: Icons.question_answer_outlined,
              title: 'No Inquiries',
              message: 'Your property inquiries will appear here',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myInquiriesProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: inquiries.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final inquiry = inquiries[index] as Map<String, dynamic>;
                return _InquiryCard(inquiry: inquiry);
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading inquiries...'),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(myInquiriesProvider),
        ),
      ),
    );
  }
}

class _InquiryCard extends StatelessWidget {
  final Map<String, dynamic> inquiry;

  const _InquiryCard({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    final property = inquiry['property'] as Map<String, dynamic>?;
    final owner = property?['owner'] as Map<String, dynamic>?;
    final status = inquiry['status'] as String;
    final createdAt = DateTime.parse(inquiry['createdAt'] as String);

    Color statusColor;
    String statusText;
    switch (status) {
      case 'PENDING':
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case 'CONTACTED':
        statusColor = Colors.blue;
        statusText = 'Owner Contacted';
        break;
      case 'SCHEDULED':
        statusColor = AppColors.accent;
        statusText = 'Visit Scheduled';
        break;
      case 'CLOSED':
        statusColor = AppColors.success;
        statusText = 'Closed';
        break;
      case 'REJECTED':
        statusColor = AppColors.error;
        statusText = 'Rejected';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = status;
    }

    final photos = property?['photos'] as List<dynamic>? ?? [];
    final coverPhoto = photos.isNotEmpty ? photos[0]['url'] as String : null;
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
          if (property != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailsScreen(
                  propertyId: property['id'],
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property preview
            if (property != null && coverPhoto != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      coverPhoto,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.home,
                            size: 32,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
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
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (property != null) ...[
                    Text(
                      property['title'] ?? 'Property',
                      style: AppTypography.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      currencyFormat.format(property['price']),
                      style: AppTypography.price.copyWith(fontSize: 16),
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
                    const Divider(height: AppSpacing.lg),
                  ],
                  Text(
                    'Your Message',
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    inquiry['message'] ?? 'No message',
                    style: AppTypography.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sent ${_formatDate(createdAt)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (owner != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Owner: ${owner['name']}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
}
