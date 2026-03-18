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

  UserPreferences({
    this.claudeApiKey,
    this.useKilometers = true,
    this.hasCompletedOnboarding = false,
  });
}
