import 'package:hive/hive.dart';
import 'workout.dart';

part 'training_week.g.dart';

@HiveType(typeId: 2)
class TrainingWeek extends HiveObject {
  @HiveField(0)
  late int weekNumber;

  @HiveField(1)
  late String weekTheme;

  @HiveField(2)
  late double targetWeeklyKm;

  @HiveField(3)
  late bool isTaperWeek;

  @HiveField(4)
  late List<Workout> workouts; // 7 entries, rest days explicit

  TrainingWeek({
    required this.weekNumber,
    required this.weekTheme,
    required this.targetWeeklyKm,
    required this.isTaperWeek,
    required this.workouts,
  });
}
