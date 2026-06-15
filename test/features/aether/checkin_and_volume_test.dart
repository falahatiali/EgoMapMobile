import 'package:egomap_mobile/features/aether/models/aether_checkin_models.dart';
import 'package:egomap_mobile/features/aether/models/aether_volume_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AetherCheckInStatus', () {
    test('parses is_due true with week and date', () {
      final status = AetherCheckInStatus.fromJson({
        'is_due': true,
        'current_week': 3,
        'last_check_in_date': '2026-06-08',
      });
      expect(status.isDue, isTrue);
      expect(status.currentWeek, 3);
      expect(status.lastCheckInDate, '2026-06-08');
    });

    test('defaults to not due when is_due is missing', () {
      final status = AetherCheckInStatus.fromJson({});
      expect(status.isDue, isFalse);
      expect(status.currentWeek, 1);
      expect(status.lastCheckInDate, isNull);
    });
  });

  group('AetherCheckInPayload', () {
    test('serializes to correct JSON', () {
      const payload = AetherCheckInPayload(
        sessionsCompleted: 4,
        intensityRating: 2,
        hadPain: false,
        painNotes: null,
      );
      final json = payload.toJson();
      expect(json['sessions_completed'], 4);
      expect(json['intensity_rating'], 2);
      expect(json['had_pain'], false);
      expect(json['pain_notes'], isNull);
    });

    test('includes pain_notes when had_pain is true', () {
      const payload = AetherCheckInPayload(
        sessionsCompleted: 3,
        intensityRating: 3,
        hadPain: true,
        painNotes: 'left knee',
      );
      expect(payload.toJson()['pain_notes'], 'left knee');
    });
  });

  group('AetherCheckInResult', () {
    test('parses coaching message and adjustment hint', () {
      final result = AetherCheckInResult.fromJson({
        'check_in': {'workout_adherence_percent': 75},
        'coaching': {
          'message': 'Great week!',
          'adjustment_hint': 'Add one extra set.',
        },
      });
      expect(result.coachingMessage, 'Great week!');
      expect(result.adjustmentHint, 'Add one extra set.');
      expect(result.workoutAdherencePercent, 75);
    });

    test('adjustmentHint is null when not provided', () {
      final result = AetherCheckInResult.fromJson({
        'check_in': {'workout_adherence_percent': 100},
        'coaching': {'message': 'Perfect!', 'adjustment_hint': null},
      });
      expect(result.adjustmentHint, isNull);
    });
  });

  group('AetherVolumeChart', () {
    test('parses days correctly', () {
      final chart = AetherVolumeChart.fromJson({
        'days': [
          {'date': '2026-06-01', 'volume_kg': 1200.5, 'sets_logged': 12},
          {'date': '2026-06-03', 'volume_kg': 1350.0, 'sets_logged': 14},
        ],
      });
      expect(chart.days.length, 2);
      expect(chart.days.first.date, '2026-06-01');
      expect(chart.days.first.volumeKg, 1200.5);
      expect(chart.days.first.setsLogged, 12);
    });

    test('isEmpty returns true when no days', () {
      final chart = AetherVolumeChart.fromJson({'days': []});
      expect(chart.isEmpty, isTrue);
    });

    test('maxVolume returns highest volume', () {
      final chart = AetherVolumeChart.fromJson({
        'days': [
          {'date': '2026-06-01', 'volume_kg': 1000.0, 'sets_logged': 10},
          {'date': '2026-06-02', 'volume_kg': 1500.0, 'sets_logged': 15},
          {'date': '2026-06-03', 'volume_kg': 1200.0, 'sets_logged': 12},
        ],
      });
      expect(chart.maxVolume, 1500.0);
    });
  });
}
