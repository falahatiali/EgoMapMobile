import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../data/auth_repository.dart';
import '../models/auth_models.dart';

class AuthState {
  const AuthState({
    this.isBootstrapping = true,
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.pendingVerification,
  });

  final bool isBootstrapping;
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;
  final VerificationChallenge? pendingVerification;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isBootstrapping,
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
    VerificationChallenge? pendingVerification,
    bool clearUser = false,
    bool clearError = false,
    bool clearPendingVerification = false,
  }) {
    return AuthState(
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingVerification: clearPendingVerification
          ? null
          : (pendingVerification ?? this.pendingVerification),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  bool _restoreStarted = false;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _restoreSessionOnce();

    return const AuthState(isBootstrapping: true);
  }

  void _restoreSessionOnce() {
    if (_restoreStarted) {
      return;
    }

    _restoreStarted = true;
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await ref.read(appLocalStorageProvider).readApiToken();

    if (token == null || token.isEmpty) {
      state = const AuthState(isBootstrapping: false);
      return;
    }

    try {
      final user = await _repository.currentUser();
      state = state.copyWith(
        isBootstrapping: false,
        user: user,
        clearUser: user == null,
        clearError: true,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await ref.read(apiClientProvider).clearToken();
        state = state.copyWith(
          isBootstrapping: false,
          clearUser: true,
          clearError: true,
        );
        return;
      }

      state = state.copyWith(
        isBootstrapping: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isBootstrapping: false,
        clearError: true,
      );
    }
  }

  Future<VerificationChallenge> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final challenge = await _repository.register(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        pendingVerification: challenge,
      );
      return challenge;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.displayMessage);
      rethrow;
    }
  }

  Future<VerificationChallenge?> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _repository.login(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        user: session.user,
        clearError: true,
      );
      return null;
    } on VerificationRequiredException catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        pendingVerification: error.challenge,
      );
      return error.challenge;
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.displayMessage);
      rethrow;
    }
  }

  Future<void> verifyEmail({
    required String verificationToken,
    required String code,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _repository.verifyEmail(
        verificationToken: verificationToken,
        code: code,
      );
      state = state.copyWith(
        isLoading: false,
        user: session.user,
        clearError: true,
        clearPendingVerification: true,
      );
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.displayMessage);
      rethrow;
    }
  }

  Future<int> resendVerification(String verificationToken) async {
    return _repository.resendVerification(verificationToken);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(clearUser: true, clearError: true, clearPendingVerification: true);
  }

  void clearPendingVerification() {
    state = state.copyWith(clearPendingVerification: true);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
