// Data models for the weekly check-in (re-calibration) feature.

class AetherCheckInStatus {
  const AetherCheckInStatus({
    required this.isDue,
    required this.currentWeek,
    this.lastCheckInDate,
  });

  /// Whether the user owes a check-in for the just-completed week.
  final bool isDue;

  /// Current program week (1-based).
  final int currentWeek;

  /// Date of the most recent check-in, or null if none yet.
  final String? lastCheckInDate;

  factory AetherCheckInStatus.fromJson(Map<String, dynamic> json) {
    return AetherCheckInStatus(
      isDue: json['is_due'] as bool? ?? false,
      currentWeek: json['current_week'] as int? ?? 1,
      lastCheckInDate: json['last_check_in_date'] as String?,
    );
  }
}

class AetherCheckInPayload {
  const AetherCheckInPayload({
    required this.sessionsCompleted,
    required this.intensityRating,
    required this.hadPain,
    this.painNotes,
  });

  /// Number of sessions completed this week (0–7).
  final int sessionsCompleted;

  /// 1 = too easy, 2 = just right, 3 = too hard.
  final int intensityRating;

  final bool hadPain;
  final String? painNotes;

  Map<String, dynamic> toJson() => {
        'sessions_completed': sessionsCompleted,
        'intensity_rating': intensityRating,
        'had_pain': hadPain,
        'pain_notes': painNotes,
      };
}

class AetherCheckInResult {
  const AetherCheckInResult({
    required this.coachingMessage,
    this.adjustmentHint,
    required this.workoutAdherencePercent,
  });

  final String coachingMessage;
  final String? adjustmentHint;
  final int workoutAdherencePercent;

  factory AetherCheckInResult.fromJson(Map<String, dynamic> json) {
    final checkIn = json['check_in'] as Map<String, dynamic>? ?? {};
    final coaching = json['coaching'] as Map<String, dynamic>? ?? {};

    return AetherCheckInResult(
      coachingMessage: coaching['message'] as String? ?? '',
      adjustmentHint: coaching['adjustment_hint'] as String?,
      workoutAdherencePercent: checkIn['workout_adherence_percent'] as int? ?? 0,
    );
  }
}
