import 'package:flutter/material.dart';
import '../models/coaching_insight.dart';
import '../models/enums.dart';
import '../models/training_plan.dart';
import '../models/workout.dart';

class InsightsService {
  static List<CoachingInsight> generate(TrainingPlan plan) {
    final insights = <CoachingInsight>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysSinceStart = today
        .difference(DateTime(
          plan.startDate.year,
          plan.startDate.month,
          plan.startDate.day,
        ))
        .inDays;

    final currentWeekIndex =
        (daysSinceStart ~/ 7).clamp(0, plan.totalWeeks - 1);
    final currentWeek = plan.weeks[currentWeekIndex];

    // ── 1. Race countdown ───────────────────────────────────────────────────
    if (plan.raceDate != null) {
      final daysToRace = plan.raceDate!.difference(today).inDays;
      if (daysToRace >= 0) insights.add(_raceCountdown(daysToRace, plan.goalType));
    }

    // ── 2. Taper week ───────────────────────────────────────────────────────
    if (currentWeek.isTaperWeek) {
      insights.add(const CoachingInsight(
        title: 'Taper Week',
        body: 'Lower volume is intentional — your body is absorbing the training and storing energy for race day. Trust the process.',
        icon: Icons.battery_charging_full,
        type: InsightType.info,
        priority: 5,
      ));
    }

    // ── 3. Recovery week (volume drops ≥15% vs previous) ───────────────────
    if (!currentWeek.isTaperWeek && currentWeekIndex > 0) {
      final prevKm = plan.weeks[currentWeekIndex - 1].targetWeeklyKm;
      final thisKm = currentWeek.targetWeeklyKm;
      if (prevKm > 0 && thisKm / prevKm < 0.88) {
        insights.add(const CoachingInsight(
          title: 'Recovery Week',
          body: "This week's volume is intentionally lower. Recovery weeks are where fitness is consolidated — don't be tempted to add extra miles.",
          icon: Icons.self_improvement,
          type: InsightType.info,
          priority: 6,
        ));
      }
    }

    // ── 4. First week welcome ───────────────────────────────────────────────
    if (currentWeekIndex == 0 && daysSinceStart < 7) {
      insights.add(const CoachingInsight(
        title: 'Week 1 — Welcome!',
        body: 'Focus on building the habit, not the pace. Completing every run, however slowly, is what matters right now.',
        icon: Icons.waving_hand,
        type: InsightType.motivation,
        priority: 4,
      ));
    }

    // ── 5. Overall completion rate ──────────────────────────────────────────
    final pastWorkouts = <Workout>[];
    for (int wi = 0; wi < currentWeekIndex; wi++) {
      pastWorkouts.addAll(
          plan.weeks[wi].workouts.where((w) => w.type != WorkoutType.rest));
    }
    if (pastWorkouts.isNotEmpty) {
      final done = pastWorkouts.where((w) => w.isCompleted).length;
      final rate = done / pastWorkouts.length;
      if (rate >= 0.85) {
        insights.add(CoachingInsight(
          title: 'Excellent Consistency',
          body: '${(rate * 100).toStringAsFixed(0)}% of planned sessions completed. That level of consistency is what separates finishers from DNFs.',
          icon: Icons.emoji_events,
          type: InsightType.positive,
          priority: 10,
        ));
      } else if (rate < 0.55 && currentWeekIndex >= 2) {
        insights.add(CoachingInsight(
          title: 'Consistency Needs Work',
          body: "You've completed ${(rate * 100).toStringAsFixed(0)}% of planned sessions. Even shorter, slower runs count — aim for 70%+ to see real fitness gains.",
          icon: Icons.warning_amber_rounded,
          type: InsightType.warning,
          priority: 8,
        ));
      }
    }

    // ── 6. Recent missed workouts (last 7 days, excluding today) ───────────
    int recentMissed = 0;
    for (int d = 1; d <= 7; d++) {
      final date = today.subtract(Duration(days: d));
      final ds = date
          .difference(DateTime(
            plan.startDate.year,
            plan.startDate.month,
            plan.startDate.day,
          ))
          .inDays;
      if (ds < 0) break;
      final wi = ds ~/ 7;
      if (wi >= plan.weeks.length) continue;
      final dow = date.weekday;
      final w = plan.weeks[wi].workouts
          .where((w) => w.dayOfWeek == dow && w.type != WorkoutType.rest)
          .firstOrNull;
      if (w != null && !w.isCompleted) recentMissed++;
    }
    if (recentMissed >= 3) {
      insights.add(CoachingInsight(
        title: 'Getting Back on Track',
        body: "You've missed $recentMissed sessions in the last 7 days. Life happens — don't try to make up missed runs. Just pick up where you are.",
        icon: Icons.refresh,
        type: InsightType.warning,
        priority: 7,
      ));
    }

    // ── 7. Current week volume progress ─────────────────────────────────────
    final weekLoggedKm = currentWeek.workouts
        .where((w) => w.isCompleted && w.type != WorkoutType.rest)
        .fold<double>(0, (s, w) => s + (w.actualDistanceKm ?? w.distanceKm ?? 0));
    final weekTargetKm = currentWeek.targetWeeklyKm;
    final todayDow = today.weekday; // 1=Mon, 7=Sun
    // Workouts planned so far this week (Mon up to and including today)
    final plannedSoFar = currentWeek.workouts
        .where((w) => w.dayOfWeek <= todayDow && w.type != WorkoutType.rest)
        .fold<double>(0, (s, w) => s + (w.distanceKm ?? 0));

    if (plannedSoFar > 0) {
      final weekCompletionRate = weekLoggedKm / plannedSoFar;
      if (weekCompletionRate >= 1.0 && todayDow >= 3) {
        insights.add(CoachingInsight(
          title: 'On Track This Week',
          body: "You've already logged ${weekLoggedKm.toStringAsFixed(1)} km of your ${weekTargetKm.toStringAsFixed(0)} km target. Keep it up!",
          icon: Icons.trending_up,
          type: InsightType.positive,
          priority: 12,
        ));
      } else if (weekCompletionRate < 0.4 && todayDow >= 4) {
        final remaining = (weekTargetKm - weekLoggedKm).clamp(0, 999);
        insights.add(CoachingInsight(
          title: 'Behind This Week',
          body: 'You still have ${remaining.toStringAsFixed(1)} km to go to hit your weekly target. There\'s still time — make it count.',
          icon: Icons.directions_run,
          type: InsightType.warning,
          priority: 9,
        ));
      }
    }

    // ── 8. Easy runs paced too fast ──────────────────────────────────────────
    final loggedEasyRuns = plan.weeks
        .expand((w) => w.workouts)
        .where((w) =>
            w.type == WorkoutType.easyRun &&
            w.isCompleted &&
            w.actualDistanceKm != null &&
            w.actualDistanceKm! > 0 &&
            w.actualDurationMinutes != null &&
            w.durationMinutes != null &&
            w.distanceKm != null &&
            w.distanceKm! > 0)
        .toList();

    if (loggedEasyRuns.length >= 3) {
      int tooFastCount = 0;
      for (final w in loggedEasyRuns) {
        final targetPace =
            (w.durationMinutes! * 60) / w.distanceKm!; // sec/km
        final actualPace =
            (w.actualDurationMinutes! * 60) / w.actualDistanceKm!;
        if (actualPace < targetPace * 0.92) tooFastCount++;
      }
      final ratio = tooFastCount / loggedEasyRuns.length;
      if (ratio >= 0.6) {
        insights.add(const CoachingInsight(
          title: 'Easy Runs Too Fast',
          body: 'Your easy runs are consistently faster than target pace. Running easy too hard blunts adaptation. Slow down — if you can\'t hold a conversation, it\'s too fast.',
          icon: Icons.speed,
          type: InsightType.warning,
          priority: 11,
        ));
      }
    }

    // ── 9. Long run skipped last week ─────────────────────────────────────
    if (currentWeekIndex > 0) {
      final prevWeek = plan.weeks[currentWeekIndex - 1];
      final longRun = prevWeek.workouts
          .where((w) => w.type == WorkoutType.longRun)
          .firstOrNull;
      if (longRun != null && !longRun.isCompleted) {
        insights.add(const CoachingInsight(
          title: 'Missed Long Run',
          body: 'You skipped last week\'s long run. The long run is the cornerstone of endurance training — try to prioritise it above other sessions.',
          icon: Icons.flag,
          type: InsightType.warning,
          priority: 8,
        ));
      }
    }

    // ── 10. Streak celebration ───────────────────────────────────────────────
    int streak = 0;
    for (int d = 0; d < 30; d++) {
      final date = today.subtract(Duration(days: d));
      final ds = date
          .difference(DateTime(
            plan.startDate.year,
            plan.startDate.month,
            plan.startDate.day,
          ))
          .inDays;
      if (ds < 0) break;
      final wi = ds ~/ 7;
      if (wi >= plan.weeks.length) break;
      final dow = date.weekday;
      final w = plan.weeks[wi].workouts
          .where((w) => w.dayOfWeek == dow && w.type != WorkoutType.rest)
          .firstOrNull;
      if (w == null) continue; // rest day, doesn't break streak
      if (!w.isCompleted) break;
      streak++;
    }
    if (streak >= 5) {
      insights.add(CoachingInsight(
        title: '$streak-Session Streak 🔥',
        body: "You haven't missed a scheduled run in $streak sessions. That consistency compounds into serious fitness.",
        icon: Icons.local_fire_department,
        type: InsightType.positive,
        priority: 13,
      ));
    }

    // ── 11. Tomorrow has a key session ────────────────────────────────────
    final tomorrow = today.add(const Duration(days: 1));
    final tDs = tomorrow
        .difference(DateTime(
          plan.startDate.year,
          plan.startDate.month,
          plan.startDate.day,
        ))
        .inDays;
    if (tDs >= 0) {
      final tWi = tDs ~/ 7;
      if (tWi < plan.weeks.length) {
        final tDow = tomorrow.weekday;
        final tomorrowWorkout = plan.weeks[tWi].workouts
            .where((w) => w.dayOfWeek == tDow)
            .firstOrNull;
        if (tomorrowWorkout != null &&
            (tomorrowWorkout.type == WorkoutType.longRun ||
                tomorrowWorkout.type == WorkoutType.intervalRun ||
                tomorrowWorkout.type == WorkoutType.tempoRun)) {
          final typeLabel = tomorrowWorkout.type.displayName;
          final km = tomorrowWorkout.distanceKm != null
              ? ' (${tomorrowWorkout.distanceKm!.toStringAsFixed(1)} km)'
              : '';
          insights.add(CoachingInsight(
            title: 'Key Session Tomorrow',
            body: '$typeLabel$km tomorrow. Sleep well tonight, eat well, and plan your route in advance.',
            icon: Icons.event,
            type: InsightType.motivation,
            priority: 14,
          ));
        }
      }
    }

    return insights..sort((a, b) => a.priority.compareTo(b.priority));
  }

  // ── helpers ─────────────────────────────────────────────────────────────
  static CoachingInsight _raceCountdown(int daysToRace, GoalType goal) {
    final race = goal.displayName;
    if (daysToRace == 0) {
      return CoachingInsight(
        title: 'Race Day! 🏁',
        body: "Today is your $race. You've done the work — trust your training and enjoy every kilometre.",
        icon: Icons.emoji_events,
        type: InsightType.motivation,
        priority: 1,
      );
    } else if (daysToRace <= 7) {
      return CoachingInsight(
        title: '$daysToRace Days to Race',
        body: 'Race week for your $race. Prioritise rest, sleep, hydration, and a final easy shakeout run.',
        icon: Icons.flag,
        type: InsightType.motivation,
        priority: 2,
      );
    } else if (daysToRace <= 21) {
      final weeks = (daysToRace / 7).ceil();
      return CoachingInsight(
        title: '$weeks Weeks to Go',
        body: "Your $race is almost here. The hay is in the barn — trust your training and avoid heroic sessions.",
        icon: Icons.directions_run,
        type: InsightType.info,
        priority: 3,
      );
    } else {
      final weeks = (daysToRace / 7).ceil();
      return CoachingInsight(
        title: '$weeks Weeks to Race Day',
        body: "You have $weeks weeks to build fitness for your $race. Stay consistent — small daily habits create big race results.",
        icon: Icons.calendar_month,
        type: InsightType.info,
        priority: 15,
      );
    }
  }
}
