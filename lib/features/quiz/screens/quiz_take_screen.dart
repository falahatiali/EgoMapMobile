import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_animated_stage.dart';
import '../widgets/quiz_completing_overlay.dart';
import '../widgets/quiz_option_tile.dart';
import '../widgets/quiz_segment_progress.dart';

class QuizTakeScreen extends ConsumerStatefulWidget {
  const QuizTakeScreen({super.key, required this.sessionUuid});

  final String sessionUuid;

  @override
  ConsumerState<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends ConsumerState<QuizTakeScreen> {
  QuizSessionState? _state;
  bool _loading = true;
  bool _submitting = false;
  bool _isCompleting = false;
  String? _error;
  final Set<String> _multiSelection = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant QuizTakeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionUuid != widget.sessionUuid) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final state = await ref.read(quizRepositoryProvider).fetchSession(widget.sessionUuid);
      _applyState(state);
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  bool _isLastQuestion(QuizSessionState? state) {
    if (state == null) {
      return false;
    }

    final question = state.question;
    if (question != null) {
      return question.sortOrder >= state.progress.total;
    }

    return state.progress.current >= state.progress.total;
  }

  void _beginCompleting() {
    if (!_isCompleting) {
      setState(() => _isCompleting = true);
    }
  }

  Future<void> _navigateToResult() async {
    _beginCompleting();
    await Future<void>.delayed(Duration.zero);

    const minimumOverlay = Duration(milliseconds: 1400);
    await Future<void>.delayed(minimumOverlay);

    if (!mounted) {
      return;
    }

    context.go('/quiz/session/${widget.sessionUuid}/result');
  }

  void _applyState(QuizSessionState state) {
    if (state.screen == 'result') {
      unawaited(_navigateToResult());
      return;
    }

    setState(() {
      _state = state;
      _loading = false;
      _submitting = false;
      _isCompleting = false;
      _multiSelection.clear();
    });
  }

  Future<void> _submitSingle(String value) async {
    if (_submitting) {
      return;
    }

    setState(() {
      _submitting = true;
      if (_isLastQuestion(_state)) {
        _isCompleting = true;
      }
    });
    HapticFeedback.selectionClick();

    try {
      final state = await ref.read(quizRepositoryProvider).submitAnswer(
            widget.sessionUuid,
            value: value,
          );
      _applyState(state);
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _submitting = false;
        _isCompleting = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _submitting = false;
        _isCompleting = false;
      });
    }
  }

  Future<void> _submitMulti() async {
    if (_submitting || _multiSelection.isEmpty) {
      return;
    }

    setState(() {
      _submitting = true;
      if (_isLastQuestion(_state)) {
        _isCompleting = true;
      }
    });
    HapticFeedback.lightImpact();

    try {
      final state = await ref.read(quizRepositoryProvider).submitAnswer(
            widget.sessionUuid,
            value: _multiSelection.toList(),
          );
      _applyState(state);
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _submitting = false;
        _isCompleting = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _submitting = false;
        _isCompleting = false;
      });
    }
  }

  Future<void> _submitSafety(String value) async {
    if (_submitting) {
      return;
    }

    setState(() => _submitting = true);
    HapticFeedback.lightImpact();

    try {
      final state = await ref.read(quizRepositoryProvider).submitSafetyAnswer(
            widget.sessionUuid,
            int.parse(value),
          );
      _applyState(state);
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _submitting = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _submitting = false;
      });
    }
  }

  Future<void> _goBack() async {
    if (_submitting || _state == null || !_state!.canGoBack) {
      return;
    }

    setState(() => _submitting = true);

    try {
      final state = await ref.read(quizRepositoryProvider).goBack(widget.sessionUuid);
      _applyState(state);
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _submitting = false;
      });
    }
  }

  Future<void> _resetAfterCrisis() async {
    if (_submitting) {
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await ref.read(quizRepositoryProvider).resetAfterCrisis(widget.sessionUuid);
      if (!mounted) {
        return;
      }

      final storage = ref.read(appLocalStorageProvider);
      final slug = result.state.session.quizSlug;
      await storage.writeQuizSessionUuid(slug, result.state.session.uuid);

      if (!mounted) {
        return;
      }

      final newUuid = result.state.session.uuid;
      if (newUuid == widget.sessionUuid) {
        _applyState(result.state);
        return;
      }

      context.replace('/quiz/session/$newUuid');
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _submitting = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not reset the assessment. Please try again.';
        _submitting = false;
      });
    }
  }

  void _toggleMulti(QuizQuestion question, String value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_multiSelection.contains(value)) {
        _multiSelection.remove(value);
      } else if (_multiSelection.length < question.maxSelections) {
        _multiSelection.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressLabel = _state != null
        ? 'Question ${_state!.progress.current} of ${_state!.progress.total}'
        : 'Loading your session…';

    return EgFlowScaffold(
      title: 'Assessment',
      subtitle: _loading ? null : progressLabel,
      body: Stack(
        children: [
          _loading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
                  ),
                )
              : _error != null
                  ? _ErrorView(message: _error!, onRetry: _load)
                  : _buildBody(),
          if (_isCompleting) const QuizCompletingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final state = _state!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, EgSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.canGoBack && state.screen == 'question')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton.icon(
                onPressed: _submitting ? null : _goBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: Text(
                  'Previous question',
                  style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w600, color: EgColors.slate400),
                ),
              ),
            ),
          QuizSegmentProgress(
            total: state.progress.total,
            current: state.progress.current,
            percent: state.progress.percent,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: QuizAnimatedStage(
              stageKey: '${state.screen}-${state.session.currentSortOrder}',
              child: switch (state.screen) {
                'question' => _QuestionStage(
                  question: state.question!,
                  submitting: _submitting,
                  multiSelection: _multiSelection,
                  onSingleTap: _submitSingle,
                  onMultiToggle: _toggleMulti,
                  onMultiSubmit: _submitMulti,
                ),
                'safety' => _SafetyStage(
                  safety: state.safety!,
                  submitting: _submitting,
                  onSelect: _submitSafety,
                ),
                'crisis' => _CrisisStage(
                  crisis: state.crisis!,
                  submitting: _submitting,
                  onReset: _resetAfterCrisis,
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionStage extends StatelessWidget {
  const _QuestionStage({
    required this.question,
    required this.submitting,
    required this.multiSelection,
    required this.onSingleTap,
    required this.onMultiToggle,
    required this.onMultiSubmit,
  });

  final QuizQuestion question;
  final bool submitting;
  final Set<String> multiSelection;
  final ValueChanged<String> onSingleTap;
  final void Function(QuizQuestion question, String value) onMultiToggle;
  final VoidCallback onMultiSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: EgFonts.style(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
            color: EgColors.textPrimary,
          ),
        ),
        if (question.helpText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            question.helpText,
            style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400),
          ),
        ],
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: question.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final option = question.options[index];
              final selected = multiSelection.contains(option.value);

              return QuizOptionTile(
                option: option,
                index: question.isMultipleChoice ? null : index,
                selected: question.isMultipleChoice ? selected : false,
                showCheckbox: question.isMultipleChoice,
                onTap: submitting
                    ? () {}
                    : () {
                        if (question.isMultipleChoice) {
                          onMultiToggle(question, option.value);
                        } else {
                          onSingleTap(option.value);
                        }
                      },
              );
            },
          ),
        ),
        if (question.isMultipleChoice) ...[
          const SizedBox(height: 12),
          EgPrimaryButton(
            label: 'Continue',
            loading: submitting,
            backgroundColor: EgColors.success,
            onPressed: multiSelection.isEmpty ? null : onMultiSubmit,
          ),
          if (question.maxSelections > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${multiSelection.length} of ${question.maxSelections} selected',
                textAlign: TextAlign.center,
                style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
              ),
            ),
        ],
      ],
    );
  }
}

class _SafetyStage extends StatelessWidget {
  const _SafetyStage({
    required this.safety,
    required this.submitting,
    required this.onSelect,
  });

  final QuizSafetyPrompt safety;
  final bool submitting;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(label: safety.badge, color: EgColors.danger),
        const SizedBox(height: 18),
        Text(safety.title, style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 10),
        Text(safety.intro, style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: safety.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final option = safety.options[index];

              return QuizOptionTile(
                option: option,
                index: index,
                selected: false,
                onTap: submitting ? () {} : () => onSelect(option.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CrisisStage extends StatelessWidget {
  const _CrisisStage({
    required this.crisis,
    required this.submitting,
    required this.onReset,
  });

  final QuizCrisisPrompt crisis;
  final bool submitting;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(label: crisis.badge, color: EgColors.danger),
        const SizedBox(height: 18),
        Text(crisis.title, style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2)),
        const SizedBox(height: 10),
        Text(crisis.body, style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400)),
        const Spacer(),
        EgPrimaryButton(
          label: crisis.resetLabel,
          loading: submitting,
          backgroundColor: EgColors.danger,
          onPressed: onReset,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load quiz', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 14, color: EgColors.slate500)),
            const SizedBox(height: 20),
            EgPrimaryButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
