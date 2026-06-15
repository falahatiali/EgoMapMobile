enum AetherWizardStepId {
  gender,
  age,
  height,
  weight,
  currentBody,
  targetBody,
  goal,
  gymConfidence,
  days,
  session,
  equipment,
  injuries,
  style,
  motivation,
  review,
}

const List<AetherWizardStepId> aetherWizardFlow = [
  AetherWizardStepId.gender,
  AetherWizardStepId.age,
  AetherWizardStepId.height,
  AetherWizardStepId.weight,
  AetherWizardStepId.currentBody,
  AetherWizardStepId.targetBody,
  AetherWizardStepId.goal,
  AetherWizardStepId.gymConfidence,
  AetherWizardStepId.days,
  AetherWizardStepId.session,
  AetherWizardStepId.equipment,
  AetherWizardStepId.injuries,
  AetherWizardStepId.style,
  AetherWizardStepId.motivation,
  AetherWizardStepId.review,
];

extension AetherWizardStepIdX on AetherWizardStepId {
  String get apiKey => switch (this) {
        AetherWizardStepId.gender => 'gender',
        AetherWizardStepId.age => 'age',
        AetherWizardStepId.height => 'height',
        AetherWizardStepId.weight => 'weight',
        AetherWizardStepId.currentBody => 'current_body',
        AetherWizardStepId.targetBody => 'target_body',
        AetherWizardStepId.goal => 'goal',
        AetherWizardStepId.gymConfidence => 'gym_confidence',
        AetherWizardStepId.days => 'days',
        AetherWizardStepId.session => 'session',
        AetherWizardStepId.equipment => 'equipment',
        AetherWizardStepId.injuries => 'injuries',
        AetherWizardStepId.style => 'style',
        AetherWizardStepId.motivation => 'motivation',
        AetherWizardStepId.review => 'review',
      };

  bool canProceed(Map<String, dynamic> wizard) {
    return switch (this) {
      AetherWizardStepId.currentBody => _filled(wizard['current_body_build']),
      AetherWizardStepId.targetBody => _filled(wizard['target_body_goal']),
      AetherWizardStepId.gymConfidence => _filled(wizard['gym_confidence']),
      _ => true,
    };
  }

  bool _filled(Object? value) => value is String && value.isNotEmpty;
}
