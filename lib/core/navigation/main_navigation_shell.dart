import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_controller.dart';
import '../../features/billing/providers/billing_provider.dart';
import '../../features/ghost_mode/providers/ghost_mode_provider.dart';
import '../../features/missions/providers/missions_provider.dart';
import '../../features/virtue/providers/virtue_provider.dart';
import '../theme/eg_colors.dart';
import '../theme/eg_fonts.dart';
import '../widgets/app_subscription_header.dart';
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

    if (index == AppRoutes.missionsBranch) {
      Future(() => ref.read(missionsHubProvider.notifier).ensureLoaded());
    }

    if (index == AppRoutes.ghostModeBranch) {
      Future(() => ref.read(ghostModeProvider.notifier).ensureLoaded());
    }

    if (index == AppRoutes.virtueBranch) {
      Future(() => ref.read(virtueHubProvider.notifier).ensureLoaded());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated && !(previous?.isAuthenticated ?? false)) {
        ref.read(billingCheckoutControllerProvider.notifier).refreshCatalog();
      }
    });

    final isAuthenticated = ref.watch(authControllerProvider.select((state) => state.isAuthenticated));

    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSubscriptionHeader(
                pageTitle: _pageTitle(_currentIndex),
                pageSubtitle: _pageSubtitle(_currentIndex),
              ),
              Expanded(child: navigationShell),
            ],
          ),
        ),
        bottomNavigationBar: _EgBottomNav(
          currentIndex: _currentIndex,
          isAuthenticated: isAuthenticated,
          onSelectBranch: (index) => _goToBranch(index, ref),
          onSignIn: () => context.push(AppRoutes.login),
        ),
      ),
    );
  }
}

String _pageTitle(int currentIndex) => switch (currentIndex) {
      AppRoutes.missionsBranch => 'Missions',
      AppRoutes.profileBranch => 'Profile',
      AppRoutes.ghostModeBranch => 'Ghost Mode',
      AppRoutes.virtueBranch => 'Virtue Forge',
      _ => 'EgoMap',
    };

String _pageSubtitle(int currentIndex) => switch (currentIndex) {
      AppRoutes.missionsBranch => 'Structured rebuild paths',
      AppRoutes.profileBranch => 'Your recovery hub',
      AppRoutes.ghostModeBranch => 'No contact protocol',
      AppRoutes.virtueBranch => 'Forge your character',
      _ => 'Break the loop. Rebuild yourself.',
    };

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
                icon: Icons.flag_rounded,
                label: 'Missions',
                selected: currentIndex == AppRoutes.missionsBranch,
                onTap: () {
                  if (isAuthenticated) {
                    onSelectBranch(AppRoutes.missionsBranch);
                  } else {
                    onSignIn();
                  }
                },
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
              _NavItem(
                icon: Icons.psychology_alt_rounded,
                label: 'Virtue',
                selected: currentIndex == AppRoutes.virtueBranch,
                onTap: () {
                  if (isAuthenticated) {
                    onSelectBranch(AppRoutes.virtueBranch);
                  } else {
                    onSignIn();
                  }
                },
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
