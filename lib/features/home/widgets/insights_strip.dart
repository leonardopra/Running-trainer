import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/coaching_insight.dart';

class InsightsStrip extends StatelessWidget {
  final List<CoachingInsight> insights;

  const InsightsStrip({super.key, required this.insights});

  Color _color(InsightType type) {
    switch (type) {
      case InsightType.positive:   return AppColors.secondary;
      case InsightType.warning:    return const Color(0xFFFF9800);
      case InsightType.info:       return AppColors.primary;
      case InsightType.motivation: return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: insights.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final insight = insights[i];
          final color = _color(insight.type);
          return _InsightCard(insight: insight, color: color);
        },
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final CoachingInsight insight;
  final Color color;

  const _InsightCard({required this.insight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(insight.icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              insight.body,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceMuted,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
