import 'package:flutter_test/flutter_test.dart';
import 'package:running_trainer_app/models/enums.dart';
import 'package:running_trainer_app/models/training_plan.dart';
import 'package:running_trainer_app/models/training_week.dart';
import 'package:running_trainer_app/models/workout.dart';
import 'package:running_trainer_app/services/insights_service.dart';
import 'package:running_trainer_app/services/plan_generator_service.dart';
import 'package:running_trainer_app/l10n/app_localizations_en.dart';

void main() {
  late PlanGeneratorService generator;
  final l10n = AppLocalizationsEn();

  setUp(() {
    generator = PlanGeneratorService();
  });

  // ── Build helpers ──────────────────────────────────────────────────────────

  TrainingPlan makePlan({
    required DateTime startDate,
    required List<TrainingWeek> weeks,
    DateTime? raceDate,
    GoalType goalType = GoalType.tenK,
  }) {
    return TrainingPlan(
      id: 'test',
      goalType: goalType,
      fitnessLevel: FitnessLevel.intermediate,
      startDate: startDate,
      raceDate: raceDate,
      totalWeeks: weeks.length,
      trainingDaysPerWeek: 4,
      weeks: weeks,
      createdAt: startDate,
    );
  }

  Workout makeWorkout({
    required WorkoutType type,
    required int dayOfWeek,
    String? id,
    bool completed = false,
    double? distanceKm,
    int? durationMinutes,
    double? actualDistanceKm,
    int? actualDurationMinutes,
    DateTime? completedAt,
    int? rpe,
    WorkoutFeeling? feeling,
  }) {
    return Workout(
      id: id ?? '${type.name}_$dayOfWeek',
      type: type,
      dayOfWeek: dayOfWeek,
      effortLevel: EffortLevel.easy,
      title: type.displayName,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      isCompleted: completed,
      actualDistanceKm: actualDistanceKm,
      actualDurationMinutes: actualDurationMinutes,
      completedAt: completedAt,
      rpe: rpe,
      feeling: feeling,
    );
  }

  /// Build a [TrainingWeek] with the given workouts; rest days fill remaining slots.
  TrainingWeek makeWeek({
    required int weekNum,
    required List<Workout> workouts,
    double km = 30,
    bool isTaper = false,
  }) {
    final byDay = {for (final wk in workouts) wk.dayOfWeek: wk};
    final all = List.generate(7, (i) {
      final dow = i + 1;
      return byDay[dow] ??
          Workout(
            id: 'rest_w${weekNum}_$dow',
            type: WorkoutType.rest,
            dayOfWeek: dow,
            effortLevel: EffortLevel.easy,
            title: 'Rest Day',
          );
    });
    return TrainingWeek(
      weekNumber: weekNum,
      weekTheme: 'Test Theme',
      targetWeeklyKm: km,
      isTaperWeek: isTaper,
      workouts: all,
    );
  }

  /// Full rest week (7 rest days).
  TrainingWeek restWeek(int weekNum, {double km = 30, bool isTaper = false}) {
    return makeWeek(weekNum: weekNum, workouts: [], km: km, isTaper: isTaper);
  }

  // ── Basic ──────────────────────────────────────────────────────────────────

  group('InsightsService – basic', () {
    test('returns a list for any valid plan', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      expect(InsightsService.generate(plan, l10n), isA<List>());
    });

    test('insights are sorted by priority ascending', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.advanced,
        trainingDaysPerWeek: 5,
        raceDate: DateTime.now().add(const Duration(days: 90)),
      );
      final insights = InsightsService.generate(plan, l10n);
      for (int i = 1; i < insights.length; i++) {
        expect(
          insights[i].priority >= insights[i - 1].priority,
          isTrue,
          reason:
              'index $i (p=${insights[i].priority}) must be >= index ${i - 1} '
              '(p=${insights[i - 1].priority})',
        );
      }
    });

    test('all insight fields are non-empty', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.advanced,
        trainingDaysPerWeek: 6,
        raceDate: DateTime.now().add(const Duration(days: 45)),
      );
      for (final insight in InsightsService.generate(plan, l10n)) {
        expect(insight.title, isNotEmpty);
        expect(insight.body, isNotEmpty);
      }
    });
  });

  // ── Category 1: Race countdown ─────────────────────────────────────────────

  group('InsightsService – category 1: race countdown', () {
    test('race day (daysToRace == 0, priority 1)', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
        raceDate: DateTime.now(),
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Race Day! 🏁'), isTrue);
      expect(insights.firstWhere((i) => i.title == 'Race Day! 🏁').priority, 1);
    });

    test('race week (1–7 days, priority 2)', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
        raceDate: DateTime.now().add(const Duration(days: 4)),
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.priority == 2),
        isTrue,
        reason: 'Should emit race-week insight (priority 2) when 4 days to race',
      );
    });

    test('almost there (8–21 days, priority 3)', () {
      final plan = generator.generatePlan(
        goalType: GoalType.halfMarathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        raceDate: DateTime.now().add(const Duration(days: 14)),
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.priority == 3),
        isTrue,
        reason: 'Should emit almost-there insight (priority 3) when 14 days to race',
      );
    });

    test('weeks to go (> 21 days, priority 15)', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        raceDate: DateTime.now().add(const Duration(days: 60)),
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.priority == 15),
        isTrue,
        reason: 'Should emit weeks-to-go insight (priority 15) when 60 days to race',
      );
    });

    test('no countdown when no race date', () {
      final plan = generator.generatePlan(
        goalType: GoalType.generalFitness,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, l10n);
      // Priorities 1–3 and 15 are all race countdown variants
      expect(
        insights.any((i) => i.priority <= 3 || i.priority == 15),
        isFalse,
        reason: 'No race countdown insight without a race date',
      );
    });

    test('no countdown when race date is in the past', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
        raceDate: yesterday,
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.priority <= 3 || i.priority == 15),
        isFalse,
      );
    });
  });

  // ── Category 2: Taper week ─────────────────────────────────────────────────

  group('InsightsService – category 2: taper week', () {
    test('fires when the current week is a taper week', () {
      // 16-week marathon, startDate 91 days ago → currentWeekIndex = 13 (week 14 = taper)
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 91));
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        startDate: startDate,
      );
      expect(
        plan.weeks[13].isTaperWeek,
        isTrue,
        reason: 'Week 14 of a 16-week marathon plan must be a taper week',
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Taper Week'), isTrue);
    });

    test('does not fire when current week is not a taper week', () {
      // Plan starts today: week 0 is never a taper week
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
      );
      expect(plan.weeks[0].isTaperWeek, isFalse);
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Taper Week'), isFalse);
    });
  });

  // ── Category 3: Recovery week ──────────────────────────────────────────────

  group('InsightsService – category 3: recovery week', () {
    test('fires when current week km drops ≥ 12% vs previous week', () {
      // Week 4 (index 3) of a 16-week marathon plan is a recovery week (80% of prev)
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 21));
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        startDate: startDate,
      );
      final ratio = plan.weeks[3].targetWeeklyKm / plan.weeks[2].targetWeeklyKm;
      expect(ratio, lessThan(0.88), reason: 'Week 4 km should be ~80% of week 3');
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Recovery Week'), isTrue);
    });

    test('does not fire when weekly volume stays stable', () {
      final today = DateTime.now();
      final plan = makePlan(
        startDate: today.subtract(const Duration(days: 7)),
        weeks: [
          makeWeek(weekNum: 1, workouts: [], km: 30),
          makeWeek(weekNum: 2, workouts: [], km: 30), // same km, no drop
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Recovery Week'), isFalse);
    });
  });

  // ── Category 4: Week 1 welcome ─────────────────────────────────────────────

  group('InsightsService – category 4: week 1 welcome', () {
    test('fires when plan starts today', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title.contains('Week 1')), isTrue);
    });

    test('does not fire after week 1 has passed', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
        startDate: DateTime.now().subtract(const Duration(days: 8)),
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title.contains('Week 1')), isFalse);
    });
  });

  // ── Category 5: Overall completion rate ───────────────────────────────────

  group('InsightsService – category 5: overall completion rate', () {
    test('high-consistency insight fires when completion rate ≥ 85%', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        startDate: DateTime.now().subtract(const Duration(days: 21)),
      );
      for (int wi = 0; wi < 3; wi++) {
        for (final wk in plan.weeks[wi].workouts) {
          if (wk.type != WorkoutType.rest) wk.isCompleted = true;
        }
      }
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title.contains('Excellent Consistency')), isTrue);
    });

    test('low-consistency warning fires when completion rate < 55% after week 2', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        startDate: DateTime.now().subtract(const Duration(days: 21)),
      );
      // All workouts left uncompleted (default)
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title.contains('Consistency Needs Work')), isTrue);
    });

    test('no consistency insight in week 1 (no past data)', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title.contains('Consistency')), isFalse);
    });
  });

  // ── Category 6: Recent missed workouts ────────────────────────────────────

  group('InsightsService – category 6: recent missed workouts', () {
    test('fires when ≥ 3 training workouts missed in the last 7 days', () {
      // Start 14 days ago → last 7 days land in week index 1.
      // With 5 training days [1,2,4,5,7] all uncompleted, 5 misses ≥ 3.
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 5,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'Getting Back on Track'),
        isTrue,
        reason: '5 uncompleted training days in the last 7 days → Back on Track',
      );
    });

    test('does not fire when recent workouts are all completed', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 5,
        startDate: DateTime.now().subtract(const Duration(days: 14)),
      );
      for (final week in plan.weeks) {
        for (final wk in week.workouts) {
          wk.isCompleted = true;
        }
      }
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Getting Back on Track'), isFalse);
    });
  });

  // ── Category 7: Weekly volume progress ────────────────────────────────────

  group('InsightsService – category 7: weekly volume progress', () {
    test('on-track fires when all planned km are logged and day ≥ Wednesday', () {
      final now = DateTime.now();
      if (now.weekday < 3) return; // insight requires todayDow >= 3
      final todayNorm = DateTime(now.year, now.month, now.day);
      final todayDow = now.weekday;
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: todayDow,
                id: 'on_track_run',
                completed: true,
                distanceKm: 8,
                actualDistanceKm: 8,
              ),
            ],
            km: 8,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'On Track This Week'),
        isTrue,
        reason: 'All planned km logged → On Track This Week (Wed or later)',
      );
    });

    test('behind-this-week fires when little done and day ≥ Thursday', () {
      final now = DateTime.now();
      if (now.weekday < 4) return; // insight requires todayDow >= 4
      final todayNorm = DateTime(now.year, now.month, now.day);
      final todayDow = now.weekday;
      // 30 km planned today, 0 logged → rate = 0 < 0.4
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: todayDow,
                id: 'behind_run',
                completed: false,
                distanceKm: 30,
              ),
            ],
            km: 30,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'Behind This Week'),
        isTrue,
        reason: '0% completion rate → Behind This Week (Thu or later)',
      );
    });
  });

  // ── Category 8: Easy runs paced too fast ──────────────────────────────────

  group('InsightsService – category 8: easy runs paced too fast', () {
    test('fires when ≥ 60% of easy runs are significantly faster than target pace', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 14));

      // Target pace 6:00/km (360 sec/km), actual 5:00/km (300 sec/km)
      // 300 < 360 * 0.92 = 331.2 → too fast
      Workout fast(int dow, String id) => makeWorkout(
            type: WorkoutType.easyRun,
            dayOfWeek: dow,
            id: id,
            completed: true,
            distanceKm: 10,
            durationMinutes: 60,
            actualDistanceKm: 10,
            actualDurationMinutes: 50,
            completedAt: now,
          );
      Workout normal(int dow, String id) => makeWorkout(
            type: WorkoutType.easyRun,
            dayOfWeek: dow,
            id: id,
            completed: true,
            distanceKm: 10,
            durationMinutes: 60,
            actualDistanceKm: 10,
            actualDurationMinutes: 60,
            completedAt: now,
          );

      // 4 fast + 1 normal = 80% too fast ≥ 0.6 threshold
      final plan = makePlan(
        startDate: startDate,
        weeks: [
          makeWeek(weekNum: 1, workouts: [fast(1, 'f1'), fast(3, 'f2'), fast(5, 'f3')], km: 30),
          makeWeek(weekNum: 2, workouts: [fast(2, 'f4'), normal(4, 'n1')], km: 30),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'Easy Runs Too Fast'),
        isTrue,
        reason: '4/5 easy runs too fast (ratio 0.8 ≥ 0.6)',
      );
    });

    test('does not fire when fewer than 3 easy runs are logged', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: 1,
                id: 'only_run',
                completed: true,
                distanceKm: 8,
                durationMinutes: 48,
                actualDistanceKm: 8,
                actualDurationMinutes: 40,
                completedAt: now,
              ),
            ],
            km: 8,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Easy Runs Too Fast'), isFalse);
    });

    test('does not fire when most easy runs are properly paced', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 14));

      Workout proper(int dow, String id) => makeWorkout(
            type: WorkoutType.easyRun,
            dayOfWeek: dow,
            id: id,
            completed: true,
            distanceKm: 10,
            durationMinutes: 60,
            actualDistanceKm: 10,
            actualDurationMinutes: 58, // actualPace / targetPace ≈ 0.97 > 0.92
            completedAt: now,
          );
      final plan = makePlan(
        startDate: startDate,
        weeks: [
          makeWeek(weekNum: 1, workouts: [proper(1, 'p1'), proper(3, 'p2'), proper(5, 'p3')], km: 30),
          makeWeek(weekNum: 2, workouts: [proper(2, 'p4'), proper(4, 'p5')], km: 30),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Easy Runs Too Fast'), isFalse);
    });
  });

  // ── Category 9: Long run skipped last week ────────────────────────────────

  group('InsightsService – category 9: long run skipped last week', () {
    test('fires when previous week had an incomplete long run', () {
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
      final plan = makePlan(
        startDate: startDate,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.longRun,
                dayOfWeek: 7,
                id: 'lr_skipped',
                completed: false,
                distanceKm: 15,
              ),
            ],
            km: 35,
          ),
          restWeek(2, km: 35), // current week
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'Missed Long Run'),
        isTrue,
        reason: 'Long run in previous week was not completed',
      );
    });

    test('does not fire when previous week long run was completed', () {
      final today = DateTime.now();
      final startDate = today.subtract(const Duration(days: 7));
      final plan = makePlan(
        startDate: startDate,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.longRun,
                dayOfWeek: 7,
                id: 'lr_done',
                completed: true,
                distanceKm: 15,
                completedAt: today.subtract(const Duration(days: 1)),
              ),
            ],
            km: 35,
          ),
          restWeek(2, km: 35),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Missed Long Run'), isFalse);
    });

    test('does not fire in week 1 (no previous week)', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Missed Long Run'), isFalse);
    });
  });

  // ── Category 10: Streak celebration ──────────────────────────────────────

  group('InsightsService – category 10: streak celebration', () {
    test('fires when ≥ 5 consecutive training days are completed', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      // Start 6 days ago; all 7 days are training (easyRun) and completed
      final startDate = todayNorm.subtract(const Duration(days: 6));
      final allCompleted = List.generate(7, (i) {
        return makeWorkout(
          type: WorkoutType.easyRun,
          dayOfWeek: i + 1,
          id: 'streak_${i + 1}',
          completed: true,
          distanceKm: 5,
          completedAt: startDate.add(Duration(days: i)),
        );
      });
      final plan = makePlan(
        startDate: startDate,
        weeks: [
          TrainingWeek(
            weekNumber: 1,
            weekTheme: 'Streak Test',
            targetWeeklyKm: 35,
            isTaperWeek: false,
            workouts: allCompleted,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title.contains('Session Streak')),
        isTrue,
        reason: '7 consecutive training days completed → streak ≥ 5',
      );
    });

    test('does not fire when streak is fewer than 5', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      // Plan starts today: at most 1 day of streak data exists
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: todayNorm.weekday,
                id: 'short_streak',
                completed: true,
                completedAt: todayNorm,
              ),
            ],
            km: 5,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title.contains('Session Streak')), isFalse);
    });
  });

  // ── Category 11: Key session tomorrow ────────────────────────────────────

  group('InsightsService – category 11: key session tomorrow', () {
    test('fires when tomorrow has a long run', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final tomorrowDow = todayNorm.add(const Duration(days: 1)).weekday;
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.longRun,
                dayOfWeek: tomorrowDow,
                id: 'lr_tomorrow',
                distanceKm: 18,
              ),
            ],
            km: 40,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Key Session Tomorrow'), isTrue);
    });

    test('fires when tomorrow has a tempo run', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final tomorrowDow = todayNorm.add(const Duration(days: 1)).weekday;
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.tempoRun,
                dayOfWeek: tomorrowDow,
                id: 'tempo_tomorrow',
                distanceKm: 8,
              ),
            ],
            km: 30,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Key Session Tomorrow'), isTrue);
    });

    test('fires when tomorrow has an interval run', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final tomorrowDow = todayNorm.add(const Duration(days: 1)).weekday;
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.intervalRun,
                dayOfWeek: tomorrowDow,
                id: 'interval_tomorrow',
                distanceKm: 6,
              ),
            ],
            km: 25,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Key Session Tomorrow'), isTrue);
    });

    test('does not fire when tomorrow is a rest day', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      // Only put a workout on today; tomorrow slot stays rest
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: todayNorm.weekday,
                id: 'easy_today',
              ),
            ],
            km: 8,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Key Session Tomorrow'), isFalse);
    });

    test('does not fire when tomorrow has only an easy run', () {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final tomorrowDow = todayNorm.add(const Duration(days: 1)).weekday;
      final plan = makePlan(
        startDate: todayNorm,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: tomorrowDow,
                id: 'easy_tomorrow',
              ),
            ],
            km: 8,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Key Session Tomorrow'), isFalse);
    });
  });

  // ── Category 12: Easy runs RPE too high ───────────────────────────────────

  group('InsightsService – category 12: easy runs RPE too high', () {
    test('fires when ≥ 3 recent easy runs have RPE ≥ 7', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now.subtract(const Duration(days: 14)),
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 1, id: 'rpe1', completed: true, rpe: 8, completedAt: now.subtract(const Duration(days: 10))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 3, id: 'rpe2', completed: true, rpe: 7, completedAt: now.subtract(const Duration(days: 8))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 5, id: 'rpe3', completed: true, rpe: 9, completedAt: now.subtract(const Duration(days: 6))),
            ],
            km: 30,
          ),
          restWeek(2, km: 30),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'Easy runs feel too hard'),
        isTrue,
        reason: '3 easy runs with RPE ≥ 7 within last 14 days',
      );
    });

    test('does not fire when fewer than 3 recent easy runs with high RPE', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now.subtract(const Duration(days: 7)),
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 1, id: 'rpe1', completed: true, rpe: 8, completedAt: now.subtract(const Duration(days: 5))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 3, id: 'rpe2', completed: true, rpe: 3, completedAt: now.subtract(const Duration(days: 3))),
            ],
            km: 20,
          ),
          restWeek(2, km: 20),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Easy runs feel too hard'), isFalse);
    });

    test('does not fire when high-RPE runs are older than 14 days', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now.subtract(const Duration(days: 30)),
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 1, id: 'old1', completed: true, rpe: 9, completedAt: now.subtract(const Duration(days: 20))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 3, id: 'old2', completed: true, rpe: 8, completedAt: now.subtract(const Duration(days: 18))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 5, id: 'old3', completed: true, rpe: 7, completedAt: now.subtract(const Duration(days: 16))),
            ],
            km: 30,
          ),
          restWeek(2, km: 30),
          restWeek(3, km: 30),
          restWeek(4, km: 30),
          restWeek(5, km: 30), // current week (index 4)
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Easy runs feel too hard'), isFalse);
    });
  });

  // ── Category 13: Consecutive negative feeling ─────────────────────────────

  group('InsightsService – category 13: consecutive negative feeling', () {
    test('fires when the last 2+ completed workouts report tired or injured', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now.subtract(const Duration(days: 7)),
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 1, id: 'f1', completed: true, feeling: WorkoutFeeling.great, completedAt: now.subtract(const Duration(days: 5))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 3, id: 'f2', completed: true, feeling: WorkoutFeeling.tired, completedAt: now.subtract(const Duration(days: 3))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 5, id: 'f3', completed: true, feeling: WorkoutFeeling.injured, completedAt: now.subtract(const Duration(days: 1))),
            ],
            km: 25,
          ),
          restWeek(2, km: 25),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(
        insights.any((i) => i.title == 'Signs of fatigue'),
        isTrue,
        reason: 'Last 2 workouts (injured then tired) → consecutive negative feeling',
      );
    });

    test('fires with "injured" feeling on its own two consecutive times', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now.subtract(const Duration(days: 7)),
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 2, id: 'inj1', completed: true, feeling: WorkoutFeeling.injured, completedAt: now.subtract(const Duration(days: 4))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 4, id: 'inj2', completed: true, feeling: WorkoutFeeling.injured, completedAt: now.subtract(const Duration(days: 2))),
            ],
            km: 20,
          ),
          restWeek(2, km: 20),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Signs of fatigue'), isTrue);
    });

    test('does not fire when the most recent workout felt good', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now.subtract(const Duration(days: 7)),
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 1, id: 'g1', completed: true, feeling: WorkoutFeeling.tired, completedAt: now.subtract(const Duration(days: 3))),
              makeWorkout(type: WorkoutType.easyRun, dayOfWeek: 3, id: 'g2', completed: true, feeling: WorkoutFeeling.good, completedAt: now.subtract(const Duration(days: 1))),
            ],
            km: 20,
          ),
          restWeek(2, km: 20),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Signs of fatigue'), isFalse);
    });

    test('does not fire when fewer than 2 completed workouts with feeling', () {
      final now = DateTime.now();
      final plan = makePlan(
        startDate: now,
        weeks: [
          makeWeek(
            weekNum: 1,
            workouts: [
              makeWorkout(
                type: WorkoutType.easyRun,
                dayOfWeek: now.weekday,
                id: 'only_one',
                completed: true,
                feeling: WorkoutFeeling.tired,
                completedAt: now,
              ),
            ],
            km: 10,
          ),
        ],
      );
      final insights = InsightsService.generate(plan, l10n);
      expect(insights.any((i) => i.title == 'Signs of fatigue'), isFalse);
    });
  });
}
