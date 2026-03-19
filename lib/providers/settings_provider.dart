import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';
import 'storage_provider.dart';

class SettingsNotifier extends Notifier<UserPreferences> {
  @override
  UserPreferences build() {
    return ref.read(storageServiceProvider).getPreferences();
  }

  Future<void> setApiKey(String key) async {
    state = UserPreferences(
      claudeApiKey: key.isEmpty ? null : key,
      useKilometers: state.useKilometers,
      hasCompletedOnboarding: state.hasCompletedOnboarding,
      name: state.name,
      age: state.age,
      weightKg: state.weightKg,
      heightCm: state.heightCm,
    );
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> setUseKilometers(bool value) async {
    state = UserPreferences(
      claudeApiKey: state.claudeApiKey,
      useKilometers: value,
      hasCompletedOnboarding: state.hasCompletedOnboarding,
      name: state.name,
      age: state.age,
      weightKg: state.weightKg,
      heightCm: state.heightCm,
    );
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> completeOnboarding() async {
    state = UserPreferences(
      claudeApiKey: state.claudeApiKey,
      useKilometers: state.useKilometers,
      hasCompletedOnboarding: true,
      name: state.name,
      age: state.age,
      weightKg: state.weightKg,
      heightCm: state.heightCm,
    );
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> updateProfile({
    required String name,
    int? age,
    double? weightKg,
    double? heightCm,
  }) async {
    state = UserPreferences(
      claudeApiKey: state.claudeApiKey,
      useKilometers: state.useKilometers,
      hasCompletedOnboarding: state.hasCompletedOnboarding,
      name: name.trim().isEmpty ? null : name.trim(),
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
    );
    await ref.read(storageServiceProvider).savePreferences(state);
  }

  Future<void> resetAll() async {
    await ref.read(storageServiceProvider).deleteAllData();
    state = UserPreferences();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, UserPreferences>(() {
  return SettingsNotifier();
});
