import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';

/// A compact bottom sheet for logging the weight used in a set.
///
/// Returns the entered [double] when the user confirms, or [null] when they
/// tap "Skip". The caller is responsible for calling the API.
///
/// Usage:
/// ```dart
/// final weight = await WeightInputSheet.show(
///   context,
///   exerciseName: 'Bench Press',
///   setNumber: 2,
///   previousWeightKg: set.weightKg,
///   suggestedWeightKg: set.suggestedWeightKg,
/// );
/// if (weight != null) { /* call API */ }
/// ```
class WeightInputSheet extends StatefulWidget {
  const WeightInputSheet({
    super.key,
    required this.exerciseName,
    required this.setNumber,
    this.previousWeightKg,
    this.suggestedWeightKg,
  });

  final String exerciseName;
  final int setNumber;

  /// Weight already logged for this set (if any).
  final double? previousWeightKg;

  /// Suggested weight calculated from previous weeks + overload.
  final double? suggestedWeightKg;

  static Future<double?> show(
    BuildContext context, {
    required String exerciseName,
    required int setNumber,
    double? previousWeightKg,
    double? suggestedWeightKg,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => WeightInputSheet(
        exerciseName: exerciseName,
        setNumber: setNumber,
        previousWeightKg: previousWeightKg,
        suggestedWeightKg: suggestedWeightKg,
      ),
    );
  }

  @override
  State<WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends State<WeightInputSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isKg = true;

  // Quick-select presets rendered as pill chips.
  static const List<double> _presets = [
    20, 30, 40, 50, 60, 70, 80, 100,
  ];

  @override
  void initState() {
    super.initState();

    final initial = widget.previousWeightKg ?? widget.suggestedWeightKg;
    _controller = TextEditingController(
      text: initial != null ? _formatWeight(initial) : '',
    );
    _focusNode = FocusNode();

    // Auto-open keyboard after the sheet fully slides in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatWeight(double kg) {
    if (!_isKg) {
      final lbs = kg * 2.20462;
      return lbs % 1 == 0 ? lbs.toInt().toString() : lbs.toStringAsFixed(1);
    }
    return kg % 1 == 0 ? kg.toInt().toString() : kg.toStringAsFixed(1);
  }

  double? get _parsedValueKg {
    final raw = double.tryParse(_controller.text.trim());
    if (raw == null || raw <= 0) {
      return null;
    }
    return _isKg ? raw : raw / 2.20462;
  }

  void _applyPreset(double kg) {
    HapticFeedback.selectionClick();
    setState(() {
      _controller.text = _formatWeight(kg);
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _confirm() {
    final value = _parsedValueKg;
    if (value == null) {
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(value);
  }

  void _skip() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            EgSpacing.page, 18, EgSpacing.page, EgSpacing.page,
          ),
          decoration: const BoxDecoration(
            color: EgColors.navy900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle ──────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // ── Title row ────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How much did you lift?',
                          style: EgFonts.style(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.exerciseName} · Set ${widget.setNumber}',
                          style: EgFonts.style(
                            fontSize: 13,
                            color: EgColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // kg / lbs toggle
                  _UnitToggle(
                    isKg: _isKg,
                    onToggle: () {
                      final currentKg = _parsedValueKg;
                      setState(() => _isKg = !_isKg);
                      if (currentKg != null) {
                        _controller.text = _formatWeight(currentKg);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Suggested weight hint ────────────────────────────────────
              if (widget.suggestedWeightKg != null)
                GestureDetector(
                  onTap: () => _applyPreset(widget.suggestedWeightKg!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(EgSpacing.radius),
                      border: Border.all(color: EgColors.success.withValues(alpha: 0.4)),
                      color: EgColors.success.withValues(alpha: 0.07),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: EgColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Suggested: ',
                              style: EgFonts.style(
                                fontSize: 13,
                                color: EgColors.slate400,
                              ),
                              children: [
                                TextSpan(
                                  text: _formatWeight(widget.suggestedWeightKg!),
                                  style: EgFonts.style(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: EgColors.success,
                                  ),
                                ),
                                TextSpan(
                                  text: _isKg ? ' kg' : ' lbs',
                                  style: EgFonts.style(
                                    fontSize: 13,
                                    color: EgColors.success,
                                  ),
                                ),
                                TextSpan(
                                  text: ' (+2.5 kg from last week)',
                                  style: EgFonts.style(
                                    fontSize: 12,
                                    color: EgColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.touch_app_rounded,
                          color: EgColors.slate500,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Input field ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(EgSpacing.radius),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? EgColors.accentBright
                        : EgColors.borderSubtle,
                    width: 1.5,
                  ),
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  textAlign: TextAlign.center,
                  style: EgFonts.style(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    hintText: '0',
                    hintStyle: EgFonts.style(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        _isKg ? 'kg' : 'lbs',
                        style: EgFonts.style(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: EgColors.slate400,
                        ),
                      ),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minHeight: 0, minWidth: 0),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _confirm(),
                ),
              ),

              const SizedBox(height: 14),

              // ── Quick preset chips ────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _presets.map((kg) {
                    final label = _formatWeight(kg);
                    final isSelected = _parsedValueKg != null &&
                        (_parsedValueKg! - kg).abs() < 0.1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _PresetChip(
                        label: '$label ${_isKg ? 'kg' : 'lbs'}',
                        selected: isSelected,
                        onTap: () => _applyPreset(kg),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // ── Confirm / Skip ────────────────────────────────────────────
              Row(
                children: [
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: EgColors.slate400,
                      minimumSize: const Size(80, 50),
                    ),
                    child: Text(
                      'Skip',
                      style: EgFonts.style(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _parsedValueKg != null ? _confirm : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: EgColors.accentBright,
                        foregroundColor: EgColors.navy950,
                        disabledBackgroundColor:
                            EgColors.accentBright.withValues(alpha: 0.25),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(EgSpacing.radius),
                        ),
                      ),
                      child: Text(
                        'Log weight',
                        style: EgFonts.style(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.isKg, required this.onToggle});

  final bool isKg;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          color: Colors.white.withValues(alpha: 0.06),
        ),
        child: Row(
          children: [
            _UnitLabel(label: 'kg', active: isKg),
            const SizedBox(width: 4),
            Container(width: 1, height: 14, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(width: 4),
            _UnitLabel(label: 'lbs', active: !isKg),
          ],
        ),
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  const _UnitLabel({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: EgFonts.style(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: active ? EgColors.textPrimary : EgColors.slate500,
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected
              ? EgColors.accentBright.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? EgColors.accentBright
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Text(
          label,
          style: EgFonts.style(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? EgColors.accentBright : EgColors.slate400,
          ),
        ),
      ),
    );
  }
}
