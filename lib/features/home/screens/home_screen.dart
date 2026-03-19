import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
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
    final greeting = '${_greeting()},\n${settings.name ?? 'Runner'}';

    return Scaffold(
      body: SafeArea(
        child: plan == null
            ? _buildNoPlan(context, greeting)
            : _buildWithPlan(context, plan, greeting),
      ),
    );
  }

  Widget _buildNoPlan(BuildContext context, String greeting) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, greeting),
          const Spacer(),
          const Center(
            child: Column(
              children: [
                Icon(Icons.directions_run, color: AppColors.primary, size: 64),
                SizedBox(height: 16),
                Text('No active plan', style: AppTextStyles.heading2),
                SizedBox(height: 8),
                Text(
                  'Your plan will appear here once generated.',
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

  Widget _buildWithPlan(BuildContext context, TrainingPlan plan, String greeting) {
    final weekIndex = _currentWeekIndex(plan);
    final currentWeek = plan.weeks[weekIndex];
    final todayWorkout = _todayWorkout(currentWeek);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, greeting),
          const SizedBox(height: 32),
          // Week chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.35)),
            ),
            child: Text(
              'Week ${weekIndex + 1} of ${plan.totalWeeks} — ${currentWeek.weekTheme}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Today
          Text('Today', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          TodayWorkoutCard(
            workout: todayWorkout,
            onTap: todayWorkout != null && todayWorkout.type != WorkoutType.rest
                ? () => context.push('/plan/workout/${todayWorkout.id}', extra: todayWorkout)
                : null,
          ),
          const SizedBox(height: 28),
          // Week strip
          Text('This Week', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          WeekSummaryStrip(workouts: currentWeek.workouts),
          const SizedBox(height: 32),
          // View full plan
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.push('/plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('View Full Plan', style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              )),
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
