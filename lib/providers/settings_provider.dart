import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_plan.dart';
import '../models/user_preferences.dart';
import '../services/notification_service.dart';
import 'storage_provider.dart';

class SettingsNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    return ref.read(storageServiceProvider).getPreferences();
  }

  /// Convenience: copy current state with overrides.
  UserPreferences _copy({
    Object? claudeApiKey = _keep,
    bool? useKilometers,
    bool? hasCompletedOnboarding,
    Object? name = _keep,
    Object? age = _keep,
    Object? weightKg = _keep,
    Object? heightCm = _keep,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return UserPreferences(
      claudeApiKey: claudeApiKey == _keep
          ? state.claudeApiKey
          : claudeApiKey as String?,
      useKilometers: useKilometers ?? state.useKilometers,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? state.hasCompletedOnboarding,
      name: name == _keep ? state.name : name as String?,
      age: age == _keep ? state.age : age as int?,
      weightKg: weightKg == _keep ? state.weightKg : weightKg as double?,
      heightCm: heightCm == _keep ? state.heightCm : heightCm as double?,
      notificationsEnabled:
          notificationsEnabled ?? state.notificationsEnabled,
      notificationHour: notificationHour ?? state.notificationHour,
      notificationMinute: notificationMinute ?? state.notificationMinute,
    );
  }

  Future<void> _save(UserPreferences prefs) async {
    state = prefs;
    await ref.read(storageServiceProvider).savePreferences(prefs);
  }

  Future<void> setApiKey(String key) async {
    await _save(_copy(claudeApiKey: key.isEmpty ? null : key));
  }

  Future<void> setUseKilometers(bool value) async {
    await _save(_copy(useKilometers: value));
  }

  Future<void> completeOnboarding() async {
    await _save(_copy(hasCompletedOnboarding: true));
  }

  Future<void> updateProfile({
    required String name,
    int? age,
    double? weightKg,
    double? heightCm,
  }) async {
    await _save(_copy(
      name: name.trim().isEmpty ? null : name.trim(),
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
    ));
  }

  Future<void> setNotifications({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    await _save(_copy(
      notificationsEnabled: enabled,
      notificationHour: hour,
      notificationMinute: minute,
    ));

    if (!enabled) {
      await NotificationService.cancelAll();
      return;
    }

    // Reschedule for the active plan if there is one
    final plan = ref.read(storageServiceProvider).getActivePlan();
    if (plan != null) {
      await NotificationService.scheduleForPlan(
        plan,
        hour: state.notificationHour,
        minute: state.notificationMinute,
      );
    }
  }

  Future<void> resetAll() async {
    await NotificationService.cancelAll();
    await ref.read(storageServiceProvider).deleteAllData();
    state = UserPreferences();
  }
}

// Sentinel for optional nullable overrides
const _keep = Object();

// Convenience: schedule (or cancel) notifications for a freshly generated plan.
Future<void> scheduleNotificationsForPlan(
  TrainingPlan plan,
  UserPreferences prefs,
) async {
  if (!prefs.notificationsEnabled) return;
  await NotificationService.scheduleForPlan(
    plan,
    hour: prefs.notificationHour,
    minute: prefs.notificationMinute,
  );
}

final settingsProvider = NotifierProvider<SettingsNotifier, UserPreferences>(() {
  return SettingsNotifier();
});
