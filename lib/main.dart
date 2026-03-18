import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/enums.dart';
import 'models/workout.dart';
import 'models/training_week.dart';
import 'models/training_plan.dart';
import 'models/user_preferences.dart';
import 'core/constants/hive_boxes.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(GoalTypeAdapter());
  Hive.registerAdapter(FitnessLevelAdapter());
  Hive.registerAdapter(WorkoutTypeAdapter());
  Hive.registerAdapter(EffortLevelAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(TrainingWeekAdapter());
  Hive.registerAdapter(TrainingPlanAdapter());
  Hive.registerAdapter(UserPreferencesAdapter());

  // Open boxes
  await Hive.openBox<TrainingPlan>(HiveBoxes.trainingPlans);
  await Hive.openBox<UserPreferences>(HiveBoxes.userPreferences);

  runApp(const ProviderScope(child: RunningTrainerApp()));
}
