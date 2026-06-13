import 'mission_workspace_models.dart';

class MissionLabels {
  const MissionLabels({
    required this.pageTitle,
    required this.myMissionsTitle,
    required this.myMissionsSubtitle,
    required this.browseMissions,
    required this.noActiveMissions,
    required this.catalogTitle,
    required this.catalogSubtitle,
    required this.featured,
    required this.startMission,
    required this.continueMission,
    required this.includes,
    required this.phases,
    required this.daysPattern,
    required this.ghostHint,
  });

  final String pageTitle;
  final String myMissionsTitle;
  final String myMissionsSubtitle;
  final String browseMissions;
  final String noActiveMissions;
  final String catalogTitle;
  final String catalogSubtitle;
  final String featured;
  final String startMission;
  final String continueMission;
  final String includes;
  final String phases;
  final String daysPattern;
  final String ghostHint;

  factory MissionLabels.fromJson(Map<String, dynamic> json) {
    return MissionLabels(
      pageTitle: json['page_title'] as String? ?? 'Missions',
      myMissionsTitle: json['my_missions_title'] as String? ?? 'My missions',
      myMissionsSubtitle: json['my_missions_subtitle'] as String? ?? '',
      browseMissions: json['browse_missions'] as String? ?? 'Browse missions',
      noActiveMissions: json['no_active_missions'] as String? ?? '',
      catalogTitle: json['catalog_title'] as String? ?? 'Missions',
      catalogSubtitle: json['catalog_subtitle'] as String? ?? '',
      featured: json['featured'] as String? ?? 'Featured',
      startMission: json['start_mission'] as String? ?? 'Start mission',
      continueMission: json['continue_mission'] as String? ?? 'Continue',
      includes: json['includes'] as String? ?? 'Includes',
      phases: json['phases'] as String? ?? 'Phases',
      daysPattern: json['days'] as String? ?? ':count days',
      ghostHint: json['ghost_hint'] as String? ?? '',
    );
  }

  String daysLabel(int count) => daysPattern.replaceAll(':count', '$count');
}

class MissionTemplateCard {
  const MissionTemplateCard({
    required this.slug,
    required this.title,
    required this.summary,
    required this.icon,
    required this.category,
    required this.estimatedDays,
    required this.isFeatured,
    required this.ghostModeRecommended,
    required this.accent,
    required this.hasActiveEnrollment,
    this.enrollmentUuid,
  });

  final String slug;
  final String title;
  final String summary;
  final String icon;
  final String? category;
  final int? estimatedDays;
  final bool isFeatured;
  final bool ghostModeRecommended;
  final String accent;
  final bool hasActiveEnrollment;
  final String? enrollmentUuid;

  factory MissionTemplateCard.fromJson(Map<String, dynamic> json) {
    return MissionTemplateCard(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      icon: json['icon'] as String? ?? 'fa-flag',
      category: json['category'] as String?,
      estimatedDays: json['estimated_days'] as int?,
      isFeatured: json['is_featured'] as bool? ?? false,
      ghostModeRecommended: json['ghost_mode_recommended'] as bool? ?? false,
      accent: json['accent'] as String? ?? 'emerald',
      hasActiveEnrollment: json['has_active_enrollment'] as bool? ?? false,
      enrollmentUuid: json['enrollment_uuid'] as String?,
    );
  }
}

class MissionPhase {
  const MissionPhase({
    required this.slug,
    required this.title,
    required this.durationDays,
  });

  final String slug;
  final String title;
  final int? durationDays;

  factory MissionPhase.fromJson(Map<String, dynamic> json) {
    return MissionPhase(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      durationDays: json['duration_days'] as int?,
    );
  }
}

class MissionCapability {
  const MissionCapability({
    required this.key,
    required this.name,
    required this.icon,
  });

  final String key;
  final String name;
  final String icon;

  factory MissionCapability.fromJson(Map<String, dynamic> json) {
    return MissionCapability(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? 'fa-circle',
    );
  }
}

class MissionEnrollmentSummary {
  const MissionEnrollmentSummary({
    required this.uuid,
    required this.status,
    required this.title,
    required this.templateSlug,
    required this.icon,
    required this.progressPercent,
    this.startedAt,
    this.lastActivityAt,
    this.currentPhaseTitle,
    this.estimatedDays,
  });

  final String uuid;
  final String status;
  final String title;
  final String? templateSlug;
  final String icon;
  final double progressPercent;
  final String? startedAt;
  final String? lastActivityAt;
  final String? currentPhaseTitle;
  final int? estimatedDays;

  factory MissionEnrollmentSummary.fromJson(Map<String, dynamic> json) {
    return MissionEnrollmentSummary(
      uuid: json['uuid'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      title: json['title'] as String? ?? '',
      templateSlug: json['template_slug'] as String?,
      icon: json['icon'] as String? ?? 'fa-dumbbell',
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      startedAt: json['started_at'] as String?,
      lastActivityAt: json['last_activity_at'] as String?,
      currentPhaseTitle: json['current_phase_title'] as String?,
      estimatedDays: json['estimated_days'] as int?,
    );
  }
}

class MissionTemplateDetail extends MissionTemplateCard {
  const MissionTemplateDetail({
    required super.slug,
    required super.title,
    required super.summary,
    required super.icon,
    required super.category,
    required super.estimatedDays,
    required super.isFeatured,
    required super.ghostModeRecommended,
    required super.accent,
    required super.hasActiveEnrollment,
    super.enrollmentUuid,
    required this.description,
    required this.phases,
    required this.capabilities,
    this.enrollment,
  });

  final String description;
  final List<MissionPhase> phases;
  final List<MissionCapability> capabilities;
  final MissionEnrollmentSummary? enrollment;

  factory MissionTemplateDetail.fromJson(Map<String, dynamic> json) {
    return MissionTemplateDetail(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      icon: json['icon'] as String? ?? 'fa-flag',
      category: json['category'] as String?,
      estimatedDays: json['estimated_days'] as int?,
      isFeatured: json['is_featured'] as bool? ?? false,
      ghostModeRecommended: json['ghost_mode_recommended'] as bool? ?? false,
      accent: json['accent'] as String? ?? 'emerald',
      hasActiveEnrollment: json['has_active_enrollment'] as bool? ?? false,
      enrollmentUuid: json['enrollment_uuid'] as String?,
      description: json['description'] as String? ?? '',
      phases: (json['phases'] as List<dynamic>? ?? [])
          .map((e) => MissionPhase.fromJson(e as Map<String, dynamic>))
          .toList(),
      capabilities: (json['capabilities'] as List<dynamic>? ?? [])
          .map((e) => MissionCapability.fromJson(e as Map<String, dynamic>))
          .toList(),
      enrollment: json['enrollment'] is Map<String, dynamic>
          ? MissionEnrollmentSummary.fromJson(json['enrollment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MissionHubState {
  const MissionHubState({
    required this.labels,
    required this.templates,
    required this.activeEnrollments,
  });

  final MissionLabels labels;
  final List<MissionTemplateCard> templates;
  final List<MissionEnrollmentSummary> activeEnrollments;

  factory MissionHubState.fromJson(Map<String, dynamic> json) {
    return MissionHubState(
      labels: MissionLabels.fromJson(json['labels'] as Map<String, dynamic>? ?? {}),
      templates: (json['templates'] as List<dynamic>? ?? [])
          .map((e) => MissionTemplateCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeEnrollments: (json['active_enrollments'] as List<dynamic>? ?? [])
          .map((e) => MissionEnrollmentSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MissionEnrollResult {
  const MissionEnrollResult({
    required this.enrollment,
    required this.workspace,
  });

  final MissionEnrollmentSummary enrollment;
  final MissionWorkspaceResponse workspace;

  factory MissionEnrollResult.fromJson(Map<String, dynamic> json) {
    return MissionEnrollResult(
      enrollment: MissionEnrollmentSummary.fromJson(json['enrollment'] as Map<String, dynamic>),
      workspace: MissionWorkspaceResponse.fromJson(json['workspace'] as Map<String, dynamic>),
    );
  }
}

class MissionTemplateDetailResponse {
  const MissionTemplateDetailResponse({
    required this.labels,
    required this.template,
  });

  final MissionLabels labels;
  final MissionTemplateDetail template;

  factory MissionTemplateDetailResponse.fromJson(Map<String, dynamic> json) {
    return MissionTemplateDetailResponse(
      labels: MissionLabels.fromJson(json['labels'] as Map<String, dynamic>? ?? {}),
      template: MissionTemplateDetail.fromJson(json['template'] as Map<String, dynamic>),
    );
  }
}
