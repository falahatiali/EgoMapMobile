import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/virtue_models.dart';
import '../providers/virtue_provider.dart';

// ignore_for_file: unnecessary_underscores

const _kVirtueColor = Color(0xFF8B5CF6);

class VirtueHabitPickerScreen extends ConsumerStatefulWidget {
  const VirtueHabitPickerScreen({super.key});

  @override
  ConsumerState<VirtueHabitPickerScreen> createState() => _VirtueHabitPickerScreenState();
}

class _VirtueHabitPickerScreenState extends ConsumerState<VirtueHabitPickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  VirtueHabit? _selectedHabit;
  final _customController = TextEditingController();
  bool _isAnalyzing = false;
  bool _isStarting = false;
  VirtueHabit? _analyzedCustomHabit;
  String _goalType = 'days_count';
  int _goalTarget = 21;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _analyzeCustomHabit() async {
    final description = _customController.text.trim();
    if (description.length < 5) return;

    setState(() {
      _isAnalyzing = true;
      _analyzedCustomHabit = null;
    });

    try {
      final habit = await ref.read(virtueRepositoryProvider).analyzeCustomHabit(description);
      setState(() {
        _analyzedCustomHabit = habit;
        _selectedHabit = habit;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI analysis failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _startRoutine() async {
    final habit = _selectedHabit;
    if (habit == null) return;

    setState(() => _isStarting = true);
    HapticFeedback.mediumImpact();

    final ok = await ref.read(virtueHubProvider.notifier).startRoutine(
          habitId: habit.id,
          personalNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
          goalType: _goalType,
          goalTarget: _goalTarget,
        );

    if (mounted) {
      setState(() => _isStarting = false);
      if (ok) {
        HapticFeedback.heavyImpact();
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EgColors.navy950,
      appBar: AppBar(
        backgroundColor: EgColors.navy900,
        title: Text('Choose Your Mission', style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _kVirtueColor,
          unselectedLabelColor: EgColors.slate500,
          indicatorColor: _kVirtueColor,
          tabs: const [
            Tab(text: 'Suggested'),
            Tab(text: 'My Own Habit'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SuggestedTab(
            selectedHabit: _selectedHabit,
            onSelect: (h) => setState(() => _selectedHabit = h),
          ),
          _CustomTab(
            controller: _customController,
            isAnalyzing: _isAnalyzing,
            analyzedHabit: _analyzedCustomHabit,
            onAnalyze: _analyzeCustomHabit,
          ),
        ],
      ),
      bottomSheet: _selectedHabit != null
          ? _StartRoutineSheet(
              habit: _selectedHabit!,
              noteController: _noteController,
              goalType: _goalType,
              goalTarget: _goalTarget,
              isStarting: _isStarting,
              onGoalTypeChanged: (v) => setState(() => _goalType = v),
              onGoalTargetChanged: (v) => setState(() => _goalTarget = v),
              onStart: _startRoutine,
            )
          : null,
    );
  }
}

class _SuggestedTab extends ConsumerWidget {
  const _SuggestedTab({required this.selectedHabit, required this.onSelect});

  final VirtueHabit? selectedHabit;
  final ValueChanged<VirtueHabit> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(virtueHabitsProvider);

    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _kVirtueColor)),
      error: (e, _) => Center(
        child: Text('Failed to load', style: EgFonts.style(color: EgColors.danger)),
      ),
      data: (habits) {
        final grouped = <String, List<VirtueHabit>>{};
        for (final h in habits) {
          grouped.putIfAbsent(h.categoryLabel, () => []).add(h);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(EgSpacing.page, 16, EgSpacing.page, 220),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        entry.value.first.categoryIcon,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: EgFonts.style(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: EgColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map((habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HabitTile(
                        habit: habit,
                        selected: selectedHabit?.id == habit.id,
                        onTap: () => onSelect(habit),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.selected,
    required this.onTap,
  });

  final VirtueHabit habit;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _kVirtueColor.withValues(alpha: 0.12) : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _kVirtueColor.withValues(alpha: 0.5) : EgColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: EgFonts.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selected ? EgColors.textPrimary : EgColors.textPrimary,
                    ),
                  ),
                  if (habit.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      habit.description!,
                      style: EgFonts.style(fontSize: 13, height: 1.4, color: EgColors.slate500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: _kVirtueColor, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: EgColors.borderSubtle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomTab extends StatelessWidget {
  const _CustomTab({
    required this.controller,
    required this.isAnalyzing,
    required this.analyzedHabit,
    required this.onAnalyze,
  });

  final TextEditingController controller;
  final bool isAnalyzing;
  final VirtueHabit? analyzedHabit;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 24, EgSpacing.page, 220),
      children: [
        Text(
          'Describe the habit in your own words',
          style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Our AI will analyse its root cause and create a personalised plan for you.',
          style: EgFonts.style(fontSize: 13, height: 1.5, color: EgColors.slate500),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          maxLines: 4,
          style: EgFonts.style(fontSize: 15),
          decoration: InputDecoration(
            hintText: "e.g. I always use sarcasm when I'm upset instead of saying how I feel...",
            hintStyle: EgFonts.style(fontSize: 14, color: EgColors.slate500),
            filled: true,
            fillColor: const Color(0x08FFFFFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: EgColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: EgColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kVirtueColor),
            ),
          ),
        ),
        const SizedBox(height: 14),
        EgPrimaryButton(
          label: isAnalyzing ? 'Analysing with AI…' : 'Analyse My Habit',
          icon: Icons.auto_awesome_rounded,
          loading: isAnalyzing,
          backgroundColor: _kVirtueColor,
          onPressed: isAnalyzing ? null : onAnalyze,
        ),
        if (analyzedHabit != null) ...[
          const SizedBox(height: 24),
          _AiCoachingCard(habit: analyzedHabit!),
        ],
      ],
    );
  }
}

class _AiCoachingCard extends StatelessWidget {
  const _AiCoachingCard({required this.habit});

  final VirtueHabit habit;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kVirtueColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  habit.categoryLabel,
                  style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w600, color: _kVirtueColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (habit.aiRootCause != null) ...[
            Text('Root Cause', style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: EgColors.slate400)),
            const SizedBox(height: 4),
            Text(habit.aiRootCause!, style: EgFonts.style(fontSize: 14, height: 1.5)),
            const SizedBox(height: 14),
          ],
          if (habit.aiSteps.isNotEmpty) ...[
            Text('Your Daily Practice', style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: EgColors.slate400)),
            const SizedBox(height: 8),
            ...habit.aiSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(top: 1),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _kVirtueColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${step.order}',
                          style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w700, color: _kVirtueColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.action, style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(step.dailyPractice, style: EgFonts.style(fontSize: 13, height: 1.45, color: EgColors.slate400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (habit.aiAffirmation != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kVirtueColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kVirtueColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded, color: _kVirtueColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.aiAffirmation!,
                      style: EgFonts.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kVirtueColor,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StartRoutineSheet extends StatelessWidget {
  const _StartRoutineSheet({
    required this.habit,
    required this.noteController,
    required this.goalType,
    required this.goalTarget,
    required this.isStarting,
    required this.onGoalTypeChanged,
    required this.onGoalTargetChanged,
    required this.onStart,
  });

  final VirtueHabit habit;
  final TextEditingController noteController;
  final String goalType;
  final int goalTarget;
  final bool isStarting;
  final ValueChanged<String> onGoalTypeChanged;
  final ValueChanged<int> onGoalTargetChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(EgSpacing.page, 16, EgSpacing.page, bottomInset + 16),
      decoration: BoxDecoration(
        color: EgColors.navy900,
        border: Border(top: BorderSide(color: EgColors.borderSubtle)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: _kVirtueColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  habit.name,
                  style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w700, color: _kVirtueColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _GoalChip(
                label: '21-Day',
                selected: goalType == 'days_count' && goalTarget == 21,
                onTap: () {
                  onGoalTypeChanged('days_count');
                  onGoalTargetChanged(21);
                },
              ),
              const SizedBox(width: 8),
              _GoalChip(
                label: '30 Wins',
                selected: goalType == 'success_count' && goalTarget == 30,
                onTap: () {
                  onGoalTypeChanged('success_count');
                  onGoalTargetChanged(30);
                },
              ),
              const SizedBox(width: 8),
              _GoalChip(
                label: '90-Day',
                selected: goalType == 'days_count' && goalTarget == 90,
                onTap: () {
                  onGoalTypeChanged('days_count');
                  onGoalTargetChanged(90);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          EgPrimaryButton(
            label: isStarting ? 'Starting…' : 'Begin This Mission',
            icon: Icons.play_arrow_rounded,
            loading: isStarting,
            backgroundColor: _kVirtueColor,
            onPressed: isStarting ? null : onStart,
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kVirtueColor.withValues(alpha: 0.2) : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? _kVirtueColor : EgColors.borderSubtle),
        ),
        child: Text(
          label,
          style: EgFonts.style(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? _kVirtueColor : EgColors.slate400,
          ),
        ),
      ),
    );
  }
}
