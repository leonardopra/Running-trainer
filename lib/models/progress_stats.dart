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

  const ProgressStats({
    required this.totalNonRestWorkouts,
    required this.completedWorkouts,
    required this.totalPlannedKm,
    required this.totalLoggedKm,
    required this.currentStreak,
    required this.weeklyProgress,
  });

  double get completionRate =>
      totalNonRestWorkouts == 0 ? 0 : completedWorkouts / totalNonRestWorkouts;

  double get loggedRate =>
      totalPlannedKm == 0 ? 0 : totalLoggedKm / totalPlannedKm;
}
