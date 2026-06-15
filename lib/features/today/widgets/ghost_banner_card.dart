import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../ghost_mode/models/ghost_mode_models.dart';

/// Compact Ghost Mode status card for the Today dashboard.
/// Tapping navigates to the full Ghost Mode screen.
class GhostBannerCard extends StatelessWidget {
  const GhostBannerCard({
    super.key,
    required this.ghostState,
    required this.loading,
    required this.onTap,
  });

  final GhostModeState? ghostState;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _Shell(
        borderColor: EgColors.borderSubtle,
        backgroundColor: EgColors.navy900.withValues(alpha: 0.55),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
          ),
        ),
      );
    }

    final mode = ghostState?.timer.mode;

    if (mode == 'active') {
      return _GhostActiveBanner(state: ghostState!, onTap: onTap);
    }

    if (mode == 'completed') {
      return _GhostCompletedBanner(state: ghostState!, onTap: onTap);
    }

    return _GhostSetupBanner(onTap: onTap);
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.child,
    required this.borderColor,
    required this.backgroundColor,
    this.onTap,
  });

  final Widget child;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EgSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );

    if (onTap == null) {
      return container;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: container,
      ),
    );
  }
}

// ── Setup (not started) ───────────────────────────────────────────────────────

class _GhostSetupBanner extends StatelessWidget {
  const _GhostSetupBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      onTap: onTap,
      borderColor: EgColors.borderSubtle,
      backgroundColor: EgColors.navy900.withValues(alpha: 0.55),
      child: Row(
        children: [
          _IconBadge(
            icon: Icons.shield_moon_outlined,
            color: EgColors.success,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ghost Mode',
                  style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Start your no-contact protocol',
                  style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: EgColors.slate500),
        ],
      ),
    );
  }
}

// ── Active ────────────────────────────────────────────────────────────────────

class _GhostActiveBanner extends StatefulWidget {
  const _GhostActiveBanner({required this.state, required this.onTap});

  final GhostModeState state;
  final VoidCallback onTap;

  @override
  State<_GhostActiveBanner> createState() => _GhostActiveBannerState();
}

class _GhostActiveBannerState extends State<_GhostActiveBanner> {
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
  void didUpdateWidget(covariant _GhostActiveBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.timer.protocolUuid != widget.state.timer.protocolUuid) {
      _syncClock();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
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
    return day.clamp(1, widget.state.timer.durationDays ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.state.timer;
    final percent = _progressPercent;
    final day = _currentDay;
    final total = timer.durationDays ?? 90;

    return _Shell(
      onTap: widget.onTap,
      borderColor: EgColors.success.withValues(alpha: 0.3),
      backgroundColor: EgColors.success.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(icon: Icons.shield_moon_rounded, color: EgColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GHOST MODE · ACTIVE',
                      style: EgFonts.style(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: EgColors.success,
                      ),
                    ),
                    Text(
                      'Day $day of $total',
                      style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: EgColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$percent%',
                  style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: EgColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percent / 100.0,
              backgroundColor: EgColors.success.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(EgColors.success),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 14, color: EgColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.state.wallet.streakDays} day streak',
                    style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'View details',
                    style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: EgColors.slate500),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Completed ─────────────────────────────────────────────────────────────────

class _GhostCompletedBanner extends StatelessWidget {
  const _GhostCompletedBanner({required this.state, required this.onTap});

  final GhostModeState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Shell(
      onTap: onTap,
      borderColor: EgColors.accent.withValues(alpha: 0.3),
      backgroundColor: EgColors.accent.withValues(alpha: 0.06),
      child: Row(
        children: [
          _IconBadge(icon: Icons.emoji_events_outlined, color: EgColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.copy.completedTitle,
                  style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Start a new protocol',
                  style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: EgColors.slate500),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
