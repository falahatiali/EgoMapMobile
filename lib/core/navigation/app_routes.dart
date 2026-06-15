abstract final class AppRoutes {
  static const home = '/';
  static const missions = '/missions';
  static const profile = '/profile';
  static const ghostMode = '/ghost-mode';
  static const virtue = '/virtue';
  static const missionsCatalog = '/missions/catalog';
  static const subscription = '/billing';
  static const billingCheckout = '/billing/checkout';
  static const quizIntro = '/quiz-intro';
  static const login = '/login';
  static const register = '/register';

  static const homeBranch = 0;
  static const missionsBranch = 1;
  static const profileBranch = 2;
  static const ghostModeBranch = 3;
  static const virtueBranch = 4;

  static const shellPaths = {home, missions, profile, ghostMode, virtue};

  static bool isShellRoute(String path) => shellPaths.contains(path);
}
