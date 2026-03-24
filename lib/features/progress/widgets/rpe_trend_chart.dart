import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/enums.dart';
import '../../../models/progress_stats.dart';

class RpeTrendChart extends StatelessWidget {
  final List<RpeDataPoint> points;
  const RpeTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (points.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(l10n.progressNoRpeData,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E9AAB)),
              textAlign: TextAlign.center),
        ),
      );
    }

    return SizedBox(
      height: 170,
      child: CustomPaint(
        painter: _RpeChartPainter(points: points),
        size: Size.infinite,
      ),
    );
  }
}

class _RpeChartPainter extends CustomPainter {
  final List<RpeDataPoint> points;
  _RpeChartPainter({required this.points});

  static const double _leftPad = 28;
  static const double _rightPad = 8;
  static const double _topPad = 8;
  static const double _bottomPad = 28;

  Color _colorForType(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return const Color(0xFF4CAF50);
      case WorkoutType.longRun: return const Color(0xFF2196F3);
      case WorkoutType.tempoRun: return const Color(0xFFFF9800);
      case WorkoutType.intervalRun: return const Color(0xFFF44336);
      default: return const Color(0xFF9E9E9E);
    }
  }

  double _yForRpe(int rpe, double chartHeight) {
    return _topPad + chartHeight * (1 - (rpe - 1) / 9.0);
  }

  double _xForIndex(int i, int total, double chartWidth) {
    if (total == 1) return _leftPad + chartWidth / 2;
    return _leftPad + (i / (total - 1)) * chartWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - _leftPad - _rightPad;
    final chartHeight = size.height - _topPad - _bottomPad;

    // Background zones
    final greenZone = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.08);
    final orangeZone = Paint()..color = const Color(0xFFFF9800).withOpacity(0.08);
    final redZone = Paint()..color = const Color(0xFFF44336).withOpacity(0.08);

    // RPE 1–4: green (bottom)
    final y4 = _yForRpe(4, chartHeight);
    final y7 = _yForRpe(7, chartHeight);
    final y10 = _yForRpe(10, chartHeight);
    final yBottom = _topPad + chartHeight;

    canvas.drawRect(Rect.fromLTRB(_leftPad, y4, size.width - _rightPad, yBottom), greenZone);
    canvas.drawRect(Rect.fromLTRB(_leftPad, y7, size.width - _rightPad, y4), orangeZone);
    canvas.drawRect(Rect.fromLTRB(_leftPad, y10, size.width - _rightPad, y7), redZone);

    // Y axis labels
    final labelStyle = TextStyle(fontSize: 10, color: Colors.grey[500]);
    for (final rpe in [1, 5, 10]) {
      final y = _yForRpe(rpe, chartHeight);
      final tp = TextPainter(
        text: TextSpan(text: '$rpe', style: labelStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_leftPad - tp.width - 4, y - tp.height / 2));
    }

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
      final y = _yForRpe(points[i].rpe, chartHeight);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    // Points and X labels
    final skipLabels = points.length > 8;
    final dateFormat = DateFormat('MMM d');

    for (int i = 0; i < points.length; i++) {
      final x = _xForIndex(i, points.length, chartWidth);
      final y = _yForRpe(points[i].rpe, chartHeight);

      final dotPaint = Paint()
        ..color = _colorForType(points[i].type)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 5, dotPaint);

      // X label
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
  bool shouldRepaint(_RpeChartPainter oldDelegate) => oldDelegate.points != points;
}
