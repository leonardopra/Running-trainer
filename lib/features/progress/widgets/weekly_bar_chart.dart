import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/progress_stats.dart';

class WeeklyBarChart extends StatefulWidget {
  final List<WeekProgress> weeks;
  final bool useKilometers;

  const WeeklyBarChart({
    super.key,
    required this.weeks,
    required this.useKilometers,
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
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

    final factor = widget.useKilometers ? 1.0 : 0.621371;
    final unitLabel = widget.useKilometers ? 'km' : 'mi';
    final points = widget.weeks;
    final maxY = points
            .map((week) => week.plannedKm > week.loggedKm ? week.plannedKm : week.loggedKm)
            .fold<double>(0, (max, value) => value > max ? value : max) *
        factor;
    final chartMaxY = maxY <= 0 ? 5.0 : (maxY * 1.2).clamp(5.0, 9999.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendDot(
              color: AppColors.primary,
              label: l10n.progressPlanned,
            ),
            const SizedBox(width: 16),
            _LegendDot(
              color: AppColors.secondary,
              label: l10n.progressLogged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (points.length - 1).toDouble(),
              minY: 0,
              maxY: chartMaxY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: chartMaxY / 4,
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
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchCallback: (event, response) {
                  if (!mounted) return;
                  setState(() {
                    _touchedIndex = response?.lineBarSpots?.first.spotIndex;
                  });
                },
                getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
                    .map(
                      (_) => TouchedSpotIndicatorData(
                        const FlLine(
                          color: Color(0x55FFFFFF),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 5,
                            color: bar.color ?? AppColors.primary,
                            strokeWidth: 2,
                            strokeColor: AppColors.background,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipRoundedRadius: 12,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tooltipMargin: 12,
                  getTooltipColor: (_) => AppColors.surfaceVariant,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final week = points[spot.x.toInt()];
                      final value = spot.y.toStringAsFixed(1);
                      final label = spot.barIndex == 0 ? l10n.progressPlanned : l10n.progressLogged;
                      return LineTooltipItem(
                        'W${week.weekNumber}\n$label: $value $unitLabel',
                        TextStyle(
                          color: spot.bar.color ?? AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    interval: chartMaxY / 4,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.onSurfaceMuted,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }

                      final isHighlighted = _touchedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'W${points[index].weekNumber}',
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
              lineBarsData: [
                _buildLineData(
                  points: points,
                  factor: factor,
                  color: AppColors.primary,
                  isPlanned: true,
                ),
                _buildLineData(
                  points: points,
                  factor: factor,
                  color: AppColors.secondary,
                  isPlanned: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  LineChartBarData _buildLineData({
    required List<WeekProgress> points,
    required double factor,
    required Color color,
    required bool isPlanned,
  }) {
    return LineChartBarData(
      spots: [
        for (int i = 0; i < points.length; i++)
          FlSpot(
            i.toDouble(),
            (isPlanned ? points[i].plannedKm : points[i].loggedKm) * factor,
          ),
      ],
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: _touchedIndex == index ? 5 : 3.5,
          color: color,
          strokeWidth: 1.5,
          strokeColor: AppColors.background,
        ),
      ),
      belowBarData: BarAreaData(
        show: isPlanned,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
