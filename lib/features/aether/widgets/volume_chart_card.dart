import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/aether_volume_models.dart';
import '../providers/aether_provider.dart';

/// A self-loading card that shows the weekly volume (kg) trend chart.
///
/// Renders a line chart using [CustomPainter] — no external chart library
/// required. Shows the last N days of training volume.
class VolumeChartCard extends ConsumerWidget {
  const VolumeChartCard({super.key, required this.programUuid});

  final String programUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartAsync = ref.watch(volumeChartProvider(programUuid));

    return chartAsync.when(
      loading: () => _shell(child: const _LoadingPlaceholder()),
      error: (_, __) => const SizedBox.shrink(),
      data: (chart) {
        if (chart.isEmpty) {
          return _shell(child: const _EmptyState());
        }
        return _shell(child: _ChartBody(chart: chart));
      },
    );
  }

  Widget _shell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: EgColors.borderSubtle),
      ),
      child: child,
    );
  }
}

// ─── Chart body ──────────────────────────────────────────────────────────────

class _ChartBody extends StatefulWidget {
  const _ChartBody({required this.chart});

  final AetherVolumeChart chart;

  @override
  State<_ChartBody> createState() => _ChartBodyState();
}

class _ChartBodyState extends State<_ChartBody> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final chart = widget.chart;
    final days = chart.days;
    final maxVol = chart.maxVolume;

    // Total volume and best day
    final totalVolume =
        days.fold<double>(0, (sum, d) => sum + d.volumeKg).toStringAsFixed(0);
    final bestDay = days.reduce((a, b) => a.volumeKg > b.volumeKg ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: EgColors.accentBright,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Volume trend',
                style: EgFonts.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: EgColors.accentBright.withValues(alpha: 0.12),
                ),
                child: Text(
                  '${days.length}d',
                  style: EgFonts.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: EgColors.accentBright,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            '$totalVolume kg total · best day ${bestDay.volumeKg.toStringAsFixed(0)} kg',
            style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
          ),

          const SizedBox(height: 20),

          // ── Line chart ───────────────────────────────────────────────
          GestureDetector(
            onTapDown: (details) {
              final index = _indexFromOffset(
                details.localPosition,
                days.length,
                _chartWidth(context),
              );
              setState(() => _hoveredIndex = index);
            },
            onTapUp: (_) => setState(() => _hoveredIndex = null),
            onTapCancel: () => setState(() => _hoveredIndex = null),
            child: SizedBox(
              height: 140,
              child: CustomPaint(
                painter: _LinePainter(
                  data: days.map((d) => d.volumeKg).toList(),
                  maxValue: maxVol,
                  hoveredIndex: _hoveredIndex,
                  lineColor: EgColors.accentBright,
                  fillColorTop: EgColors.accentBright.withValues(alpha: 0.25),
                  fillColorBottom: EgColors.accentBright.withValues(alpha: 0.0),
                ),
                size: Size.infinite,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── X-axis labels ─────────────────────────────────────────────
          if (days.length >= 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _shortDate(days.first.date),
                  style: EgFonts.style(fontSize: 11, color: EgColors.slate500),
                ),
                Text(
                  _shortDate(days.last.date),
                  style: EgFonts.style(fontSize: 11, color: EgColors.slate500),
                ),
              ],
            ),

          // ── Tooltip ───────────────────────────────────────────────────
          if (_hoveredIndex != null && _hoveredIndex! < days.length) ...[
            const SizedBox(height: 12),
            _Tooltip(day: days[_hoveredIndex!]),
          ],
        ],
      ),
    );
  }

  double _chartWidth(BuildContext context) =>
      MediaQuery.of(context).size.width - EgSpacing.page * 2 - 32;

  int _indexFromOffset(Offset offset, int count, double width) {
    if (count <= 1) {
      return 0;
    }
    final step = width / (count - 1);
    return (offset.dx / step).round().clamp(0, count - 1);
  }

  String _shortDate(String iso) {
    final parts = iso.split('-');
    if (parts.length < 3) {
      return iso;
    }
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${parts[2]} ${months[m]}';
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.day});

  final AetherVolumeDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: EgColors.accentBright.withValues(alpha: 0.12),
        border: Border.all(color: EgColors.accentBright.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day.date,
            style: EgFonts.style(fontSize: 12, color: EgColors.slate400),
          ),
          const SizedBox(width: 12),
          Text(
            '${day.volumeKg.toStringAsFixed(1)} kg',
            style: EgFonts.style(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: EgColors.accentBright,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '· ${day.setsLogged} sets',
            style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder states ───────────────────────────────────────────────────────

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: EgColors.accentBright,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.bar_chart_rounded, size: 32, color: EgColors.slate500),
          const SizedBox(height: 10),
          Text(
            'Log some sets to see your volume trend.',
            textAlign: TextAlign.center,
            style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
          ),
        ],
      ),
    );
  }
}

// ─── CustomPainter ────────────────────────────────────────────────────────────

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.data,
    required this.maxValue,
    required this.lineColor,
    required this.fillColorTop,
    required this.fillColorBottom,
    this.hoveredIndex,
  });

  final List<double> data;
  final double maxValue;
  final Color lineColor;
  final Color fillColorTop;
  final Color fillColorBottom;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) {
      return;
    }

    final n = data.length;
    final xStep = n > 1 ? size.width / (n - 1) : size.width / 2;

    Offset point(int i) {
      final x = n > 1 ? i * xStep : size.width / 2;
      final y = maxValue == 0
          ? size.height
          : size.height - (data[i] / maxValue) * size.height * 0.9;
      return Offset(x, y);
    }

    // Build smooth path using cubic bezier.
    final linePath = Path();
    final fillPath = Path();

    linePath.moveTo(point(0).dx, point(0).dy);
    fillPath.moveTo(point(0).dx, size.height);
    fillPath.lineTo(point(0).dx, point(0).dy);

    for (int i = 1; i < n; i++) {
      final prev = point(i - 1);
      final curr = point(i);
      final cpX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
      fillPath.cubicTo(cpX, prev.dy, cpX, curr.dy, curr.dx, curr.dy);
    }

    fillPath.lineTo(point(n - 1).dx, size.height);
    fillPath.close();

    // Fill gradient under the line.
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColorTop, fillColorBottom],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Line stroke.
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Dots on each data point.
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < n; i++) {
      final p = point(i);
      final isHovered = i == hoveredIndex;
      final r = isHovered ? 6.0 : 3.5;
      canvas.drawCircle(p, r, dotPaint);
      if (isHovered) {
        canvas.drawCircle(p, r, dotBorderPaint);
        // Vertical guide line
        canvas.drawLine(
          Offset(p.dx, 0),
          Offset(p.dx, size.height),
          Paint()
            ..color = lineColor.withValues(alpha: 0.25)
            ..strokeWidth = 1,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) =>
      old.data != data ||
      old.maxValue != maxValue ||
      old.hoveredIndex != hoveredIndex;
}
