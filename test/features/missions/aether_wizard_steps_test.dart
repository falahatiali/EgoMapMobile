import 'package:egomap_mobile/features/missions/aether/aether_wizard_copy.dart';
import 'package:egomap_mobile/features/missions/aether/aether_wizard_steps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('body and confidence steps require explicit selection', () {
    const wizard = <String, dynamic>{
      'current_body_build': '',
      'target_body_goal': '',
      'gym_confidence': '',
    };

    expect(AetherWizardStepId.currentBody.canProceed(wizard), isFalse);
    expect(AetherWizardStepId.targetBody.canProceed(wizard), isFalse);
    expect(AetherWizardStepId.gymConfidence.canProceed(wizard), isFalse);
    expect(AetherWizardStepId.gender.canProceed(wizard), isTrue);
  });

  test('age range maps to representative age', () {
    expect(AetherWizardCopy.ageFromRange('30_39'), 35);
    expect(AetherWizardCopy.trainingExperienceFromConfidence('confident_plan'), 'advanced');
  });

  test('wizard flow has fifteen steps ending in review', () {
    expect(aetherWizardFlow.length, 15);
    expect(aetherWizardFlow.last, AetherWizardStepId.review);
  });
}
