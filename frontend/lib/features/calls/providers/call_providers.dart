import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../repositories/call_repository.dart';
import '../services/call_socket_service.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CallRepository(dio);
});

final callSocketServiceProvider = Provider<CallSocketService>((ref) {
  return CallSocketService();
});
