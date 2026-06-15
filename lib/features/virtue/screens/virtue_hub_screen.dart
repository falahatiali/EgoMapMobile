import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../providers/virtue_provider.dart';
import '../widgets/virtue_routine_card.dart';

class VirtueHubScreen extends ConsumerStatefulWidget {
  const VirtueHubScreen({super.key});

  @override
  ConsumerState<VirtueHubScreen> createState() => _VirtueHubScreenState();
}

class _VirtueHubScreenState extends ConsumerState<VirtueHubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(virtueHubProvider.notifier).ensureLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(virtueHubProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(virtueHubProvider.notifier).refresh(),
      color: _kVirtueColor,
      backgroundColor: EgColors.navy900,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _HubHeader(activeCount: state.activeRoutines.length)),
          if (state.isLoading && !state.isLoaded)
            const SliverFillRemaining(child: _LoadingView())
          else if (state.error != null && state.routines.isEmpty)
            SliverFillRemaining(child: _ErrorView(message: state.error!, onRetry: () => ref.read(virtueHubProvider.notifier).refresh()))
          else if (state.routines.isEmpty)
            const SliverFillRemaining(child: _EmptyView())
          else ...[
            if (state.activeRoutines.isNotEmpty) ...[
              _SectionHeader(title: 'Active Missions', count: state.activeRoutines.length),
              SliverList.separated(
                itemCount: state.activeRoutines.length,
                separatorBuilder: (context, i) => const SizedBox(height: 12),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: EgSpacing.page),
                  child: VirtueRoutineCard(
                    routine: state.activeRoutines[i],
                    onTap: () => context.push('/virtue/routines/${state.activeRoutines[i].id}'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
            if (state.completedRoutines.isNotEmpty) ...[
              _SectionHeader(title: 'Victories', count: state.completedRoutines.length),
              SliverList.separated(
                itemCount: state.completedRoutines.length,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: EgSpacing.page),
                  child: VirtueRoutineCard(
                    routine: state.completedRoutines[i],
                    onTap: () => context.push('/virtue/routines/${state.completedRoutines[i].id}'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, 40),
              child: EgPrimaryButton(
                label: 'Start a New Mission',
                icon: Icons.add_rounded,
                backgroundColor: _kVirtueColor,
                onPressed: () => context.push('/virtue/habits'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _kVirtueColor = Color(0xFF8B5CF6);

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 16, EgSpacing.page, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kVirtueColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kVirtueColor.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.psychology_alt_rounded, color: _kVirtueColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Virtue Forge',
                      style: EgFonts.style(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Forge your character, one habit at a time.',
                      style: EgFonts.style(fontSize: 13, color: EgColors.slate500, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (activeCount > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _kVirtueColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kVirtueColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: _kVirtueColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$activeCount active mission${activeCount > 1 ? 's' : ''} in progress',
                    style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600, color: _kVirtueColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, 12),
        child: Row(
          children: [
            Text(
              title,
              style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700, color: EgColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: EgColors.borderSubtle,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$count',
                style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.slate400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kVirtueColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_alt_rounded, size: 40, color: _kVirtueColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Your forge is empty',
              style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Pick a habit you want to transform. The AI will show you why it exists and exactly how to fix it.',
              textAlign: TextAlign.center,
              style: EgFonts.style(fontSize: 15, height: 1.6, color: EgColors.slate400),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: _kVirtueColor),
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
            Text('Could not load', style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            EgPrimaryButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
