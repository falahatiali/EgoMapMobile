import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../../auth/providers/auth_controller.dart';
import '../../ghost_mode/models/ghost_mode_models.dart';
import '../../ghost_mode/providers/ghost_mode_provider.dart';
import '../../missions/providers/missions_provider.dart';
import '../widgets/emotional_checkin_card.dart';
import '../widgets/ghost_banner_card.dart';
import '../widgets/today_active_mission_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ghostModeProvider.notifier).ensureLoaded();
      ref.read(missionsHubProvider.notifier).ensureLoaded();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(ghostModeProvider.notifier).refresh(),
      ref.read(missionsHubProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final ghostUi = ref.watch(ghostModeProvider);
    final missionsAsync = ref.watch(missionsHubProvider);
    final isAuthenticated = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));

    final ghostState = ghostUi.data;
    final missionsHub = missionsAsync.maybeWhen(data: (d) => d, orElse: () => null);

    final ghostLoading = ghostUi.loading && ghostState == null;
    final missionsLoading = missionsAsync.isLoading && missionsHub == null;

    return RefreshIndicator(
      color: EgColors.success,
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(EgSpacing.page, 8, EgSpacing.page, 48),
        children: [
          // Greeting
          _GreetingHeader(),
          const SizedBox(height: 22),

          // Ghost Mode banner
          GhostBannerCard(
            ghostState: ghostState,
            loading: ghostLoading,
            onTap: () => context.push(AppRoutes.ghostMode),
          ),
          const SizedBox(height: 14),

          // Active Mission (auth only)
          if (isAuthenticated) ...[
            TodayActiveMissionCard(
              hub: missionsHub,
              loading: missionsLoading,
              onOpen: (uuid) => context.push('/missions/workspace/$uuid'),
              onBrowse: () => context.push(AppRoutes.missionsCatalog),
            ),
            const SizedBox(height: 14),
          ] else ...[
            _StartJourneyCard(onTap: () => context.push(AppRoutes.quizIntro)),
            const SizedBox(height: 14),
          ],

          // Emotional check-in
          const EmotionalCheckinCard(),

          // Wallet strip (only when ghost is active)
          if (ghostState != null && ghostState.timer.mode == 'active') ...[
            const SizedBox(height: 14),
            _WalletStrip(wallet: ghostState.wallet),
          ],
        ],
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String get _dateLabel {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting,
          style: EgFonts.style(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _dateLabel,
          style: EgFonts.style(fontSize: 15, color: EgColors.slate500),
        ),
      ],
    );
  }
}

// ── Start Journey CTA (unauthenticated) ───────────────────────────────────────

class _StartJourneyCard extends StatelessWidget {
  const _StartJourneyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      padding: const EdgeInsets.all(EgSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: EgColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.radar_rounded, size: 22, color: EgColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WHERE DO YOU STAND?',
                      style: EgFonts.style(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: EgColors.success,
                      ),
                    ),
                    Text(
                      'Take the 5-minute scan',
                      style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get a personalised blueprint for rebuilding your mind, body, and character.',
            style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400),
          ),
          const SizedBox(height: 16),
          EgPrimaryButton(
            label: 'Start your scan',
            icon: Icons.play_arrow_rounded,
            backgroundColor: EgColors.success,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

// ── Wallet strip ──────────────────────────────────────────────────────────────

class _WalletStrip extends StatelessWidget {
  const _WalletStrip({required this.wallet});

  final GhostModeWallet wallet;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _WalletStat(icon: Icons.star_rounded, label: '${wallet.points} pts', color: EgColors.warning),
          const SizedBox(width: 20),
          _WalletStat(
            icon: Icons.local_fire_department_rounded,
            label: '${wallet.streakDays}d streak',
            color: EgColors.danger,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: EgColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Lv ${wallet.level}',
              style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.accentBright),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletStat extends StatelessWidget {
  const _WalletStat({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(label, style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
