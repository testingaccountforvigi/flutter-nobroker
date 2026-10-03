import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../services/call_socket_service.dart';
import '../widgets/incoming_call_dialog.dart';
import 'call_providers.dart';

final callManagerProvider = Provider<CallManager>((ref) {
  return CallManager(ref);
});

class CallManager {
  final Ref ref;
  bool _isInitialized = false;
  BuildContext? _context;

  CallManager(this.ref);

  void initialize(BuildContext context) {
    _context = context;
    
    if (_isInitialized) return;

    final authState = ref.read(authStateProvider);
    if (authState.user == null) {
      print('CallManager: No user found, skipping initialization');
      return;
    }

    final userId = authState.user!['id'] as String;
    print('CallManager: Initializing for user $userId');

    final socketService = ref.read(callSocketServiceProvider);
    
    // Connect to socket
    socketService.connect(userId);
    print('CallManager: Socket connection initiated');

    // Listen for incoming calls
    socketService.incomingCallStream.listen((callData) {
      print('CallManager: Incoming call received from ${callData.caller.name}');
      _showIncomingCallDialog(callData);
    });

    _isInitialized = true;
    print('CallManager: Initialization complete');
  }

  void _showIncomingCallDialog(IncomingCallData callData) {
    final context = _context;
    if (context == null || !context.mounted) {
      print('CallManager: Context not available for showing dialog');
      return;
    }

    print('CallManager: Showing incoming call dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => IncomingCallDialog(callData: callData),
    );
  }

  void dispose() {
    print('CallManager: Disposing');
    final socketService = ref.read(callSocketServiceProvider);
    socketService.dispose();
    _isInitialized = false;
    _context = null;
  }
}
