import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/bootstrap_models.dart';

class DiagnosticPanelCard extends StatefulWidget {
  const DiagnosticPanelCard({super.key, required this.panel});

  final DiagnosticPanel panel;

  @override
  State<DiagnosticPanelCard> createState() => _DiagnosticPanelCardState();
}

class _DiagnosticPanelCardState extends State<DiagnosticPanelCard> {
  bool _animated = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _animated = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final panel = widget.panel;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x14FFFFFF)),
        color: const Color(0x660F172A),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _PulseDot(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  panel.title,
                  style: EgFonts.style(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: EgColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _MetricRow(
            label: panel.currentState,
            value: panel.currentStateValue,
            valueColor: EgColors.warning,
          ),
          const _RowDivider(),
          _MetricRow(
            label: panel.mainRisk,
            value: panel.mainRiskValue,
            valueColor: EgColors.danger,
            progress: _animated ? 0.78 : 0,
            progressColor: EgColors.warning,
          ),
          const _RowDivider(),
          _MetricRow(
            label: panel.ghostMode,
            value: panel.ghostModeValue,
            valueColor: const Color(0xFF7DD3FC),
          ),
          const _RowDivider(),
          _MetricRow(
            label: panel.rebuildIndex,
            value: panel.rebuildValue,
            valueColor: EgColors.textPrimary,
            progress: _animated ? 0.32 : 0,
            progressColor: EgColors.accent,
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: EgColors.success.withValues(alpha: 0.6 + _controller.value * 0.4),
          ),
        );
      },
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Divider(height: 1, color: EgColors.borderSubtle),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.progress,
    this.progressColor = EgColors.accent,
  });

  final String label;
  final String value;
  final Color valueColor;
  final double? progress;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: EgFonts.style(
                  fontSize: 14,
                  height: 1.4,
                  color: EgColors.slate500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              value,
              style: EgFonts.style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: valueColor,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 4,
                  backgroundColor: const Color(0x14FFFFFF),
                  color: progressColor,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
