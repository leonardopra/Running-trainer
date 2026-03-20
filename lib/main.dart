import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/enums.dart';
import 'models/workout.dart';
import 'models/training_week.dart';
import 'models/training_plan.dart';
import 'models/user_preferences.dart';
import 'core/constants/hive_boxes.dart';
import 'services/encryption_service.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(WorkoutFeelingAdapter());
  Hive.registerAdapter(GoalTypeAdapter());
  Hive.registerAdapter(FitnessLevelAdapter());
  Hive.registerAdapter(WorkoutTypeAdapter());
  Hive.registerAdapter(EffortLevelAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(TrainingWeekAdapter());
  Hive.registerAdapter(TrainingPlanAdapter());
  Hive.registerAdapter(UserPreferencesAdapter());

  // Training plans — unencrypted (no PII)
  await Hive.openBox<TrainingPlan>(HiveBoxes.trainingPlans);

  // User preferences — encrypted with AES-256 key stored in OS keychain
  final cipher = await EncryptionService.getOrCreateCipher();
  try {
    await Hive.openBox<UserPreferences>(HiveBoxes.userPreferences, encryptionCipher: cipher);
  } catch (_) {
    // Migration: existing unencrypted box on disk — wipe and reopen encrypted.
    // User will be taken through onboarding again (safe fallback).
    await Hive.deleteBoxFromDisk(HiveBoxes.userPreferences);
    await Hive.openBox<UserPreferences>(HiveBoxes.userPreferences, encryptionCipher: cipher);
  }

  await NotificationService.initialize();

  runApp(const ProviderScope(child: RunningTrainerApp()));
}
