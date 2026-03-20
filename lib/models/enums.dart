import 'package:hive/hive.dart';

part 'enums.g.dart';

@HiveType(typeId: 10)
enum GoalType {
  @HiveField(0)
  fiveK,
  @HiveField(1)
  tenK,
  @HiveField(2)
  halfMarathon,
  @HiveField(3)
  marathon,
  @HiveField(4)
  generalFitness,
}

@HiveType(typeId: 11)
enum FitnessLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
}

@HiveType(typeId: 12)
enum WorkoutType {
  @HiveField(0)
  easyRun,
  @HiveField(1)
  tempoRun,
  @HiveField(2)
  intervalRun,
  @HiveField(3)
  longRun,
  @HiveField(4)
  rest,
  @HiveField(5)
  crossTrain,
}

@HiveType(typeId: 14)
enum WorkoutFeeling {
  @HiveField(0) great,
  @HiveField(1) good,
  @HiveField(2) ok,
  @HiveField(3) tired,
  @HiveField(4) injured,
}

@HiveType(typeId: 13)
enum EffortLevel {
  @HiveField(0)
  veryEasy,
  @HiveField(1)
  easy,
  @HiveField(2)
  moderate,
  @HiveField(3)
  hard,
  @HiveField(4)
  veryHard,
}

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.fiveK: return '5K';
      case GoalType.tenK: return '10K';
      case GoalType.halfMarathon: return 'Half Marathon';
      case GoalType.marathon: return 'Marathon';
      case GoalType.generalFitness: return 'General Fitness';
    }
  }

  String get emoji {
    switch (this) {
      case GoalType.fiveK: return '🏃';
      case GoalType.tenK: return '🏃‍♂️';
      case GoalType.halfMarathon: return '🥈';
      case GoalType.marathon: return '🏅';
      case GoalType.generalFitness: return '💪';
    }
  }
}

extension FitnessLevelExtension on FitnessLevel {
  String get displayName {
    switch (this) {
      case FitnessLevel.beginner: return 'Beginner';
      case FitnessLevel.intermediate: return 'Intermediate';
      case FitnessLevel.advanced: return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Running less than 15km/week or just starting out';
      case FitnessLevel.intermediate:
        return 'Consistently running 20–40km/week for 6+ months';
      case FitnessLevel.advanced:
        return 'Running 50km+/week with structured training history';
    }
  }
}

extension WorkoutTypeExtension on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.easyRun: return 'Easy Run';
      case WorkoutType.tempoRun: return 'Tempo Run';
      case WorkoutType.intervalRun: return 'Intervals';
      case WorkoutType.longRun: return 'Long Run';
      case WorkoutType.rest: return 'Rest Day';
      case WorkoutType.crossTrain: return 'Cross Train';
    }
  }
}

extension EffortLevelExtension on EffortLevel {
  String get displayName {
    switch (this) {
      case EffortLevel.veryEasy: return 'Very Easy';
      case EffortLevel.easy: return 'Easy';
      case EffortLevel.moderate: return 'Moderate';
      case EffortLevel.hard: return 'Hard';
      case EffortLevel.veryHard: return 'Very Hard';
    }
  }

  int get colorValue {
    switch (this) {
      case EffortLevel.veryEasy: return 0xFF4CAF50;
      case EffortLevel.easy: return 0xFF8BC34A;
      case EffortLevel.moderate: return 0xFFFF9800;
      case EffortLevel.hard: return 0xFFFF5722;
      case EffortLevel.veryHard: return 0xFFF44336;
    }
  }
}
