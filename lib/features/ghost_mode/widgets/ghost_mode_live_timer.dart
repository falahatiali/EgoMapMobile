import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/ghost_mode_models.dart';

class GhostModeLiveTimer extends StatefulWidget {
  const GhostModeLiveTimer({
    super.key,
    required this.timer,
    required this.copy,
  });

  final GhostModeTimer timer;
  final GhostModeCopy copy;

  @override
  State<GhostModeLiveTimer> createState() => _GhostModeLiveTimerState();
}

class _GhostModeLiveTimerState extends State<GhostModeLiveTimer> {
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
  void didUpdateWidget(covariant GhostModeLiveTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.timer.protocolUuid != widget.timer.protocolUuid) {
      _syncClock();
    }
  }

  void _syncClock() {
    final startedAt = DateTime.tryParse(widget.timer.streakStartedAt ?? '');
    final endsAt = DateTime.tryParse(widget.timer.targetEndsAt ?? '');
    final serverNow = DateTime.tryParse(widget.timer.serverNow ?? '');

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

  int get _remainingSeconds {
    final remaining = _endsAt.difference(_now).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  String _pad2(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final elapsed = _elapsedSeconds;
    final remaining = _remainingSeconds;
    final days = elapsed ~/ 86400;
    final hours = (elapsed % 86400) ~/ 3600;
    final minutes = (elapsed % 3600) ~/ 60;
    final seconds = elapsed % 60;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          decoration: BoxDecoration(
            color: EgColors.navy900.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            border: Border.all(color: EgColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: EgColors.success.withValues(alpha: 0.1),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85,
                      colors: [
                        EgColors.success.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimerUnit(value: '$days', label: widget.copy.unitDays),
                    const _TimerSeparator(),
                    _TimerUnit(value: _pad2(hours), label: widget.copy.unitHours),
                    const _TimerSeparator(),
                    _TimerUnit(value: _pad2(minutes), label: widget.copy.unitMinutes),
                    const _TimerSeparator(),
                    _TimerUnit(
                      value: _pad2(seconds),
                      label: widget.copy.unitSeconds,
                      accent: EgColors.accentBright,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DurationMetricCard(
                label: widget.copy.statElapsed,
                seconds: elapsed,
                copy: widget.copy,
                accent: EgColors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DurationMetricCard(
                label: widget.copy.remainingLabel,
                seconds: remaining,
                copy: widget.copy,
                accent: EgColors.accentBright,
                icon: Icons.hourglass_top_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimerUnit extends StatelessWidget {
  const _TimerUnit({
    required this.value,
    required this.label,
    this.accent = EgColors.textPrimary,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 62,
        child: Column(
          children: [
            Text(
              value,
              style: EgFonts.style(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: accent,
                height: 1,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: EgFonts.style(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: EgColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerSeparator extends StatelessWidget {
  const _TimerSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Text(
        ':',
        style: EgFonts.style(
          fontSize: 30,
          fontWeight: FontWeight.w300,
          color: EgColors.slate500.withValues(alpha: 0.7),
          height: 1,
        ),
      ),
    );
  }
}

class _DurationMetricCard extends StatelessWidget {
  const _DurationMetricCard({
    required this.label,
    required this.seconds,
    required this.copy,
    required this.accent,
    required this.icon,
  });

  final String label;
  final int seconds;
  final GhostModeCopy copy;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(EgSpacing.radius),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: EgFonts.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: EgColors.slate400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (days > 0) ...[
            _DurationChunk(value: '$days', unit: copy.unitDays, accent: accent),
            const SizedBox(height: 8),
          ],
          _DurationChunk(value: '$hours', unit: copy.unitHours, accent: accent),
          const SizedBox(height: 8),
          _DurationChunk(value: '$minutes', unit: copy.unitMinutes, accent: accent),
        ],
      ),
    );
  }
}

class _DurationChunk extends StatelessWidget {
  const _DurationChunk({
    required this.value,
    required this.unit,
    required this.accent,
  });

  final String value;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: EgFonts.style(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
            color: accent,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            unit,
            style: EgFonts.style(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: EgColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
