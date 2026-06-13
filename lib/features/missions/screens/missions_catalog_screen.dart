import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../providers/missions_provider.dart';
import '../widgets/mission_template_tile.dart';

class MissionsCatalogScreen extends ConsumerWidget {
  const MissionsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubAsync = ref.watch(missionsHubProvider);

    return EgFlowScaffold(
      title: hubAsync.value?.labels.catalogTitle ?? 'Missions',
      subtitle: hubAsync.value?.labels.catalogSubtitle,
      body: hubAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: EgColors.success)),
        error: (error, _) => Center(
          child: Text(missionErrorMessage(error) ?? 'Could not load catalog'),
        ),
        data: (hub) {
          if (hub == null || hub.templates.isEmpty) {
            return Center(
              child: Text(
                hub?.labels.catalogSubtitle ?? 'No missions published yet.',
                style: EgFonts.style(color: EgColors.slate500),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(EgSpacing.page),
            itemCount: hub.templates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final template = hub.templates[index];

              return MissionTemplateTile(
                template: template,
                labels: hub.labels,
                onTap: () => context.push('/missions/templates/${template.slug}'),
              );
            },
          );
        },
      ),
    );
  }
}
