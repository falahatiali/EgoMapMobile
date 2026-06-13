import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../providers/missions_provider.dart';
import '../widgets/mission_template_tile.dart';

class MissionDetailScreen extends ConsumerStatefulWidget {
  const MissionDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends ConsumerState<MissionDetailScreen> {
  bool _starting = false;
  String? _error;

  Future<void> _startOrContinue(String? enrollmentUuid, bool hasActive) async {
    if (_starting) {
      return;
    }

    if (hasActive && enrollmentUuid != null) {
      if (mounted) {
        context.push('/missions/workspace/$enrollmentUuid');
      }
      return;
    }

    setState(() {
      _starting = true;
      _error = null;
    });

    try {
      final result = await enrollInMission(ref, widget.slug);

      if (!mounted) {
        return;
      }

      setState(() => _starting = false);

      if (result != null) {
        context.pushReplacement('/missions/workspace/${result.enrollment.uuid}');
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _starting = false;
        _error = error.displayMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(missionTemplateProvider(widget.slug));

    return detailAsync.when(
      loading: () => const EgFlowScaffold(
        title: 'Mission',
        body: Center(child: CircularProgressIndicator(color: EgColors.success)),
      ),
      error: (error, _) => EgFlowScaffold(
        title: 'Mission',
        body: Center(child: Text(missionErrorMessage(error) ?? 'Could not load mission')),
      ),
      data: (response) {
        final template = response.template;
        final labels = response.labels;
        final accent = missionAccentColor(template.accent);

        return EgFlowScaffold(
          title: template.title,
          subtitle: template.summary,
          body: ListView(
            padding: const EdgeInsets.all(EgSpacing.page),
            children: [
              IgnorePointer(
                child: MissionTemplateTile(
                  template: template,
                  labels: labels,
                  compact: true,
                  onTap: () {},
                ),
              ),
              if (template.description.isNotEmpty) ...[
                const SizedBox(height: 20),
                EgSurface(
                  child: Text(
                    template.description,
                    style: EgFonts.style(fontSize: 16, height: 1.6, color: EgColors.slate400),
                  ),
                ),
              ],
              if (template.phases.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(labels.phases, style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...template.phases.map(
                  (phase) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: EgSurface(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.flag_circle_rounded, color: accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(phase.title, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                                if (phase.durationDays != null)
                                  Text(
                                    labels.daysLabel(phase.durationDays!),
                                    style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              if (template.capabilities.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(labels.includes, style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: template.capabilities
                      .map(
                        (cap) => Chip(
                          label: Text(cap.name),
                          backgroundColor: accent.withValues(alpha: 0.1),
                          side: BorderSide(color: accent.withValues(alpha: 0.25)),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 28),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: EgFonts.style(fontSize: 14, color: EgColors.danger),
                  ),
                ),
              EgPrimaryButton(
                label: template.hasActiveEnrollment ? labels.continueMission : labels.startMission,
                icon: template.hasActiveEnrollment ? Icons.play_arrow_rounded : Icons.rocket_launch_rounded,
                loading: _starting,
                backgroundColor: accent,
                onPressed: () => _startOrContinue(template.enrollmentUuid, template.hasActiveEnrollment),
              ),
            ],
          ),
        );
      },
    );
  }
}
