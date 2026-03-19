import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import '../widgets/effort_badge.dart';
import '../../stretching/screens/stretching_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  Color _getTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun: return AppColors.easyRun;
      case WorkoutType.tempoRun: return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun: return AppColors.longRun;
      case WorkoutType.crossTrain: return AppColors.crossTrain;
      case WorkoutType.rest: return AppColors.rest;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor = _getTypeColor(workout.type);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(workout.type.displayName, style: AppTextStyles.heading3),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero stat row
                  Row(
                    children: [
                      if (workout.distanceKm != null) ...[
                        _StatCard(
                          label: 'Distance',
                          value: '${workout.distanceKm!.toStringAsFixed(1)} km',
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (workout.durationMinutes != null) ...[
                        _StatCard(
                          label: 'Duration',
                          value: '${workout.durationMinutes} min',
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                      ],
                      _StatCard(
                        label: 'Effort',
                        value: workout.effortLevel.displayName,
                        color: Color(workout.effortLevel.colorValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Description
                  if (workout.description != null) ...[
                    Text('Workout Overview', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(workout.description!, style: AppTextStyles.body),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Coaching tip
                  if (workout.coachingTip != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.tips_and_updates,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Coach\'s Tip', style: AppTextStyles.heading3),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(workout.coachingTip!, style: AppTextStyles.body),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // No Claude data fallback
                  if (workout.description == null && workout.coachingTip == null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.onSurfaceMuted, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add your Claude API key in Settings to unlock AI coaching descriptions.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  EffortBadge(effort: workout.effortLevel),
                  // Stretching routines (not for rest days)
                  if (workout.type != WorkoutType.rest) ...[
                    const SizedBox(height: 32),
                    Text('Stretching Routines', style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(
                      'Warm up before and cool down after your run.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StretchButton(
                            label: 'Pre-Run\nWarm-Up',
                            icon: Icons.local_fire_department,
                            color: AppColors.primary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const StretchingScreen(isPreRun: true),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StretchButton(
                            label: 'Post-Run\nCool-Down',
                            icon: Icons.spa,
                            color: AppColors.secondary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const StretchingScreen(isPreRun: false),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StretchButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StretchButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceMuted,
              fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            )),
          ],
        ),
      ),
    );
  }
}
