import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../providers/plan_generation_provider.dart';
import '../widgets/selection_card.dart';
import '../widgets/onboarding_progress.dart';

class FitnessLevelScreen extends ConsumerWidget {
  const FitnessLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: OnboardingProgress(currentStep: 2, totalSteps: 5),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text('What\'s your\nfitness level?', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text('Be honest — we\'ll build the right plan for you.',
                  style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: FitnessLevel.values.map((level) {
                    return SelectionCard(
                      title: level.displayName,
                      subtitle: level.description,
                      isSelected: state.fitnessLevel == level,
                      onTap: () => ref.read(onboardingProvider.notifier).setFitnessLevel(level),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.fitnessLevel != null
                      ? () => context.push('/onboarding/days')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Continue', style: TextStyle(
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
