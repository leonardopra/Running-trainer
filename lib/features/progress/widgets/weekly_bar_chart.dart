import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/progress_stats.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<WeekProgress> weeks;

  const WeeklyBarChart({super.key, required this.weeks});

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Builder(builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.chartNoData,
                style: const TextStyle(color: AppColors.onSurfaceMuted));
          }),
        ),
      );
    }

    final maxKm = weeks.fold<double>(
      1,
      (m, w) => m < w.plannedKm ? w.plannedKm : m,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Builder(builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Row(
            children: [
              _LegendDot(color: AppColors.primary.withOpacity(0.3), label: l10n.progressPlanned),
              const SizedBox(width: 16),
              _LegendDot(color: AppColors.primary, label: l10n.progressLogged),
            ],
          );
        }),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeks.map((w) => _WeekBar(
                week: w,
                maxKm: maxKm,
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekBar extends StatelessWidget {
  final WeekProgress week;
  final double maxKm;

  const _WeekBar({required this.week, required this.maxKm});

  @override
  Widget build(BuildContext context) {
    const barWidth = 18.0;
    const maxHeight = 120.0;
    const gap = 4.0;
    const groupWidth = 56.0;

    final plannedH = maxKm > 0 ? (week.plannedKm / maxKm * maxHeight).clamp(2.0, maxHeight) : 2.0;
    final loggedH  = maxKm > 0 ? (week.loggedKm  / maxKm * maxHeight).clamp(0.0, maxHeight) : 0.0;

    return SizedBox(
      width: groupWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // km label above bars
          Text(
            week.loggedKm > 0
                ? '${week.loggedKm.toStringAsFixed(0)}k'
                : '',
            style: const TextStyle(fontSize: 9, color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Planned bar
              Container(
                width: barWidth,
                height: plannedH,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.25),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(width: gap),
              // Logged bar
              if (loggedH > 0)
                Container(
                  width: barWidth,
                  height: loggedH,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                )
              else
                SizedBox(width: barWidth),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'W${week.weekNumber}',
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceMuted)),
      ],
    );
  }
}
