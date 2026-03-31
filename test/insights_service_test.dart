import 'package:flutter_test/flutter_test.dart';
import 'package:running_trainer_app/models/enums.dart';
import 'package:running_trainer_app/services/insights_service.dart';
import 'package:running_trainer_app/services/plan_generator_service.dart';
import 'package:running_trainer_app/l10n/app_localizations_en.dart';

void main() {
  late PlanGeneratorService generator;

  setUp(() {
    generator = PlanGeneratorService();
  });

  group('InsightsService', () {
    test('returns a list for any valid plan', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(insights, isA<List>());
    });

    test('insights are sorted by priority ascending', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.advanced,
        trainingDaysPerWeek: 5,
        raceDate: DateTime.now().add(const Duration(days: 90)),
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      for (int i = 1; i < insights.length; i++) {
        expect(
          insights[i].priority >= insights[i - 1].priority,
          isTrue,
          reason: 'Insight at index $i (priority ${insights[i].priority}) '
              'should not have lower priority than index ${i - 1} '
              '(priority ${insights[i - 1].priority})',
        );
      }
    });

    test('week 1 welcome insight fires when plan starts today', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(
        insights.any((i) => i.title.contains('Week 1')),
        isTrue,
        reason: 'Should show week 1 welcome when plan just started',
      );
    });

    test('race countdown insight fires when race date is set', () {
      final plan = generator.generatePlan(
        goalType: GoalType.halfMarathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        raceDate: DateTime.now().add(const Duration(days: 60)),
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(
        insights.any((i) =>
            i.title.contains('Weeks to Race Day') ||
            i.title.contains('Weeks to Go') ||
            i.title.contains('Days to Race') ||
            i.title.contains('Race Day')),
        isTrue,
        reason: 'Should show race countdown when raceDate is provided',
      );
    });

    test('race day insight fires when race is today', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
        raceDate: DateTime.now(),
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(
        insights.any((i) => i.title.contains('Race Day')),
        isTrue,
      );
    });

    test('no race countdown when no race date is set', () {
      final plan = generator.generatePlan(
        goalType: GoalType.generalFitness,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(
        insights.any((i) =>
            i.title.contains('Race Day') ||
            i.title.contains('Weeks to Race') ||
            i.title.contains('Days to Race')),
        isFalse,
        reason: 'No race countdown for plans without a race date',
      );
    });

    test('excellent consistency insight fires when all past workouts are done', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        // Start 21 days ago so currentWeekIndex = 3, past weeks = 0,1,2
        startDate: DateTime.now().subtract(const Duration(days: 21)),
      );
      // Mark all non-rest workouts in past weeks as completed
      for (int wi = 0; wi < 3; wi++) {
        for (final w in plan.weeks[wi].workouts) {
          if (w.type != WorkoutType.rest) {
            w.isCompleted = true;
            w.completedAt = DateTime.now().subtract(Duration(days: (3 - wi) * 7));
          }
        }
      }
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(
        insights.any((i) => i.title.contains('Excellent Consistency')),
        isTrue,
        reason: 'Should fire when completion rate >= 85%',
      );
    });

    test('consistency warning fires when completion rate is very low', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        startDate: DateTime.now().subtract(const Duration(days: 21)),
      );
      // Leave all past workouts incomplete (default)
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      expect(
        insights.any((i) => i.title.contains('Consistency Needs Work')),
        isTrue,
        reason: 'Should warn when completion rate < 55% after week 2',
      );
    });

    test('all insight fields are non-empty', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.advanced,
        trainingDaysPerWeek: 6,
        raceDate: DateTime.now().add(const Duration(days: 45)),
      );
      final insights = InsightsService.generate(plan, AppLocalizationsEn());
      for (final insight in insights) {
        expect(insight.title, isNotEmpty);
        expect(insight.body, isNotEmpty);
      }
    });
  });
}
