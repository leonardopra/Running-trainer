import 'package:hive/hive.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 4)
class UserPreferences extends HiveObject {
  @HiveField(0)
  String? claudeApiKey;

  @HiveField(1)
  bool useKilometers = true;

  @HiveField(2)
  bool hasCompletedOnboarding = false;

  @HiveField(3)
  String? name;

  @HiveField(4)
  int? age;

  @HiveField(5)
  double? weightKg;

  @HiveField(6)
  double? heightCm;

  @HiveField(7)
  bool notificationsEnabled = false;

  @HiveField(8)
  int notificationHour = 8;

  @HiveField(9)
  int notificationMinute = 0;

  UserPreferences({
    this.claudeApiKey,
    this.useKilometers = true,
    this.hasCompletedOnboarding = false,
    this.name,
    this.age,
    this.weightKg,
    this.heightCm,
    this.notificationsEnabled = false,
    this.notificationHour = 8,
    this.notificationMinute = 0,
  });
}
