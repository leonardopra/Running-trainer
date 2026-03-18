import 'package:flutter/material.dart';
import '../../../models/enums.dart';

class EffortBadge extends StatelessWidget {
  final EffortLevel effort;

  const EffortBadge({super.key, required this.effort});

  @override
  Widget build(BuildContext context) {
    final color = Color(effort.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        effort.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
