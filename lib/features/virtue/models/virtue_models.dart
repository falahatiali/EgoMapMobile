class VirtueHabit {
  const VirtueHabit({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.categoryLabel,
    required this.categoryIcon,
    this.description,
    this.aiRootCause,
    this.aiSteps = const [],
    this.aiAffirmation,
    this.isPredefined = true,
  });

  final int id;
  final String slug;
  final String name;
  final String category;
  final String categoryLabel;
  final String categoryIcon;
  final String? description;
  final String? aiRootCause;
  final List<VirtueHabitStep> aiSteps;
  final String? aiAffirmation;
  final bool isPredefined;

  factory VirtueHabit.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['ai_steps'] as List<dynamic>? ?? [];
    return VirtueHabit(
      id: json['id'] as int,
      slug: json['slug'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      categoryLabel: json['category_label'] as String? ?? '',
      categoryIcon: json['category_icon'] as String? ?? '✨',
      description: json['description'] as String?,
      aiRootCause: json['ai_root_cause'] as String?,
      aiSteps: rawSteps.map((s) => VirtueHabitStep.fromJson(s as Map<String, dynamic>)).toList(),
      aiAffirmation: json['ai_affirmation'] as String?,
      isPredefined: (json['is_predefined'] as bool?) ?? true,
    );
  }
}

class VirtueHabitStep {
  const VirtueHabitStep({
    required this.order,
    required this.action,
    required this.dailyPractice,
  });

  final int order;
  final String action;
  final String dailyPractice;

  factory VirtueHabitStep.fromJson(Map<String, dynamic> json) => VirtueHabitStep(
        order: json['order'] as int? ?? 0,
        action: json['action'] as String? ?? '',
        dailyPractice: json['daily_practice'] as String? ?? '',
      );
}

class VirtueRoutine {
  const VirtueRoutine({
    required this.id,
    required this.uuid,
    required this.status,
    required this.goalType,
    required this.goalTarget,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSuccesses,
    required this.totalSlips,
    required this.progressPercent,
    required this.createdAt,
    this.habit,
    this.personalNote,
    this.lastSuccessDate,
    this.completedAt,
    this.recentSuccesses = const [],
  });

  final int id;
  final String uuid;
  final String status;
  final String goalType;
  final int goalTarget;
  final int currentStreak;
  final int bestStreak;
  final int totalSuccesses;
  final int totalSlips;
  final double progressPercent;
  final String createdAt;
  final VirtueHabit? habit;
  final String? personalNote;
  final String? lastSuccessDate;
  final String? completedAt;
  final List<VirtueSuccessLog> recentSuccesses;

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  factory VirtueRoutine.fromJson(Map<String, dynamic> json) {
    final habitJson = json['habit'] as Map<String, dynamic>?;
    final successList = json['recent_successes'] as List<dynamic>? ?? [];
    return VirtueRoutine(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      status: json['status'] as String,
      goalType: json['goal_type'] as String,
      goalTarget: json['goal_target'] as int,
      currentStreak: json['current_streak'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      totalSuccesses: json['total_successes'] as int? ?? 0,
      totalSlips: json['total_slips'] as int? ?? 0,
      progressPercent: (json['progress_percent'] as num? ?? 0).toDouble(),
      createdAt: json['created_at'] as String,
      habit: habitJson != null ? VirtueHabit.fromJson(habitJson) : null,
      personalNote: json['personal_note'] as String?,
      lastSuccessDate: json['last_success_date'] as String?,
      completedAt: json['completed_at'] as String?,
      recentSuccesses:
          successList.map((s) => VirtueSuccessLog.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class VirtueSuccessLog {
  const VirtueSuccessLog({
    required this.id,
    required this.pointsEarned,
    required this.loggedAt,
    this.situation,
    this.emotionalState,
    this.aiEncouragement,
  });

  final int id;
  final int pointsEarned;
  final String loggedAt;
  final String? situation;
  final String? emotionalState;
  final String? aiEncouragement;

  factory VirtueSuccessLog.fromJson(Map<String, dynamic> json) => VirtueSuccessLog(
        id: json['id'] as int,
        pointsEarned: json['points_earned'] as int? ?? 5,
        loggedAt: json['logged_at'] as String,
        situation: json['situation'] as String?,
        emotionalState: json['emotional_state'] as String?,
        aiEncouragement: json['ai_encouragement'] as String?,
      );
}

class VirtueSlipResult {
  const VirtueSlipResult({
    required this.routine,
    required this.aiResponse,
    required this.punishmentSuggestions,
  });

  final VirtueRoutine routine;
  final VirtueAiSlipResponse? aiResponse;
  final List<Map<String, dynamic>> punishmentSuggestions;

  factory VirtueSlipResult.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_response'] as Map<String, dynamic>?;
    final suggestions = (json['punishment_suggestions'] as List<dynamic>? ?? [])
        .map((s) => Map<String, dynamic>.from(s as Map))
        .toList();
    return VirtueSlipResult(
      routine: VirtueRoutine.fromJson(json['routine'] as Map<String, dynamic>),
      aiResponse: aiJson != null ? VirtueAiSlipResponse.fromJson(aiJson) : null,
      punishmentSuggestions: suggestions,
    );
  }
}

class VirtueAiSlipResponse {
  const VirtueAiSlipResponse({
    required this.acknowledgement,
    required this.microTask,
    required this.motivationClose,
    required this.pointsDeductedMessage,
  });

  final String acknowledgement;
  final String microTask;
  final String motivationClose;
  final String pointsDeductedMessage;

  factory VirtueAiSlipResponse.fromJson(Map<String, dynamic> json) => VirtueAiSlipResponse(
        acknowledgement: json['acknowledgement'] as String? ?? '',
        microTask: json['micro_task'] as String? ?? '',
        motivationClose: json['motivation_close'] as String? ?? '',
        pointsDeductedMessage: json['points_deducted_message'] as String? ?? '',
      );
}
