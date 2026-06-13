/// API Contract v1 — GET /missions/enrollments/{uuid}
/// Manual parsing (matches project convention; no code generation).

enum WorkspaceMode {
  locked,
  calibrating,
  active;

  static WorkspaceMode fromApi(String? value) {
    return WorkspaceMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => WorkspaceMode.locked,
    );
  }
}

enum AetherEngineStatus {
  notApplicable,
  locked,
  calibrating,
  active,
  proRequired;

  static AetherEngineStatus fromApi(String? value) {
    return switch (value) {
      'locked' => AetherEngineStatus.locked,
      'calibrating' => AetherEngineStatus.calibrating,
      'active' => AetherEngineStatus.active,
      'pro_required' => AetherEngineStatus.proRequired,
      'not_applicable' => AetherEngineStatus.notApplicable,
      _ => AetherEngineStatus.notApplicable,
    };
  }
}

enum MissionToolStatus {
  locked,
  active,
  comingSoon;

  static MissionToolStatus fromApi(String? value) {
    return switch (value) {
      'active' => MissionToolStatus.active,
      'coming_soon' => MissionToolStatus.comingSoon,
      _ => MissionToolStatus.locked,
    };
  }
}

class MissionWorkspaceResponse {
  const MissionWorkspaceResponse({
    required this.meta,
    required this.labels,
    required this.mission,
    required this.enrollment,
    required this.engines,
    required this.workspace,
    required this.tools,
    this.activation,
    this.reveal,
  });

  final WorkspaceMeta meta;
  final WorkspaceLabels labels;
  final WorkspaceMission mission;
  final WorkspaceEnrollment enrollment;
  final AetherEngines engines;
  final WorkspaceUi workspace;
  final List<MissionTool> tools;
  final WorkspaceActivation? activation;
  final WorkspaceReveal? reveal;

  bool get isActive => workspace.mode == WorkspaceMode.active;

  bool get needsCalibration {
    final aether = engines.aether;
    if (aether == null) {
      return false;
    }

    return aether.status == AetherEngineStatus.locked;
  }

  bool get needsPro {
    final aether = engines.aether;
    return aether?.status == AetherEngineStatus.proRequired;
  }

  factory MissionWorkspaceResponse.fromJson(Map<String, dynamic> json) {
    final mission = WorkspaceMission.fromJson(json['mission'] as Map<String, dynamic>? ?? {});

    return MissionWorkspaceResponse(
      meta: WorkspaceMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
      labels: WorkspaceLabels.fromJson(json['labels'] as Map<String, dynamic>? ?? {}),
      mission: mission,
      enrollment: WorkspaceEnrollment.fromJson(
        json['enrollment'] as Map<String, dynamic>? ?? {},
        mission: mission,
      ),
      engines: AetherEngines.fromJson(json['engines'] as Map<String, dynamic>? ?? {}),
      workspace: WorkspaceUi.fromJson(json['workspace'] as Map<String, dynamic>? ?? {}),
      tools: (json['tools'] as List<dynamic>? ?? [])
          .map((e) => MissionTool.fromJson(e as Map<String, dynamic>))
          .toList(),
      activation: json['activation'] is Map<String, dynamic>
          ? WorkspaceActivation.fromJson(json['activation'] as Map<String, dynamic>)
          : null,
      reveal: json['reveal'] is Map<String, dynamic>
          ? WorkspaceReveal.fromJson(json['reveal'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WorkspaceMeta {
  const WorkspaceMeta({required this.apiVersion, this.generatedAt});

  final String apiVersion;
  final String? generatedAt;

  factory WorkspaceMeta.fromJson(Map<String, dynamic> json) {
    return WorkspaceMeta(
      apiVersion: json['api_version'] as String? ?? '',
      generatedAt: json['generated_at'] as String?,
    );
  }
}

class WorkspaceLabels {
  const WorkspaceLabels({
    required this.workspaceTitle,
    required this.workspaceSubtitle,
    required this.activateMission,
    required this.calibrationCta,
    required this.continueCalibration,
    required this.lockedReasonAether,
    required this.lockedReasonPro,
  });

  final String workspaceTitle;
  final String workspaceSubtitle;
  final String activateMission;
  final String calibrationCta;
  final String continueCalibration;
  final String lockedReasonAether;
  final String lockedReasonPro;

  factory WorkspaceLabels.fromJson(Map<String, dynamic> json) {
    return WorkspaceLabels(
      workspaceTitle: json['workspace_title'] as String? ?? 'Your mission',
      workspaceSubtitle: json['workspace_subtitle'] as String? ?? '',
      activateMission: json['activate_mission'] as String? ?? 'Activate mission',
      calibrationCta: json['calibration_cta'] as String? ?? 'Calibrate AetherEngine',
      continueCalibration: json['continue_calibration'] as String? ?? 'Continue calibration',
      lockedReasonAether: json['locked_reason_aether'] as String? ?? '',
      lockedReasonPro: json['locked_reason_pro'] as String? ?? '',
    );
  }
}

class WorkspaceMission {
  const WorkspaceMission({
    required this.slug,
    required this.title,
    required this.icon,
    required this.accent,
    this.engineModule,
    this.currentPhase,
  });

  final String slug;
  final String title;
  final String icon;
  final String accent;
  final String? engineModule;
  final WorkspacePhase? currentPhase;

  factory WorkspaceMission.fromJson(Map<String, dynamic> json) {
    return WorkspaceMission(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? 'fa-flag',
      accent: json['accent'] as String? ?? 'emerald',
      engineModule: json['engine_module'] as String?,
      currentPhase: json['current_phase'] is Map<String, dynamic>
          ? WorkspacePhase.fromJson(json['current_phase'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WorkspacePhase {
  const WorkspacePhase({required this.slug, required this.title});

  final String slug;
  final String title;

  factory WorkspacePhase.fromJson(Map<String, dynamic> json) {
    return WorkspacePhase(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}

class WorkspaceEnrollment {
  const WorkspaceEnrollment({
    required this.uuid,
    required this.status,
    required this.progressPercent,
    required this.title,
    required this.icon,
    this.startedAt,
    this.lastActivityAt,
  });

  final String uuid;
  final String status;
  final double progressPercent;
  final String title;
  final String icon;
  final String? startedAt;
  final String? lastActivityAt;

  factory WorkspaceEnrollment.fromJson(
    Map<String, dynamic> json, {
    required WorkspaceMission mission,
  }) {
    return WorkspaceEnrollment(
      uuid: json['uuid'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      title: mission.title,
      icon: mission.icon,
      startedAt: json['started_at'] as String?,
      lastActivityAt: json['last_activity_at'] as String?,
    );
  }
}

class AetherEngines {
  const AetherEngines({this.aether});

  final AetherEngineState? aether;

  factory AetherEngines.fromJson(Map<String, dynamic> json) {
    return AetherEngines(
      aether: json['aether'] is Map<String, dynamic>
          ? AetherEngineState.fromJson(json['aether'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AetherEngineState {
  const AetherEngineState({
    required this.status,
    required this.calibration,
    required this.access,
    required this.programs,
  });

  final AetherEngineStatus status;
  final AetherCalibration calibration;
  final AetherAccess access;
  final AetherPrograms programs;

  factory AetherEngineState.fromJson(Map<String, dynamic> json) {
    return AetherEngineState(
      status: AetherEngineStatus.fromApi(json['status'] as String?),
      calibration: AetherCalibration.fromJson(json['calibration'] as Map<String, dynamic>? ?? {}),
      access: AetherAccess.fromJson(json['access'] as Map<String, dynamic>? ?? {}),
      programs: AetherPrograms.fromJson(json['programs'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class AetherCalibration {
  const AetherCalibration({
    required this.isComplete,
    required this.progressPercent,
    required this.totalSteps,
    required this.canResume,
    this.defaultsApi,
    this.completeApi,
    this.regenerateApi,
  });

  final bool isComplete;
  final int progressPercent;
  final int totalSteps;
  final bool canResume;
  final String? defaultsApi;
  final String? completeApi;
  final String? regenerateApi;

  factory AetherCalibration.fromJson(Map<String, dynamic> json) {
    return AetherCalibration(
      isComplete: json['is_complete'] as bool? ?? false,
      progressPercent: json['progress_percent'] as int? ?? 0,
      totalSteps: json['total_steps'] as int? ?? 8,
      canResume: json['can_resume'] as bool? ?? false,
      defaultsApi: json['defaults_api'] as String?,
      completeApi: json['complete_api'] as String?,
      regenerateApi: json['regenerate_api'] as String?,
    );
  }
}

class AetherAccess {
  const AetherAccess({
    required this.canCalibrate,
    required this.userHasPro,
    required this.canGenerateWorkout,
    required this.canGenerateMeal,
  });

  final bool canCalibrate;
  final bool userHasPro;
  final bool canGenerateWorkout;
  final bool canGenerateMeal;

  factory AetherAccess.fromJson(Map<String, dynamic> json) {
    return AetherAccess(
      canCalibrate: json['can_calibrate'] as bool? ?? false,
      userHasPro: json['user_has_pro'] as bool? ?? false,
      canGenerateWorkout: json['can_generate_workout'] as bool? ?? false,
      canGenerateMeal: json['can_generate_meal'] as bool? ?? false,
    );
  }
}

class AetherPrograms {
  const AetherPrograms({this.workout, this.meal});

  final LinkedAetherProgram? workout;
  final LinkedAetherProgram? meal;

  factory AetherPrograms.fromJson(Map<String, dynamic> json) {
    return AetherPrograms(
      workout: json['workout'] is Map<String, dynamic>
          ? LinkedAetherProgram.fromJson(json['workout'] as Map<String, dynamic>)
          : null,
      meal: json['meal'] is Map<String, dynamic>
          ? LinkedAetherProgram.fromJson(json['meal'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LinkedAetherProgram {
  const LinkedAetherProgram({
    required this.uuid,
    required this.summary,
    required this.apiUrl,
    this.adherencePercent,
  });

  final String uuid;
  final String summary;
  final String apiUrl;
  final int? adherencePercent;

  factory LinkedAetherProgram.fromJson(Map<String, dynamic> json) {
    return LinkedAetherProgram(
      uuid: json['uuid'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      apiUrl: json['api_url'] as String? ?? '',
      adherencePercent: json['adherence_percent'] as int?,
    );
  }
}

class WorkspaceUi {
  const WorkspaceUi({
    required this.mode,
    required this.primaryCta,
    required this.hero,
  });

  final WorkspaceMode mode;
  final WorkspacePrimaryCta primaryCta;
  final WorkspaceHero hero;

  factory WorkspaceUi.fromJson(Map<String, dynamic> json) {
    return WorkspaceUi(
      mode: WorkspaceMode.fromApi(json['mode'] as String?),
      primaryCta: WorkspacePrimaryCta.fromJson(json['primary_cta'] as Map<String, dynamic>? ?? {}),
      hero: WorkspaceHero.fromJson(json['hero'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class WorkspacePrimaryCta {
  const WorkspacePrimaryCta({
    required this.action,
    required this.label,
    this.toolKey,
    this.engineModule,
    this.programUuid,
  });

  final String action;
  final String label;
  final String? toolKey;
  final String? engineModule;
  final String? programUuid;

  factory WorkspacePrimaryCta.fromJson(Map<String, dynamic> json) {
    return WorkspacePrimaryCta(
      action: json['action'] as String? ?? '',
      label: json['label'] as String? ?? '',
      toolKey: json['tool_key'] as String?,
      engineModule: json['engine_module'] as String?,
      programUuid: json['program_uuid'] as String?,
    );
  }
}

class WorkspaceHero {
  const WorkspaceHero({
    required this.headline,
    required this.subheadline,
    required this.progressLabel,
  });

  final String headline;
  final String subheadline;
  final String progressLabel;

  factory WorkspaceHero.fromJson(Map<String, dynamic> json) {
    return WorkspaceHero(
      headline: json['headline'] as String? ?? '',
      subheadline: json['subheadline'] as String? ?? '',
      progressLabel: json['progress_label'] as String? ?? '',
    );
  }
}

class MissionTool {
  const MissionTool({
    required this.key,
    required this.label,
    required this.icon,
    required this.status,
    this.lock,
    this.snippet,
    this.insight,
    this.deepLink,
  });

  final String key;
  final String label;
  final String icon;
  final MissionToolStatus status;
  final MissionToolLock? lock;
  final MissionToolSnippet? snippet;
  final MissionToolInsight? insight;
  final MissionToolDeepLink? deepLink;

  bool get isLocked => status == MissionToolStatus.locked;

  factory MissionTool.fromJson(Map<String, dynamic> json) {
    return MissionTool(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String? ?? 'fa-circle',
      status: MissionToolStatus.fromApi(json['status'] as String?),
      lock: json['lock'] is Map<String, dynamic>
          ? MissionToolLock.fromJson(json['lock'] as Map<String, dynamic>)
          : null,
      snippet: json['snippet'] is Map<String, dynamic>
          ? MissionToolSnippet.fromJson(json['snippet'] as Map<String, dynamic>)
          : null,
      insight: json['insight'] is Map<String, dynamic>
          ? MissionToolInsight.fromJson(json['insight'] as Map<String, dynamic>)
          : null,
      deepLink: json['deep_link'] is Map<String, dynamic>
          ? MissionToolDeepLink.fromJson(json['deep_link'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MissionToolLock {
  const MissionToolLock({
    required this.reason,
    required this.message,
    required this.action,
  });

  final String reason;
  final String message;
  final String action;

  factory MissionToolLock.fromJson(Map<String, dynamic> json) {
    return MissionToolLock(
      reason: json['reason'] as String? ?? '',
      message: json['message'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }
}

class MissionToolSnippet {
  const MissionToolSnippet({
    required this.type,
    required this.headline,
    required this.detail,
    this.metric,
  });

  final String type;
  final String headline;
  final String detail;
  final MissionToolMetric? metric;

  factory MissionToolSnippet.fromJson(Map<String, dynamic> json) {
    return MissionToolSnippet(
      type: json['type'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
      metric: json['metric'] is Map<String, dynamic>
          ? MissionToolMetric.fromJson(json['metric'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MissionToolMetric {
  const MissionToolMetric({required this.label, required this.value});

  final String label;
  final String value;

  factory MissionToolMetric.fromJson(Map<String, dynamic> json) {
    return MissionToolMetric(
      label: json['label'] as String? ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class MissionToolInsight {
  const MissionToolInsight({required this.source, required this.text});

  final String source;
  final String text;

  factory MissionToolInsight.fromJson(Map<String, dynamic> json) {
    return MissionToolInsight(
      source: json['source'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class MissionToolDeepLink {
  const MissionToolDeepLink({
    required this.type,
    this.toolKey,
    this.programUuid,
    this.apiUrl,
  });

  final String type;
  final String? toolKey;
  final String? programUuid;
  final String? apiUrl;

  factory MissionToolDeepLink.fromJson(Map<String, dynamic> json) {
    return MissionToolDeepLink(
      type: json['type'] as String? ?? '',
      toolKey: json['tool_key'] as String?,
      programUuid: json['program_uuid'] as String?,
      apiUrl: json['api_url'] as String?,
    );
  }
}

class WorkspaceActivation {
  const WorkspaceActivation({required this.status, required this.focusToolKey});

  final String status;
  final String focusToolKey;

  factory WorkspaceActivation.fromJson(Map<String, dynamic> json) {
    return WorkspaceActivation(
      status: json['status'] as String? ?? '',
      focusToolKey: json['focus_tool_key'] as String? ?? '',
    );
  }
}

class WorkspaceReveal {
  const WorkspaceReveal({
    required this.headline,
    required this.subheadline,
    required this.primaryCta,
  });

  final String headline;
  final String subheadline;
  final WorkspacePrimaryCta primaryCta;

  factory WorkspaceReveal.fromJson(Map<String, dynamic> json) {
    return WorkspaceReveal(
      headline: json['headline'] as String? ?? '',
      subheadline: json['subheadline'] as String? ?? '',
      primaryCta: WorkspacePrimaryCta.fromJson(json['primary_cta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class CalibrationDefaults {
  const CalibrationDefaults({
    required this.wizard,
    required this.profileComplete,
    required this.alreadyCalibrated,
  });

  final Map<String, dynamic> wizard;
  final bool profileComplete;
  final bool alreadyCalibrated;

  factory CalibrationDefaults.fromJson(Map<String, dynamic> json) {
    return CalibrationDefaults(
      wizard: Map<String, dynamic>.from(json['wizard'] as Map? ?? {}),
      profileComplete: json['profile_complete'] as bool? ?? false,
      alreadyCalibrated: json['already_calibrated'] as bool? ?? false,
    );
  }
}
