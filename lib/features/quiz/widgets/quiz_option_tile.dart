import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/quiz_models.dart';

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
    this.showCheckbox = false,
    this.index,
  });

  final QuizOption option;
  final bool selected;
  final VoidCallback onTap;
  final bool showCheckbox;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(option.accent);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Transform.scale(
          scale: 1 + (t * 0.01),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Color.lerp(EgColors.borderSubtle, accent, selected ? 1 : 0)!,
                width: selected ? 1.5 : 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selected
                    ? [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0.06)]
                    : [const Color(0x0CFFFFFF), const Color(0x05FFFFFF)],
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? accent.withValues(alpha: 0.2) : const Color(0x12FFFFFF),
                    ),
                    child: Text(
                      '${index! + 1}',
                      style: EgFonts.style(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? accent : EgColors.slate500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (showCheckbox) ...[
                  Icon(
                    selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 20,
                    color: selected ? accent : EgColors.slate500,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    style: EgFonts.style(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: EgColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(String accent) {
    return switch (accent) {
      'blue' => const Color(0xFF60A5FA),
      'purple' => const Color(0xFFA78BFA),
      'amber' => const Color(0xFFFBBF24),
      'rose' => const Color(0xFFF87171),
      _ => EgColors.success,
    };
  }
}
