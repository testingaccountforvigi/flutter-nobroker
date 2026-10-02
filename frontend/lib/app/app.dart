import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';

/// Main application widget.
class NoBrokerApp extends ConsumerWidget {
  const NoBrokerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'NoBroker Owner Listings',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Router will be added in next phases
      home: const Scaffold(
        body: Center(
          child: Text('NoBroker Owner Listings'),
        ),
      ),
    );
  }
}
