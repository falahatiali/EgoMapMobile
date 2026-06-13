import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../providers/missions_provider.dart';
import '../widgets/mission_template_tile.dart';

class MissionsHubScreen extends ConsumerStatefulWidget {
  const MissionsHubScreen({super.key});

  @override
  ConsumerState<MissionsHubScreen> createState() => _MissionsHubScreenState();
}

class _MissionsHubScreenState extends ConsumerState<MissionsHubScreen> {
  bool _loadScheduled = false;

  void _scheduleLoad() {
    if (_loadScheduled || !mounted) {
      return;
    }

    if (GoRouterState.of(context).uri.path != AppRoutes.missions) {
      return;
    }

    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (!mounted) {
        return;
      }

      ref.read(missionsHubProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleLoad();

    final hubAsync = ref.watch(missionsHubProvider);

    return hubAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
        ),
      ),
      error: (error, _) => _ErrorView(
        message: missionErrorMessage(error) ?? 'Could not load missions.',
        onRetry: () => ref.read(missionsHubProvider.notifier).refresh(),
      ),
      data: (hub) {
        if (hub == null) {
          return const SizedBox.shrink();
        }

        final labels = hub.labels;
        final hasActive = hub.activeEnrollments.isNotEmpty;

        return RefreshIndicator(
          color: EgColors.success,
          onRefresh: () => ref.read(missionsHubProvider.notifier).refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(EgSpacing.page, 8, EgSpacing.page, 24),
            children: [
              Text(
                labels.myMissionsTitle,
                style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                labels.myMissionsSubtitle,
                style: EgFonts.style(fontSize: 16, height: 1.55, color: EgColors.slate400),
              ),
              const SizedBox(height: 24),
              if (hasActive) ...[
                ...hub.activeEnrollments.map(
                  (enrollment) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ActiveMissionHeroCard(
                      enrollment: enrollment,
                      labels: labels,
                      onOpen: () => context.push('/missions/workspace/${enrollment.uuid}'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                _EmptyMissionsCard(
                  message: labels.noActiveMissions,
                  onBrowse: () => context.push(AppRoutes.missionsCatalog),
                ),
                const SizedBox(height: 20),
              ],
              EgPrimaryButton(
                label: labels.browseMissions,
                icon: Icons.explore_rounded,
                backgroundColor: hasActive ? EgColors.navy900 : EgColors.success,
                onPressed: () => context.push(AppRoutes.missionsCatalog),
              ),
              if (hub.templates.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text(
                  labels.catalogTitle,
                  style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...hub.templates.take(2).map(
                      (template) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MissionTemplateTile(
                          template: template,
                          labels: labels,
                          compact: true,
                          onTap: () => context.push('/missions/templates/${template.slug}'),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyMissionsCard extends StatelessWidget {
  const _EmptyMissionsCard({
    required this.message,
    required this.onBrowse,
  });

  final String message;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EgSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        color: const Color(0x10FFFFFF),
        border: Border.all(color: EgColors.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EgColors.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.route_rounded, size: 34, color: EgColors.accent),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: EgFonts.style(fontSize: 16, height: 1.55, color: EgColors.slate400),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load missions', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 14, color: EgColors.slate500)),
            const SizedBox(height: 20),
            EgPrimaryButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
