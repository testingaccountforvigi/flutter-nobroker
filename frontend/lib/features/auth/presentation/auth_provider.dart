import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      try {
        final userData = await _repository.getMe();
        state = state.copyWith(
          isAuthenticated: true,
          user: userData,
        );
      } catch (e) {
        state = state.copyWith(isAuthenticated: false);
      }
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String intent,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        intent: intent,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: result['user'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isAuthenticated: true,
        user: result['user'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }
}
