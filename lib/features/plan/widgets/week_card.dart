import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/training_week.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import 'workout_tile.dart';
import '../../../core/l10n_helpers.dart';

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

  String _dayLabel(int dayOfWeek, AppLocalizations l10n) {
    switch (dayOfWeek) {
      case 1: return l10n.dayMon;
      case 2: return l10n.dayTue;
      case 3: return l10n.dayWed;
      case 4: return l10n.dayThu;
      case 5: return l10n.dayFri;
      case 6: return l10n.daySat;
      case 7: return l10n.daySun;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        Text(l10n.weekCardWeek(widget.week.weekNumber),
                            style: AppTextStyles.caption),
                        const SizedBox(height: 2),
                        Text(localizedWeekTheme(widget.week.weekTheme, l10n), style: AppTextStyles.heading3),
                        const SizedBox(height: 4),
                        Text(
                          l10n.weekCardStats(
                            widget.week.targetWeeklyKm.toStringAsFixed(0),
                            completedCount,
                            totalCount,
                          ),
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
                  final dayName = _dayLabel(workout.dayOfWeek, l10n);
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
