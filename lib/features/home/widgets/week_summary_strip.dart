import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';

class WeekSummaryStrip extends StatelessWidget {
  final List<Workout> workouts; // 7 entries, one per day of week

  const WeekSummaryStrip({super.key, required this.workouts});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final dayOfWeek = i + 1;
        final isToday = dayOfWeek == today;

        final workout = workouts.firstWhere(
          (w) => w.dayOfWeek == dayOfWeek,
          orElse: () => workouts[i % workouts.length],
        );

        final color = _workoutColor(workout.type);
        final isCompleted = workout.isCompleted && workout.type != WorkoutType.rest;

        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.secondary.withValues(alpha:0.15)
                    : color.withValues(alpha:0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isToday
                      ? AppColors.primary
                      : isCompleted
                          ? AppColors.secondary.withValues(alpha:0.6)
                          : color.withValues(alpha:0.5),
                  width: isToday ? 2.0 : 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  workout.type == WorkoutType.rest
                      ? Icons.horizontal_rule
                      : isCompleted
                          ? Icons.check
                          : Icons.directions_run,
                  color: isToday
                      ? AppColors.primary
                      : isCompleted
                          ? AppColors.secondary
                          : color,
                  size: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dayLabels[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday ? AppColors.primary : AppColors.onSurfaceMuted,
              ),
            ),
          ],
        );
      }),
    );
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
}
