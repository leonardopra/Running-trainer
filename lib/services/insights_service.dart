import 'package:flutter/material.dart';
import '../models/coaching_insight.dart';
import '../models/enums.dart';
import '../models/training_plan.dart';
import '../models/workout.dart';
import '../core/l10n_helpers.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';

class InsightsService {
  static List<CoachingInsight> generate(TrainingPlan plan, AppLocalizations l10n) {
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
      if (daysToRace >= 0) insights.add(_raceCountdown(daysToRace, plan.goalType, l10n));
    }

    // ── 2. Taper week ───────────────────────────────────────────────────────
    if (currentWeek.isTaperWeek) {
      insights.add(CoachingInsight(
        title: l10n.insightTaperWeekTitle,
        body: l10n.insightTaperWeekBody,
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
        insights.add(CoachingInsight(
          title: l10n.insightRecoveryWeekTitle,
          body: l10n.insightRecoveryWeekBody,
          icon: Icons.self_improvement,
          type: InsightType.info,
          priority: 6,
        ));
      }
    }

    // ── 4. First week welcome ───────────────────────────────────────────────
    if (currentWeekIndex == 0 && daysSinceStart < 7) {
      insights.add(CoachingInsight(
        title: l10n.insightWeek1Title,
        body: l10n.insightWeek1Body,
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
          title: l10n.insightHighConsistencyTitle,
          body: l10n.insightHighConsistencyBody((rate * 100).toStringAsFixed(0)),
          icon: Icons.emoji_events,
          type: InsightType.positive,
          priority: 10,
        ));
      } else if (rate < 0.55 && currentWeekIndex >= 2) {
        insights.add(CoachingInsight(
          title: l10n.insightLowConsistencyTitle,
          body: l10n.insightLowConsistencyBody((rate * 100).toStringAsFixed(0)),
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
        title: l10n.insightBackOnTrackTitle,
        body: l10n.insightBackOnTrackBody(recentMissed),
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
          title: l10n.insightOnTrackTitle,
          body: l10n.insightOnTrackBody(
            weekLoggedKm.toStringAsFixed(1),
            weekTargetKm.toStringAsFixed(0),
          ),
          icon: Icons.trending_up,
          type: InsightType.positive,
          priority: 12,
        ));
      } else if (weekCompletionRate < 0.4 && todayDow >= 4) {
        final remaining = (weekTargetKm - weekLoggedKm).clamp(0, 999);
        insights.add(CoachingInsight(
          title: l10n.insightBehindTitle,
          body: l10n.insightBehindBody(remaining.toStringAsFixed(1)),
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
        insights.add(CoachingInsight(
          title: l10n.insightEasyRunsFastTitle,
          body: l10n.insightEasyRunsFastBody,
          icon: Icons.speed,
          type: InsightType.warning,
          priority: 11,
        ));
      }
    }

    // ── 12. Easy runs RPE too high ───────────────────────────────────────
    final recentEasyWithRpe = plan.weeks
        .expand((w) => w.workouts)
        .where((w) =>
            w.type == WorkoutType.easyRun &&
            w.isCompleted &&
            w.rpe != null &&
            w.completedAt != null &&
            today.difference(w.completedAt!).inDays <= 14)
        .toList();
    if (recentEasyWithRpe.length >= 3) {
      final highRpeCount =
          recentEasyWithRpe.where((w) => w.rpe! >= 7).length;
      if (highRpeCount >= 3) {
        insights.add(CoachingInsight(
          title: l10n.insightHighRpeEasyTitle,
          body: l10n.insightHighRpeEasyBody,
          icon: Icons.monitor_heart,
          type: InsightType.warning,
          priority: 11,
        ));
      }
    }

    // ── 13. Consecutive negative feeling ────────────────────────────────
    final completedByDate = plan.weeks
        .expand((w) => w.workouts)
        .where((w) =>
            w.isCompleted &&
            w.feeling != null &&
            w.type != WorkoutType.rest &&
            w.completedAt != null)
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    if (completedByDate.length >= 2) {
      int consecutiveNeg = 0;
      for (final w in completedByDate) {
        if (w.feeling == WorkoutFeeling.tired ||
            w.feeling == WorkoutFeeling.injured) {
          consecutiveNeg++;
        } else {
          break;
        }
      }
      if (consecutiveNeg >= 2) {
        insights.add(CoachingInsight(
          title: l10n.insightNegativeFeelingTitle,
          body: l10n.insightNegativeFeelingBody,
          icon: Icons.bedtime,
          type: InsightType.warning,
          priority: 9,
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
        insights.add(CoachingInsight(
          title: l10n.insightMissedLongRunTitle,
          body: l10n.insightMissedLongRunBody,
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
        title: l10n.insightStreakTitle(streak),
        body: l10n.insightStreakBody(streak),
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
          final typeLabel = tomorrowWorkout.type.localizedName(l10n);
          final km = tomorrowWorkout.distanceKm != null
              ? tomorrowWorkout.distanceKm!.toStringAsFixed(1)
              : '—';
          insights.add(CoachingInsight(
            title: l10n.insightKeyTomorrowTitle,
            body: l10n.insightKeyTomorrowBody(typeLabel, km),
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
  static CoachingInsight _raceCountdown(int daysToRace, GoalType goal, AppLocalizations l10n) {
    final race = goal.localizedName(l10n);
    if (daysToRace == 0) {
      return CoachingInsight(
        title: l10n.insightRaceDayTitle,
        body: l10n.insightRaceDayBody(race),
        icon: Icons.emoji_events,
        type: InsightType.motivation,
        priority: 1,
      );
    } else if (daysToRace <= 7) {
      return CoachingInsight(
        title: l10n.insightRaceWeekTitle(daysToRace),
        body: l10n.insightRaceWeekBody(race),
        icon: Icons.flag,
        type: InsightType.motivation,
        priority: 2,
      );
    } else if (daysToRace <= 21) {
      final weeks = (daysToRace / 7).ceil();
      return CoachingInsight(
        title: l10n.insightAlmostThereTitle(weeks),
        body: l10n.insightAlmostThereBody(race),
        icon: Icons.directions_run,
        type: InsightType.info,
        priority: 3,
      );
    } else {
      final weeks = (daysToRace / 7).ceil();
      return CoachingInsight(
        title: l10n.insightWeeksToGoTitle(weeks),
        body: l10n.insightWeeksToGoBody(weeks, race),
        icon: Icons.calendar_month,
        type: InsightType.info,
        priority: 15,
      );
    }
  }
}
