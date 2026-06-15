import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../models/virtue_models.dart';
import '../providers/virtue_provider.dart';

const _kVirtueColor = Color(0xFF8B5CF6);

class VirtueLogSuccessSheet extends ConsumerStatefulWidget {
  const VirtueLogSuccessSheet({super.key, required this.routine});

  final VirtueRoutine routine;

  static Future<bool?> show(BuildContext context, {required VirtueRoutine routine}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VirtueLogSuccessSheet(routine: routine),
    );
  }

  @override
  ConsumerState<VirtueLogSuccessSheet> createState() => _VirtueLogSuccessSheetState();
}

class _VirtueLogSuccessSheetState extends ConsumerState<VirtueLogSuccessSheet> {
  final _situationController = TextEditingController();
  String? _selectedEmotion;
  bool _isLogging = false;
  String? _aiEncouragement;

  final _emotions = ['😊 Proud', '🙂 Calm', '💪 Strong', '😌 Peaceful', '🤩 Amazing'];

  @override
  void dispose() {
    _situationController.dispose();
    super.dispose();
  }

  Future<void> _logSuccess() async {
    setState(() => _isLogging = true);
    HapticFeedback.mediumImpact();

    try {
      final result = await ref.read(virtueRepositoryProvider).logSuccess(
            widget.routine.id,
            situation: _situationController.text.trim().isNotEmpty ? _situationController.text.trim() : null,
            emotionalState: _selectedEmotion,
          );

      final successLog = result['success_log'] as Map<String, dynamic>?;
      final encouragement = successLog?['ai_encouragement'] as String?;

      await ref.read(virtueHubProvider.notifier).refresh();

      if (mounted) {
        if (encouragement != null && encouragement.isNotEmpty) {
          setState(() {
            _aiEncouragement = encouragement;
            _isLogging = false;
          });
          await Future.delayed(const Duration(seconds: 3));
        }
        if (mounted) {
          HapticFeedback.heavyImpact();
          Navigator.of(context).pop(true);
        }
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
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 36, height: 4, decoration: BoxDecoration(color: EgColors.borderSubtle, borderRadius: BorderRadius.circular(99))),
          ),
          const SizedBox(height: 20),
          if (_aiEncouragement != null) ...[
            _EncouragementBanner(message: _aiEncouragement!),
          ] else ...[
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You Won Today!', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('+5 points incoming', style: EgFonts.style(fontSize: 13, color: EgColors.success)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('What happened? (optional)', style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _situationController,
              maxLines: 3,
              style: EgFonts.style(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. I was upset with a friend but spoke directly instead of being sarcastic…',
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
                  borderSide: const BorderSide(color: _kVirtueColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('How did you feel?', style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emotions.map((emotion) {
                final selected = _selectedEmotion == emotion;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmotion = selected ? null : emotion),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? EgColors.success.withValues(alpha: 0.15) : const Color(0x08FFFFFF),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: selected ? EgColors.success : EgColors.borderSubtle),
                    ),
                    child: Text(
                      emotion,
                      style: EgFonts.style(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            EgPrimaryButton(
              label: _isLogging ? 'Logging…' : 'Log & Earn +5 pts',
              icon: Icons.check_circle_rounded,
              loading: _isLogging,
              backgroundColor: EgColors.success,
              onPressed: _isLogging ? null : _logSuccess,
            ),
          ],
        ],
      ),
    );
  }
}

class _EncouragementBanner extends StatelessWidget {
  const _EncouragementBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EgColors.success.withValues(alpha: 0.1), _kVirtueColor.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EgColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('✨', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: EgFonts.style(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
