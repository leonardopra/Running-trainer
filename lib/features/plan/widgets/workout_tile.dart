import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import 'effort_badge.dart';

class WorkoutTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback? onTap;

  const WorkoutTile({super.key, required this.workout, this.onTap});

  Color _getTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return AppColors.easyRun;
      case WorkoutType.tempoRun: return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun: return AppColors.longRun;
      case WorkoutType.crossTrain: return AppColors.crossTrain;
      case WorkoutType.rest: return AppColors.rest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRest = workout.type == WorkoutType.rest;
    final typeColor = _getTypeColor(workout.type);

    return GestureDetector(
      onTap: isRest ? null : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: workout.isCompleted
              ? Border.all(color: AppColors.secondary.withOpacity(0.4))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.title, style: AppTextStyles.label),
                  if (workout.distanceKm != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${workout.distanceKm!.toStringAsFixed(1)} km',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            if (!isRest) EffortBadge(effort: workout.effortLevel),
            if (workout.isCompleted) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
