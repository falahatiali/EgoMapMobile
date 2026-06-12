class GhostModePreset {
  const GhostModePreset({
    required this.days,
    required this.label,
    required this.description,
    required this.recommended,
  });

  final int days;
  final String label;
  final String description;
  final bool recommended;

  factory GhostModePreset.fromJson(Map<String, dynamic> json) {
    return GhostModePreset(
      days: json['days'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      recommended: json['recommended'] as bool? ?? false,
    );
  }
}

class GhostModeCopy {
  const GhostModeCopy({
    required this.pageTitle,
    required this.pageSubtitle,
    required this.setupBadge,
    required this.setupTitle,
    required this.setupSubtitle,
    required this.recommended,
    required this.startProtocol,
    required this.statusNotStarted,
    required this.statusActive,
    required this.shieldTitle,
    required this.statElapsed,
    required this.remainingLabel,
    required this.unitDays,
    required this.unitHours,
    required this.unitMinutes,
    required this.unitSeconds,
    required this.completedBadge,
    required this.completedTitle,
    required this.startAgain,
    required this.mobileActiveNote,
    required this.truthTitle,
    required this.truthSubtitle,
    required this.truthNext,
    this.completedSubtitle,
  });

  final String pageTitle;
  final String pageSubtitle;
  final String setupBadge;
  final String setupTitle;
  final String setupSubtitle;
  final String recommended;
  final String startProtocol;
  final String statusNotStarted;
  final String statusActive;
  final String shieldTitle;
  final String statElapsed;
  final String remainingLabel;
  final String unitDays;
  final String unitHours;
  final String unitMinutes;
  final String unitSeconds;
  final String completedBadge;
  final String completedTitle;
  final String startAgain;
  final String mobileActiveNote;
  final String truthTitle;
  final String truthSubtitle;
  final String truthNext;
  final String? completedSubtitle;

  factory GhostModeCopy.fromJson(Map<String, dynamic> json) {
    return GhostModeCopy(
      pageTitle: json['page_title'] as String? ?? 'Ghost Mode',
      pageSubtitle: json['page_subtitle'] as String? ?? '',
      setupBadge: json['setup_badge'] as String? ?? 'Day zero',
      setupTitle: json['setup_title'] as String? ?? 'Activate Ghost Mode',
      setupSubtitle: json['setup_subtitle'] as String? ?? '',
      recommended: json['recommended'] as String? ?? 'Recommended',
      startProtocol: json['start_protocol'] as String? ?? 'Activate Ghost Mode',
      statusNotStarted: json['status_not_started'] as String? ?? 'Not started',
      statusActive: json['status_active'] as String? ?? 'Active',
      shieldTitle: json['shield_title'] as String? ?? 'Integrity Shield',
      statElapsed: json['stat_elapsed'] as String? ?? 'Clean streak',
      remainingLabel: json['remaining_label'] as String? ?? 'Time remaining',
      unitDays: json['unit_days'] as String? ?? 'days',
      unitHours: json['unit_hours'] as String? ?? 'hours',
      unitMinutes: json['unit_minutes'] as String? ?? 'minutes',
      unitSeconds: json['unit_seconds'] as String? ?? 'seconds',
      completedBadge: json['completed_badge'] as String? ?? 'Ghost Mode complete',
      completedTitle: json['completed_title'] as String? ?? 'You held the line',
      startAgain: json['start_again'] as String? ?? 'Activate again',
      mobileActiveNote: json['mobile_active_note'] as String? ?? '',
      truthTitle: json['truth_title'] as String? ?? 'Truth Flashlight',
      truthSubtitle: json['truth_subtitle'] as String? ?? '',
      truthNext: json['truth_next'] as String? ?? 'Next truth',
      completedSubtitle: json['completed_subtitle'] as String?,
    );
  }

  String completedSubtitleFor(int days) {
    return (completedSubtitle ?? ':days days of silence. Start again if you need another season.')
        .replaceAll(':days', '$days');
  }

  String shieldPercentLabel(int percent) {
    return 'Shield $percent%';
  }

  String dayOfLabel(int day, int total) {
    return 'Day $day of $total';
  }
}

class GhostModeWallet {
  const GhostModeWallet({
    required this.points,
    required this.coins,
    required this.streakDays,
    required this.level,
  });

  final int points;
  final int coins;
  final int streakDays;
  final int level;

  factory GhostModeWallet.fromJson(Map<String, dynamic> json) {
    return GhostModeWallet(
      points: json['points'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
    );
  }
}

class GhostModeGamificationToast {
  const GhostModeGamificationToast({
    required this.headline,
    required this.subtitle,
  });

  final String headline;
  final String subtitle;

  factory GhostModeGamificationToast.fromEvent(Map<String, dynamic> json) {
    final toast = json['toast'] as Map<String, dynamic>? ?? {};

    return GhostModeGamificationToast(
      headline: toast['headline'] as String? ?? (json['message'] as String? ?? ''),
      subtitle: toast['subtitle'] as String? ?? '',
    );
  }
}

class GhostModeTimer {
  const GhostModeTimer({
    required this.mode,
    required this.presets,
    required this.recommendedDays,
    this.protocolUuid,
    this.durationDays,
    this.progressPercent,
    this.remainingSeconds,
    this.elapsedSeconds,
    this.elapsedLabel,
    this.streakStartedAt,
    this.targetEndsAt,
    this.serverNow,
    this.slipCount,
  });

  final String mode;
  final List<GhostModePreset> presets;
  final int recommendedDays;
  final String? protocolUuid;
  final int? durationDays;
  final int? progressPercent;
  final int? remainingSeconds;
  final int? elapsedSeconds;
  final String? elapsedLabel;
  final String? streakStartedAt;
  final String? targetEndsAt;
  final String? serverNow;
  final int? slipCount;

  factory GhostModeTimer.fromJson(Map<String, dynamic> json) {
    return GhostModeTimer(
      mode: json['mode'] as String? ?? 'setup',
      presets: (json['presets'] as List<dynamic>? ?? [])
          .map((e) => GhostModePreset.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedDays: json['recommended_days'] as int? ?? 90,
      protocolUuid: json['protocol_uuid'] as String?,
      durationDays: json['duration_days'] as int?,
      progressPercent: json['progress_percent'] as int?,
      remainingSeconds: json['remaining_seconds'] as int?,
      elapsedSeconds: json['elapsed_seconds'] as int?,
      elapsedLabel: json['elapsed_label'] as String?,
      streakStartedAt: json['streak_started_at'] as String?,
      targetEndsAt: json['target_ends_at'] as String?,
      serverNow: json['server_now'] as String?,
      slipCount: json['slip_count'] as int?,
    );
  }

  int get currentDay {
    final elapsed = elapsedSeconds ?? 0;
    final day = (elapsed ~/ 86400) + 1;
    final total = durationDays ?? 1;

    return day.clamp(1, total);
  }
}

class GhostModeState {
  const GhostModeState({
    required this.timer,
    required this.copy,
    required this.isAuthenticated,
    required this.wallet,
    required this.truthFlashes,
    required this.gamificationToasts,
    this.guestToken,
  });

  final GhostModeTimer timer;
  final GhostModeCopy copy;
  final bool isAuthenticated;
  final GhostModeWallet wallet;
  final List<String> truthFlashes;
  final List<GhostModeGamificationToast> gamificationToasts;
  final String? guestToken;

  factory GhostModeState.fromJson(Map<String, dynamic> json) {
    final events = json['gamification_events'] as List<dynamic>? ?? [];

    return GhostModeState(
      timer: GhostModeTimer.fromJson(json['timer'] as Map<String, dynamic>),
      copy: GhostModeCopy.fromJson(json['copy'] as Map<String, dynamic>? ?? {}),
      isAuthenticated: json['is_authenticated'] as bool? ?? false,
      wallet: GhostModeWallet.fromJson(json['wallet'] as Map<String, dynamic>? ?? {}),
      truthFlashes: (json['truth_flashes'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .where((e) => e.isNotEmpty)
          .toList(),
      gamificationToasts: events
          .whereType<Map<String, dynamic>>()
          .map(GhostModeGamificationToast.fromEvent)
          .where((toast) => toast.headline.isNotEmpty)
          .toList(),
      guestToken: json['guest_token'] as String?,
    );
  }
}
