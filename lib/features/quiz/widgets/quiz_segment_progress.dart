import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';

class QuizSegmentProgress extends StatelessWidget {
  const QuizSegmentProgress({
    super.key,
    required this.total,
    required this.current,
    required this.percent,
  });

  final int total;
  final int current;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(total, (index) {
            final step = index + 1;
            final isDone = step < current;
            final isCurrent = step == current;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == total - 1 ? 0 : 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  height: isCurrent ? 6 : 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: isDone || isCurrent
                        ? EgColors.success
                        : const Color(0x1FFFFFFF),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: EgColors.success.withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$percent%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: EgColors.success,
            ),
          ),
        ),
      ],
    );
  }
}
