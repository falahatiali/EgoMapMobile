import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/theme/eg_text.dart';

class FlowPills extends StatelessWidget {
  const FlowPills({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: EgSpacing.sm,
      runSpacing: EgSpacing.sm,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: EgColors.borderSubtle),
              ),
              child: Text(item, style: EgText.caption(color: EgColors.slate400)),
            ),
          )
          .toList(),
    );
  }
}
