import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../aether/aether_wizard_copy.dart';
import '../aether/aether_wizard_steps.dart';
import '../providers/missions_provider.dart';
import '../widgets/aether/aether_body_card.dart';
import '../widgets/aether/aether_choice_tile.dart';
import '../widgets/aether/aether_wizard_progress.dart';

class MissionCalibrationScreen extends ConsumerStatefulWidget {
  const MissionCalibrationScreen({
    super.key,
    required this.enrollmentUuid,
    this.entryToolKey,
  });

  final String enrollmentUuid;
  final String? entryToolKey;

  @override
  ConsumerState<MissionCalibrationScreen> createState() => _MissionCalibrationScreenState();
}

class _MissionCalibrationScreenState extends ConsumerState<MissionCalibrationScreen> {
  int _stepIndex = 0;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic> _wizard = {};
  bool _initialized = false;

  AetherWizardStepId get _step => aetherWizardFlow[_stepIndex];
  int get _totalSteps => aetherWizardFlow.length;

  @override
  Widget build(BuildContext context) {
    final defaultsAsync = ref.watch(calibrationDefaultsProvider(widget.enrollmentUuid));

    return defaultsAsync.when(
      loading: () => const EgFlowScaffold(
        title: 'AetherEngine',
        body: Center(child: CircularProgressIndicator(color: EgColors.success)),
      ),
      error: (error, _) => EgFlowScaffold(
        title: 'AetherEngine',
        body: Center(child: Text(missionErrorMessage(error) ?? 'Could not load calibration')),
      ),
      data: (defaults) {
        if (!_initialized) {
          _wizard = _normalizeWizard(Map<String, dynamic>.from(defaults.wizard));
          _initialized = true;
        }

        final stepKey = _step.apiKey;
        final canProceed = _step.canProceed(_wizard);

        return EgFlowScaffold(
          title: 'AetherEngine',
          subtitle: '${AetherWizardCopy.kicker(stepKey)} · Step ${_stepIndex + 1} of $_totalSteps',
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>(stepKey),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(EgSpacing.page, 8, EgSpacing.page, 120),
                children: [
                  AetherWizardProgress(current: _stepIndex + 1, total: _totalSteps),
                  const SizedBox(height: 28),
                  Text(
                    AetherWizardCopy.title(stepKey),
                    style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5),
                  ),
                  if (AetherWizardCopy.help(stepKey) case final help?) ...[
                    const SizedBox(height: 10),
                    Text(help, style: EgFonts.style(fontSize: 15, height: 1.5, color: EgColors.slate400)),
                  ],
                  const SizedBox(height: 22),
                  if (_error != null) ...[
                    Text(_error!, style: EgFonts.style(fontSize: 14, color: EgColors.danger)),
                    const SizedBox(height: 12),
                  ],
                  ..._buildStep(stepKey),
                ],
              ),
            ),
          ),
          bottom: Padding(
            padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, EgSpacing.page),
            child: Row(
              children: [
                if (_stepIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : _goBack,
                      child: const Text('Back'),
                    ),
                  ),
                if (_stepIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: EgPrimaryButton(
                    label: _step == AetherWizardStepId.review ? 'Build my plan' : 'Continue',
                    loading: _submitting,
                    onPressed: (!_submitting && canProceed) ? _onContinue : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _normalizeWizard(Map<String, dynamic> wizard) {
    wizard.putIfAbsent('gender', () => 'male');
    wizard.putIfAbsent('age_range', () => '18_29');
    wizard.putIfAbsent('age', () => AetherWizardCopy.ageFromRange('18_29'));
    wizard.putIfAbsent('height_cm', () => 175);
    wizard.putIfAbsent('weight_kg', () => 75.0);
    wizard.putIfAbsent('primary_goal', () => 'muscle_gain');
    wizard.putIfAbsent('training_days_per_week', () => 4);
    wizard.putIfAbsent('session_duration', () => '45_60');
    wizard.putIfAbsent('equipment', () => 'full_gym');
    wizard.putIfAbsent('training_style', () => 'heavy_weights');
    wizard.putIfAbsent('motivation_style', () => 'feeling_strong');
    wizard.putIfAbsent('dietary_pattern', () => 'omnivore');
    wizard.putIfAbsent('injury_tags', () => <String>[]);
    wizard.putIfAbsent('current_body_build', () => '');
    wizard.putIfAbsent('target_body_goal', () => '');
    wizard.putIfAbsent('gym_confidence', () => '');
    return wizard;
  }

  List<Widget> _buildStep(String stepKey) {
    return switch (stepKey) {
      'gender' => _choiceStep(
          AetherWizardCopy.genders,
          _wizard['gender'] as String? ?? 'male',
          (value) => _patchWizard({'gender': value}, autoAdvance: true),
        ),
      'age' => _choiceStep(
          AetherWizardCopy.ageRanges,
          _wizard['age_range'] as String? ?? '18_29',
          (value) => _patchWizard({
            'age_range': value,
            'age': AetherWizardCopy.ageFromRange(value),
          }, autoAdvance: true),
        ),
      'height' => [
          AetherMetricPicker(
            value: (_wizard['height_cm'] as num? ?? 175).toDouble(),
            min: 140,
            max: 220,
            divisions: 80,
            unit: 'cm',
            formatValue: (value) => value.round().toString(),
            ticks: const [150, 165, 175, 185, 200],
            onChanged: (value) => setState(() => _wizard['height_cm'] = value.round()),
          ),
        ],
      'weight' => [
          AetherMetricPicker(
            value: (_wizard['weight_kg'] as num? ?? 75).toDouble(),
            min: 40,
            max: 160,
            divisions: 240,
            unit: 'kg',
            formatValue: (value) => value.toStringAsFixed(1),
            ticks: const [55, 70, 85, 100, 115],
            onChanged: (value) => setState(() => _wizard['weight_kg'] = value),
          ),
        ],
      'current_body' => _bodyGridStep(
          AetherWizardCopy.bodyBuilds,
          _wizard['current_body_build'] as String? ?? '',
          'current_body_build',
          goalMode: false,
        ),
      'target_body' => _bodyGridStep(
          AetherWizardCopy.bodyGoals,
          _wizard['target_body_goal'] as String? ?? '',
          'target_body_goal',
          goalMode: true,
        ),
      'goal' => _choiceStep(
          AetherWizardCopy.goals,
          _wizard['primary_goal'] as String? ?? 'muscle_gain',
          (value) => _patchWizard({'primary_goal': value}, autoAdvance: true),
        ),
      'gym_confidence' => _choiceStep(
          AetherWizardCopy.gymConfidence,
          _wizard['gym_confidence'] as String? ?? '',
          (value) => _patchWizard({
            'gym_confidence': value,
            'training_experience': AetherWizardCopy.trainingExperienceFromConfidence(value),
          }, autoAdvance: true),
        ),
      'days' => [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(5, (index) {
              final value = index + 2;
              final selected = (_wizard['training_days_per_week'] as int? ?? 4) == value;
              return ChoiceChip(
                label: Text('$value days / week'),
                selected: selected,
                onSelected: (_) => _patchWizard({'training_days_per_week': value}, autoAdvance: true),
              );
            }),
          ),
        ],
      'session' => _choiceStep(
          AetherWizardCopy.sessions,
          _wizard['session_duration'] as String? ?? '45_60',
          (value) => _patchWizard({'session_duration': value}, autoAdvance: true),
        ),
      'equipment' => _choiceStep(
          AetherWizardCopy.equipment,
          _wizard['equipment'] as String? ?? 'full_gym',
          (value) => _patchWizard({'equipment': value}, autoAdvance: true),
        ),
      'injuries' => _injuryStep(),
      'style' => _choiceStep(
          AetherWizardCopy.styles,
          _wizard['training_style'] as String? ?? 'heavy_weights',
          (value) => _patchWizard({'training_style': value}, autoAdvance: true),
        ),
      'motivation' => _choiceStep(
          AetherWizardCopy.motivation,
          _wizard['motivation_style'] as String? ?? 'feeling_strong',
          (value) => _patchWizard({'motivation_style': value}, autoAdvance: true),
        ),
      'review' => _reviewStep(),
      _ => [const SizedBox.shrink()],
    };
  }

  List<Widget> _choiceStep(
    List<(String, String)> options,
    String selected,
    ValueChanged<String> onSelect,
  ) {
    return options
        .map(
          (option) => AetherChoiceTile(
            label: option.$2,
            selected: selected == option.$1,
            onTap: () => onSelect(option.$1),
          ),
        )
        .toList();
  }

  List<Widget> _bodyGridStep(
    List<(String, String)> options,
    String selected,
    String field, {
    required bool goalMode,
  }) {
    final gender = _wizard['gender'] as String? ?? 'male';

    return [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
        children: options
            .map(
              (option) => AetherBodyCard(
                variant: option.$1,
                label: option.$2,
                gender: gender,
                goalMode: goalMode,
                selected: selected == option.$1,
                onTap: () => _patchWizard({field: option.$1}, autoAdvance: true),
              ),
            )
            .toList(),
      ),
    ];
  }

  List<Widget> _injuryStep() {
    final tags = List<String>.from(_wizard['injury_tags'] as List? ?? []);

    return AetherWizardCopy.injuries
        .map(
          (option) => AetherChoiceTile(
            label: option.$2,
            selected: option.$1 == 'none' ? tags.isEmpty : tags.contains(option.$1),
            onTap: () {
              setState(() {
                if (option.$1 == 'none') {
                  _wizard['injury_tags'] = <String>[];
                } else {
                  final next = List<String>.from(tags);
                  if (next.contains(option.$1)) {
                    next.remove(option.$1);
                  } else {
                    next.add(option.$1);
                  }
                  _wizard['injury_tags'] = next;
                }
                _error = null;
              });
            },
          ),
        )
        .toList();
  }

  List<Widget> _reviewStep() {
    return [
      Text(
        'Quick check — then we build your 12-week plan.',
        style: EgFonts.style(fontSize: 15, height: 1.5, color: EgColors.slate400),
      ),
      const SizedBox(height: 18),
      _ReviewRow(label: 'Gender', value: '${_wizard['gender']}'),
      _ReviewRow(label: 'Age', value: '${_wizard['age_range']}'),
      _ReviewRow(label: 'Height', value: '${_wizard['height_cm']} cm'),
      _ReviewRow(label: 'Weight', value: '${_wizard['weight_kg']} kg'),
      _ReviewRow(label: 'Current body', value: '${_wizard['current_body_build']}'),
      _ReviewRow(label: 'Target look', value: '${_wizard['target_body_goal']}'),
      _ReviewRow(label: 'Goal', value: '${_wizard['primary_goal']}'),
      _ReviewRow(label: 'Gym confidence', value: '${_wizard['gym_confidence']}'),
      _ReviewRow(label: 'Days / week', value: '${_wizard['training_days_per_week']}'),
      _ReviewRow(label: 'Session', value: '${_wizard['session_duration']}'),
      _ReviewRow(label: 'Equipment', value: '${_wizard['equipment']}'),
      _ReviewRow(label: 'Style', value: '${_wizard['training_style']}'),
      _ReviewRow(label: 'Motivation', value: '${_wizard['motivation_style']}'),
    ];
  }

  void _patchWizard(Map<String, dynamic> patch, {bool autoAdvance = false}) {
    setState(() {
      _wizard.addAll(patch);
      _error = null;
    });

    if (autoAdvance && _step.canProceed(_wizard) && _stepIndex < _totalSteps - 1) {
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) {
          return;
        }
        if (_step.canProceed(_wizard)) {
          _goNext();
        }
      });
    }
  }

  void _goBack() {
    HapticFeedback.lightImpact();
    setState(() {
      _stepIndex = (_stepIndex - 1).clamp(0, _totalSteps - 1);
      _error = null;
    });
  }

  void _goNext() {
    if (_stepIndex >= _totalSteps - 1) {
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _stepIndex += 1;
      _error = null;
    });
  }

  Future<void> _onContinue() async {
    if (!_step.canProceed(_wizard)) {
      setState(() => _error = 'Pick an option to continue.');
      return;
    }

    if (_step != AetherWizardStepId.review) {
      _goNext();
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final response = await ref.read(missionsRepositoryProvider).completeCalibration(
            enrollmentUuid: widget.enrollmentUuid,
            targets: const ['workout'],
            wizard: _wizard,
            entryToolKey: widget.entryToolKey,
          );

      if (!mounted) {
        return;
      }

      await _showRevealDialog(response.reveal?.headline ?? 'Your plan is ready');

      if (mounted) {
        context.pop(true);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
        _error = error.displayMessage;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
        _error = 'Could not complete calibration.';
      });
    }
  }

  Future<void> _showRevealDialog(String headline) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: EgColors.navy900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(headline, style: EgFonts.style(fontWeight: FontWeight.w800)),
        content: Text(
          'AetherEngine calibrated your Foundation week.',
          style: EgFonts.style(color: EgColors.slate400),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Open mission'),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: EgFonts.style(fontSize: 14, color: EgColors.slate500))),
          Text(value, style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
