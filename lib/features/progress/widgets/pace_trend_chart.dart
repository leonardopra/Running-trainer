import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/enums.dart';
import '../../../models/progress_stats.dart';

class PaceTrendChart extends StatelessWidget {
  final List<PaceDataPoint> points;
  final bool useKilometers;

  const PaceTrendChart({super.key, required this.points, required this.useKilometers});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (points.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            l10n.progressNoPaceData,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8E9AAB)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final unitLabel = useKilometers ? 'min/km' : 'min/mi';

    return SizedBox(
      height: 170,
      child: CustomPaint(
        painter: _PaceChartPainter(points: points, useKilometers: useKilometers, unitLabel: unitLabel),
        size: Size.infinite,
      ),
    );
  }
}

String _formatPace(double minPerUnit) {
  final min = minPerUnit.floor();
  final sec = ((minPerUnit - min) * 60).round();
  return '$min:${sec.toString().padLeft(2, '0')}';
}

class _PaceChartPainter extends CustomPainter {
  final List<PaceDataPoint> points;
  final bool useKilometers;
  final String unitLabel;

  _PaceChartPainter({required this.points, required this.useKilometers, required this.unitLabel});

  static const double _leftPad = 44;
  static const double _rightPad = 8;
  static const double _topPad = 8;
  static const double _bottomPad = 28;

  double _displayPace(double paceMinPerKm) =>
      useKilometers ? paceMinPerKm : paceMinPerKm / 0.621371;

  Color _colorForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return const Color(0xFF4CAF50);
      case WorkoutType.longRun: return const Color(0xFF2196F3);
      case WorkoutType.tempoRun: return const Color(0xFFFF9800);
      case WorkoutType.intervalRun: return const Color(0xFFF44336);
      default: return const Color(0xFF9E9E9E);
    }
  }

  // Y axis is inverted: faster pace (lower value) = higher on chart
  double _yForPace(double pace, double minPace, double maxPace, double chartHeight) {
    if (maxPace == minPace) return _topPad + chartHeight / 2;
    final normalized = (pace - minPace) / (maxPace - minPace);
    return _topPad + chartHeight * normalized;
  }

  double _xForIndex(int i, int total, double chartWidth) {
    if (total == 1) return _leftPad + chartWidth / 2;
    return _leftPad + (i / (total - 1)) * chartWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - _leftPad - _rightPad;
    final chartHeight = size.height - _topPad - _bottomPad;

    final displayPaces = points.map((p) => _displayPace(p.paceMinPerKm)).toList();
    final rawMin = displayPaces.reduce((a, b) => a < b ? a : b);
    final rawMax = displayPaces.reduce((a, b) => a > b ? a : b);
    final padding = (rawMax - rawMin) * 0.1;
    final minPace = rawMin - padding;
    final maxPace = rawMax + padding;

    // Y axis labels (top = fastest = minPace, bottom = slowest = maxPace)
    final labelStyle = TextStyle(fontSize: 10, color: Colors.grey[500]);
    final yLabels = [minPace, (minPace + maxPace) / 2, maxPace];
    for (int i = 0; i < yLabels.length; i++) {
      final pace = yLabels[i];
      final y = _yForPace(pace, minPace, maxPace, chartHeight);
      final tp = TextPainter(
        text: TextSpan(text: _formatPace(pace), style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_leftPad - tp.width - 4, y - tp.height / 2));
    }

    // Unit label at top-left
    final unitTp = TextPainter(
      text: TextSpan(text: unitLabel, style: TextStyle(fontSize: 9, color: Colors.grey[400])),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    unitTp.paint(canvas, const Offset(0, 0));

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = _xForIndex(i, points.length, chartWidth);
      final y = _yForPace(displayPaces[i], minPace, maxPace, chartHeight);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    // Points and X labels
    final skipLabels = points.length > 8;
    final dateFormat = DateFormat('MMM d');

    for (int i = 0; i < points.length; i++) {
      final x = _xForIndex(i, points.length, chartWidth);
      final y = _yForPace(displayPaces[i], minPace, maxPace, chartHeight);

      final dotPaint = Paint()
        ..color = _colorForType(points[i].type)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 5, dotPaint);

      if (!skipLabels || i % 2 == 0) {
        final label = dateFormat.format(points[i].date);
        final tp = TextPainter(
          text: TextSpan(text: label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
          textDirection: ui.TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, _topPad + chartHeight + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_PaceChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.useKilometers != useKilometers;
}
