import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/enums.dart';
import '../../../models/progress_stats.dart';

class WorkoutTypeDistributionChart extends StatefulWidget {
  final List<WorkoutTypeCount> counts;

  const WorkoutTypeDistributionChart({
    super.key,
    required this.counts,
  });

  @override
  State<WorkoutTypeDistributionChart> createState() => _WorkoutTypeDistributionChartState();
}

class _WorkoutTypeDistributionChartState extends State<WorkoutTypeDistributionChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.counts.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            l10n.chartNoData,
            style: const TextStyle(color: AppColors.onSurfaceMuted),
          ),
        ),
      );
    }

    final total = widget.counts.fold<int>(0, (sum, entry) => sum + entry.count);

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!mounted) return;
                    setState(() {
                      _touchedIndex = response?.touchedSection?.touchedSectionIndex;
                    });
                  },
                ),
                sections: [
                  for (int i = 0; i < widget.counts.length; i++)
                    _buildSection(
                      context: context,
                      index: i,
                      count: widget.counts[i],
                      total: total,
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.counts.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _LegendRow(
                    color: _colorForType(widget.counts[i].type),
                    label: _labelForType(l10n, widget.counts[i].type),
                    value: '${widget.counts[i].count}',
                    isHighlighted: _touchedIndex == i,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _buildSection({
    required BuildContext context,
    required int index,
    required WorkoutTypeCount count,
    required int total,
  }) {
    final percentage = total == 0 ? 0 : (count.count / total) * 100;
    final isTouched = _touchedIndex == index;
    final color = _colorForType(count.type);

    return PieChartSectionData(
      value: count.count.toDouble(),
      color: color,
      radius: isTouched ? 58 : 50,
      title: percentage >= 10 ? '${percentage.toStringAsFixed(0)}%' : '',
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
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

  String _labelForType(AppLocalizations l10n, WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun:
        return l10n.workoutTypeEasyRun;
      case WorkoutType.tempoRun:
        return l10n.workoutTypeTempoRun;
      case WorkoutType.intervalRun:
        return l10n.workoutTypeIntervalRun;
      case WorkoutType.longRun:
        return l10n.workoutTypeLongRun;
      case WorkoutType.crossTrain:
        return l10n.workoutTypeCrossTrain;
      case WorkoutType.rest:
        return l10n.workoutTypeRest;
    }
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isHighlighted;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isHighlighted ? Colors.white : AppColors.onSurfaceMuted,
                fontSize: 12,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
