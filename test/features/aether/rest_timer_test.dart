import 'package:egomap_mobile/features/aether/models/aether_program_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AetherWorkoutSet rest logic', () {
    test('returns server rest seconds when set', () {
      const set = AetherWorkoutSet(
        id: 1,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 10,
        restSeconds: 75,
        completed: false,
      );
      expect(set.restSeconds, 75);
    });

    test('rest seconds is nullable for AMRAP sets', () {
      const set = AetherWorkoutSet(
        id: 2,
        setNumber: 1,
        targetRepsMin: null,
        targetRepsMax: null,
        restSeconds: null,
        completed: false,
      );
      expect(set.restSeconds, isNull);
    });

    test('repsLabel for range', () {
      const set = AetherWorkoutSet(
        id: 3,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 12,
        restSeconds: null,
        completed: false,
      );
      expect(set.repsLabel, '8–12 reps');
    });

    test('repsLabel for exact reps', () {
      const set = AetherWorkoutSet(
        id: 4,
        setNumber: 2,
        targetRepsMin: 5,
        targetRepsMax: 5,
        restSeconds: null,
        completed: false,
      );
      expect(set.repsLabel, '5 reps');
    });

    test('repsLabel AMRAP when no reps specified', () {
      const set = AetherWorkoutSet(
        id: 5,
        setNumber: 3,
        targetRepsMin: null,
        targetRepsMax: null,
        restSeconds: null,
        completed: false,
      );
      expect(set.repsLabel, 'AMRAP');
    });
  });

  group('AetherWorkoutSet weight labels', () {
    test('weightLabel is null when not logged', () {
      const set = AetherWorkoutSet(
        id: 10,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 10,
        restSeconds: 90,
        completed: true,
      );
      expect(set.weightLabel, isNull);
    });

    test('weightLabel shows whole kg without decimal', () {
      const set = AetherWorkoutSet(
        id: 11,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 10,
        restSeconds: 90,
        completed: true,
        weightKg: 60.0,
      );
      expect(set.weightLabel, '60 kg');
    });

    test('weightLabel shows decimal when fractional', () {
      const set = AetherWorkoutSet(
        id: 12,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 10,
        restSeconds: 90,
        completed: true,
        weightKg: 52.5,
      );
      expect(set.weightLabel, '52.5 kg');
    });

    test('suggestedWeightLabel is null when no prior data', () {
      const set = AetherWorkoutSet(
        id: 13,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 10,
        restSeconds: 90,
        completed: false,
      );
      expect(set.suggestedWeightLabel, isNull);
    });

    test('suggestedWeightLabel shows formatted kg', () {
      const set = AetherWorkoutSet(
        id: 14,
        setNumber: 1,
        targetRepsMin: 8,
        targetRepsMax: 10,
        restSeconds: 90,
        completed: false,
        suggestedWeightKg: 62.5,
      );
      expect(set.suggestedWeightLabel, '62.5 kg');
    });

    test('fromJson parses weight_kg and suggested_weight_kg', () {
      final set = AetherWorkoutSet.fromJson({
        'id': 20,
        'set_number': 2,
        'target_reps_min': 6,
        'target_reps_max': 8,
        'rest_seconds': 120,
        'completed': true,
        'weight_kg': 80.0,
        'suggested_weight_kg': 82.5,
      });
      expect(set.weightKg, 80.0);
      expect(set.suggestedWeightKg, 82.5);
      expect(set.weightLabel, '80 kg');
      expect(set.suggestedWeightLabel, '82.5 kg');
    });

    test('fromJson handles null weight fields gracefully', () {
      final set = AetherWorkoutSet.fromJson({
        'id': 21,
        'set_number': 1,
        'target_reps_min': 10,
        'target_reps_max': 12,
        'rest_seconds': null,
        'completed': false,
        'weight_kg': null,
        'suggested_weight_kg': null,
      });
      expect(set.weightKg, isNull);
      expect(set.suggestedWeightKg, isNull);
    });
  });
}
