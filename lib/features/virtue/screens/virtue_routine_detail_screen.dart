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
import '../widgets/virtue_log_success_sheet.dart';
import '../widgets/virtue_log_slip_sheet.dart';

const _kVirtueColor = Color(0xFF8B5CF6);

class VirtueRoutineDetailScreen extends ConsumerStatefulWidget {
  const VirtueRoutineDetailScreen({super.key, required this.routineId});

  final int routineId;

  @override
  ConsumerState<VirtueRoutineDetailScreen> createState() => _VirtueRoutineDetailScreenState();
}

class _VirtueRoutineDetailScreenState extends ConsumerState<VirtueRoutineDetailScreen> {
  VirtueRoutine? _cached;

  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(virtueRoutineDetailProvider(widget.routineId));

    return Scaffold(
      backgroundColor: EgColors.navy950,
      appBar: AppBar(
        backgroundColor: EgColors.navy900,
        title: Text(
          _cached?.habit?.name ?? 'Virtue Mission',
          style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () => ref.invalidate(virtueRoutineDetailProvider(widget.routineId)),
          ),
        ],
      ),
      body: routineAsync.when(
        loading: () {
          if (_cached != null) return _DetailBody(routine: _cached!, onRefresh: _refresh);
          return const Center(child: CircularProgressIndicator(color: _kVirtueColor));
        },
        error: (e, _) => Center(
          child: EgPrimaryButton(
            label: 'Retry',
            onPressed: _refresh,
          ),
        ),
        data: (routine) {
          _cached = routine;
          return _DetailBody(routine: routine, onRefresh: _refresh);
        },
      ),
    );
  }

  void _refresh() => ref.invalidate(virtueRoutineDetailProvider(widget.routineId));
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.routine, required this.onRefresh});

  final VirtueRoutine routine;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _HeroSection(routine: routine)),
        SliverToBoxAdapter(child: _CoachingCard(habit: routine.habit)),
        if (routine.isActive) SliverToBoxAdapter(child: _ActionButtons(routine: routine, onRefresh: onRefresh)),
        if (routine.recentSuccesses.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(EgSpacing.page, 24, EgSpacing.page, 12),
              child: Text(
                'Recent Wins',
                style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverList.separated(
            itemCount: routine.recentSuccesses.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: EgSpacing.page),
              child: _SuccessLogTile(log: routine.recentSuccesses[i]),
            ),
          ),
        ],
        if (routine.isCompleted) SliverToBoxAdapter(child: _CompletionBanner(routine: routine)),
        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.routine});

  final VirtueRoutine routine;

  @override
  Widget build(BuildContext context) {
    final isCompleted = routine.isCompleted;

    return Padding(
      padding: const EdgeInsets.all(EgSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress ring + stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isCompleted ? EgColors.success.withValues(alpha: 0.1) : _kVirtueColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted ? EgColors.success.withValues(alpha: 0.3) : _kVirtueColor.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BigStat(
                      value: routine.currentStreak.toString(),
                      label: 'Current\nStreak',
                      icon: Icons.local_fire_department_rounded,
                      color: EgColors.warning,
                    ),
                    _CircularProgress(percent: routine.progressPercent, isCompleted: isCompleted),
                    _BigStat(
                      value: routine.bestStreak.toString(),
                      label: 'Best\nStreak',
                      icon: Icons.emoji_events_rounded,
                      color: _kVirtueColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SmallStat(label: 'Total Wins', value: routine.totalSuccesses.toString()),
                    Container(width: 1, height: 30, color: EgColors.borderSubtle),
                    _SmallStat(label: 'Slips', value: routine.totalSlips.toString()),
                    Container(width: 1, height: 30, color: EgColors.borderSubtle),
                    _SmallStat(label: 'Goal', value: '${routine.goalTarget} ${routine.goalType == "days_count" ? "days" : "wins"}'),
                  ],
                ),
              ],
            ),
          ),
          if (routine.habit?.aiAffirmation != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _kVirtueColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kVirtueColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_quote_rounded, size: 16, color: _kVirtueColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routine.habit!.aiAffirmation!,
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

class _CircularProgress extends StatelessWidget {
  const _CircularProgress({required this.percent, required this.isCompleted});

  final double percent;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? EgColors.success : _kVirtueColor;

    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            backgroundColor: EgColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation(color),
            strokeWidth: 6,
          ),
          if (isCompleted)
            Icon(Icons.check_rounded, color: EgColors.success, size: 30)
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w800, color: color),
                ),
                Text('done', style: EgFonts.style(fontSize: 10, color: EgColors.slate500)),
              ],
            ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.value, required this.label, required this.icon, required this.color});

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: EgFonts.style(fontSize: 11, color: EgColors.slate500, height: 1.3),
        ),
      ],
    );
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: EgFonts.style(fontSize: 11, color: EgColors.slate500)),
      ],
    );
  }
}

class _CoachingCard extends StatelessWidget {
  const _CoachingCard({required this.habit});

  final VirtueHabit? habit;

  @override
  Widget build(BuildContext context) {
    if (habit == null || habit!.aiSteps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EgSpacing.page),
      child: EgSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_alt_rounded, color: _kVirtueColor, size: 18),
                const SizedBox(width: 8),
                Text('Your Daily Practice', style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
            if (habit!.aiRootCause != null) ...[
              const SizedBox(height: 12),
              Text(
                habit!.aiRootCause!,
                style: EgFonts.style(fontSize: 13, height: 1.5, color: EgColors.slate400),
              ),
            ],
            const SizedBox(height: 14),
            for (final step in habit!.aiSteps)
              Padding(
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
                            Text(step.dailyPractice, style: EgFonts.style(fontSize: 12, height: 1.45, color: EgColors.slate400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.routine, required this.onRefresh});

  final VirtueRoutine routine;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 20, EgSpacing.page, 0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: EgPrimaryButton(
              label: 'I Won Today 🏆',
              icon: Icons.check_circle_rounded,
              backgroundColor: EgColors.success,
              onPressed: () async {
                HapticFeedback.mediumImpact();
                final result = await VirtueLogSuccessSheet.show(context, routine: routine);
                if (result == true) onRefresh();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: EgPrimaryButton(
              label: 'I Slipped',
              backgroundColor: EgColors.danger.withValues(alpha: 0.7),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final result = await VirtueLogSlipSheet.show(context, routine: routine);
                if (result == true) onRefresh();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessLogTile extends StatelessWidget {
  const _SuccessLogTile({required this.log});

  final VirtueSuccessLog log;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EgColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EgColors.success.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: EgColors.success, size: 16),
              const SizedBox(width: 6),
              Text(
                '+${log.pointsEarned} pts',
                style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: EgColors.success),
              ),
              const Spacer(),
              Text(
                _formatDate(log.loggedAt),
                style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
              ),
            ],
          ),
          if (log.situation != null && log.situation!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(log.situation!, style: EgFonts.style(fontSize: 13, height: 1.45)),
          ],
          if (log.aiEncouragement != null) ...[
            const SizedBox(height: 6),
            Text(
              log.aiEncouragement!,
              style: EgFonts.style(fontSize: 12, color: _kVirtueColor).copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.routine});

  final VirtueRoutine routine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EgSpacing.page),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [EgColors.success.withValues(alpha: 0.15), _kVirtueColor.withValues(alpha: 0.1)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: EgColors.success.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Mission Complete!',
              style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800, color: EgColors.success),
            ),
            const SizedBox(height: 8),
            Text(
              "You went ${routine.goalTarget} ${routine.goalType == "days_count" ? "days" : "wins"} strong. That's a new you.",
              textAlign: TextAlign.center,
              style: EgFonts.style(fontSize: 15, height: 1.5, color: EgColors.slate400),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: EgColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: EgColors.success.withValues(alpha: 0.3)),
              ),
              child: Text(
                '🏅 +200 points  •  Virtue Master badge',
                style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600, color: EgColors.success),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
