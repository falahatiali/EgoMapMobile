import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/eg_colors.dart';
import '../../../../core/theme/eg_fonts.dart';

class AetherBodyCard extends StatelessWidget {
  const AetherBodyCard({
    super.key,
    required this.variant,
    required this.label,
    required this.selected,
    required this.onTap,
    this.gender = 'male',
    this.goalMode = false,
  });

  final String variant;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String gender;
  final bool goalMode;

  @override
  Widget build(BuildContext context) {
    final accent = goalMode ? const Color(0xFF818CF8) : EgColors.success;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent.withValues(alpha: 0.75) : EgColors.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
            gradient: RadialGradient(
              center: const Alignment(0, -0.65),
              radius: 1.2,
              colors: selected
                  ? [accent.withValues(alpha: 0.18), const Color(0x08FFFFFF)]
                  : [const Color(0x10FFFFFF), const Color(0x04FFFFFF)],
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 132,
                child: CustomPaint(
                  painter: _BodySilhouettePainter(
                    variant: variant,
                    gender: gender,
                    selected: selected,
                    accent: accent,
                  ),
                  size: const Size(double.infinity, 132),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: EgFonts.style(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? EgColors.textPrimary : EgColors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodySilhouettePainter extends CustomPainter {
  _BodySilhouettePainter({
    required this.variant,
    required this.gender,
    required this.selected,
    required this.accent,
  });

  final String variant;
  final String gender;
  final bool selected;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final widthScale = switch (variant) {
      'slender' || 'lean' => 0.82,
      'average' || 'athletic' => 1.0,
      'stocky' || 'defined' => 1.12,
      'heavy' || 'muscular' => 1.28,
      _ => 1.0,
    };

    final hipScale = gender == 'female' ? 1.08 : 1.0;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: selected ? 0.95 : 0.82),
          EgColors.slate500.withValues(alpha: 0.55),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.08);
    canvas.scale(widthScale * hipScale, 1);

    final head = Rect.fromCenter(center: Offset(0, 18), width: 26, height: 30);
    canvas.drawOval(head, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, 38), width: 12, height: 12), const Radius.circular(4)),
      paint,
    );

    final torso = Path()
      ..moveTo(-18, 48)
      ..quadraticBezierTo(-22, 72, -16, 98)
      ..quadraticBezierTo(-8, 112, 0, 114)
      ..quadraticBezierTo(8, 112, 16, 98)
      ..quadraticBezierTo(22, 72, 18, 48)
      ..close();
    canvas.drawPath(torso, paint);

    canvas.drawPath(
      Path()
        ..moveTo(-18, 50)
        ..quadraticBezierTo(-30, 72, -26, 104)
        ..quadraticBezierTo(-22, 112, -16, 108)
        ..quadraticBezierTo(-14, 86, -16, 64)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(18, 50)
        ..quadraticBezierTo(30, 72, 26, 104)
        ..quadraticBezierTo(22, 112, 16, 108)
        ..quadraticBezierTo(14, 86, 16, 64)
        ..close(),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(-10, 114)
        ..quadraticBezierTo(-12, 150, -8, 186)
        ..quadraticBezierTo(-6, 198, -2, 198)
        ..quadraticBezierTo(0, 186, -2, 150)
        ..quadraticBezierTo(-4, 128, -4, 114)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(10, 114)
        ..quadraticBezierTo(12, 150, 8, 186)
        ..quadraticBezierTo(6, 198, 2, 198)
        ..quadraticBezierTo(0, 186, 2, 150)
        ..quadraticBezierTo(4, 128, 4, 114)
        ..close(),
      paint,
    );

    if (variant == 'defined' || variant == 'muscular') {
      final detail = Paint()
        ..color = const Color(0x440F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(
        Path()
          ..moveTo(-8, 68)
          ..quadraticBezierTo(0, 78, 8, 68),
        detail,
      );
    }

    canvas.restore();

    if (selected) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - 8),
          width: size.width * 0.55,
          height: 10,
        ),
        Paint()..color = accent.withValues(alpha: 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BodySilhouettePainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.gender != gender ||
        oldDelegate.selected != selected;
  }
}

class AetherMetricPicker extends StatelessWidget {
  const AetherMetricPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    required this.ticks,
    required this.formatValue,
  });

  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final ValueChanged<double> onChanged;
  final List<double> ticks;
  final String Function(double value) formatValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EgColors.borderSubtle),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatValue(value),
                style: EgFonts.style(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  unit,
                  style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w600, color: EgColors.slate400),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: EgColors.success,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              thumbColor: const Color(0xFFF8FAFC),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: (next) {
                HapticFeedback.selectionClick();
                onChanged(next);
              },
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ticks.map((tick) {
              final selected = (value - tick).abs() < 0.01;
              return ActionChip(
                label: Text(formatValue(tick)),
                backgroundColor: selected ? EgColors.success.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.04),
                side: BorderSide(color: selected ? EgColors.success : EgColors.borderSubtle),
                onPressed: () => onChanged(tick),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
