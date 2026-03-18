import 'package:hive_flutter/hive_flutter.dart';
import '../models/training_plan.dart';
import '../models/user_preferences.dart';
import '../core/constants/hive_boxes.dart';

class StorageService {
  Box<TrainingPlan> get _plansBox => Hive.box<TrainingPlan>(HiveBoxes.trainingPlans);
  Box<UserPreferences> get _prefsBox => Hive.box<UserPreferences>(HiveBoxes.userPreferences);

  // User Preferences
  UserPreferences getPreferences() {
    return _prefsBox.get('prefs') ?? UserPreferences();
  }

  Future<void> savePreferences(UserPreferences prefs) async {
    await _prefsBox.put('prefs', prefs);
  }

  // Training Plans
  Future<void> savePlan(TrainingPlan plan) async {
    await _plansBox.put(plan.id, plan);
  }

  TrainingPlan? getActivePlan() {
    if (_plansBox.isEmpty) return null;
    return _plansBox.values.last;
  }

  List<TrainingPlan> getAllPlans() {
    return _plansBox.values.toList();
  }

  Future<void> deletePlan(String id) async {
    await _plansBox.delete(id);
  }

  Future<void> deleteAllData() async {
    await _plansBox.clear();
    final prefs = UserPreferences();
    await _prefsBox.put('prefs', prefs);
  }
}
