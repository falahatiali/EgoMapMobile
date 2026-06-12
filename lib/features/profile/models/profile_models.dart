class ProfilePalette {
  const ProfilePalette({
    required this.accent,
    required this.soft,
    required this.glow,
    required this.group,
  });

  final String accent;
  final String soft;
  final String glow;
  final String group;

  factory ProfilePalette.fromJson(Map<String, dynamic> json) {
    return ProfilePalette(
      accent: json['accent'] as String? ?? '#6EE7B7',
      soft: json['soft'] as String? ?? '#064E3B',
      glow: json['glow'] as String? ?? '#34D399',
      group: json['group'] as String? ?? 'emerald',
    );
  }
}

class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.emailVerified,
    this.memberSinceLabel,
  });

  final int id;
  final String uuid;
  final String name;
  final String email;
  final bool emailVerified;
  final String? memberSinceLabel;

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: (json['id'] as num).toInt(),
      uuid: json['uuid'] as String,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : json['email'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool? ?? false,
      memberSinceLabel: json['member_since_label'] as String?,
    );
  }
}

class ProfileStats {
  const ProfileStats({
    required this.total,
    required this.inProgress,
    required this.completed,
  });

  final int total;
  final int inProgress;
  final int completed;

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      total: json['total'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
    );
  }
}

class ProfileLabels {
  const ProfileLabels({
    required this.pageTitle,
    required this.member,
    required this.verified,
    required this.myTestsTitle,
    required this.myTestsSubtitle,
    required this.takeNewTest,
    required this.filterAll,
    required this.filterInProgress,
    required this.filterCompleted,
    required this.noTestsTitle,
    required this.noTestsBody,
  });

  final String pageTitle;
  final String member;
  final String verified;
  final String myTestsTitle;
  final String myTestsSubtitle;
  final String takeNewTest;
  final String filterAll;
  final String filterInProgress;
  final String filterCompleted;
  final String noTestsTitle;
  final String noTestsBody;

  factory ProfileLabels.fromJson(Map<String, dynamic> json) {
    return ProfileLabels(
      pageTitle: json['page_title'] as String? ?? 'Your profile',
      member: json['member'] as String? ?? 'Member',
      verified: json['verified'] as String? ?? 'Email verified',
      myTestsTitle: json['my_tests_title'] as String? ?? 'My tests',
      myTestsSubtitle: json['my_tests_subtitle'] as String? ?? '',
      takeNewTest: json['take_new_test'] as String? ?? 'Take a new test',
      filterAll: json['filter_all'] as String? ?? 'All',
      filterInProgress: json['filter_in_progress'] as String? ?? 'In progress',
      filterCompleted: json['filter_completed'] as String? ?? 'Completed',
      noTestsTitle: json['no_tests_title'] as String? ?? 'No tests yet',
      noTestsBody: json['no_tests_body'] as String? ?? '',
    );
  }
}

class ProfileTestRecord {
  const ProfileTestRecord({
    required this.sessionUuid,
    required this.quizName,
    required this.quizSlug,
    required this.palette,
    required this.isRebootProtocol,
    required this.isInProgress,
    required this.progressPercent,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.statusLabel,
    this.typeCode,
    this.typeLabel,
    this.resultTitle,
    this.tagline,
    this.completedAtLabel,
    this.startedAtLabel,
  });

  final String sessionUuid;
  final String quizName;
  final String quizSlug;
  final ProfilePalette palette;
  final bool isRebootProtocol;
  final bool isInProgress;
  final int progressPercent;
  final int currentQuestion;
  final int totalQuestions;
  final String statusLabel;
  final String? typeCode;
  final String? typeLabel;
  final String? resultTitle;
  final String? tagline;
  final String? completedAtLabel;
  final String? startedAtLabel;

  factory ProfileTestRecord.fromJson(Map<String, dynamic> json) {
    return ProfileTestRecord(
      sessionUuid: json['session_uuid'] as String,
      quizName: json['quiz_name'] as String,
      quizSlug: json['quiz_slug'] as String,
      palette: ProfilePalette.fromJson(json['palette'] as Map<String, dynamic>),
      isRebootProtocol: json['is_reboot_protocol'] as bool? ?? false,
      isInProgress: json['is_in_progress'] as bool? ?? false,
      progressPercent: json['progress_percent'] as int? ?? 0,
      currentQuestion: json['current_question'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      statusLabel: json['status_label'] as String? ?? '',
      typeCode: json['type_code'] as String?,
      typeLabel: json['type_label'] as String?,
      resultTitle: json['result_title'] as String?,
      tagline: json['tagline'] as String?,
      completedAtLabel: json['completed_at_label'] as String?,
      startedAtLabel: json['started_at_label'] as String?,
    );
  }
}

class ProfilePayload {
  const ProfilePayload({
    required this.user,
    required this.stats,
    required this.testsFilter,
    required this.tests,
    required this.labels,
  });

  final ProfileUser user;
  final ProfileStats stats;
  final String testsFilter;
  final List<ProfileTestRecord> tests;
  final ProfileLabels labels;

  factory ProfilePayload.fromJson(Map<String, dynamic> json) {
    final tests = json['tests'] as List<dynamic>? ?? [];

    return ProfilePayload(
      user: ProfileUser.fromJson(json['user'] as Map<String, dynamic>),
      stats: ProfileStats.fromJson(json['stats'] as Map<String, dynamic>),
      testsFilter: json['tests_filter'] as String? ?? 'all',
      tests: tests
          .whereType<Map<String, dynamic>>()
          .map(ProfileTestRecord.fromJson)
          .toList(),
      labels: ProfileLabels.fromJson(json['labels'] as Map<String, dynamic>),
    );
  }
}

enum ProfileTestsFilter {
  all('all'),
  inProgress('in_progress'),
  completed('completed');

  const ProfileTestsFilter(this.apiValue);

  final String apiValue;
}
