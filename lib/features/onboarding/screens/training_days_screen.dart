import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/plan_generation_provider.dart';
import '../widgets/onboarding_progress.dart';

class TrainingDaysScreen extends ConsumerStatefulWidget {
  const TrainingDaysScreen({super.key});

  @override
  ConsumerState<TrainingDaysScreen> createState() => _TrainingDaysScreenState();
}

class _TrainingDaysScreenState extends ConsumerState<TrainingDaysScreen> {
  final Set<int> _selectedDays = {};

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
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
                    child: OnboardingProgress(currentStep: 3, totalSteps: 5),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text('Which days can\nyou train?', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text('Select at least 3 days for an effective plan.',
                  style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(7, (i) {
                  final isSelected = _selectedDays.contains(i);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          if (_selectedDays.length > 3) _selectedDays.remove(i);
                        } else {
                          if (_selectedDays.length < 6) _selectedDays.add(i);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Text(
                '${_selectedDays.length} days selected',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedDays.length >= 3
                      ? () {
                          ref.read(onboardingProvider.notifier)
                              .setTrainingDays(_selectedDays.toList()..sort());
                          context.push('/onboarding/profile');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Build My Plan', style: TextStyle(
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
