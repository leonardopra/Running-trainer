import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/progress_stats.dart';

class CompletionRateChart extends StatefulWidget {
  final List<WeekProgress> weeks;

  const CompletionRateChart({
    super.key,
    required this.weeks,
  });

  @override
  State<CompletionRateChart> createState() => _CompletionRateChartState();
}

class _CompletionRateChartState extends State<CompletionRateChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.weeks.isEmpty) {
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

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: 100,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0x1FFFFFFF),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
              top: BorderSide.none,
              right: BorderSide.none,
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipColor: (_) => AppColors.surfaceVariant,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final week = widget.weeks[group.x.toInt()];
                final percentage = (week.completionRate * 100).toStringAsFixed(0);
                return BarTooltipItem(
                  'W${week.weekNumber}\n$percentage% • ${week.completedWorkouts}/${week.totalWorkouts}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              },
            ),
            touchCallback: (event, response) {
              if (!mounted) return;
              setState(() {
                _touchedIndex = response?.spot?.touchedBarGroupIndex;
              });
            },
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    color: AppColors.onSurfaceMuted,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.weeks.length) {
                    return const SizedBox.shrink();
                  }

                  final isHighlighted = _touchedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'W${widget.weeks[index].weekNumber}',
                      style: TextStyle(
                        color: isHighlighted ? Colors.white : AppColors.onSurfaceMuted,
                        fontSize: 10,
                        fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < widget.weeks.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: widget.weeks[i].completionRate * 100,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: _barGradient(i == _touchedIndex),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _barGradient(bool highlighted) {
    if (highlighted) {
      return [
        const Color(0xFF9CFF4D),
        AppColors.secondary,
      ];
    }

    return [
      AppColors.secondary.withValues(alpha: 0.75),
      AppColors.primary.withValues(alpha: 0.65),
    ];
  }
}
