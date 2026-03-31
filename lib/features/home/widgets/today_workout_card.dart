import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n_helpers.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';

class TodayWorkoutCard extends StatelessWidget {
  final Workout? workout;
  final VoidCallback? onTap;

  const TodayWorkoutCard({super.key, required this.workout, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (workout == null || workout!.type == WorkoutType.rest) {
      return _buildRestCard();
    }
    return _buildWorkoutCard();
  }

  Widget _buildRestCard() {
    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Row(
          children: [
            const _WorkoutIcon(color: AppColors.rest, icon: Icons.self_improvement),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.workoutRestDay, style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(l10n.workoutRestDayDesc, style: AppTextStyles.bodyMuted),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWorkoutCard() {
    final w = workout!;
    final color = _workoutColor(w.type);

    return Builder(builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              _WorkoutIcon(color: color, icon: _workoutIcon(w.type)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            w.distanceKm != null
                                ? '${w.distanceKm!.toStringAsFixed(1)} km · ${w.type.localizedName(l10n)}'
                                : w.type.localizedName(l10n),
                            style: AppTextStyles.heading3,
                          ),
                        ),
                        if (w.isCompleted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(children: [
                              const Icon(Icons.check_circle,
                                  color: AppColors.secondary, size: 12),
                              const SizedBox(width: 4),
                              Text(l10n.workoutLogCompleted,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  )),
                            ]),
                          ),
                        ],
                      ],
                    ),
                    if (w.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        w.description!,
                        style: AppTextStyles.bodyMuted,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.onSurfaceMuted),
            ],
          ),
        ),
      );
    });
  }

  Color _workoutColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return AppColors.easyRun;
      case WorkoutType.tempoRun: return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun: return AppColors.longRun;
      case WorkoutType.crossTrain: return AppColors.crossTrain;
      case WorkoutType.rest: return AppColors.rest;
    }
  }

  IconData _workoutIcon(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return Icons.directions_run;
      case WorkoutType.tempoRun: return Icons.speed;
      case WorkoutType.intervalRun: return Icons.timer;
      case WorkoutType.longRun: return Icons.landscape;
      case WorkoutType.crossTrain: return Icons.fitness_center;
      case WorkoutType.rest: return Icons.self_improvement;
    }
  }
}

class _WorkoutIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _WorkoutIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
