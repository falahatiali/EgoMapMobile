import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/app_routes.dart';
import '../theme/eg_colors.dart';
import '../theme/eg_fonts.dart';
import '../theme/eg_spacing.dart';
import 'eg_background.dart';

class EgFlowScaffold extends StatelessWidget {
  const EgFlowScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.showHome = true,
    this.trailing,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final bool showHome;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();

    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, EgSpacing.page, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (canPop)
                      _HeaderIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => context.pop(),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: EgFonts.style(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.4,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: EgFonts.style(fontSize: 15, height: 1.4, color: EgColors.slate400),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (trailing != null)
                      trailing!
                    else if (showHome)
                      _HeaderIconButton(
                        icon: Icons.home_rounded,
                        onPressed: () => context.go(AppRoutes.home),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(child: body),
              if (bottom != null) bottom!,
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EgColors.borderSubtle),
          ),
          child: Icon(icon, size: 22, color: EgColors.textPrimary),
        ),
      ),
    );
  }
}
