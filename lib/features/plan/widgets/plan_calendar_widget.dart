import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/training_plan.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';

class PlanCalendarWidget extends StatefulWidget {
  const PlanCalendarWidget({
    super.key,
    required this.plan,
    required this.onWorkoutTap,
    required this.localeCode,
  });

  final TrainingPlan plan;
  final void Function(Workout) onWorkoutTap;
  final String localeCode;

  @override
  State<PlanCalendarWidget> createState() => _PlanCalendarWidgetState();
}

class _PlanCalendarWidgetState extends State<PlanCalendarWidget> {
  late DateTime _displayedMonth;
  late Map<DateTime, Workout> _workoutDays;
  late List<DateTime> _validMonths;

  @override
  void initState() {
    super.initState();
    _buildWorkoutMap();
    _displayedMonth = DateTime(
      widget.plan.startDate.year,
      widget.plan.startDate.month,
    );
  }

  void _buildWorkoutMap() {
    _workoutDays = {};
    for (var wi = 0; wi < widget.plan.weeks.length; wi++) {
      final week = widget.plan.weeks[wi];
      for (final workout in week.workouts) {
        final date = widget.plan.startDate
            .add(Duration(days: wi * 7 + (workout.dayOfWeek - 1)));
        final key = DateTime(date.year, date.month, date.day);
        _workoutDays[key] = workout;
      }
    }

    final months = _workoutDays.keys
        .map((d) => DateTime(d.year, d.month))
        .toSet()
        .toList()
      ..sort();
    _validMonths = months;
  }

  void _prevMonth() {
    final idx = _validMonths.indexOf(_displayedMonth);
    if (idx > 0) setState(() => _displayedMonth = _validMonths[idx - 1]);
  }

  void _nextMonth() {
    final idx = _validMonths.indexOf(_displayedMonth);
    if (idx < _validMonths.length - 1) {
      setState(() => _displayedMonth = _validMonths[idx + 1]);
    }
  }

  Color _colorForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun:
        return AppColors.easyRun;
      case WorkoutType.tempoRun:
        return AppColors.tempoRun;
      case WorkoutType.intervalRun:
        return AppColors.intervalRun;
      case WorkoutType.longRun:
        return AppColors.longRun;
      case WorkoutType.crossTrain:
        return AppColors.crossTrain;
      case WorkoutType.rest:
        return AppColors.rest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.localeCode;
    final firstDay = _displayedMonth;
    final daysInMonth =
        DateUtils.getDaysInMonth(firstDay.year, firstDay.month);
    final firstWeekday = firstDay.weekday; // 1=Mon, 7=Sun
    final leadingBlanks = firstWeekday - 1;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final idx = _validMonths.indexOf(_displayedMonth);
    final canPrev = idx > 0;
    final canNext = idx < _validMonths.length - 1;

    final dayLabels = List.generate(7, (i) {
      final weekday = DateTime(2024, 1, 1 + i); // 2024-01-01 is Monday
      return DateFormat.E(locale).format(weekday);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: canPrev ? AppColors.onSurface : AppColors.onSurfaceMuted,
                ),
                onPressed: canPrev ? _prevMonth : null,
              ),
              Text(
                DateFormat('MMMM yyyy', locale).format(_displayedMonth),
                style: AppTextStyles.heading3,
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: canNext ? AppColors.onSurface : AppColors.onSurfaceMuted,
                ),
                onPressed: canNext ? _nextMonth : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day-of-week header
          Row(
            children: dayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox();

              final day = index - leadingBlanks + 1;
              final date = DateTime(firstDay.year, firstDay.month, day);
              final workout = _workoutDays[date];
              final isToday = date == todayKey;

              return GestureDetector(
                onTap: workout != null ? () => widget.onWorkoutTap(workout) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday || (workout?.isCompleted ?? false)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                      ),
                      if (workout != null) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: workout.isCompleted
                                ? AppColors.secondary
                                : _colorForType(workout.type),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Legend
          _Legend(colorForType: _colorForType),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.colorForType});
  final Color Function(WorkoutType) colorForType;

  @override
  Widget build(BuildContext context) {
    final entries = [
      (WorkoutType.easyRun, 'Easy'),
      (WorkoutType.longRun, 'Long'),
      (WorkoutType.tempoRun, 'Tempo'),
      (WorkoutType.intervalRun, 'Intervals'),
      (WorkoutType.crossTrain, 'Cross'),
      (WorkoutType.rest, 'Rest'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorForType(e.$1),
              ),
            ),
            const SizedBox(width: 4),
            Text(e.$2, style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        );
      }).toList(),
    );
  }
}
