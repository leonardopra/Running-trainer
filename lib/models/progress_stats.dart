import 'enums.dart';

class WorkoutTypeCount {
  final WorkoutType type;
  final int count;

  const WorkoutTypeCount({
    required this.type,
    required this.count,
  });
}

class PaceDataPoint {
  final double paceMinPerKm;
  final WorkoutType type;
  final DateTime date;
  const PaceDataPoint({required this.paceMinPerKm, required this.type, required this.date});
}

class RpeDataPoint {
  final DateTime date;
  final int rpe;
  final WorkoutType type;

  const RpeDataPoint({required this.date, required this.rpe, required this.type});
}

class WeekProgress {
  final int weekNumber;
  final double plannedKm;
  final double loggedKm;
  final int totalWorkouts;   // non-rest
  final int completedWorkouts;
  final bool hasStarted;

  const WeekProgress({
    required this.weekNumber,
    required this.plannedKm,
    required this.loggedKm,
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.hasStarted,
  });

  double get completionRate =>
      totalWorkouts == 0 ? 0 : completedWorkouts / totalWorkouts;
}

class ProgressStats {
  final int totalNonRestWorkouts;
  final int completedWorkouts;
  final double totalPlannedKm;
  final double totalLoggedKm;
  final int currentStreak; // consecutive completed run days up to today
  final List<WeekProgress> weeklyProgress; // only weeks that have started
  final List<RpeDataPoint> rpeDataPoints;
  final Map<WorkoutFeeling, int> feelingCounts;
  final List<PaceDataPoint> paceDataPoints;
  final List<WorkoutTypeCount> workoutTypeCounts;

  const ProgressStats({
    required this.totalNonRestWorkouts,
    required this.completedWorkouts,
    required this.totalPlannedKm,
    required this.totalLoggedKm,
    required this.currentStreak,
    required this.weeklyProgress,
    required this.rpeDataPoints,
    required this.feelingCounts,
    this.paceDataPoints = const [],
    this.workoutTypeCounts = const [],
  });

  double get completionRate =>
      totalNonRestWorkouts == 0 ? 0 : completedWorkouts / totalNonRestWorkouts;

  double get loggedRate =>
      totalPlannedKm == 0 ? 0 : totalLoggedKm / totalPlannedKm;
}
