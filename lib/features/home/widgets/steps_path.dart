import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/bootstrap_models.dart';

class StepsPath extends StatelessWidget {
  const StepsPath({super.key, required this.steps});

  final List<StepItem> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(bottom: 28),
                color: EgColors.borderSubtle,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: i == 0 ? EgColors.accent : EgColors.borderSubtle,
                    ),
                    color: i == 0 ? const Color(0x1A6366F1) : Colors.transparent,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: EgFonts.style(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == 0 ? EgColors.accentBright : EgColors.slate500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  steps[i].title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: EgFonts.style(
                    fontSize: 11,
                    height: 1.3,
                    color: EgColors.slate400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
