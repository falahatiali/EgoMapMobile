abstract final class AppRoutes {
  static const home = '/';
  static const missions = '/missions';
  static const growth = '/growth';
  static const profile = '/profile';
  static const ghostMode = '/ghost-mode';
  static const virtue = '/virtue';
  static const missionsCatalog = '/missions/catalog';
  static const subscription = '/billing';
  static const billingCheckout = '/billing/checkout';
  static const quizIntro = '/quiz-intro';
  static const login = '/login';
  static const register = '/register';

  static const todayBranch = 0;
  static const missionsBranch = 1;
  static const growthBranch = 2;
  static const meBranch = 3;

  /// Kept for legacy references.
  static const homeBranch = todayBranch;
  static const profileBranch = meBranch;

  static const shellPaths = {home, missions, growth, profile};

  static bool isShellRoute(String path) => shellPaths.contains(path);
}
