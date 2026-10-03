import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/call_providers.dart';
import '../providers/call_manager_provider.dart';
import '../screens/call_screen.dart';
import '../models/call.dart';
import '../../auth/presentation/auth_provider.dart';

Future<void> initiateCall({
  required BuildContext context,
  required WidgetRef ref,
  required String receiverId,
  required String receiverName,
  String? propertyId,
}) async {
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final callRepository = ref.read(callRepositoryProvider);
    final socketService = ref.read(callSocketServiceProvider);
    final authState = ref.read(authStateProvider);

    if (authState.user == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to make calls')),
      );
      return;
    }

    // Initiate call
    final callResponse = await callRepository.initiateCall(
      receiverId: receiverId,
      propertyId: propertyId,
    );

    // Emit socket event to notify receiver
    socketService.emitCallInitiated(
      receiverId: receiverId,
      callId: callResponse.call.id,
      caller: CallUser(
        id: authState.user!['id'] as String,
        name: authState.user!['name'] as String,
        email: authState.user!['email'] as String,
      ),
      property: callResponse.call.property,
      roomName: callResponse.roomName,
      receiverToken: callResponse.receiverToken,
      livekitUrl: callResponse.livekitUrl,
    );

    // Close loading dialog
    Navigator.of(context).pop();

    // Navigate to call screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          roomUrl: callResponse.livekitUrl,
          token: callResponse.callerToken,
          callId: callResponse.call.id,
          otherUserId: receiverId,
          otherUserName: receiverName,
          isOutgoing: true,
        ),
      ),
    );
  } catch (e) {
    // Close loading dialog
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to initiate call: $e')),
    );
  }
}
