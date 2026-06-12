import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../data/ghost_mode_repository.dart';
import '../models/ghost_mode_models.dart';

final ghostModeRepositoryProvider = Provider<GhostModeRepository>((ref) {
  return GhostModeRepository(ref.watch(apiClientProvider));
});

final ghostModeProvider =
    NotifierProvider<GhostModeNotifier, GhostModeUiState>(GhostModeNotifier.new);

class GhostModeUiState {
  const GhostModeUiState({
    this.data,
    this.loading = false,
    this.refreshing = false,
    this.loadError,
    this.actionError,
  });

  final GhostModeState? data;
  final bool loading;
  final bool refreshing;
  final String? loadError;
  final String? actionError;

  GhostModeUiState copyWith({
    GhostModeState? data,
    bool? loading,
    bool? refreshing,
    String? loadError,
    String? actionError,
    bool clearActionError = false,
    bool clearLoadError = false,
  }) {
    return GhostModeUiState(
      data: data ?? this.data,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}

class GhostModeNotifier extends Notifier<GhostModeUiState> {
  @override
  GhostModeUiState build() => const GhostModeUiState();

  Future<void> ensureLoaded() async {
    if (state.data != null || state.loading) {
      return;
    }

    await _load(initial: true);
  }

  Future<void> refresh() async {
    if (state.loading || state.refreshing) {
      return;
    }

    await _load(refreshing: true);
  }

  Future<bool> activate(int durationDays) async {
    state = state.copyWith(clearActionError: true);

    try {
      final storage = ref.read(appLocalStorageProvider);
      final next = await ref.read(ghostModeRepositoryProvider).startProtocol(durationDays);

      if (next.guestToken != null && next.guestToken!.isNotEmpty) {
        await storage.writeGuestToken(next.guestToken!);
      }

      state = GhostModeUiState(data: next);
      return true;
    } on ApiException catch (error) {
      state = state.copyWith(actionError: error.displayMessage);
      return false;
    } catch (error) {
      state = state.copyWith(actionError: error.toString());
      return false;
    }
  }

  Future<void> _load({bool initial = false, bool refreshing = false}) async {
    final previous = state.data;

    state = state.copyWith(
      loading: initial,
      refreshing: refreshing,
      clearLoadError: true,
      clearActionError: true,
    );

    try {
      final storage = ref.read(appLocalStorageProvider);
      final next = await ref.read(ghostModeRepositoryProvider).fetchState();

      if (next.guestToken != null && next.guestToken!.isNotEmpty) {
        await storage.writeGuestToken(next.guestToken!);
      }

      state = GhostModeUiState(data: next);
    } on ApiException catch (error) {
      state = GhostModeUiState(
        data: previous,
        loadError: error.displayMessage,
      );
    } catch (error) {
      state = GhostModeUiState(
        data: previous,
        loadError: error.toString(),
      );
    }
  }
}
