import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/progress_stats.dart';
import '../models/training_plan.dart';
import 'training_plan_provider.dart';

final progressStatsProvider = Provider<ProgressStats?>((ref) {
  final plan = ref.watch(activePlanProvider);
  if (plan == null) return null;
  return _computeStats(plan);
});

ProgressStats _computeStats(TrainingPlan plan) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final daysSinceStart = today.difference(
    DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day),
  ).inDays;
  final currentWeekIndex = (daysSinceStart ~/ 7).clamp(0, plan.totalWeeks - 1);

  int totalNonRest = 0;
  int completed = 0;
  double totalPlanned = 0;
  double totalLogged = 0;
  final weeklyProgress = <WeekProgress>[];

  for (int wi = 0; wi < plan.weeks.length; wi++) {
    final week = plan.weeks[wi];
    final hasStarted = wi <= currentWeekIndex;

    double weekPlanned = 0;
    double weekLogged = 0;
    int weekNonRest = 0;
    int weekCompleted = 0;

    for (final w in week.workouts) {
      if (w.type == WorkoutType.rest) continue;
      weekNonRest++;
      totalNonRest++;
      weekPlanned += w.distanceKm ?? 0;
      totalPlanned += w.distanceKm ?? 0;

      if (w.isCompleted) {
        weekCompleted++;
        completed++;
        weekLogged += w.actualDistanceKm ?? w.distanceKm ?? 0;
        totalLogged += w.actualDistanceKm ?? w.distanceKm ?? 0;
      }
    }

    if (hasStarted) {
      weeklyProgress.add(WeekProgress(
        weekNumber: wi + 1,
        plannedKm: weekPlanned,
        loggedKm: weekLogged,
        totalWorkouts: weekNonRest,
        completedWorkouts: weekCompleted,
        hasStarted: true,
      ));
    }
  }

  // Streak: count consecutive days going back from today where a run was
  // scheduled AND completed. Rest days are skipped (don't break streak).
  int streak = 0;
  outer:
  for (int d = 0; d >= -365; d--) {
    final date = today.add(Duration(days: d));
    final daysSince = date.difference(
      DateTime(plan.startDate.year, plan.startDate.month, plan.startDate.day),
    ).inDays;
    if (daysSince < 0) break;

    final wi = daysSince ~/ 7;
    if (wi >= plan.weeks.length) continue;
    final dow = date.weekday; // 1=Mon
    final workout = plan.weeks[wi].workouts
        .where((w) => w.dayOfWeek == dow)
        .firstOrNull;

    if (workout == null || workout.type == WorkoutType.rest) continue;
    if (!workout.isCompleted) break outer;
    streak++;
  }

  return ProgressStats(
    totalNonRestWorkouts: totalNonRest,
    completedWorkouts: completed,
    totalPlannedKm: totalPlanned,
    totalLoggedKm: totalLogged,
    currentStreak: streak,
    weeklyProgress: weeklyProgress,
  );
}
