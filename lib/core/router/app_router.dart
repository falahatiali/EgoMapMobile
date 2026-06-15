import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/navigation/main_navigation_shell.dart';
import '../../features/aether/screens/workout_day_screen.dart';
import '../../features/aether/screens/workout_program_screen.dart';
import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/ghost_mode/screens/ghost_mode_screen.dart';
import '../../features/home/screens/landing_screen.dart';
import '../../features/virtue/screens/virtue_habit_picker_screen.dart';
import '../../features/virtue/screens/virtue_hub_screen.dart';
import '../../features/virtue/screens/virtue_routine_detail_screen.dart';
import '../../features/home/screens/quiz_intro_screen.dart';
import '../../features/missions/screens/mission_calibration_screen.dart';
import '../../features/missions/screens/mission_detail_screen.dart';
import '../../features/missions/screens/mission_tool_placeholder_screen.dart';
import '../../features/missions/screens/mission_workspace_screen.dart';
import '../../features/missions/screens/missions_catalog_screen.dart';
import '../../features/missions/screens/missions_hub_screen.dart';
import '../../features/billing/screens/billing_checkout_screen.dart';
import '../../features/billing/screens/subscription_screen.dart';
import '../../features/quiz/models/quiz_models.dart';
import '../../features/quiz/screens/quiz_result_screen.dart';
import '../../features/quiz/screens/quiz_returning_screen.dart';
import '../../features/quiz/screens/quiz_take_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;

      if (authState.isBootstrapping) {
        return null;
      }

      if (path == '/home') {
        return AppRoutes.profile;
      }

      if (authState.isAuthenticated && (path == '/login' || path == '/register' || path == '/verify-email')) {
        return AppRoutes.home;
      }

      if (!authState.isAuthenticated && (path == AppRoutes.profile || path == AppRoutes.missions || path == AppRoutes.subscription)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LandingScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.missions,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MissionsHubScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ghostMode,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: GhostModeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.virtue,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: VirtueHubScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.missionsCatalog,
        builder: (context, state) => const MissionsCatalogScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/missions/templates/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;

          return MissionDetailScreen(slug: slug);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/missions/workspace/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;

          return MissionWorkspaceScreen(enrollmentUuid: uuid);
        },
        routes: [
          GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            path: 'calibrate',
            builder: (context, state) {
              final uuid = state.pathParameters['uuid']!;

              return MissionCalibrationScreen(
                enrollmentUuid: uuid,
                entryToolKey: state.extra as String?,
              );
            },
          ),
          GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            path: 'tools/:toolKey',
            builder: (context, state) {
              final toolKey = state.pathParameters['toolKey']!;

              return _MissionToolPlaceholderRoute(toolKey: toolKey);
            },
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/aether/programs/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;

          return WorkoutProgramScreen(programUuid: uuid);
        },
        routes: [
          GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            path: 'days/:dayId',
            builder: (context, state) {
              final uuid = state.pathParameters['uuid']!;
              final dayId = int.parse(state.pathParameters['dayId']!);

              return WorkoutDayScreen(programUuid: uuid, dayId: dayId);
            },
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/virtue/habits',
        builder: (context, state) => const VirtueHabitPickerScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/virtue/routines/:routineId',
        builder: (context, state) {
          final routineId = int.parse(state.pathParameters['routineId']!);
          return VirtueRoutineDetailScreen(routineId: routineId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.billingCheckout,
        builder: (context, state) {
          final checkoutUrl = state.extra as String?;

          if (checkoutUrl == null || checkoutUrl.isEmpty) {
            return const SubscriptionScreen();
          }

          return BillingCheckoutScreen(checkoutUrl: checkoutUrl);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.quizIntro,
        builder: (context, state) => const QuizIntroScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/quiz/returning',
        builder: (context, state) {
          final preview = state.extra as QuizReturningPreview?;
          final slug = state.uri.queryParameters['slug'] ?? 'reboot-protocol';

          if (preview == null) {
            return const QuizIntroScreen();
          }

          return QuizReturningScreen(slug: slug, preview: preview);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/quiz/session/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;

          return QuizTakeScreen(
            key: ValueKey('quiz-take-$uuid'),
            sessionUuid: uuid,
          );
        },
        routes: [
          GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            path: 'result',
            builder: (context, state) {
              final uuid = state.pathParameters['uuid']!;

              return QuizResultScreen(
                key: ValueKey('quiz-result-$uuid'),
                sessionUuid: uuid,
              );
            },
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
    ],
  );

  ref.listen(authControllerProvider, (previous, next) {
    final authChanged = previous?.isBootstrapping != next.isBootstrapping ||
        previous?.isAuthenticated != next.isAuthenticated ||
        previous?.pendingVerification?.verificationToken != next.pendingVerification?.verificationToken;

    if (authChanged) {
      router.refresh();
    }
  });

  ref.onDispose(router.dispose);

  return router;
});

class _MissionToolPlaceholderRoute extends StatelessWidget {
  const _MissionToolPlaceholderRoute({required this.toolKey});

  final String toolKey;

  @override
  Widget build(BuildContext context) {
    final (title, description, icon) = switch (toolKey) {
      'nutrition' => (
          'Nutrition',
          'Meal logging and AI meal plans are on the way. Your workout plan is ready now — start there.',
          Icons.restaurant_rounded,
        ),
      'supplements' => (
          'Supplements',
          'Track your supplement stack daily. Full logging arrives in the next app update.',
          Icons.medication_liquid_rounded,
        ),
      'equipment' => (
          'Equipment',
          'Build your gear list and know exactly what you have for each workout.',
          Icons.shopping_bag_rounded,
        ),
      _ => (
          'Coming soon',
          'This mission tool is being polished for mobile.',
          Icons.construction_rounded,
        ),
    };

    return MissionToolPlaceholderScreen(
      title: title,
      description: description,
      icon: icon,
    );
  }
}
