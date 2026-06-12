import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/ghost_mode_models.dart';
import '../providers/ghost_mode_provider.dart';
import '../widgets/ghost_mode_live_timer.dart';
import '../widgets/ghost_mode_shield_ring.dart';

class GhostModeScreen extends ConsumerStatefulWidget {
  const GhostModeScreen({super.key});

  @override
  ConsumerState<GhostModeScreen> createState() => _GhostModeScreenState();
}

class _GhostModeScreenState extends ConsumerState<GhostModeScreen> {
  int? _selectedDays;
  int _truthIndex = 0;
  bool _activating = false;
  bool _loadScheduled = false;

  void _scheduleLoadIfVisible() {
    if (_loadScheduled || !mounted) {
      return;
    }

    if (GoRouterState.of(context).uri.path != AppRoutes.ghostMode) {
      return;
    }

    final ui = ref.read(ghostModeProvider);
    if (ui.data != null || ui.loading) {
      return;
    }

    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;

      if (!mounted) {
        return;
      }

      if (GoRouterState.of(context).uri.path != AppRoutes.ghostMode) {
        return;
      }

      ref.read(ghostModeProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleLoadIfVisible();

    final ui = ref.watch(ghostModeProvider);

    ref.listen(ghostModeProvider, (previous, next) {
      final previousCount = previous?.data?.gamificationToasts.length ?? 0;
      final nextCount = next.data?.gamificationToasts.length ?? 0;

      if (nextCount <= previousCount || !mounted) {
        return;
      }

      final toast = next.data!.gamificationToasts.first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(toast.headline),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    if (ui.loading && ui.data == null) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
        ),
      );
    }

    if (ui.data == null && ui.loadError != null) {
      return _ErrorView(
        message: ui.loadError!,
        onRetry: () => ref.read(ghostModeProvider.notifier).refresh(),
      );
    }

    final state = ui.data;
    if (state == null) {
      return const SizedBox.shrink();
    }

    _selectedDays ??= state.timer.recommendedDays;

    return Stack(
      children: [
        RefreshIndicator(
          color: EgColors.success,
          onRefresh: () => ref.read(ghostModeProvider.notifier).refresh(),
          child: switch (state.timer.mode) {
            'active' => _ActiveView(
                state: state,
                truthIndex: _truthIndex,
                onNextTruth: _nextTruth,
              ),
            'completed' => _CompletedView(
                state: state,
                onRestart: () => ref.read(ghostModeProvider.notifier).refresh(),
              ),
            _ => _SetupView(
                state: state,
                selectedDays: _selectedDays!,
                errorMessage: ui.actionError,
                onSelectDays: (days) => setState(() => _selectedDays = days),
                onActivate: () => _activate(_selectedDays!),
                activating: _activating,
              ),
          },
        ),
        if (ui.refreshing)
          const Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
              ),
            ),
          ),
      ],
    );
  }

  void _nextTruth() {
    final flashes = ref.read(ghostModeProvider).data?.truthFlashes ?? [];
    if (flashes.isEmpty) {
      return;
    }

    setState(() {
      _truthIndex = (_truthIndex + 1).clamp(0, flashes.length - 1);
    });
  }

  Future<void> _activate(int days) async {
    if (_activating) {
      return;
    }

    setState(() => _activating = true);
    HapticFeedback.lightImpact();

    final success = await ref.read(ghostModeProvider.notifier).activate(days);

    if (mounted) {
      setState(() {
        if (success) {
          _truthIndex = 0;
        }
        _activating = false;
      });
    }
  }
}

class _GhostHeader extends StatelessWidget {
  const _GhostHeader({
    required this.copy,
    required this.statusLabel,
    required this.statusColor,
    this.icon = Icons.shield_moon_outlined,
  });

  final GhostModeCopy copy;
  final String statusLabel;
  final Color statusColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: EgColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: EgColors.success.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: EgColors.success.withValues(alpha: 0.15),
                blurRadius: 24,
              ),
            ],
          ),
          child: Icon(icon, size: 32, color: EgColors.success),
        ),
        const SizedBox(height: 16),
        Text(
          copy.pageTitle.toUpperCase(),
          style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: EgColors.slate500),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            statusLabel.toUpperCase(),
            style: EgFonts.style(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: statusColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          copy.pageSubtitle,
          textAlign: TextAlign.center,
          style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400),
        ),
      ],
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView({
    required this.state,
    required this.selectedDays,
    required this.onSelectDays,
    required this.onActivate,
    required this.activating,
    this.errorMessage,
  });

  final GhostModeState state;
  final int selectedDays;
  final ValueChanged<int> onSelectDays;
  final VoidCallback onActivate;
  final bool activating;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final copy = state.copy;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(EgSpacing.page),
      children: [
        _GhostHeader(
          copy: copy,
          statusLabel: copy.statusNotStarted,
          statusColor: EgColors.slate500,
        ),
        const SizedBox(height: 28),
        EgSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EgColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  copy.setupBadge,
                  textAlign: TextAlign.center,
                  style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w700, color: EgColors.accent),
                ),
              ),
              const SizedBox(height: 16),
              Text(copy.setupTitle, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                copy.setupSubtitle,
                textAlign: TextAlign.center,
                style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.timer.presets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final preset = state.timer.presets[index];
                  final selected = preset.days == selectedDays;

                  return _PresetCard(
                    preset: preset,
                    selected: selected,
                    recommendedLabel: copy.recommended,
                    onTap: () => onSelectDays(preset.days),
                  );
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(errorMessage!, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 13, color: EgColors.danger)),
              ],
              const SizedBox(height: 20),
              EgPrimaryButton(
                label: copy.startProtocol,
                icon: Icons.shield_moon_outlined,
                loading: activating,
                backgroundColor: EgColors.success,
                onPressed: onActivate,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.recommendedLabel,
    required this.onTap,
  });

  final GhostModePreset preset;
  final bool selected;
  final String recommendedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? EgColors.success.withValues(alpha: 0.1) : const Color(0x10FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? EgColors.success : EgColors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (preset.recommended)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: EgColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    recommendedLabel,
                    style: EgFonts.style(fontSize: 9, fontWeight: FontWeight.w700, color: EgColors.success),
                  ),
                ),
              Text(preset.label, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                preset.description,
                style: EgFonts.style(fontSize: 12, height: 1.4, color: EgColors.slate500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveView extends StatefulWidget {
  const _ActiveView({
    required this.state,
    required this.truthIndex,
    required this.onNextTruth,
  });

  final GhostModeState state;
  final int truthIndex;
  final VoidCallback onNextTruth;

  @override
  State<_ActiveView> createState() => _ActiveViewState();
}

class _ActiveViewState extends State<_ActiveView> {
  Timer? _ticker;
  late DateTime _startedAt;
  late DateTime _endsAt;
  late Duration _serverOffset;

  @override
  void initState() {
    super.initState();
    _syncClock();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ActiveView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state.timer.protocolUuid != widget.state.timer.protocolUuid) {
      _syncClock();
    }
  }

  void _syncClock() {
    final timer = widget.state.timer;
    final startedAt = DateTime.tryParse(timer.streakStartedAt ?? '');
    final endsAt = DateTime.tryParse(timer.targetEndsAt ?? '');
    final serverNow = DateTime.tryParse(timer.serverNow ?? '');

    _startedAt = startedAt ?? DateTime.now();
    _endsAt = endsAt ?? DateTime.now();
    _serverOffset = serverNow != null ? serverNow.difference(DateTime.now()) : Duration.zero;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime get _now => DateTime.now().add(_serverOffset);

  int get _elapsedSeconds {
    final elapsed = _now.difference(_startedAt).inSeconds;
    return elapsed < 0 ? 0 : elapsed;
  }

  int get _progressPercent {
    final total = _endsAt.difference(_startedAt).inSeconds;
    if (total <= 0) {
      return widget.state.timer.progressPercent ?? 0;
    }

    return ((_elapsedSeconds / total) * 100).clamp(0, 100).round();
  }

  int get _currentDay {
    final day = (_elapsedSeconds ~/ 86400) + 1;
    final total = widget.state.timer.durationDays ?? 1;

    return day.clamp(1, total);
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.state.timer;
    final copy = widget.state.copy;
    final wallet = widget.state.wallet;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(EgSpacing.page),
      children: [
        _GhostHeader(
          copy: copy,
          statusLabel: copy.statusActive,
          statusColor: EgColors.success,
        ),
        const SizedBox(height: 24),
        GhostModeShieldRing(
          percent: _progressPercent,
          copy: copy,
          day: _currentDay,
          totalDays: timer.durationDays ?? 0,
        ),
        const SizedBox(height: 20),
        GhostModeLiveTimer(timer: timer, copy: copy),
        const SizedBox(height: 20),
        _WalletStrip(wallet: wallet),
        const SizedBox(height: 16),
        EgSurface(
          child: Text(
            copy.mobileActiveNote,
            style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400),
          ),
        ),
        if (widget.state.truthFlashes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _TruthFlashCard(
            copy: copy,
            flashes: widget.state.truthFlashes,
            index: widget.truthIndex,
            onNext: widget.onNextTruth,
          ),
        ],
      ],
    );
  }
}

class _WalletStrip extends StatelessWidget {
  const _WalletStrip({required this.wallet});

  final GhostModeWallet wallet;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _WalletStat(icon: Icons.star_rounded, label: '${wallet.points}', color: EgColors.warning),
          const SizedBox(width: 16),
          _WalletStat(icon: Icons.paid_rounded, label: '${wallet.coins}', color: EgColors.accent),
          const SizedBox(width: 16),
          _WalletStat(icon: Icons.local_fire_department_rounded, label: '${wallet.streakDays}', color: EgColors.danger),
          const Spacer(),
          Text('Lv ${wallet.level}', style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.slate500)),
        ],
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  const _WalletStat({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TruthFlashCard extends StatelessWidget {
  const _TruthFlashCard({
    required this.copy,
    required this.flashes,
    required this.index,
    required this.onNext,
  });

  final GhostModeCopy copy;
  final List<String> flashes;
  final int index;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(copy.truthTitle, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(copy.truthSubtitle, style: EgFonts.style(fontSize: 13, color: EgColors.slate500)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x12FFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EgColors.borderSubtle),
            ),
            child: Text(
              flashes[index],
              style: EgFonts.style(fontSize: 15, height: 1.55),
            ),
          ),
          if (index < flashes.length - 1) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onNext, child: Text(copy.truthNext)),
          ],
        ],
      ),
    );
  }
}

class _CompletedView extends ConsumerWidget {
  const _CompletedView({
    required this.state,
    required this.onRestart,
  });

  final GhostModeState state;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = state.copy;
    final days = state.timer.durationDays ?? 0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(EgSpacing.page),
      children: [
        _GhostHeader(
          copy: copy,
          statusLabel: copy.completedBadge,
          statusColor: EgColors.accent,
          icon: Icons.emoji_events_outlined,
        ),
        const SizedBox(height: 28),
        EgSurface(
          child: Column(
            children: [
              Text(copy.completedTitle, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(
                copy.completedSubtitleFor(days),
                textAlign: TextAlign.center,
                style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400),
              ),
              const SizedBox(height: 20),
              EgPrimaryButton(
                label: copy.startAgain,
                icon: Icons.shield_moon_outlined,
                backgroundColor: EgColors.success,
                onPressed: () async {
                  await ref.read(ghostModeProvider.notifier).refresh();
                  onRestart();
                },
              ),
            ],
          ),
        ),
      ],
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
            Text('Could not load Ghost Mode', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w600)),
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
