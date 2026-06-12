import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/auth_models.dart';
import '../../features/auth/providers/auth_controller.dart';
import '../../features/ghost_mode/providers/ghost_mode_provider.dart';
import '../theme/eg_colors.dart';
import '../theme/eg_fonts.dart';
import '../theme/eg_spacing.dart';
import '../widgets/eg_background.dart';
import 'app_routes.dart';

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  int get _currentIndex => navigationShell.currentIndex;

  void _goToBranch(int index, WidgetRef ref) {
    navigationShell.goBranch(
      index,
      initialLocation: index == _currentIndex,
    );

    if (index == AppRoutes.ghostModeBranch) {
      Future(() => ref.read(ghostModeProvider.notifier).ensureLoaded());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MainHeader(
                currentIndex: _currentIndex,
                user: user,
                onProfileTap: () {
                  if (user != null) {
                    _goToBranch(AppRoutes.profileBranch, ref);
                  } else {
                    context.push(AppRoutes.login);
                  }
                },
                onSignInTap: () => context.push(AppRoutes.login),
              ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
        bottomNavigationBar: _EgBottomNav(
          currentIndex: _currentIndex,
          isAuthenticated: auth.isAuthenticated,
          onSelectBranch: (index) => _goToBranch(index, ref),
          onSignIn: () => context.push(AppRoutes.login),
        ),
      ),
    );
  }
}

class _MainHeader extends StatelessWidget {
  const _MainHeader({
    required this.currentIndex,
    required this.user,
    required this.onProfileTap,
    required this.onSignInTap,
  });

  final int currentIndex;
  final UserModel? user;
  final VoidCallback onProfileTap;
  final VoidCallback onSignInTap;

  String get _title => switch (currentIndex) {
        AppRoutes.profileBranch => 'Profile',
        AppRoutes.ghostModeBranch => 'Ghost Mode',
        _ => 'EgoMap',
      };

  String get _subtitle => switch (currentIndex) {
        AppRoutes.profileBranch => 'Your recovery hub',
        AppRoutes.ghostModeBranch => 'No contact protocol',
        _ => 'Break the loop. Rebuild yourself.',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 12, EgSpacing.page, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EgColors.success.withValues(alpha: 0.25),
                  EgColors.accent.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EgColors.borderSubtle),
            ),
            child: const Icon(Icons.bolt_rounded, color: EgColors.success, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: EgFonts.style(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle,
                  style: EgFonts.style(fontSize: 15, height: 1.35, color: EgColors.slate400),
                ),
              ],
            ),
          ),
          if (user != null)
            _HeaderAvatar(user: user!, onTap: onProfileTap)
          else
            TextButton(
              onPressed: onSignInTap,
              style: TextButton.styleFrom(
                foregroundColor: EgColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                'Sign in',
                style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.user, required this.onTap});

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
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: EgColors.success.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: EgColors.success.withValues(alpha: 0.35)),
          ),
          child: Text(
            initial,
            style: EgFonts.style(fontSize: 19, fontWeight: FontWeight.w800, color: EgColors.success),
          ),
        ),
      ),
    );
  }
}

class _EgBottomNav extends StatelessWidget {
  const _EgBottomNav({
    required this.currentIndex,
    required this.isAuthenticated,
    required this.onSelectBranch,
    required this.onSignIn,
  });

  final int currentIndex;
  final bool isAuthenticated;
  final ValueChanged<int> onSelectBranch;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? bottomInset : 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: EgColors.navy900.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: EgColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: currentIndex == AppRoutes.homeBranch,
                onTap: () => onSelectBranch(AppRoutes.homeBranch),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: currentIndex == AppRoutes.profileBranch,
                onTap: () {
                  if (isAuthenticated) {
                    onSelectBranch(AppRoutes.profileBranch);
                  } else {
                    onSignIn();
                  }
                },
              ),
              _NavItem(
                icon: Icons.shield_moon_outlined,
                label: 'Ghost',
                selected: currentIndex == AppRoutes.ghostModeBranch,
                onTap: () => onSelectBranch(AppRoutes.ghostModeBranch),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? EgColors.success : EgColors.slate500;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? EgColors.success.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: EgFonts.style(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
