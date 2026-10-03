import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calls/utils/call_helpers.dart' as call_utils;
import 'package:url_launcher/url_launcher.dart';

class ContactOwnerDialog extends ConsumerWidget {
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String? propertyId;

  const ContactOwnerDialog({
    super.key,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Contact Owner',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ownerName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Email Option
            _ContactOption(
              icon: Icons.email,
              title: 'Send Email',
              subtitle: ownerEmail,
              onTap: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: ownerEmail,
                  query: 'subject=Property Inquiry',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                  Navigator.of(context).pop();
                }
              },
            ),

            const SizedBox(height: 16),

            // Call Option
            _ContactOption(
              icon: Icons.phone,
              title: 'Call Now',
              subtitle: 'Instant audio call',
              color: const Color(0xFFD4735A),
              onTap: () {
                Navigator.of(context).pop();
                call_utils.initiateCall(
                  context: context,
                  ref: ref,
                  receiverId: ownerId,
                  receiverName: ownerName,
                  propertyId: propertyId,
                );
              },
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final optionColor = color ?? Colors.blue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: optionColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: optionColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
