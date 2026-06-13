import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../providers/missions_provider.dart';

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
  int _step = 0;
  bool _submitting = false;
  String? _error;
  Map<String, dynamic> _wizard = {};

  static const _totalSteps = 4;

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
        if (_wizard.isEmpty) {
          _wizard = Map<String, dynamic>.from(defaults.wizard);
        }

        return EgFlowScaffold(
          title: 'Calibrate AetherEngine',
          subtitle: 'Step ${_step + 1} of $_totalSteps',
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_step + 1) / _totalSteps,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                color: EgColors.success,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(EgSpacing.page),
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: EgFonts.style(fontSize: 14, color: EgColors.danger),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...switch (_step) {
                      0 => _goalStep(),
                      1 => _scheduleStep(),
                      2 => _equipmentStep(),
                      _ => _reviewStep(),
                    },
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, EgSpacing.page),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _submitting ? null : () => setState(() => _step -= 1),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: EgPrimaryButton(
                        label: _step == _totalSteps - 1 ? 'Confirm & build plan' : 'Continue',
                        loading: _submitting,
                        onPressed: _submitting ? null : _onContinue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _goalStep() {
    const options = [
      ('muscle_gain', 'Build muscle', Icons.fitness_center_rounded),
      ('fat_loss', 'Lose fat', Icons.local_fire_department_rounded),
      ('recomposition', 'Recompose', Icons.balance_rounded),
      ('strength', 'Get stronger', Icons.bolt_rounded),
    ];

    return [
      Text('What is your main focus?', style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(
        'AetherEngine will shape your training around this.',
        style: EgFonts.style(fontSize: 15, color: EgColors.slate400, height: 1.5),
      ),
      const SizedBox(height: 20),
      ...options.map((option) {
        final selected = _wizard['primary_goal'] == option.$1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OptionCard(
            label: option.$2,
            icon: option.$3,
            selected: selected,
            onTap: () => setState(() => _wizard['primary_goal'] = option.$1),
          ),
        );
      }),
    ];
  }

  List<Widget> _scheduleStep() {
    final days = _wizard['training_days_per_week'] as int? ?? 4;

    return [
      Text('How often can you train?', style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(5, (index) {
          final value = index + 2;
          final selected = days == value;

          return ChoiceChip(
            label: Text('$value days / week'),
            selected: selected,
            onSelected: (_) => setState(() => _wizard['training_days_per_week'] = value),
          );
        }),
      ),
      const SizedBox(height: 24),
      Text('Session length', style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: [
          ('30_45', '30–45 min'),
          ('45_60', '45–60 min'),
          ('60_plus', '60+ min'),
        ].map((option) {
          final selected = _wizard['session_duration'] == option.$1;

          return ChoiceChip(
            label: Text(option.$2),
            selected: selected,
            onSelected: (_) => setState(() => _wizard['session_duration'] = option.$1),
          );
        }).toList(),
      ),
    ];
  }

  List<Widget> _equipmentStep() {
    const options = [
      ('full_gym', 'Full gym', Icons.apartment_rounded),
      ('home_gym', 'Home gym', Icons.home_rounded),
      ('bodyweight_only', 'Minimal gear', Icons.directions_walk_rounded),
    ];

    return [
      Text('Where do you usually train?', style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      ...options.map((option) {
        final selected = _wizard['equipment'] == option.$1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OptionCard(
            label: option.$2,
            icon: option.$3,
            selected: selected,
            onTap: () => setState(() => _wizard['equipment'] = option.$1),
          ),
        );
      }),
    ];
  }

  List<Widget> _reviewStep() {
    return [
      Text('Ready to activate?', style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(
        'AetherEngine will build your Week 1 Foundation plan.',
        style: EgFonts.style(fontSize: 15, color: EgColors.slate400, height: 1.5),
      ),
      const SizedBox(height: 20),
      _ReviewRow(label: 'Goal', value: '${_wizard['primary_goal']}'),
      _ReviewRow(label: 'Days / week', value: '${_wizard['training_days_per_week']}'),
      _ReviewRow(label: 'Session', value: '${_wizard['session_duration']}'),
      _ReviewRow(label: 'Environment', value: '${_wizard['equipment']}'),
    ];
  }

  Future<void> _onContinue() async {
    if (_step < _totalSteps - 1) {
      setState(() {
        _step += 1;
        _error = null;
      });
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            border: Border.all(
              color: selected ? EgColors.success : EgColors.borderSubtle,
            ),
            color: selected ? EgColors.success.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? EgColors.success : EgColors.slate400),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
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
          Expanded(
            child: Text(label, style: EgFonts.style(fontSize: 14, color: EgColors.slate500)),
          ),
          Text(value, style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
