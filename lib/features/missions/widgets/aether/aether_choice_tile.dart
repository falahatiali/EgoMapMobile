import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/eg_colors.dart';
import '../../../../core/theme/eg_fonts.dart';

class AetherChoiceTile extends StatelessWidget {
  const AetherChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.autoAdvance = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  final bool autoAdvance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1 : 0),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Transform.translate(
            offset: Offset(0, -2 * t),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? const Color(0xCCF8FAFC) : EgColors.borderSubtle,
                  width: selected ? 1.5 : 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selected
                      ? [const Color(0x1AFFFFFF), EgColors.success.withValues(alpha: 0.12)]
                      : [const Color(0x0AFFFFFF), const Color(0x05FFFFFF)],
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: EgColors.success.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: EgFonts.style(
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? const Color(0xFFF8FAFC) : EgColors.slate500,
                        width: 2,
                      ),
                      color: selected ? const Color(0xFF34D399) : Colors.transparent,
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded, size: 14, color: Color(0xFF041016))
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
