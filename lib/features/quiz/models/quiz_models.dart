class QuizMeta {
  const QuizMeta({
    required this.slug,
    required this.name,
    required this.description,
    required this.estimatedMinutes,
    required this.questionCount,
    required this.welcome,
  });

  final String slug;
  final String name;
  final String description;
  final int estimatedMinutes;
  final int questionCount;
  final QuizWelcome welcome;

  factory QuizMeta.fromJson(Map<String, dynamic> json) {
    return QuizMeta(
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
      questionCount: json['question_count'] as int? ?? 0,
      welcome: QuizWelcome.fromJson(json['welcome'] as Map<String, dynamic>),
    );
  }
}

class QuizWelcome {
  const QuizWelcome({
    required this.title,
    required this.body,
    required this.note,
    required this.beginLabel,
  });

  final String title;
  final String body;
  final String note;
  final String beginLabel;

  factory QuizWelcome.fromJson(Map<String, dynamic> json) {
    return QuizWelcome(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      note: json['note'] as String? ?? '',
      beginLabel: json['begin_label'] as String? ?? 'Begin',
    );
  }
}

class QuizSessionState {
  const QuizSessionState({
    required this.screen,
    required this.session,
    required this.progress,
    this.question,
    this.safety,
    this.crisis,
    this.result,
    this.canGoBack = false,
  });

  final String screen;
  final QuizSessionInfo session;
  final QuizProgress progress;
  final QuizQuestion? question;
  final QuizSafetyPrompt? safety;
  final QuizCrisisPrompt? crisis;
  final QuizResultPayload? result;
  final bool canGoBack;

  factory QuizSessionState.fromJson(Map<String, dynamic> json) {
    return QuizSessionState(
      screen: json['screen'] as String,
      session: QuizSessionInfo.fromJson(json['session'] as Map<String, dynamic>),
      progress: QuizProgress.fromJson(json['progress'] as Map<String, dynamic>),
      question: json['question'] is Map<String, dynamic>
          ? QuizQuestion.fromJson(json['question'] as Map<String, dynamic>)
          : null,
      safety: json['safety'] is Map<String, dynamic>
          ? QuizSafetyPrompt.fromJson(json['safety'] as Map<String, dynamic>)
          : null,
      crisis: json['crisis'] is Map<String, dynamic>
          ? QuizCrisisPrompt.fromJson(json['crisis'] as Map<String, dynamic>)
          : null,
      result: json['result'] is Map<String, dynamic>
          ? QuizResultPayload.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      canGoBack: json['can_go_back'] as bool? ?? false,
    );
  }
}

class QuizSessionInfo {
  const QuizSessionInfo({
    required this.uuid,
    required this.status,
    required this.quizSlug,
    required this.locale,
    required this.currentSortOrder,
  });

  final String uuid;
  final String status;
  final String quizSlug;
  final String locale;
  final int currentSortOrder;

  factory QuizSessionInfo.fromJson(Map<String, dynamic> json) {
    return QuizSessionInfo(
      uuid: json['uuid'] as String,
      status: json['status'] as String,
      quizSlug: json['quiz_slug'] as String,
      locale: json['locale'] as String? ?? 'en',
      currentSortOrder: json['current_sort_order'] as int? ?? 1,
    );
  }
}

class QuizProgress {
  const QuizProgress({
    required this.current,
    required this.total,
    required this.percent,
  });

  final int current;
  final int total;
  final int percent;

  factory QuizProgress.fromJson(Map<String, dynamic> json) {
    return QuizProgress(
      current: json['current'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.sortOrder,
    required this.key,
    required this.type,
    required this.text,
    required this.helpText,
    required this.maxSelections,
    required this.requiresContinue,
    required this.options,
  });

  final int id;
  final int sortOrder;
  final String key;
  final String type;
  final String text;
  final String helpText;
  final int maxSelections;
  final bool requiresContinue;
  final List<QuizOption> options;

  bool get isMultipleChoice => type == 'multiple_choice';

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      sortOrder: json['sort_order'] as int? ?? 0,
      key: json['key'] as String? ?? '',
      type: json['type'] as String,
      text: json['text'] as String,
      helpText: json['help_text'] as String? ?? '',
      maxSelections: json['max_selections'] as int? ?? 1,
      requiresContinue: json['requires_continue'] as bool? ?? false,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizOption {
  const QuizOption({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final String accent;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      value: '${json['value']}',
      label: json['label'] as String,
      accent: json['accent'] as String? ?? 'emerald',
    );
  }
}

class QuizSafetyPrompt {
  const QuizSafetyPrompt({
    required this.badge,
    required this.title,
    required this.intro,
    required this.options,
  });

  final String badge;
  final String title;
  final String intro;
  final List<QuizOption> options;

  factory QuizSafetyPrompt.fromJson(Map<String, dynamic> json) {
    return QuizSafetyPrompt(
      badge: json['badge'] as String? ?? '',
      title: json['title'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizCrisisPrompt {
  const QuizCrisisPrompt({
    required this.badge,
    required this.title,
    required this.body,
    required this.resetLabel,
  });

  final String badge;
  final String title;
  final String body;
  final String resetLabel;

  factory QuizCrisisPrompt.fromJson(Map<String, dynamic> json) {
    return QuizCrisisPrompt(
      badge: json['badge'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      resetLabel: json['reset_label'] as String? ?? 'Start over',
    );
  }
}

class QuizResultPayload {
  const QuizResultPayload({
    required this.heroLabel,
    required this.typeLabel,
    required this.archetype,
    required this.tagline,
    required this.prescription,
    required this.disclaimer,
    required this.stabilityScore,
    required this.stabilityTitle,
    required this.stabilityNote,
    required this.scoreTagline,
    required this.emergency,
    required this.emergencyAlert,
    required this.firstPrescriptionTitle,
    required this.nextStepsTitle,
    required this.nextSteps,
    required this.dimensionRows,
    required this.dimensionBreakdownTitle,
    required this.sections,
    required this.aiInsights,
    required this.email,
    required this.accountCta,
    required this.isAuthenticated,
    required this.profileLabel,
    required this.backHomeLabel,
    required this.accentColor,
  });

  final String heroLabel;
  final String typeLabel;
  final String archetype;
  final String tagline;
  final String prescription;
  final String disclaimer;
  final int? stabilityScore;
  final String stabilityTitle;
  final String stabilityNote;
  final String scoreTagline;
  final bool emergency;
  final String emergencyAlert;
  final String firstPrescriptionTitle;
  final String nextStepsTitle;
  final List<String> nextSteps;
  final List<QuizDimensionRow> dimensionRows;
  final String dimensionBreakdownTitle;
  final List<QuizResultSection> sections;
  final QuizAiInsights? aiInsights;
  final QuizResultEmail email;
  final QuizAccountCta? accountCta;
  final bool isAuthenticated;
  final String profileLabel;
  final String backHomeLabel;
  final String accentColor;

  factory QuizResultPayload.fromJson(Map<String, dynamic> json) {
    final palette = json['palette'] as Map<String, dynamic>? ?? {};

    return QuizResultPayload(
      heroLabel: json['hero_label'] as String? ?? '',
      typeLabel: json['type_label'] as String? ?? '',
      archetype: json['archetype'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      prescription: json['prescription'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
      stabilityScore: json['stability_score'] as int?,
      stabilityTitle: json['stability_title'] as String? ?? '',
      stabilityNote: json['stability_note'] as String? ?? '',
      scoreTagline: json['score_tagline'] as String? ?? '',
      emergency: json['emergency'] as bool? ?? false,
      emergencyAlert: json['emergency_alert'] as String? ?? '',
      firstPrescriptionTitle: json['first_prescription_title'] as String? ?? '',
      nextStepsTitle: json['next_steps_title'] as String? ?? '',
      nextSteps: (json['next_steps'] as List<dynamic>? ?? []).map((e) => '$e').toList(),
      dimensionRows: (json['dimension_rows'] as List<dynamic>? ?? [])
          .map((e) => QuizDimensionRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      dimensionBreakdownTitle: json['dimension_breakdown_title'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => QuizResultSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiInsights: json['ai_insights'] is Map<String, dynamic>
          ? QuizAiInsights.fromJson(json['ai_insights'] as Map<String, dynamic>)
          : null,
      email: QuizResultEmail.fromJson(json['email'] as Map<String, dynamic>? ?? {}),
      accountCta: json['account_cta'] is Map<String, dynamic>
          ? QuizAccountCta.fromJson(json['account_cta'] as Map<String, dynamic>)
          : null,
      isAuthenticated: json['is_authenticated'] as bool? ?? false,
      profileLabel: json['profile_label'] as String? ?? 'Profile',
      backHomeLabel: json['back_home_label'] as String? ?? 'Back to home',
      accentColor: palette['accent'] as String? ?? '#34D399',
    );
  }
}

class QuizDimensionRow {
  const QuizDimensionRow({
    required this.key,
    required this.label,
    required this.percent,
    required this.description,
  });

  final String key;
  final String label;
  final int percent;
  final String description;

  factory QuizDimensionRow.fromJson(Map<String, dynamic> json) {
    return QuizDimensionRow(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      percent: json['percent'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}

class QuizAiInsights {
  const QuizAiInsights({
    required this.badge,
    required this.title,
    required this.summary,
    required this.recoveryPhase,
    required this.mainRisk,
    required this.attachmentPattern,
    required this.recommendations,
    required this.truthFlashes,
  });

  final String badge;
  final String title;
  final String summary;
  final String recoveryPhase;
  final String mainRisk;
  final String attachmentPattern;
  final List<String> recommendations;
  final List<String> truthFlashes;

  factory QuizAiInsights.fromJson(Map<String, dynamic> json) {
    return QuizAiInsights(
      badge: json['badge'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      recoveryPhase: json['recovery_phase'] as String? ?? '',
      mainRisk: json['main_risk'] as String? ?? '',
      attachmentPattern: json['attachment_pattern'] as String? ?? '',
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
      truthFlashes: (json['truth_flashes'] as List<dynamic>? ?? [])
          .map((e) => '$e')
          .toList(),
    );
  }
}

class QuizResultEmail {
  const QuizResultEmail({
    required this.sent,
    required this.address,
    required this.title,
    required this.description,
    required this.label,
    required this.placeholder,
    required this.submit,
    required this.sending,
    required this.sentTitle,
    required this.sentMessage,
  });

  final bool sent;
  final String address;
  final String title;
  final String description;
  final String label;
  final String placeholder;
  final String submit;
  final String sending;
  final String sentTitle;
  final String? sentMessage;

  factory QuizResultEmail.fromJson(Map<String, dynamic> json) {
    return QuizResultEmail(
      sent: json['sent'] as bool? ?? false,
      address: json['address'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      label: json['label'] as String? ?? '',
      placeholder: json['placeholder'] as String? ?? '',
      submit: json['submit'] as String? ?? '',
      sending: json['sending'] as String? ?? '',
      sentTitle: json['sent_title'] as String? ?? '',
      sentMessage: json['sent_message'] as String?,
    );
  }
}

class QuizAccountCta {
  const QuizAccountCta({
    required this.title,
    required this.body,
    required this.button,
  });

  final String title;
  final String body;
  final String button;

  factory QuizAccountCta.fromJson(Map<String, dynamic> json) {
    return QuizAccountCta(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      button: json['button'] as String? ?? '',
    );
  }
}

class QuizResultSection {
  const QuizResultSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;

  factory QuizResultSection.fromJson(Map<String, dynamic> json) {
    return QuizResultSection(
      heading: json['heading'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

class QuizSessionStartResult {
  const QuizSessionStartResult({
    required this.state,
    this.guestToken,
  });

  final QuizSessionState state;
  final String? guestToken;
}

class QuizEntry {
  const QuizEntry({
    required this.action,
    this.sessionUuid,
    this.returning,
    this.screen,
    this.guestToken,
  });

  final String action;
  final String? sessionUuid;
  final QuizReturningPreview? returning;
  final String? screen;
  final String? guestToken;

  bool get isShowPrevious => action == 'show_previous';

  bool get isResume => action == 'resume';

  bool get isStartFresh => action == 'start_fresh';

  factory QuizEntry.fromJson(Map<String, dynamic> json) {
    return QuizEntry(
      action: json['action'] as String,
      sessionUuid: json['session_uuid'] as String?,
      returning: json['returning'] is Map<String, dynamic>
          ? QuizReturningPreview.fromJson(json['returning'] as Map<String, dynamic>)
          : null,
      screen: json['screen'] as String?,
      guestToken: json['guest_token'] as String?,
    );
  }
}

class QuizReturningPreview {
  const QuizReturningPreview({
    required this.sessionUuid,
    required this.quizName,
    required this.typeCode,
    required this.title,
    required this.summary,
    required this.viewResultLabel,
    required this.retakeLabel,
    required this.eyebrow,
    this.completedAt,
  });

  final String sessionUuid;
  final String quizName;
  final String typeCode;
  final String title;
  final String summary;
  final String viewResultLabel;
  final String retakeLabel;
  final String eyebrow;
  final String? completedAt;

  factory QuizReturningPreview.fromJson(Map<String, dynamic> json) {
    return QuizReturningPreview(
      sessionUuid: json['session_uuid'] as String,
      quizName: json['quiz_name'] as String? ?? '',
      typeCode: json['type_code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      viewResultLabel: json['view_result_label'] as String? ?? 'View your result',
      retakeLabel: json['retake_label'] as String? ?? 'Retake test',
      eyebrow: json['eyebrow'] as String? ?? 'Your previous scan',
      completedAt: json['completed_at'] as String?,
    );
  }
}
