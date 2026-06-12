import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';

class EmergencyTile extends StatelessWidget {
  const EmergencyTile({
    super.key,
    required this.title,
    required this.line1,
    this.onTap,
  });

  final String title;
  final String line1;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x22F472B6)),
            color: const Color(0x08F472B6),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFFF472B6), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: EgFonts.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: EgColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      line1,
                      style: EgFonts.style(fontSize: 13, height: 1.45, color: EgColors.slate500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: EgColors.slate500, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
