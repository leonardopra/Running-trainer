import 'package:flutter/material.dart';

enum InsightType { positive, warning, info, motivation }

class CoachingInsight {
  final String title;
  final String body;
  final IconData icon;
  final InsightType type;
  final int priority; // lower = shown first

  const CoachingInsight({
    required this.title,
    required this.body,
    required this.icon,
    required this.type,
    required this.priority,
  });
}
