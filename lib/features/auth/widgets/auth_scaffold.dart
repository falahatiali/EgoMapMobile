import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_spacing.dart';
import '../../../core/theme/eg_text.dart';
import '../../../core/widgets/eg_background.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, EgSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: EgText.display(context).copyWith(fontSize: 28)),
                const SizedBox(height: EgSpacing.sm),
                Text(subtitle, style: EgText.body(context)),
                const SizedBox(height: EgSpacing.xl),
                child,
                if (footer != null) ...[
                  const SizedBox(height: EgSpacing.lg),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
