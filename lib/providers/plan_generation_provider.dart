import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/training_plan.dart';
import '../services/plan_generator_service.dart';
import '../services/claude_service.dart';
import 'storage_provider.dart';
import 'settings_provider.dart';
import 'training_plan_provider.dart';

// Onboarding state — collected across screens
class OnboardingState {
  final GoalType? goalType;
  final FitnessLevel? fitnessLevel;
  final List<int> trainingDays; // day indices 0=Mon..6=Sun
  final DateTime? raceDate;
  final int? durationWeeks;

  const OnboardingState({
    this.goalType,
    this.fitnessLevel,
    this.trainingDays = const [],
    this.raceDate,
    this.durationWeeks,
  });

  OnboardingState copyWith({
    GoalType? goalType,
    FitnessLevel? fitnessLevel,
    List<int>? trainingDays,
    DateTime? raceDate,
    int? durationWeeks,
    bool clearRaceDate = false,
  }) {
    return OnboardingState(
      goalType: goalType ?? this.goalType,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      trainingDays: trainingDays ?? this.trainingDays,
      raceDate: clearRaceDate ? null : (raceDate ?? this.raceDate),
      durationWeeks: durationWeeks ?? this.durationWeeks,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setGoal(GoalType goal) => state = state.copyWith(goalType: goal);
  void setFitnessLevel(FitnessLevel level) => state = state.copyWith(fitnessLevel: level);
  void setTrainingDays(List<int> days) => state = state.copyWith(trainingDays: days);
  void setRaceDate(DateTime date) => state = state.copyWith(raceDate: date);
  void setDurationWeeks(int weeks) => state = state.copyWith(durationWeeks: weeks, clearRaceDate: true);
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(() {
  return OnboardingNotifier();
});

/// When true, the onboarding flow can run even if the user is already onboarded,
/// so they can generate a new plan without losing their history or profile.
final isNewPlanFlowProvider = StateProvider<bool>((ref) => false);

// Generation progress
enum GenerationStep { idle, generating, enriching, done, error }

class GenerationState {
  final GenerationStep step;
  final int enrichedWeeks;
  final int totalWeeks;
  final String? errorMessage;
  final TrainingPlan? plan;

  const GenerationState({
    this.step = GenerationStep.idle,
    this.enrichedWeeks = 0,
    this.totalWeeks = 0,
    this.errorMessage,
    this.plan,
  });

  GenerationState copyWith({
    GenerationStep? step,
    int? enrichedWeeks,
    int? totalWeeks,
    String? errorMessage,
    TrainingPlan? plan,
  }) {
    return GenerationState(
      step: step ?? this.step,
      enrichedWeeks: enrichedWeeks ?? this.enrichedWeeks,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      errorMessage: errorMessage ?? this.errorMessage,
      plan: plan ?? this.plan,
    );
  }

  double get progress {
    if (totalWeeks == 0) return 0;
    return enrichedWeeks / totalWeeks;
  }
}

class GenerationNotifier extends Notifier<GenerationState> {
  @override
  GenerationState build() => const GenerationState();

  Future<TrainingPlan?> generatePlan() async {
    final onboarding = ref.read(onboardingProvider);
    if (onboarding.goalType == null || onboarding.fitnessLevel == null) {
      state = state.copyWith(step: GenerationStep.error, errorMessage: 'Missing onboarding data');
      return null;
    }

    state = state.copyWith(step: GenerationStep.generating);

    // Read profile data saved during onboarding profile step
    final settings = ref.read(settingsProvider);

    // Step 1: Rule-based generation (age-aware)
    final generator = PlanGeneratorService();
    DateTime? raceDate;
    if (onboarding.raceDate != null) {
      raceDate = onboarding.raceDate;
    }

    final plan = generator.generatePlan(
      goalType: onboarding.goalType!,
      fitnessLevel: onboarding.fitnessLevel!,
      trainingDaysPerWeek: onboarding.trainingDays.length.clamp(3, 6),
      raceDate: raceDate,
      age: settings.age,
    );

    // Step 2: Save skeleton plan immediately
    final storage = ref.read(storageServiceProvider);
    await storage.savePlan(plan);

    state = state.copyWith(
      step: GenerationStep.enriching,
      plan: plan,
      totalWeeks: plan.totalWeeks,
      enrichedWeeks: 0,
    );

    // Step 3: Claude enrichment (optional, profile-aware)
    if (settings.claudeApiKey != null && settings.claudeApiKey!.isNotEmpty) {
      final claudeService = ClaudeService();
      for (int i = 0; i < plan.weeks.length; i++) {
        try {
          final enriched = await claudeService.enrichWeek(
            week: plan.weeks[i],
            apiKey: settings.claudeApiKey!,
            goalType: onboarding.goalType!.displayName,
            fitnessLevel: onboarding.fitnessLevel!.displayName,
            age: settings.age,
            weightKg: settings.weightKg,
            heightCm: settings.heightCm,
          );
          plan.weeks[i] = enriched;
          await storage.savePlan(plan);
          state = state.copyWith(enrichedWeeks: i + 1);
        } catch (e) {
          // Continue without enrichment for this week
        }
      }
      plan.isClaudeEnriched = true;
      await storage.savePlan(plan);
    }

    // Mark onboarding complete (idempotent — safe for new-plan flow too)
    await ref.read(settingsProvider.notifier).completeOnboarding();

    // Reset new-plan flow flag and plan selection so the new plan becomes active
    ref.read(isNewPlanFlowProvider.notifier).state = false;
    ref.read(selectedPlanIdProvider.notifier).state = null;

    // Invalidate plan caches so all screens pick up the new plan
    ref.invalidate(activePlanProvider);
    ref.invalidate(allPlansProvider);

    // Schedule notifications if enabled
    final latestSettings = ref.read(settingsProvider);
    await scheduleNotificationsForPlan(plan, latestSettings);

    state = state.copyWith(step: GenerationStep.done, plan: plan);
    return plan;
  }
}

final generationProvider = NotifierProvider<GenerationNotifier, GenerationState>(() {
  return GenerationNotifier();
});
