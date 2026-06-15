import 'package:egomap_mobile/features/aether/models/aether_program_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AetherProgramDetail parses workout program payload', () {
    final detail = AetherProgramDetail.fromJson({
      'program': {
        'uuid': 'abc-123',
        'version': 1,
        'status': 'active',
        'applied_target': 'workout',
        'summary': '4-day split',
        'adherence_percent': 42,
        'coach': {'week_focus': 'Build consistency'},
        'workout_days': [
          {
            'id': 7,
            'day_index': 1,
            'label': 'Day A',
            'focus': 'Push',
            'exercises': [
              {
                'id': 11,
                'slug': 'bench-press',
                'name': 'Bench Press',
                'muscle_group': 'Chest',
                'media_url': null,
                'sets': [
                  {
                    'id': 21,
                    'set_number': 1,
                    'target_reps_min': 8,
                    'target_reps_max': 10,
                    'rest_seconds': 90,
                    'completed': false,
                  },
                ],
              },
            ],
          },
        ],
      },
    });

    expect(detail.program.uuid, 'abc-123');
    expect(detail.program.workoutDays.single.label, 'Day A');
    expect(detail.program.workoutDays.single.exercises.single.sets.single.repsLabel, '8–10 reps');
    expect(detail.program.totalSets, 1);
  });
}
