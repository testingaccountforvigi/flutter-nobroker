import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/verification_repository.dart';
import '../../../core/network/dio_client.dart';

final verificationRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return VerificationRepository(dio);
});

final myVerificationRequestsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repository = ref.watch(verificationRepositoryProvider);
  return repository.getMyRequests();
});

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myVerificationRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Verification'),
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return _EmptyState(
              onSubmit: () => _showSubmitDialog(context, ref),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Info Card
              Card(
                color: AppColors.accent.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, color: AppColors.accent, size: 32),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Get Verified',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Verified owners get 3x more inquiries',
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Requests List
              Text('Your Verification Requests', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              ...requests.map((request) => _VerificationRequestCard(request: request)),

              // Submit Button
              if (requests.every((r) => r['status'] != 'PENDING'))
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: CustomButton(
                    text: 'Submit New Verification',
                    onPressed: () => _showSubmitDialog(context, ref),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                text: 'Retry',
                onPressed: () => ref.refresh(myVerificationRequestsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _SubmitVerificationDialog(
        onSubmitted: () => ref.refresh(myVerificationRequestsProvider),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onSubmit;

  const _EmptyState({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                size: 80,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Become a Verified Owner', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload your government-issued ID to verify your identity and build trust with potential tenants/buyers.',
              style: AppTypography.body.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Benefits
            _BenefitRow(
              icon: Icons.check_circle,
              text: 'Build trust with verified badge',
            ),
            _BenefitRow(
              icon: Icons.trending_up,
              text: '3x more inquiries',
            ),
            _BenefitRow(
              icon: Icons.speed,
              text: 'Faster property rental/sale',
            ),
            _BenefitRow(
              icon: Icons.security,
              text: 'Your data is secure and encrypted',
            ),
            
            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              text: 'Get Verified Now',
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _VerificationRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const _VerificationRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final status = request['status'] as String;
    final createdAt = DateTime.parse(request['createdAt']);
    final documentType = request['documentType'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                        _formatDocumentType(documentType),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted: ${DateFormat('MMM dd, yyyy').format(createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (request['documentUrl'] != null) ...[
              const Divider(),
              ListTile(
                dense: true,
                leading: const Icon(Icons.description, color: AppColors.accent),
                title: const Text('Document Uploaded'),
                subtitle: const Text('Tap to view'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open document viewer
                },
              ),
            ],
            if (request['adminNote'] != null) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: status == 'APPROVED' 
                    ? Colors.green[50] 
                    : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      status == 'APPROVED' ? Icons.check_circle : Icons.info,
                      size: 20,
                      color: status == 'APPROVED' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status == 'APPROVED' ? 'Admin Note' : 'Reason for Rejection',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            request['adminNote'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDocumentType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'APPROVED':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'REJECTED':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }
}

class _SubmitVerificationDialog extends ConsumerStatefulWidget {
  final VoidCallback onSubmitted;

  const _SubmitVerificationDialog({required this.onSubmitted});

  @override
  ConsumerState<_SubmitVerificationDialog> createState() => _SubmitVerificationDialogState();
}

class _SubmitVerificationDialogState extends ConsumerState<_SubmitVerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  String _documentType = 'AADHAAR';
  String? _documentUrl;
  bool _isLoading = false;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Submit Verification'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload a government-issued ID to verify your identity',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _documentType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'AADHAAR', child: Text('Aadhaar Card')),
                  DropdownMenuItem(value: 'PAN', child: Text('PAN Card')),
                  DropdownMenuItem(value: 'DRIVING_LICENSE', child: Text('Driving License')),
                  DropdownMenuItem(value: 'PASSPORT', child: Text('Passport')),
                  DropdownMenuItem(value: 'VOTER_ID', child: Text('Voter ID')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _documentType = value!),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Document Upload
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _documentUrl != null ? Icons.check_circle : Icons.upload_file,
                      size: 48,
                      color: _documentUrl != null ? Colors.green : Colors.grey[400],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _documentUrl != null 
                        ? 'Document uploaded!' 
                        : 'No document selected',
                      style: TextStyle(
                        color: _documentUrl != null ? Colors.green : Colors.grey[600],
                        fontWeight: _documentUrl != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_documentUrl != null ? 'Change Document' : 'Upload Document'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your document will be reviewed within 24-48 hours',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading || _documentUrl == null ? null : _submitVerification,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Submit'),
        ),
      ],
    );
  }

  Future<void> _pickDocument() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // In a real app, you would upload to cloud storage
        // For now, we'll use a mock URL
        setState(() {
          _documentUrl = 'https://example.com/documents/${image.name}';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking document: $e')),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate() || _documentUrl == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(verificationRepositoryProvider);
      await repository.submitVerification({
        'documentType': _documentType,
        'documentUrl': _documentUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification request submitted! We will review it shortly.'),
            backgroundColor: Colors.green,
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
        setState(() => _isLoading = false);
      }
    }
  }
}
