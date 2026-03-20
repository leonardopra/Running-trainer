import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import '../../../providers/training_plan_provider.dart';
import '../widgets/week_card.dart';

class PlanOverviewScreen extends ConsumerWidget {
  const PlanOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(activePlanProvider);

    if (plan == null) {
      return const Scaffold(
        body: Center(child: Text('No plan found', style: AppTextStyles.body)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.goalType.displayName, style: AppTextStyles.heading3),
                Text(
                  '${plan.totalWeeks} weeks · ${plan.fitnessLevel.displayName}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final week = plan.weeks[index];
                return WeekCard(
                  week: week,
                  isExpanded: index == 0,
                  onWorkoutTap: (Workout workout) {
                    context.push('/plan/workout/${workout.id}', extra: workout);
                  },
                );
              },
              childCount: plan.weeks.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}
