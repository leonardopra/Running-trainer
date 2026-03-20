import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/training_plan.dart';
import '../../../models/training_week.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import '../../../providers/training_plan_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/today_workout_card.dart';
import '../widgets/week_summary_strip.dart';
import '../widgets/insights_strip.dart';
import '../../../services/insights_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 17) return l10n.greetingAfternoon;
    if (hour < 21) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  int _currentWeekIndex(TrainingPlan plan) {
    final daysSinceStart = DateTime.now().difference(plan.startDate).inDays;
    if (daysSinceStart < 0) return 0;
    return (daysSinceStart ~/ 7).clamp(0, plan.totalWeeks - 1);
  }

  Workout? _todayWorkout(TrainingWeek week) {
    final todayDow = DateTime.now().weekday; // 1=Mon, 7=Sun
    try {
      return week.workouts.firstWhere((w) => w.dayOfWeek == todayDow);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(activePlanProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final greeting = '${_greeting(l10n)},\n${settings.name ?? 'Runner'}';

    return Scaffold(
      body: SafeArea(
        child: plan == null
            ? _buildNoPlan(context, greeting, l10n)
            : _buildWithPlan(context, plan, greeting, l10n),
      ),
    );
  }

  Widget _buildNoPlan(BuildContext context, String greeting, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, greeting),
          const Spacer(),
          Center(
            child: Column(
              children: [
                const Icon(Icons.directions_run, color: AppColors.primary, size: 64),
                const SizedBox(height: 16),
                Text(l10n.homeNoPlan, style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                Text(
                  l10n.homeNoPlanDesc,
                  style: AppTextStyles.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWithPlan(BuildContext context, TrainingPlan plan, String greeting, AppLocalizations l10n) {
    final weekIndex = _currentWeekIndex(plan);
    final currentWeek = plan.weeks[weekIndex];
    final todayWorkout = _todayWorkout(currentWeek);
    final insights = InsightsService.generate(plan);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: _buildHeader(context, greeting),
          ),
          const SizedBox(height: 28),
          // Week chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              ),
              child: Text(
                l10n.homeWeekChip(weekIndex + 1, plan.totalWeeks, currentWeek.weekTheme),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          // Insights strip
          if (insights.isNotEmpty) ...[
            const SizedBox(height: 20),
            InsightsStrip(insights: insights),
          ],
          const SizedBox(height: 24),
          // Today
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(l10n.homeToday, style: AppTextStyles.heading3),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TodayWorkoutCard(
              workout: todayWorkout,
              onTap: todayWorkout != null && todayWorkout.type != WorkoutType.rest
                  ? () => context.push('/plan/workout/${todayWorkout.id}', extra: todayWorkout)
                  : null,
            ),
          ),
          const SizedBox(height: 28),
          // Week strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(l10n.homeThisWeek, style: AppTextStyles.heading3),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: WeekSummaryStrip(workouts: currentWeek.workouts),
          ),
          const SizedBox(height: 32),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push('/plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(l10n.btnViewFullPlan,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.onSurface,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: AppColors.surfaceVariant),
                    ),
                    child: const Icon(Icons.bar_chart, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: ElevatedButton(
                    onPressed: () => context.push('/pace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.onSurface,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: AppColors.surfaceVariant),
                    ),
                    child: const Icon(Icons.speed, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String greeting) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(greeting, style: AppTextStyles.heading1),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }
}
