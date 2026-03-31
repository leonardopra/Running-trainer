import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n_helpers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/enums.dart';
import '../../../models/workout.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/training_plan_provider.dart';

class RunHistoryScreen extends ConsumerStatefulWidget {
  const RunHistoryScreen({super.key});

  @override
  ConsumerState<RunHistoryScreen> createState() => _RunHistoryScreenState();
}

class _RunHistoryScreenState extends ConsumerState<RunHistoryScreen> {
  WorkoutType? _filter;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(activePlanProvider);
    final useKm = ref.watch(settingsProvider).useKilometers;
    final convFactor = useKm ? 1.0 : 0.621371;
    final unitLabel = useKm ? 'km' : 'mi';
    final l10n = AppLocalizations.of(context)!;

    final allCompleted = plan == null
        ? <Workout>[]
        : plan.weeks
            .expand((w) => w.workouts)
            .where((w) => w.isCompleted && w.type != WorkoutType.rest)
            .cast<Workout>()
            .toList()
          ..sort((a, b) {
            final aDate = a.completedAt;
            final bDate = b.completedAt;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

    final filtered = _filter == null
        ? allCompleted
        : allCompleted.where((w) => w.type == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title:
                Text(l10n.progressHistoryTitle, style: AppTextStyles.heading3),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _FilterChips(
                selected: _filter,
                onSelected: (type) =>
                    setState(() => _filter = type == _filter ? null : type),
                l10n: l10n,
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(l10n.progressHistoryEmpty,
                    style: AppTextStyles.bodyMuted),
              ),
            )
          else
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(20, 4, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final w = filtered[index];
                    return _HistoryTile(
                      workout: w,
                      convFactor: convFactor,
                      unitLabel: unitLabel,
                      l10n: l10n,
                      onTap: () => context.push(
                          '/plan/workout/${w.id}',
                          extra: w),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final WorkoutType? selected;
  final ValueChanged<WorkoutType> onSelected;
  final AppLocalizations l10n;

  const _FilterChips({
    required this.selected,
    required this.onSelected,
    required this.l10n,
  });

  static const _types = [
    WorkoutType.easyRun,
    WorkoutType.longRun,
    WorkoutType.tempoRun,
    WorkoutType.intervalRun,
    WorkoutType.crossTrain,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _types.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type.localizedName(l10n)),
              selected: isSelected,
              onSelected: (_) => onSelected(type),
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceMuted,
              ),
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Workout workout;
  final double convFactor;
  final String unitLabel;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _HistoryTile({
    required this.workout,
    required this.convFactor,
    required this.unitLabel,
    required this.l10n,
    required this.onTap,
  });

  String _feelingEmoji(WorkoutFeeling f) {
    switch (f) {
      case WorkoutFeeling.great:   return '😄';
      case WorkoutFeeling.good:    return '🙂';
      case WorkoutFeeling.ok:      return '😐';
      case WorkoutFeeling.tired:   return '😴';
      case WorkoutFeeling.injured: return '🤕';
    }
  }

  Color _typeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun:     return AppColors.easyRun;
      case WorkoutType.tempoRun:    return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun:     return AppColors.longRun;
      case WorkoutType.crossTrain:  return AppColors.crossTrain;
      default:                      return AppColors.primary;
    }
  }

  String _dateLabel() {
    final date = workout.completedAt;
    if (date == null) return '';
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return l10n.progressToday;
    if (diff == 1) return l10n.progressYesterday;
    return l10n.progressDaysAgo(diff);
  }

  @override
  Widget build(BuildContext context) {
    final km = workout.actualDistanceKm ?? workout.distanceKm;
    final dur = workout.actualDurationMinutes ?? workout.durationMinutes;
    final color = _typeColor(workout.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.directions_run, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.title, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(workout.type.localizedName(l10n),
                      style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (km != null)
                  Text(
                    '${(km * convFactor).toStringAsFixed(1)} $unitLabel',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                Row(
                  children: [
                    if (dur != null)
                      Text(l10n.progressMin(dur),
                          style: AppTextStyles.bodyMuted),
                    if (workout.rpe != null) ...[
                      const SizedBox(width: 6),
                      Text('RPE ${workout.rpe}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500)),
                    ],
                    if (workout.feeling != null) ...[
                      const SizedBox(width: 4),
                      Text(_feelingEmoji(workout.feeling!),
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
                Text(_dateLabel(),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.onSurfaceMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
