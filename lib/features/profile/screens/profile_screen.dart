import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../../auth/providers/auth_controller.dart';
import '../models/profile_models.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_test_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileTestsFilter _filter = ProfileTestsFilter.all;

  void _setFilter(ProfileTestsFilter filter) {
    if (_filter == filter) {
      return;
    }

    setState(() => _filter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
        ),
      ),
      error: (error, _) => _ErrorState(
        message: error is ApiException ? error.message : 'Something went wrong.',
        onRetry: () => ref.invalidate(profileProvider),
      ),
      data: (profile) {
        final visibleTests = filterProfileTests(profile.tests, _filter);

        return RefreshIndicator(
          color: EgColors.success,
          onRefresh: () async {
            ref.invalidate(profileProvider);
            await ref.read(profileProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(EgSpacing.page, 4, EgSpacing.page, 16),
            children: [
              _ProfileHero(
                user: profile.user,
                labels: profile.labels,
                onSignOut: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
              ),
              if (profile.stats.completed > 0) ...[
                const SizedBox(height: 16),
                _GhostModeCard(onOpen: () => context.go('/ghost-mode')),
              ],
              const SizedBox(height: 16),
              _MissionsShortcutCard(onOpen: () => context.go('/missions')),
              const SizedBox(height: 28),
              _MyTestsSection(
                profile: profile,
                visibleTests: visibleTests,
                filter: _filter,
                onFilterChanged: _setFilter,
                onTakeNewTest: () => context.push('/quiz-intro'),
                onOpenTest: (record) {
                  if (record.isInProgress) {
                    context.push('/quiz/session/${record.sessionUuid}');
                    return;
                  }

                  context.push('/quiz/session/${record.sessionUuid}/result');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissionsShortcutCard extends StatelessWidget {
  const _MissionsShortcutCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(EgSpacing.radius),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: EgColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.flag_rounded, color: EgColors.success),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My missions', style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Gym, habits, and structured rebuild paths',
                    style: EgFonts.style(fontSize: 14, color: EgColors.slate500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: EgColors.slate500),
          ],
        ),
      ),
    );
  }
}

class _GhostModeCard extends StatelessWidget {
  const _GhostModeCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EgColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_moon_outlined, color: EgColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STEP 2', style: EgFonts.style(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: EgColors.accent)),
                const SizedBox(height: 4),
                Text('Activate Ghost Mode', style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Go dark. Cut contact. Start your no-contact timer.',
                  style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onOpen, icon: const Icon(Icons.arrow_forward_rounded, color: EgColors.accent)),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.labels,
    required this.onSignOut,
  });

  final ProfileUser user;
  final ProfileLabels labels;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return EgSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: EgColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: EgColors.success.withValues(alpha: 0.35)),
            ),
            child: Text(
              initial,
              style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800, color: EgColors.success),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EgColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels.member,
                    style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w700, color: EgColors.accent),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: EgFonts.style(fontSize: 16, color: EgColors.slate400),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (user.memberSinceLabel != null)
                      _MetaChip(
                        icon: Icons.calendar_today_outlined,
                        label: user.memberSinceLabel!,
                      ),
                    if (user.emailVerified)
                      _MetaChip(
                        icon: Icons.verified_outlined,
                        label: labels.verified,
                        color: EgColors.success,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                TextButton.icon(
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text('Sign out', style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(foregroundColor: EgColors.slate400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = EgColors.slate500,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: EgFonts.style(fontSize: 12, color: color)),
      ],
    );
  }
}

class _MyTestsSection extends StatelessWidget {
  const _MyTestsSection({
    required this.profile,
    required this.visibleTests,
    required this.filter,
    required this.onFilterChanged,
    required this.onTakeNewTest,
    required this.onOpenTest,
  });

  final ProfilePayload profile;
  final List<ProfileTestRecord> visibleTests;
  final ProfileTestsFilter filter;
  final ValueChanged<ProfileTestsFilter> onFilterChanged;
  final VoidCallback onTakeNewTest;
  final ValueChanged<ProfileTestRecord> onOpenTest;

  @override
  Widget build(BuildContext context) {
    final labels = profile.labels;
    final stats = profile.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels.myTestsTitle,
                    style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels.myTestsSubtitle,
                    style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            EgPrimaryButton(
              label: labels.takeNewTest,
              expanded: false,
              height: 44,
              icon: Icons.add_rounded,
              onPressed: onTakeNewTest,
            ),
          ],
        ),
        const SizedBox(height: 18),
        _FilterRow(
          filter: filter,
          labels: labels,
          stats: stats,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 18),
        if (visibleTests.isEmpty)
          EgSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(labels.noTestsTitle, style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(labels.noTestsBody, style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400)),
                const SizedBox(height: 16),
                EgPrimaryButton(
                  label: labels.takeNewTest,
                  backgroundColor: EgColors.success,
                  onPressed: onTakeNewTest,
                ),
              ],
            ),
          )
        else
          ...visibleTests.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ProfileTestCard(
                record: record,
                onTap: () => onOpenTest(record),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.labels,
    required this.stats,
    required this.onFilterChanged,
  });

  final ProfileTestsFilter filter;
  final ProfileLabels labels;
  final ProfileStats stats;
  final ValueChanged<ProfileTestsFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: labels.filterAll,
          count: stats.total,
          selected: filter == ProfileTestsFilter.all,
          onTap: () => onFilterChanged(ProfileTestsFilter.all),
        ),
        _FilterChip(
          label: labels.filterInProgress,
          count: stats.inProgress,
          selected: filter == ProfileTestsFilter.inProgress,
          onTap: () => onFilterChanged(ProfileTestsFilter.inProgress),
        ),
        _FilterChip(
          label: labels.filterCompleted,
          count: stats.completed,
          selected: filter == ProfileTestsFilter.completed,
          onTap: () => onFilterChanged(ProfileTestsFilter.completed),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? EgColors.accent.withValues(alpha: 0.12) : const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? EgColors.accent : EgColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: EgFonts.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? EgColors.accent : EgColors.slate400,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: selected ? EgColors.accent.withValues(alpha: 0.18) : const Color(0x18FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: EgFonts.style(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? EgColors.accent : EgColors.slate500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

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
            Text('Could not load profile', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w600)),
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
