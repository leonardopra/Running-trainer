import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/training_week.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import 'workout_tile.dart';

class WeekCard extends StatefulWidget {
  final TrainingWeek week;
  final bool isExpanded;
  final Function(Workout) onWorkoutTap;

  const WeekCard({
    super.key,
    required this.week,
    required this.isExpanded,
    required this.onWorkoutTap,
  });

  @override
  State<WeekCard> createState() => _WeekCardState();
}

class _WeekCardState extends State<WeekCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isExpanded;
  }

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.week.workouts
        .where((w) => w.isCompleted && w.type != WorkoutType.rest)
        .length;
    final totalCount = widget.week.workouts
        .where((w) => w.type != WorkoutType.rest)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Week ${widget.week.weekNumber}',
                            style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(widget.week.weekTheme, style: AppTextStyles.heading3),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.week.targetWeeklyKm.toStringAsFixed(0)}km · $completedCount/$totalCount workouts',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.onSurfaceMuted,
                  ),
                ],
              ),
            ),
          ),
          // Workouts
          if (_expanded) ...[
            const Divider(color: AppColors.surfaceVariant, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: widget.week.workouts.map((workout) {
                  final dayName = _dayNames[workout.dayOfWeek - 1];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(dayName,
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center),
                        ),
                      ),
                      Expanded(
                        child: WorkoutTile(
                          workout: workout,
                          onTap: () => widget.onWorkoutTap(workout),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
