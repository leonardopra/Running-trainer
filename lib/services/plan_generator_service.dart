import 'package:uuid/uuid.dart';
import '../models/enums.dart';
import '../models/workout.dart';
import '../models/training_week.dart';
import '../models/training_plan.dart';

class PlanGeneratorService {
  static const _uuid = Uuid();

  // Base weekly mileage by fitness level (km)
  static const _baseMileage = {
    FitnessLevel.beginner: 20.0,
    FitnessLevel.intermediate: 35.0,
    FitnessLevel.advanced: 55.0,
  };

  // Default weeks by goal type
  static const _defaultWeeks = {
    GoalType.fiveK: 8,
    GoalType.tenK: 10,
    GoalType.halfMarathon: 12,
    GoalType.marathon: 16,
    GoalType.generalFitness: 8,
  };

  TrainingPlan generatePlan({
    required GoalType goalType,
    required FitnessLevel fitnessLevel,
    required int trainingDaysPerWeek,
    DateTime? raceDate,
    DateTime? startDate,
    int? age,
  }) {
    final start = startDate ?? DateTime.now();
    final totalWeeks = _calculateTotalWeeks(goalType, raceDate, start);
    final weeks = _generateWeeks(
      goalType: goalType,
      fitnessLevel: fitnessLevel,
      trainingDaysPerWeek: trainingDaysPerWeek,
      totalWeeks: totalWeeks,
      age: age,
    );

    return TrainingPlan(
      id: _uuid.v4(),
      goalType: goalType,
      fitnessLevel: fitnessLevel,
      startDate: start,
      raceDate: raceDate,
      totalWeeks: totalWeeks,
      trainingDaysPerWeek: trainingDaysPerWeek,
      weeks: weeks,
      createdAt: DateTime.now(),
      isClaudeEnriched: false,
    );
  }

  int _calculateTotalWeeks(GoalType goalType, DateTime? raceDate, DateTime start) {
    if (raceDate != null) {
      final diff = raceDate.difference(start).inDays;
      final weeks = (diff / 7).floor();
      return weeks.clamp(4, 24);
    }
    return _defaultWeeks[goalType]!;
  }

  List<TrainingWeek> _generateWeeks({
    required GoalType goalType,
    required FitnessLevel fitnessLevel,
    required int trainingDaysPerWeek,
    required int totalWeeks,
    int? age,
  }) {
    final baseMileage = _baseMileage[fitnessLevel]!;
    // Runners 50+ get more frequent recovery weeks (every 3rd instead of 4th)
    final recoveryInterval = (age != null && age >= 50) ? 3 : 4;

    final mileageProgression = _calculateMileageProgression(
      baseMileage: baseMileage,
      totalWeeks: totalWeeks,
      isRaceGoal: goalType != GoalType.generalFitness,
      recoveryInterval: recoveryInterval,
    );

    return List.generate(totalWeeks, (i) {
      final weekNum = i + 1;
      final weeklyKm = mileageProgression[i];
      final isRecovery = weekNum % recoveryInterval == 0 && weekNum < totalWeeks - 2;
      final isTaper = goalType != GoalType.generalFitness &&
          weekNum > totalWeeks - 3;

      final theme = _getWeekTheme(weekNum, totalWeeks, isRecovery, isTaper, goalType, age: age);
      final workouts = _generateWorkoutsForWeek(
        weekNum: weekNum,
        trainingDaysPerWeek: trainingDaysPerWeek,
        weeklyKm: weeklyKm,
        isRecovery: isRecovery,
      );

      return TrainingWeek(
        weekNumber: weekNum,
        weekTheme: theme,
        targetWeeklyKm: weeklyKm,
        isTaperWeek: isTaper,
        workouts: workouts,
      );
    });
  }

  List<double> _calculateMileageProgression({
    required double baseMileage,
    required int totalWeeks,
    required bool isRaceGoal,
    int recoveryInterval = 4,
  }) {
    final progression = <double>[];
    double current = baseMileage;
    double peak = baseMileage;

    // Runners 50+ use a slower 7%/week progression; others use 9%
    final progressionRate = recoveryInterval == 3 ? 1.07 : 1.09;

    for (int i = 0; i < totalWeeks; i++) {
      final weekNum = i + 1;
      final isTaper = isRaceGoal && weekNum > totalWeeks - 3;
      final isRecovery = weekNum % recoveryInterval == 0 && weekNum < totalWeeks - 2;

      if (isTaper) {
        final taperWeek = weekNum - (totalWeeks - 3);
        switch (taperWeek) {
          case 1:
            current = peak * 0.70;
            break;
          case 2:
            current = peak * 0.50;
            break;
          case 3:
            current = peak * 0.30;
            break;
        }
      } else if (isRecovery) {
        current = current * 0.80;
      } else {
        if (i > 0 && progression.isNotEmpty) {
          current = progression.last * progressionRate;
        }
        if (current > peak) peak = current;
      }

      progression.add(double.parse(current.toStringAsFixed(1)));
    }

    return progression;
  }

  String _getWeekTheme(
    int weekNum,
    int totalWeeks,
    bool isRecovery,
    bool isTaper,
    GoalType goalType, {
    int? age,
  }) {
    if (weekNum == 1) return 'Foundation Week';
    if (isTaper) {
      final taperWeek = weekNum - (totalWeeks - 3);
      switch (taperWeek) {
        case 1: return 'Taper Begins';
        case 2: return 'Race Prep';
        case 3: return 'Race Week';
        default: return 'Taper';
      }
    }
    if (isRecovery) {
      return (age != null && age >= 50) ? 'Recovery Week (50+ protocol)' : 'Recovery Week';
    }
    if (weekNum <= totalWeeks * 0.4) return 'Base Building';
    if (weekNum <= totalWeeks * 0.7) return 'Strength Phase';
    return 'Peak Training';
  }

  List<Workout> _generateWorkoutsForWeek({
    required int weekNum,
    required int trainingDaysPerWeek,
    required double weeklyKm,
    required bool isRecovery,
  }) {
    final distribution = _getWorkoutDistribution(trainingDaysPerWeek);
    final scaledWorkouts = _scaleWorkoutDistances(distribution, weeklyKm);
    final schedule = _assignDaysOfWeek(scaledWorkouts, trainingDaysPerWeek);
    return schedule;
  }

  List<WorkoutType> _getWorkoutDistribution(int days) {
    switch (days) {
      case 3:
        return [WorkoutType.easyRun, WorkoutType.longRun, WorkoutType.easyRun];
      case 4:
        return [WorkoutType.easyRun, WorkoutType.tempoRun, WorkoutType.easyRun, WorkoutType.longRun];
      case 5:
        return [WorkoutType.easyRun, WorkoutType.easyRun, WorkoutType.tempoRun, WorkoutType.easyRun, WorkoutType.longRun];
      case 6:
        return [WorkoutType.easyRun, WorkoutType.easyRun, WorkoutType.tempoRun, WorkoutType.easyRun, WorkoutType.intervalRun, WorkoutType.longRun];
      default:
        return [WorkoutType.easyRun, WorkoutType.longRun, WorkoutType.easyRun];
    }
  }

  List<(WorkoutType, double)> _scaleWorkoutDistances(List<WorkoutType> types, double weeklyKm) {
    final typeWeights = <WorkoutType, double>{
      WorkoutType.easyRun: 1.0,
      WorkoutType.tempoRun: 0.8,
      WorkoutType.intervalRun: 0.7,
      WorkoutType.longRun: 1.8,
    };

    double totalWeight = 0;
    for (final t in types) {
      totalWeight += typeWeights[t] ?? 1.0;
    }

    return types.map((t) {
      final weight = typeWeights[t] ?? 1.0;
      final distance = (weeklyKm * weight / totalWeight);
      return (t, double.parse(distance.toStringAsFixed(1)));
    }).toList();
  }

  List<Workout> _assignDaysOfWeek(List<(WorkoutType, double)> workouts, int trainingDays) {
    const daysByCount = {
      3: [1, 3, 7],
      4: [1, 3, 5, 7],
      5: [1, 2, 4, 5, 7],
      6: [1, 2, 3, 5, 6, 7],
    };

    final days = daysByCount[trainingDays] ?? daysByCount[3]!;
    final allWorkouts = <Workout>[];

    for (int day = 1; day <= 7; day++) {
      final dayIndex = days.indexOf(day);
      if (dayIndex >= 0 && dayIndex < workouts.length) {
        final (type, distance) = workouts[dayIndex];
        allWorkouts.add(Workout(
          id: _uuid.v4(),
          type: type,
          dayOfWeek: day,
          distanceKm: type != WorkoutType.rest ? distance : null,
          effortLevel: _getEffortLevel(type),
          title: _getWorkoutTitle(type, distance),
        ));
      } else {
        allWorkouts.add(Workout(
          id: _uuid.v4(),
          type: WorkoutType.rest,
          dayOfWeek: day,
          effortLevel: EffortLevel.veryEasy,
          title: 'Rest Day',
        ));
      }
    }

    return allWorkouts;
  }

  EffortLevel _getEffortLevel(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return EffortLevel.easy;
      case WorkoutType.tempoRun: return EffortLevel.hard;
      case WorkoutType.intervalRun: return EffortLevel.veryHard;
      case WorkoutType.longRun: return EffortLevel.moderate;
      case WorkoutType.rest: return EffortLevel.veryEasy;
      case WorkoutType.crossTrain: return EffortLevel.easy;
    }
  }

  String _getWorkoutTitle(WorkoutType type, double distanceKm) {
    switch (type) {
      case WorkoutType.easyRun:
        return '${distanceKm.toStringAsFixed(1)}km Easy Run';
      case WorkoutType.tempoRun:
        return '${distanceKm.toStringAsFixed(1)}km Tempo Run';
      case WorkoutType.intervalRun:
        return 'Intervals (${distanceKm.toStringAsFixed(1)}km)';
      case WorkoutType.longRun:
        return '${distanceKm.toStringAsFixed(1)}km Long Run';
      case WorkoutType.rest:
        return 'Rest Day';
      case WorkoutType.crossTrain:
        return 'Cross Training';
    }
  }
}
