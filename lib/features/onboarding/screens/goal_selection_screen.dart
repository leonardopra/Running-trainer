import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n_helpers.dart';
import '../../../models/enums.dart';
import '../../../providers/plan_generation_provider.dart';
import '../widgets/selection_card.dart';
import '../widgets/onboarding_progress.dart';

class GoalSelectionScreen extends ConsumerWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingProgress(currentStep: 0, totalSteps: 5),
              const SizedBox(height: 40),
              Text(l10n.onboardingGoalTitle, style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(l10n.onboardingGoalSubtitle, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: GoalType.values.map((goal) {
                    return SelectionCard(
                      title: goal.localizedName(l10n),
                      emoji: goal.emoji,
                      isSelected: state.goalType == goal,
                      onTap: () => ref.read(onboardingProvider.notifier).setGoal(goal),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.goalType != null
                      ? () => context.push('/onboarding/race-date')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.btnContinue, style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
