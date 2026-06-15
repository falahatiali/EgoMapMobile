import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/virtue_repository.dart';
import '../models/virtue_models.dart';

// ─── Repository ──────────────────────────────────────────────────────────────

final virtueRepositoryProvider = Provider<VirtueRepository>((ref) {
  return VirtueRepository(ref.watch(apiClientProvider));
});

// ─── Habits (predefined list) ─────────────────────────────────────────────────

final virtueHabitsProvider = FutureProvider<List<VirtueHabit>>((ref) async {
  return ref.watch(virtueRepositoryProvider).fetchHabits();
});

// ─── Hub state ────────────────────────────────────────────────────────────────

class VirtueHubState {
  const VirtueHubState({
    this.routines = const [],
    this.isLoading = false,
    this.isLoaded = false,
    this.error,
    this.actionError,
  });

  final List<VirtueRoutine> routines;
  final bool isLoading;
  final bool isLoaded;
  final String? error;
  final String? actionError;

  List<VirtueRoutine> get activeRoutines => routines.where((r) => r.isActive).toList();
  List<VirtueRoutine> get completedRoutines => routines.where((r) => r.isCompleted).toList();

  VirtueHubState copyWith({
    List<VirtueRoutine>? routines,
    bool? isLoading,
    bool? isLoaded,
    String? error,
    String? actionError,
  }) =>
      VirtueHubState(
        routines: routines ?? this.routines,
        isLoading: isLoading ?? this.isLoading,
        isLoaded: isLoaded ?? this.isLoaded,
        error: error,
        actionError: actionError,
      );
}

class VirtueHubNotifier extends Notifier<VirtueHubState> {
  @override
  VirtueHubState build() => const VirtueHubState();

  VirtueRepository get _repo => ref.read(virtueRepositoryProvider);

  Future<void> ensureLoaded() async {
    if (state.isLoaded || state.isLoading) return;
    await _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final routines = await _repo.fetchRoutines();
      state = state.copyWith(routines: routines, isLoading: false, isLoaded: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoaded: true, error: e.toString());
    }
  }

  Future<bool> startRoutine({
    required int habitId,
    String? personalNote,
    String goalType = 'days_count',
    int goalTarget = 21,
  }) async {
    try {
      final routine = await _repo.startRoutine(
        habitId: habitId,
        personalNote: personalNote,
        goalType: goalType,
        goalTarget: goalTarget,
      );
      state = state.copyWith(routines: [routine, ...state.routines]);
      return true;
    } catch (e) {
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  void updateRoutineInList(VirtueRoutine updated) {
    final refreshed = state.routines.map((r) => r.id == updated.id ? updated : r).toList();
    state = state.copyWith(routines: refreshed);
  }
}

final virtueHubProvider = NotifierProvider<VirtueHubNotifier, VirtueHubState>(
  VirtueHubNotifier.new,
);

// ─── Routine detail ────────────────────────────────────────────────────────────

final virtueRoutineDetailProvider = FutureProvider.family<VirtueRoutine, int>((ref, routineId) {
  return ref.watch(virtueRepositoryProvider).fetchRoutineProgress(routineId);
});
