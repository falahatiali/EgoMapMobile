import 'package:flutter_test/flutter_test.dart';

import 'package:egomap_mobile/features/missions/models/mission_workspace_models.dart';

void main() {
  test('MissionWorkspaceResponse parses locked gym workspace', () {
    final workspace = MissionWorkspaceResponse.fromJson({
      'meta': {'api_version': '2026-06-12.v1'},
      'labels': {
        'workspace_title': 'Your mission',
        'activate_mission': 'Activate mission',
      },
      'mission': {
        'slug': 'gym-bodybuilding',
        'title': 'Gym & Bodybuilding',
        'icon': 'fa-dumbbell',
        'accent': 'emerald',
        'engine_module': 'aether',
        'current_phase': {'slug': 'foundation', 'title': 'Foundation'},
      },
      'enrollment': {
        'uuid': 'abc-123',
        'status': 'active',
        'progress_percent': 0,
      },
      'engines': {
        'aether': {
          'status': 'pro_required',
          'calibration': {
            'is_complete': false,
            'progress_percent': 0,
            'total_steps': 8,
            'can_resume': false,
          },
          'access': {
            'can_calibrate': false,
            'user_has_pro': false,
            'can_generate_workout': false,
            'can_generate_meal': false,
          },
          'programs': {'workout': null, 'meal': null},
        },
      },
      'workspace': {
        'mode': 'locked',
        'primary_cta': {
          'action': 'upgrade_pro',
          'label': 'Upgrade for AetherEngine',
        },
        'hero': {
          'headline': 'Foundation · Week 1',
          'subheadline': 'AetherEngine needs a few answers.',
          'progress_label': 'Not activated yet',
        },
      },
      'tools': [
        {
          'key': 'task',
          'label': 'Workout',
          'icon': 'fa-dumbbell',
          'status': 'locked',
          'lock': {
            'reason': 'pro_required',
            'message': 'Unlock your training plan',
            'action': 'upgrade_pro',
          },
        },
      ],
    });

    expect(workspace.mission.engineModule, 'aether');
    expect(workspace.needsPro, isTrue);
    expect(workspace.workspace.mode, WorkspaceMode.locked);
    expect(workspace.enrollment.title, 'Gym & Bodybuilding');
    expect(workspace.tools.first.isLocked, isTrue);
  });
}
