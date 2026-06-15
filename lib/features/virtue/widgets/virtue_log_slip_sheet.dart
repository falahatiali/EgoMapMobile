import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../models/virtue_models.dart';
import '../providers/virtue_provider.dart';

class VirtueLogSlipSheet extends ConsumerStatefulWidget {
  const VirtueLogSlipSheet({super.key, required this.routine});

  final VirtueRoutine routine;

  static Future<bool?> show(BuildContext context, {required VirtueRoutine routine}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VirtueLogSlipSheet(routine: routine),
    );
  }

  @override
  ConsumerState<VirtueLogSlipSheet> createState() => _VirtueLogSlipSheetState();
}

class _VirtueLogSlipSheetState extends ConsumerState<VirtueLogSlipSheet> {
  final _whatHappenedController = TextEditingController();
  bool _isLogging = false;
  VirtueSlipResult? _result;

  @override
  void dispose() {
    _whatHappenedController.dispose();
    super.dispose();
  }

  Future<void> _logSlip() async {
    setState(() => _isLogging = true);
    HapticFeedback.lightImpact();

    try {
      final result = await ref.read(virtueRepositoryProvider).logSlip(
            widget.routine.id,
            whatHappened: _whatHappenedController.text.trim().isNotEmpty
                ? _whatHappenedController.text.trim()
                : null,
          );

      await ref.read(virtueHubProvider.notifier).refresh();

      if (mounted) {
        setState(() {
          _result = result;
          _isLogging = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLogging = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(EgSpacing.page, 20, EgSpacing.page, bottomInset + 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _result != null
          ? _SlipResultView(result: _result!, onClose: () => Navigator.of(context).pop(true))
          : _SlipInputView(
              controller: _whatHappenedController,
              isLogging: _isLogging,
              onLog: _logSlip,
              onCancel: () => Navigator.of(context).pop(false),
            ),
    );
  }
}

class _SlipInputView extends StatelessWidget {
  const _SlipInputView({
    required this.controller,
    required this.isLogging,
    required this.onLog,
    required this.onCancel,
  });

  final TextEditingController controller;
  final bool isLogging;
  final VoidCallback onLog;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: EgColors.borderSubtle, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EgColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: EgColors.danger, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report a Slip', style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(
                      'Honesty takes courage. +1 pt for reporting.',
                      style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('What happened? (optional)', style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            style: EgFonts.style(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. I got frustrated at work and snapped at someone sarcastically…',
              hintStyle: EgFonts.style(fontSize: 13, color: EgColors.slate500),
              filled: true,
              fillColor: const Color(0x08FFFFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: EgColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: EgColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: EgColors.danger),
              ),
            ),
          ),
          const SizedBox(height: 20),
          EgPrimaryButton(
            label: isLogging ? 'Reporting…' : 'Report Honestly',
            loading: isLogging,
            backgroundColor: EgColors.danger,
            onPressed: isLogging ? null : onLog,
          ),
          const SizedBox(height: 10),
          EgPrimaryButton(
            label: 'Cancel',
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

class _SlipResultView extends StatelessWidget {
  const _SlipResultView({required this.result, required this.onClose});

  final VirtueSlipResult result;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ai = result.aiResponse;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: EgColors.borderSubtle, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: 20),
          if (ai != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: EgColors.danger.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: EgColors.danger.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ai.acknowledgement, style: EgFonts.style(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EgColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: EgColors.warning.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: EgColors.warning, size: 16),
                            const SizedBox(width: 6),
                            Text('Do this now:', style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: EgColors.warning)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(ai.microTask, style: EgFonts.style(fontSize: 14, height: 1.45)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ai.motivationClose,
                    style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600, color: EgColors.slate400).copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ai.pointsDeductedMessage,
                    style: EgFonts.style(fontSize: 12, color: EgColors.danger),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (result.punishmentSuggestions.isNotEmpty) ...[
            Text('Recovery Challenges', style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Choose one to earn back some points:',
              style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
            ),
            const SizedBox(height: 10),
            ...result.punishmentSuggestions.take(3).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PunishmentTile(punishment: p),
                )),
            const SizedBox(height: 16),
          ],
          EgPrimaryButton(
            label: 'Got it — Back to progress',
            icon: Icons.arrow_forward_rounded,
            backgroundColor: const Color(0xFF8B5CF6),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _PunishmentTile extends StatelessWidget {
  const _PunishmentTile({required this.punishment});

  final Map<String, dynamic> punishment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EgColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center_rounded, color: EgColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  punishment['title'] as String? ?? 'Recovery task',
                  style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '~${punishment['estimated_minutes'] ?? 10} min',
                  style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
                ),
              ],
            ),
          ),
          Text(
            '+${punishment['points'] ?? 5} pts',
            style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: EgColors.success),
          ),
        ],
      ),
    );
  }
}
