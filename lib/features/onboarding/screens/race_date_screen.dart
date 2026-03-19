import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../providers/plan_generation_provider.dart';
import '../widgets/onboarding_progress.dart';

class RaceDateScreen extends ConsumerStatefulWidget {
  const RaceDateScreen({super.key});

  @override
  ConsumerState<RaceDateScreen> createState() => _RaceDateScreenState();
}

class _RaceDateScreenState extends ConsumerState<RaceDateScreen> {
  bool _useRaceDate = true;
  DateTime? _selectedDate;
  int _selectedWeeks = 12;

  static const _weekOptions = [8, 10, 12, 16];

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final isGeneralFitness = onboarding.goalType == GoalType.generalFitness;

    if (isGeneralFitness) {
      _useRaceDate = false;
    }

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
                    child: OnboardingProgress(currentStep: 1, totalSteps: 5),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text('When is your\nrace?', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text('Set a race date or choose a training duration.',
                  style: AppTextStyles.bodyMuted),
              const SizedBox(height: 32),
              if (!isGeneralFitness) ...[
                _buildToggle(),
                const SizedBox(height: 24),
              ],
              if (_useRaceDate && !isGeneralFitness)
                _buildDatePicker()
              else
                _buildWeekSelector(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canContinue()
                      ? () {
                          if (_useRaceDate && _selectedDate != null) {
                            ref.read(onboardingProvider.notifier).setRaceDate(_selectedDate!);
                          } else {
                            ref.read(onboardingProvider.notifier).setDurationWeeks(_selectedWeeks);
                          }
                          context.push('/onboarding/fitness');
                        }
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

  bool _canContinue() {
    if (_useRaceDate) return _selectedDate != null;
    return true;
  }

  Widget _buildToggle() {
    return Row(
      children: [
        _toggleButton('Race Date', _useRaceDate, () => setState(() => _useRaceDate = true)),
        const SizedBox(width: 12),
        _toggleButton('Duration', !_useRaceDate, () => setState(() => _useRaceDate = false)),
      ],
    );
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.surfaceVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.background : AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 84)),
          firstDate: DateTime.now().add(const Duration(days: 28)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedDate != null ? AppColors.primary : AppColors.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Select race date',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Column(
      children: _weekOptions.map((weeks) {
        final isSelected = _selectedWeeks == weeks;
        return GestureDetector(
          onTap: () => setState(() => _selectedWeeks = weeks),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Text('$weeks weeks', style: AppTextStyles.heading3),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
