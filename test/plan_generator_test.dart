import 'package:flutter_test/flutter_test.dart';
import 'package:running_trainer_app/models/enums.dart';
import 'package:running_trainer_app/services/plan_generator_service.dart';

void main() {
  late PlanGeneratorService generator;

  setUp(() {
    generator = PlanGeneratorService();
  });

  group('PlanGeneratorService', () {
    test('generates correct week count for 5K goal', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      expect(plan.totalWeeks, 8);
      expect(plan.weeks.length, 8);
    });

    test('generates correct week count for marathon goal', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
      );
      expect(plan.totalWeeks, 16);
      expect(plan.weeks.length, 16);
    });

    test('calculates correct weeks from race date', () {
      final start = DateTime(2026, 1, 1);
      final race = DateTime(2026, 4, 1); // ~13 weeks
      final plan = generator.generatePlan(
        goalType: GoalType.halfMarathon,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
        raceDate: race,
        startDate: start,
      );
      expect(plan.totalWeeks, 13);
    });

    test('mileage progression increases over time', () {
      final plan = generator.generatePlan(
        goalType: GoalType.generalFitness,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 4,
      );
      // Week 1 should be less than week 3
      expect(
        plan.weeks[0].targetWeeklyKm,
        lessThan(plan.weeks[2].targetWeeklyKm),
      );
    });

    test('base mileage matches fitness level', () {
      final beginnerPlan = generator.generatePlan(
        goalType: GoalType.generalFitness,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final advancedPlan = generator.generatePlan(
        goalType: GoalType.generalFitness,
        fitnessLevel: FitnessLevel.advanced,
        trainingDaysPerWeek: 3,
      );
      expect(
        beginnerPlan.weeks[0].targetWeeklyKm,
        lessThan(advancedPlan.weeks[0].targetWeeklyKm),
      );
    });

    test('each week has exactly 7 workouts', () {
      final plan = generator.generatePlan(
        goalType: GoalType.tenK,
        fitnessLevel: FitnessLevel.intermediate,
        trainingDaysPerWeek: 4,
      );
      for (final week in plan.weeks) {
        expect(week.workouts.length, 7);
      }
    });

    test('taper weeks exist for race goals', () {
      final plan = generator.generatePlan(
        goalType: GoalType.marathon,
        fitnessLevel: FitnessLevel.advanced,
        trainingDaysPerWeek: 5,
      );
      final taperWeeks = plan.weeks.where((w) => w.isTaperWeek).toList();
      expect(taperWeeks.length, greaterThan(0));
    });

    test('3-day plan has correct workout distribution', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      final week1 = plan.weeks[0];
      final runWorkouts = week1.workouts
          .where((w) => w.type != WorkoutType.rest)
          .toList();
      expect(runWorkouts.length, 3);
    });

    test('all workouts have valid ids', () {
      final plan = generator.generatePlan(
        goalType: GoalType.fiveK,
        fitnessLevel: FitnessLevel.beginner,
        trainingDaysPerWeek: 3,
      );
      for (final week in plan.weeks) {
        for (final workout in week.workouts) {
          expect(workout.id, isNotEmpty);
        }
      }
    });
  });
}
