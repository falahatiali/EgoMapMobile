import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';

class MissionToolPlaceholderScreen extends StatelessWidget {
  const MissionToolPlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return EgFlowScaffold(
      title: title,
      body: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EgColors.success.withValues(alpha: 0.12),
                border: Border.all(color: EgColors.success.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, size: 38, color: EgColors.success),
            ),
            const SizedBox(height: 22),
            Text(title, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400),
            ),
            const Spacer(),
            EgPrimaryButton(
              label: 'Back to mission',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
