import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:running_trainer_app/models/enums.dart';
import 'package:running_trainer_app/services/plan_generator_service.dart';

void main() {
  final generator = PlanGeneratorService();

  Map<String, dynamic> loadFixture(String name) {
    final file = File('product-spec/fixtures/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('product spec contract fixtures', () {
    test('matches 5K beginner age 35 canonical fixture', () {
      final fixture = loadFixture('plan_generation_5k_beginner_age_35.json');
      final request = fixture['request'] as Map<String, dynamic>;
      final expected = fixture['expected'] as Map<String, dynamic>;

      final plan = generator.generatePlan(
        goalType: GoalType.values.byName(request['goalType'] as String),
        fitnessLevel: FitnessLevel.values.byName(request['fitnessLevel'] as String),
        trainingDaysPerWeek: request['trainingDaysPerWeek'] as int,
        startDate: DateTime.parse(request['startDate'] as String),
        age: request['age'] as int,
      );

      final runWorkouts = plan.weeks.first.workouts.where((w) => w.type != WorkoutType.rest).toList();
      final taperWeeks = plan.weeks.where((w) => w.isTaperWeek).map((w) => w.weekNumber).toList();

      expect(plan.totalWeeks, expected['totalWeeks']);
      expect(plan.weeks.map((w) => w.targetWeeklyKm).toList(), expected['weeklyTargetKm']);
      expect(plan.weeks.map((w) => w.weekTheme).toList(), expected['weekThemes']);
      expect(runWorkouts.map((w) => w.dayOfWeek).toList(), expected['week1RunDays']);
      expect(runWorkouts.map((w) => w.type.name).toList(), expected['week1RunTypes']);
      expect(runWorkouts.map((w) => w.title).toList(), expected['week1RunTitles']);
      expect(taperWeeks, expected['taperWeeks']);
      expect(plan.weeks.every((week) => week.workouts.length == 7), isTrue);
    });

    test('matches marathon advanced age 52 canonical fixture', () {
      final fixture = loadFixture('plan_generation_marathon_advanced_age_52.json');
      final request = fixture['request'] as Map<String, dynamic>;
      final expected = fixture['expected'] as Map<String, dynamic>;

      final plan = generator.generatePlan(
        goalType: GoalType.values.byName(request['goalType'] as String),
        fitnessLevel: FitnessLevel.values.byName(request['fitnessLevel'] as String),
        trainingDaysPerWeek: request['trainingDaysPerWeek'] as int,
        startDate: DateTime.parse(request['startDate'] as String),
        age: request['age'] as int,
      );

      final runWorkouts = plan.weeks.first.workouts.where((w) => w.type != WorkoutType.rest).toList();
      final taperWeeks = plan.weeks.where((w) => w.isTaperWeek).map((w) => w.weekNumber).toList();

      expect(plan.totalWeeks, expected['totalWeeks']);
      expect(plan.weeks.map((w) => w.targetWeeklyKm).toList(), expected['weeklyTargetKm']);
      expect(plan.weeks.map((w) => w.weekTheme).toList(), expected['weekThemes']);
      expect(runWorkouts.map((w) => w.dayOfWeek).toList(), expected['week1RunDays']);
      expect(runWorkouts.map((w) => w.type.name).toList(), expected['week1RunTypes']);
      expect(runWorkouts.map((w) => w.title).toList(), expected['week1RunTitles']);
      expect(taperWeeks, expected['taperWeeks']);
      expect(plan.weeks.every((week) => week.workouts.length == 7), isTrue);
    });
  });
}
