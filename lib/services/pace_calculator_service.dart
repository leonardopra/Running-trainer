import '../models/enums.dart';

class PaceZone {
  final WorkoutType type;
  final int fastSecs; // sec/km — faster end of range
  final int slowSecs; // sec/km — slower end of range
  final String description;

  const PaceZone({
    required this.type,
    required this.fastSecs,
    required this.slowSecs,
    required this.description,
  });

  String get label => type.displayName;

  String get paceRange =>
      '${_fmt(fastSecs)} – ${_fmt(slowSecs)} /km';

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class PaceCalculatorService {
  // ── Race distances ────────────────────────────────────────────────────────
  static double distanceKm(GoalType goal) {
    switch (goal) {
      case GoalType.fiveK:        return 5.0;
      case GoalType.tenK:         return 10.0;
      case GoalType.halfMarathon: return 21.0975;
      case GoalType.marathon:     return 42.195;
      case GoalType.generalFitness: return 10.0; // use 10K equivalent
    }
  }

  // ── Pace multipliers per goal type ────────────────────────────────────────
  // (fastMultiplier, slowMultiplier) relative to goal race pace (sec/km).
  // Based on Jack Daniels' VDOT training zones.
  // multiplier > 1.0 → slower than race pace; < 1.0 → faster.
  static const _zones = <GoalType, Map<WorkoutType, (double fast, double slow)>>{
    GoalType.fiveK: {
      WorkoutType.easyRun:    (1.30, 1.43),
      WorkoutType.longRun:    (1.33, 1.46),
      WorkoutType.tempoRun:   (1.06, 1.12),
      WorkoutType.intervalRun:(0.99, 1.03),
    },
    GoalType.tenK: {
      WorkoutType.easyRun:    (1.22, 1.34),
      WorkoutType.longRun:    (1.25, 1.37),
      WorkoutType.tempoRun:   (1.02, 1.08),
      WorkoutType.intervalRun:(0.94, 0.98),
    },
    GoalType.halfMarathon: {
      WorkoutType.easyRun:    (1.15, 1.26),
      WorkoutType.longRun:    (1.17, 1.28),
      WorkoutType.tempoRun:   (0.98, 1.04),
      WorkoutType.intervalRun:(0.88, 0.93),
    },
    GoalType.marathon: {
      WorkoutType.easyRun:    (1.12, 1.22),
      WorkoutType.longRun:    (1.08, 1.17),
      WorkoutType.tempoRun:   (0.93, 0.97),
      WorkoutType.intervalRun:(0.81, 0.86),
    },
    GoalType.generalFitness: {
      WorkoutType.easyRun:    (1.22, 1.34),
      WorkoutType.longRun:    (1.25, 1.37),
      WorkoutType.tempoRun:   (1.02, 1.08),
      WorkoutType.intervalRun:(0.94, 0.98),
    },
  };

  static const _descriptions = <WorkoutType, String>{
    WorkoutType.easyRun:
        'Conversational pace. Should feel easy — you could hold a full conversation. Builds aerobic base.',
    WorkoutType.longRun:
        'Slightly slower than easy. Used for your weekend long run to build endurance.',
    WorkoutType.tempoRun:
        'Comfortably hard. You can speak in short sentences. Raises lactate threshold.',
    WorkoutType.intervalRun:
        'Hard effort. Brief high-intensity bursts at or faster than race pace. Builds VO₂max.',
  };

  /// Returns pace zones for the given [goal] and [goalTimeSeconds].
  /// Returns an empty list if the time is implausible (< 10 min or > 10 h).
  static List<PaceZone> calculate({
    required GoalType goal,
    required int goalTimeSeconds,
  }) {
    if (goalTimeSeconds < 600 || goalTimeSeconds > 36000) return [];

    final racePace = goalTimeSeconds / distanceKm(goal); // sec/km
    final zones = _zones[goal] ?? _zones[GoalType.tenK]!;

    // Fixed display order
    const order = [
      WorkoutType.easyRun,
      WorkoutType.longRun,
      WorkoutType.tempoRun,
      WorkoutType.intervalRun,
    ];

    return order.map((type) {
      final (fast, slow) = zones[type]!;
      return PaceZone(
        type: type,
        fastSecs: (racePace * fast).round(),
        slowSecs: (racePace * slow).round(),
        description: _descriptions[type]!,
      );
    }).toList();
  }

  /// Formats a total-seconds goal time as "H:MM:SS" or "MM:SS".
  static String formatGoalTime(int totalSecs) {
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    final s = totalSecs % 60;
    if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
