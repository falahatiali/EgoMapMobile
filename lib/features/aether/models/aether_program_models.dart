class AetherProgramDetail {
  const AetherProgramDetail({required this.program});

  final AetherProgram program;

  factory AetherProgramDetail.fromJson(Map<String, dynamic> json) {
    return AetherProgramDetail(
      program: AetherProgram.fromJson(json['program'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AetherProgram {
  const AetherProgram({
    required this.uuid,
    required this.version,
    required this.status,
    required this.appliedTarget,
    required this.summary,
    this.split,
    this.adherencePercent,
    this.missionTitle,
    required this.coach,
    required this.workoutDays,
  });

  final String uuid;
  final int version;
  final String status;
  final String appliedTarget;
  final String summary;
  final String? split;
  final int? adherencePercent;
  final String? missionTitle;
  final AetherProgramCoach coach;
  final List<AetherWorkoutDay> workoutDays;

  factory AetherProgram.fromJson(Map<String, dynamic> json) {
    return AetherProgram(
      uuid: json['uuid'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      appliedTarget: json['applied_target'] as String? ?? 'workout',
      summary: json['summary'] as String? ?? '',
      split: json['split'] as String?,
      adherencePercent: json['adherence_percent'] as int?,
      missionTitle: json['mission_title'] as String?,
      coach: AetherProgramCoach.fromJson(json['coach'] as Map<String, dynamic>? ?? {}),
      workoutDays: (json['workout_days'] as List<dynamic>? ?? [])
          .map((e) => AetherWorkoutDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalSets => workoutDays.fold(0, (sum, day) => sum + day.totalSets);

  int get completedSets => workoutDays.fold(0, (sum, day) => sum + day.completedSets);
}

class AetherProgramCoach {
  const AetherProgramCoach({
    this.title,
    this.weekFocus,
    this.mindsetFocus,
    this.habitStack,
    this.recoveryStrategy,
  });

  final String? title;
  final String? weekFocus;
  final String? mindsetFocus;
  final String? habitStack;
  final String? recoveryStrategy;

  factory AetherProgramCoach.fromJson(Map<String, dynamic> json) {
    return AetherProgramCoach(
      title: json['title'] as String?,
      weekFocus: json['week_focus'] as String?,
      mindsetFocus: json['mindset_focus'] as String?,
      habitStack: json['habit_stack'] as String?,
      recoveryStrategy: json['recovery_strategy'] as String?,
    );
  }
}

class AetherWorkoutDay {
  const AetherWorkoutDay({
    required this.id,
    required this.dayIndex,
    required this.label,
    required this.focus,
    required this.exercises,
  });

  final int id;
  final int dayIndex;
  final String label;
  final String focus;
  final List<AetherWorkoutExercise> exercises;

  factory AetherWorkoutDay.fromJson(Map<String, dynamic> json) {
    return AetherWorkoutDay(
      id: json['id'] as int? ?? 0,
      dayIndex: json['day_index'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => AetherWorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalSets => exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);

  int get completedSets => exercises.fold(0, (sum, exercise) => sum + exercise.completedSetCount);

  double get completionRatio => totalSets == 0 ? 0 : completedSets / totalSets;
}

class AetherWorkoutExercise {
  const AetherWorkoutExercise({
    required this.id,
    required this.slug,
    required this.name,
    required this.muscleGroup,
    this.mediaUrl,
    this.notes,
    this.rpe,
    this.tempo,
    this.defaultWeightKg,
    required this.sets,
  });

  final int id;
  final String slug;
  final String name;
  final String muscleGroup;
  final String? mediaUrl;
  final String? notes;
  final String? rpe;
  final String? tempo;
  final double? defaultWeightKg;
  final List<AetherWorkoutSet> sets;

  factory AetherWorkoutExercise.fromJson(Map<String, dynamic> json) {
    return AetherWorkoutExercise(
      id: json['id'] as int? ?? 0,
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscle_group'] as String? ?? '',
      mediaUrl: json['media_url'] as String?,
      notes: json['notes'] as String?,
      rpe: json['rpe'] as String?,
      tempo: json['tempo'] as String?,
      defaultWeightKg: (json['default_weight_kg'] as num?)?.toDouble(),
      sets: (json['sets'] as List<dynamic>? ?? [])
          .map((e) => AetherWorkoutSet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get completedSetCount => sets.where((set) => set.completed).length;

  String get muscleGroupLabel {
    return muscleGroup
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class AetherWorkoutSet {
  const AetherWorkoutSet({
    required this.id,
    required this.setNumber,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.restSeconds,
    required this.completed,
    this.weightKg,
    this.suggestedWeightKg,
  });

  final int id;
  final int setNumber;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int? restSeconds;
  final bool completed;

  /// Weight the user logged for this set in kg (null = not yet logged).
  final double? weightKg;

  /// Suggested weight for this set — computed server-side from previous logs
  /// with +2.5 kg progressive overload. Null when no prior data exists.
  final double? suggestedWeightKg;

  factory AetherWorkoutSet.fromJson(Map<String, dynamic> json) {
    return AetherWorkoutSet(
      id: json['id'] as int? ?? 0,
      setNumber: json['set_number'] as int? ?? 0,
      targetRepsMin: json['target_reps_min'] as int?,
      targetRepsMax: json['target_reps_max'] as int?,
      restSeconds: json['rest_seconds'] as int?,
      completed: json['completed'] as bool? ?? false,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      suggestedWeightKg: (json['suggested_weight_kg'] as num?)?.toDouble(),
    );
  }

  String get repsLabel {
    if (targetRepsMin != null && targetRepsMax != null && targetRepsMin != targetRepsMax) {
      return '$targetRepsMin–$targetRepsMax reps';
    }

    if (targetRepsMin != null) {
      return '$targetRepsMin reps';
    }

    return 'AMRAP';
  }

  /// Format weight for display: "52.5 kg" or "52 kg" (drop .0 when whole).
  String? get weightLabel {
    if (weightKg == null) {
      return null;
    }
    final formatted = weightKg! % 1 == 0
        ? weightKg!.toInt().toString()
        : weightKg!.toStringAsFixed(1);
    return '$formatted kg';
  }

  /// Format suggested weight for display.
  String? get suggestedWeightLabel {
    if (suggestedWeightKg == null) {
      return null;
    }
    final formatted = suggestedWeightKg! % 1 == 0
        ? suggestedWeightKg!.toInt().toString()
        : suggestedWeightKg!.toStringAsFixed(1);
    return '$formatted kg';
  }
}

class AetherSetToggleResult {
  const AetherSetToggleResult({
    required this.completed,
    required this.adherencePercent,
  });

  final bool completed;
  final int adherencePercent;

  factory AetherSetToggleResult.fromJson(Map<String, dynamic> json) {
    final setLog = json['set_log'] as Map<String, dynamic>? ?? {};

    return AetherSetToggleResult(
      completed: setLog['completed'] as bool? ?? false,
      adherencePercent: json['adherence_percent'] as int? ?? 0,
    );
  }
}
