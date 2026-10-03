import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/calls/providers/call_manager_provider.dart';

/// Main application widget.
class NoBrokerApp extends ConsumerStatefulWidget {
  const NoBrokerApp({super.key});

  @override
  ConsumerState<NoBrokerApp> createState() => _NoBrokerAppState();
}

class _NoBrokerAppState extends ConsumerState<NoBrokerApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _callManagerInitialized = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Initialize call manager when user logs in
    if (authState.isAuthenticated && !_callManagerInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigatorKey.currentContext != null && mounted) {
          final callManager = ref.read(callManagerProvider);
          callManager.initialize(_navigatorKey.currentContext!);
          setState(() {
            _callManagerInitialized = true;
          });
        }
      });
    }

    // Reset when user logs out
    if (!authState.isAuthenticated && _callManagerInitialized) {
      _callManagerInitialized = false;
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'NoBroker Owner Listings',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
