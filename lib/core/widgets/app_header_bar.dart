import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/auth_models.dart';
import '../theme/eg_colors.dart';
import '../theme/eg_fonts.dart';

class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({
    super.key,
    required this.brandLabel,
    this.user,
  });

  final String brandLabel;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
      child: Row(
        children: [
          Text(
            brandLabel,
            style: EgFonts.style(fontSize: 11, letterSpacing: 1.1, color: EgColors.slate500),
          ),
          const Spacer(),
          if (user != null)
            _UserChip(
              user: user!,
              onTap: () => context.go('/home'),
            )
          else
            TextButton(
              onPressed: () => context.push('/login'),
              style: TextButton.styleFrom(foregroundColor: EgColors.slate400),
              child: Text(
                'Sign in',
                style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
          decoration: BoxDecoration(
            color: const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: EgColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: EgColors.success.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.success),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w500, color: EgColors.slate400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
