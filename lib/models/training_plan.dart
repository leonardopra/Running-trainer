import 'package:hive/hive.dart';
import 'enums.dart';
import 'training_week.dart';

part 'training_plan.g.dart';

@HiveType(typeId: 3)
class TrainingPlan extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late GoalType goalType;

  @HiveField(2)
  late FitnessLevel fitnessLevel;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  DateTime? raceDate;

  @HiveField(5)
  late int totalWeeks;

  @HiveField(6)
  late int trainingDaysPerWeek;

  @HiveField(7)
  late List<TrainingWeek> weeks;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  bool isClaudeEnriched = false;

  TrainingPlan({
    required this.id,
    required this.goalType,
    required this.fitnessLevel,
    required this.startDate,
    this.raceDate,
    required this.totalWeeks,
    required this.trainingDaysPerWeek,
    required this.weeks,
    required this.createdAt,
    this.isClaudeEnriched = false,
  });
}
