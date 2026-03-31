import 'package:flutter/material.dart';

class StretchExercise {
  final String id;
  final String name;
  final String description;
  final List<String> muscleGroups;
  final int durationSeconds;
  final String? reps;
  final bool isPreRun;
  final bool isPostRun;
  final IconData icon;
  final String youtubeQuery;

  const StretchExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.durationSeconds,
    this.reps,
    required this.isPreRun,
    required this.isPostRun,
    required this.icon,
    required this.youtubeQuery,
  });

  String get durationLabel {
    if (reps != null) return reps!;
    if (durationSeconds >= 60) {
      final mins = durationSeconds ~/ 60;
      final secs = durationSeconds % 60;
      return secs > 0 ? '${mins}m ${secs}s' : '$mins min';
    }
    return '${durationSeconds}s each side';
  }
}
