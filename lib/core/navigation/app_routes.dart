abstract final class AppRoutes {
  static const home = '/';
  static const profile = '/profile';
  static const ghostMode = '/ghost-mode';
  static const quizIntro = '/quiz-intro';
  static const login = '/login';
  static const register = '/register';

  static const homeBranch = 0;
  static const profileBranch = 1;
  static const ghostModeBranch = 2;

  static const shellPaths = {home, profile, ghostMode};

  static bool isShellRoute(String path) => shellPaths.contains(path);
}
