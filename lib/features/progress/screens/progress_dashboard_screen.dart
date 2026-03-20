import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../models/training_plan.dart';
import '../../../models/workout.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/storage_provider.dart';
import '../widgets/weekly_bar_chart.dart';

class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);
    final plan = ref.read(storageServiceProvider).getActivePlan();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(l10n.progressTitle, style: AppTextStyles.heading3),
          ),
          if (stats == null || plan == null)
            SliverFillRemaining(
              child: Center(
                child: Text(l10n.progressNoPlan, style: AppTextStyles.bodyMuted),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Overview stat cards ───────────────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _StatCard(
                          label: l10n.progressCompletion,
                          value: '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                          sub: l10n.progressCompletionSub(stats.completedWorkouts, stats.totalNonRestWorkouts),
                          color: AppColors.primary,
                          icon: Icons.check_circle_outline,
                        ),
                        _StatCard(
                          label: l10n.progressKmLogged,
                          value: stats.totalLoggedKm.toStringAsFixed(1),
                          sub: l10n.progressKmLoggedSub(stats.totalPlannedKm.toStringAsFixed(0)),
                          color: AppColors.secondary,
                          icon: Icons.route,
                        ),
                        _StatCard(
                          label: l10n.progressStreak,
                          value: '${stats.currentStreak}',
                          sub: stats.currentStreak == 1 ? l10n.progressDay : l10n.progressDays,
                          color: const Color(0xFFFF9800),
                          icon: Icons.local_fire_department,
                        ),
                        _StatCard(
                          label: l10n.progressWeeksDone,
                          value: '${stats.weeklyProgress.where((w) => w.completedWorkouts > 0).length}',
                          sub: l10n.progressWeeksDoneSub(plan.totalWeeks),
                          color: const Color(0xFF9C27B0),
                          icon: Icons.calendar_month,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Weekly bar chart ──────────────────────────────────
                    Text(l10n.progressWeeklyMileage, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(l10n.progressWeeklyMileageDesc, style: AppTextStyles.bodyMuted),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: WeeklyBarChart(weeks: stats.weeklyProgress),
                    ),
                    const SizedBox(height: 32),

                    // ── Recent activity ───────────────────────────────────
                    Text(l10n.progressRecentActivity, style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    _buildRecentActivity(plan, l10n),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(TrainingPlan plan, AppLocalizations l10n) {
    final completed = plan.weeks
        .expand((week) => week.workouts)
        .where((w) => w.isCompleted && w.type != WorkoutType.rest)
        .toList()
      ..sort((a, b) {
        final aDate = a.completedAt;
        final bDate = b.completedAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

    if (completed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty, color: AppColors.onSurfaceMuted, size: 20),
            const SizedBox(width: 12),
            Text(l10n.progressNoWorkouts, style: AppTextStyles.bodyMuted),
          ],
        ),
      );
    }

    final recent = completed.take(8).toList();
    return Column(
      children: recent.map<Widget>((w) => _ActivityTile(workout: w as Workout)).toList(),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceMuted,
              )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1,
              )),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceMuted,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent activity tile ───────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final Workout workout;
  const _ActivityTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final km = workout.actualDistanceKm ?? workout.distanceKm;
    final dur = workout.actualDurationMinutes ?? workout.durationMinutes;
    final date = workout.completedAt;

    String dateStr = '';
    if (date != null) {
      final diff = DateTime.now().difference(date).inDays;
      if (diff == 0) dateStr = l10n.progressToday;
      else if (diff == 1) dateStr = l10n.progressYesterday;
      else dateStr = l10n.progressDaysAgo(diff);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check, color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title, style: AppTextStyles.label),
                if (workout.notes != null && workout.notes!.isNotEmpty)
                  Text(workout.notes!, style: AppTextStyles.bodyMuted,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (km != null)
                Text('${(km as double).toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    )),
              if (dur != null)
                Text(l10n.progressMin(dur), style: AppTextStyles.bodyMuted),
              if (dateStr.isNotEmpty)
                Text(dateStr, style: const TextStyle(
                  fontSize: 11, color: AppColors.onSurfaceMuted,
                )),
            ],
          ),
        ],
      ),
    );
  }
}
