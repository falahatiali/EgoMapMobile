class BootstrapPayload {
  const BootstrapPayload({
    required this.locale,
    required this.landing,
    required this.quiz,
    required this.auth,
  });

  final String locale;
  final LandingContent landing;
  final QuizContent quiz;
  final AuthCopy auth;

  factory BootstrapPayload.fromJson(Map<String, dynamic> json) {
    return BootstrapPayload(
      locale: json['locale'] as String,
      landing: LandingContent.fromJson(json['landing'] as Map<String, dynamic>),
      quiz: QuizContent.fromJson(json['quiz'] as Map<String, dynamic>),
      auth: AuthCopy.fromJson(json['auth'] as Map<String, dynamic>),
    );
  }
}

class LandingContent {
  const LandingContent({
    required this.coreMessage,
    required this.heroTitle1,
    required this.heroTitle2,
    required this.heroTypedPrefix,
    required this.heroTypedWords,
    required this.heroSubtitle,
    required this.heroEmotionalLine,
    required this.ctaStep1,
    required this.ctaStep1Note,
    required this.stepsTitle,
    required this.stepsSubtitle,
    required this.steps,
    required this.flow,
    required this.panel,
    required this.terminalBar,
    required this.emergencyTitle,
    required this.emergencyLine1,
    required this.emergencyLine2,
  });

  final String coreMessage;
  final String heroTitle1;
  final String heroTitle2;
  final String heroTypedPrefix;
  final List<String> heroTypedWords;
  final String heroSubtitle;
  final String heroEmotionalLine;
  final String ctaStep1;
  final String ctaStep1Note;
  final String stepsTitle;
  final String stepsSubtitle;
  final List<StepItem> steps;
  final List<String> flow;
  final DiagnosticPanel panel;
  final String terminalBar;
  final String emergencyTitle;
  final String emergencyLine1;
  final String emergencyLine2;

  factory LandingContent.fromJson(Map<String, dynamic> json) {
    return LandingContent(
      coreMessage: json['core_message'] as String,
      heroTitle1: json['hero_title_1'] as String,
      heroTitle2: json['hero_title_2'] as String,
      heroTypedPrefix: json['hero_typed_prefix'] as String,
      heroTypedWords: (json['hero_typed_words'] as List<dynamic>)
          .map((e) => '$e')
          .toList(),
      heroSubtitle: json['hero_subtitle'] as String,
      heroEmotionalLine: json['hero_emotional_line'] as String,
      ctaStep1: json['cta_step1'] as String,
      ctaStep1Note: json['cta_step1_note'] as String,
      stepsTitle: json['steps_title'] as String,
      stepsSubtitle: json['steps_subtitle'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => StepItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      flow: (json['flow'] as List<dynamic>).map((e) => '$e').toList(),
      panel: DiagnosticPanel.fromJson(json['panel'] as Map<String, dynamic>),
      terminalBar: json['terminal_bar'] as String,
      emergencyTitle: json['emergency_title'] as String? ?? 'About to text her?',
      emergencyLine1: json['emergency_line_1'] as String? ?? 'Write it here. Don\'t send it.',
      emergencyLine2: json['emergency_line_2'] as String? ?? 'We\'ll wait 20 minutes with you.',
    );
  }
}

class StepItem {
  const StepItem({required this.title, required this.description});

  final String title;
  final String description;

  factory StepItem.fromJson(Map<String, dynamic> json) {
    return StepItem(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class DiagnosticPanel {
  const DiagnosticPanel({
    required this.title,
    required this.currentState,
    required this.currentStateValue,
    required this.mainRisk,
    required this.mainRiskValue,
    required this.ghostMode,
    required this.ghostModeValue,
    required this.rebuildIndex,
    required this.rebuildValue,
    required this.action,
    required this.actionValue,
  });

  final String title;
  final String currentState;
  final String currentStateValue;
  final String mainRisk;
  final String mainRiskValue;
  final String ghostMode;
  final String ghostModeValue;
  final String rebuildIndex;
  final String rebuildValue;
  final String action;
  final String actionValue;

  factory DiagnosticPanel.fromJson(Map<String, dynamic> json) {
    return DiagnosticPanel(
      title: json['title'] as String,
      currentState: json['current_state'] as String,
      currentStateValue: json['current_state_value'] as String,
      mainRisk: json['main_risk'] as String,
      mainRiskValue: json['main_risk_value'] as String,
      ghostMode: json['ghost_mode'] as String,
      ghostModeValue: json['ghost_mode_value'] as String,
      rebuildIndex: json['rebuild_index'] as String,
      rebuildValue: json['rebuild_value'] as String,
      action: json['action'] as String,
      actionValue: json['action_value'] as String,
    );
  }
}

class QuizContent {
  const QuizContent({
    required this.featuredSlug,
    required this.checkinTitle,
    required this.checkinSubtitle,
    required this.checkinCta,
  });

  final String featuredSlug;
  final String checkinTitle;
  final String checkinSubtitle;
  final String checkinCta;

  factory QuizContent.fromJson(Map<String, dynamic> json) {
    return QuizContent(
      featuredSlug: json['featured_slug'] as String,
      checkinTitle: json['checkin_title'] as String,
      checkinSubtitle: json['checkin_subtitle'] as String,
      checkinCta: json['checkin_cta'] as String,
    );
  }
}

class AuthCopy {
  const AuthCopy({
    required this.loginTitle,
    required this.loginSubtitle,
    required this.registerTitle,
    required this.registerSubtitle,
    required this.verifyTitle,
  });

  final String loginTitle;
  final String loginSubtitle;
  final String registerTitle;
  final String registerSubtitle;
  final String verifyTitle;

  factory AuthCopy.fromJson(Map<String, dynamic> json) {
    return AuthCopy(
      loginTitle: json['login_title'] as String,
      loginSubtitle: json['login_subtitle'] as String,
      registerTitle: json['register_title'] as String,
      registerSubtitle: json['register_subtitle'] as String,
      verifyTitle: json['verify_title'] as String,
    );
  }
}
