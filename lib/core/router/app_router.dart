import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/home/screens/home_shell_screen.dart';
import '../../features/home/screens/landing_screen.dart';
import '../../features/home/screens/quiz_intro_screen.dart';
import '../../features/quiz/screens/quiz_result_screen.dart';
import '../../features/quiz/screens/quiz_take_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final path = state.uri.path;

      if (authState.isBootstrapping) {
        return null;
      }

      if (authState.isAuthenticated && (path == '/login' || path == '/register' || path == '/verify-email')) {
        return '/';
      }

      if (!authState.isAuthenticated && path == '/home') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/quiz-intro',
        builder: (context, state) => const QuizIntroScreen(),
      ),
      GoRoute(
        path: '/quiz/session/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;

          return QuizTakeScreen(sessionUuid: uuid);
        },
        routes: [
          GoRoute(
            path: 'result',
            builder: (context, state) {
              final uuid = state.pathParameters['uuid']!;

              return QuizResultScreen(sessionUuid: uuid);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeShellScreen(),
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
