import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/enums.dart';

class FeelingDistribution extends StatelessWidget {
  final Map<WorkoutFeeling, int> counts;
  const FeelingDistribution({super.key, required this.counts});

  static const _emojis = {
    WorkoutFeeling.great: '😄',
    WorkoutFeeling.good: '🙂',
    WorkoutFeeling.ok: '😐',
    WorkoutFeeling.tired: '😓',
    WorkoutFeeling.injured: '🤕',
  };

  Color _colorForFeeling(WorkoutFeeling f) {
    switch (f) {
      case WorkoutFeeling.great: return const Color(0xFF4CAF50);
      case WorkoutFeeling.good: return const Color(0xFF8BC34A);
      case WorkoutFeeling.ok: return const Color(0xFF9E9E9E);
      case WorkoutFeeling.tired: return const Color(0xFFFF9800);
      case WorkoutFeeling.injured: return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (counts.isEmpty) {
      return Text(l10n.progressNoFeelingData,
          style: const TextStyle(fontSize: 13, color: Color(0xFF8E9AAB)));
    }

    final total = counts.values.fold(0, (s, v) => s + v);

    return Row(
      children: WorkoutFeeling.values.map((feeling) {
        final count = counts[feeling] ?? 0;
        final pct = total == 0 ? 0 : (count / total * 100).round();
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_emojis[feeling]!, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _colorForFeeling(feeling),
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8E9AAB)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
