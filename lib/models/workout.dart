import 'package:hive/hive.dart';
import 'enums.dart';

part 'workout.g.dart';

@HiveType(typeId: 1)
class Workout extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late WorkoutType type;

  @HiveField(2)
  late int dayOfWeek; // 1=Monday, 7=Sunday

  @HiveField(3)
  double? distanceKm;

  @HiveField(4)
  int? durationMinutes;

  @HiveField(5)
  late EffortLevel effortLevel;

  @HiveField(6)
  late String title;

  @HiveField(7)
  String? description; // Claude-enriched

  @HiveField(8)
  String? coachingTip; // Claude-enriched

  @HiveField(9)
  bool isCompleted = false;

  @HiveField(10)
  double? actualDistanceKm;

  @HiveField(11)
  int? actualDurationMinutes;

  @HiveField(12)
  DateTime? completedAt;

  @HiveField(13)
  String? notes;

  Workout({
    required this.id,
    required this.type,
    required this.dayOfWeek,
    this.distanceKm,
    this.durationMinutes,
    required this.effortLevel,
    required this.title,
    this.description,
    this.coachingTip,
    this.isCompleted = false,
    this.actualDistanceKm,
    this.actualDurationMinutes,
    this.completedAt,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'dayOfWeek': dayOfWeek,
    'distanceKm': distanceKm,
    'durationMinutes': durationMinutes,
    'effortLevel': effortLevel.name,
    'title': title,
  };
}
