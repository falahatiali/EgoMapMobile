// Data models for the volume chart feature.

class AetherVolumeDay {
  const AetherVolumeDay({
    required this.date,
    required this.volumeKg,
    required this.setsLogged,
  });

  final String date;

  /// Total volume for this day: sum of (weight_kg × reps) across all logged sets.
  final double volumeKg;

  final int setsLogged;

  factory AetherVolumeDay.fromJson(Map<String, dynamic> json) {
    return AetherVolumeDay(
      date: json['date'] as String,
      volumeKg: (json['volume_kg'] as num?)?.toDouble() ?? 0,
      setsLogged: json['sets_logged'] as int? ?? 0,
    );
  }
}

class AetherVolumeChart {
  const AetherVolumeChart({required this.days});

  final List<AetherVolumeDay> days;

  bool get isEmpty => days.isEmpty;

  double get maxVolume =>
      days.isEmpty ? 1 : days.map((d) => d.volumeKg).reduce((a, b) => a > b ? a : b);

  factory AetherVolumeChart.fromJson(Map<String, dynamic> json) {
    final list = json['days'] as List<dynamic>? ?? [];
    return AetherVolumeChart(
      days: list
          .map((e) => AetherVolumeDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
