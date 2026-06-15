import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/mission_workspace_models.dart';
import '../providers/missions_provider.dart';
import '../widgets/mission_template_tile.dart';
import '../widgets/mission_tool_tile.dart';

class MissionWorkspaceScreen extends ConsumerWidget {
  const MissionWorkspaceScreen({super.key, required this.enrollmentUuid});

  final String enrollmentUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(missionWorkspaceProvider(enrollmentUuid));

    return workspaceAsync.when(
      loading: () => const EgFlowScaffold(
        title: 'Mission',
        body: Center(child: CircularProgressIndicator(color: EgColors.success)),
      ),
      error: (error, _) => EgFlowScaffold(
        title: 'Mission',
        body: Center(child: Text(missionErrorMessage(error) ?? 'Could not load workspace')),
      ),
      data: (workspace) => _WorkspaceBody(
        workspace: workspace,
        enrollmentUuid: enrollmentUuid,
        onRefresh: () async {
          ref.invalidate(missionWorkspaceProvider(enrollmentUuid));
          await ref.read(missionWorkspaceProvider(enrollmentUuid).future);
        },
      ),
    );
  }
}

class _WorkspaceBody extends StatelessWidget {
  const _WorkspaceBody({
    required this.workspace,
    required this.enrollmentUuid,
    required this.onRefresh,
  });

  final MissionWorkspaceResponse workspace;
  final String enrollmentUuid;
  final Future<void> Function() onRefresh;

  String? get _workoutProgramUuid {
    final taskTool = workspace.tools.cast<MissionTool?>().firstWhere(
          (tool) => tool!.key == 'task',
          orElse: () => null,
        );

    return taskTool?.deepLink?.programUuid ??
        workspace.engines.aether?.programs.workout?.uuid;
  }

  @override
  Widget build(BuildContext context) {
    final accent = missionAccentColor(workspace.mission.accent);
    final progress = workspace.enrollment.progressPercent.clamp(0, 100);
    final hero = workspace.workspace.hero;
    final cta = workspace.workspace.primaryCta;
    final workoutUuid = _workoutProgramUuid;

    return EgFlowScaffold(
      title: workspace.labels.workspaceTitle,
      subtitle: workspace.enrollment.title,
      body: RefreshIndicator(
        color: accent,
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(EgSpacing.page),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(EgSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.16), const Color(0x10FFFFFF)],
                ),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MissionIconBadge(iconKey: workspace.enrollment.icon, accent: accent),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.headline,
                              style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hero.subheadline,
                              style: EgFonts.style(fontSize: 14, height: 1.45, color: EgColors.slate400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hero.progressLabel,
                    style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EgPrimaryButton(
              label: cta.label,
              icon: _ctaIcon(cta.action),
              backgroundColor: accent,
              onPressed: () => _handlePrimaryCta(context, cta),
            ),
            if (workoutUuid != null && workspace.isActive) ...[
              const SizedBox(height: 12),
              EgSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Simple path', style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
                    const SizedBox(height: 6),
                    Text(
                      '1. Open your plan  ·  2. Pick a day  ·  3. Check off sets',
                      style: EgFonts.style(fontSize: 13, height: 1.5, color: EgColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
            if (workspace.needsPro) ...[
              const SizedBox(height: 12),
              EgSurface(
                child: Text(
                  workspace.labels.lockedReasonPro,
                  style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text('Mission tools', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...workspace.tools.map(
              (tool) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MissionToolTile(
                  tool: tool,
                  accent: accent,
                  onTap: () => _handleToolTap(context, tool),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _ctaIcon(String action) {
    return switch (action) {
      'start_aether_calibration' => Icons.auto_awesome_rounded,
      'upgrade_pro' => Icons.workspace_premium_rounded,
      'open_tool' => Icons.play_arrow_rounded,
      'open_aether_program' => Icons.fitness_center_rounded,
      _ => Icons.rocket_launch_rounded,
    };
  }

  void _handlePrimaryCta(BuildContext context, WorkspacePrimaryCta cta) {
    switch (cta.action) {
      case 'start_aether_calibration':
        _openCalibration(context);
      case 'upgrade_pro':
        context.push(AppRoutes.subscription);
      case 'open_tool':
      case 'open_aether_program':
        final uuid = cta.programUuid ?? _workoutProgramUuid;
        if (uuid != null && uuid.isNotEmpty) {
          _openWorkoutProgram(context, uuid);
          return;
        }
        _showActiveToolMessage(context);
      default:
        _openCalibration(context);
    }
  }

  void _handleToolTap(BuildContext context, MissionTool tool) {
    if (tool.isLocked) {
      if (tool.lock?.action == 'upgrade_pro' || workspace.needsPro) {
        context.push(AppRoutes.subscription);
        return;
      }

      _openCalibration(context, entryToolKey: tool.key);
      return;
    }

    if (tool.deepLink?.type == 'aether_program') {
      final uuid = tool.deepLink?.programUuid;
      if (uuid != null && uuid.isNotEmpty) {
        _openWorkoutProgram(context, uuid);
      }
      return;
    }

    if (tool.key == 'task') {
      final uuid = _workoutProgramUuid;
      if (uuid != null && uuid.isNotEmpty) {
        _openWorkoutProgram(context, uuid);
        return;
      }
    }

    _openToolPlaceholder(context, tool);
  }

  void _openWorkoutProgram(BuildContext context, String programUuid) {
    context.push('/aether/programs/$programUuid');
  }

  void _openToolPlaceholder(BuildContext context, MissionTool tool) {
    context.push('/missions/workspace/$enrollmentUuid/tools/${tool.key}');
  }

  void _openCalibration(BuildContext context, {String? entryToolKey}) {
    context.push(
      '/missions/workspace/$enrollmentUuid/calibrate',
      extra: entryToolKey,
    ).then((activated) {
      if (activated == true) {
        onRefresh();
      }
    });
  }

  void _showActiveToolMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open your workout plan below to get started.')),
    );
  }
}
