import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/call_socket_service.dart';
import '../screens/call_screen.dart';
import '../providers/call_providers.dart';
import '../models/call.dart';

class IncomingCallDialog extends ConsumerWidget {
  final IncomingCallData callData;

  const IncomingCallDialog({
    super.key,
    required this.callData,
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
            // Caller Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFD4735A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  callData.caller.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Caller Name
            Text(
              callData.caller.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Call Type
            Text(
              'Incoming call',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            // Property Info (if available)
            if (callData.property != null) ...[
              const SizedBox(height: 8),
              Text(
                'About: ${callData.property!.title}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _rejectCall(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptCall(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptCall(BuildContext context, WidgetRef ref) async {
    final socketService = ref.read(callSocketServiceProvider);
    final callRepository = ref.read(callRepositoryProvider);

    // Emit socket event
    socketService.emitCallAccepted(callData.callId, callData.caller.id);

    // Update call status
    try {
      await callRepository.updateCallStatus(
        callData.callId,
        CallStatus.ACCEPTED,
      );
    } catch (e) {
      print('Error updating call status: $e');
    }

    // Close dialog
    Navigator.of(context).pop();

    // Navigate to call screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          roomUrl: callData.livekitUrl,
          token: callData.receiverToken,
          callId: callData.callId,
          otherUserId: callData.caller.id,
          otherUserName: callData.caller.name,
          isOutgoing: false,
        ),
      ),
    );
  }

  void _rejectCall(BuildContext context, WidgetRef ref) async {
    final socketService = ref.read(callSocketServiceProvider);
    final callRepository = ref.read(callRepositoryProvider);

    // Emit socket event
    socketService.emitCallRejected(callData.callId, callData.caller.id);

    // Update call status
    try {
      await callRepository.updateCallStatus(
        callData.callId,
        CallStatus.DECLINED,
      );
    } catch (e) {
      print('Error updating call status: $e');
    }

    // Close dialog
    Navigator.of(context).pop();
  }
}
