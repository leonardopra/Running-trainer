import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
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
    final allPlans = ref.watch(allPlansProvider);
    final selectedId = ref.watch(selectedPlanIdProvider);
    final l10n = AppLocalizations.of(context)!;

    if (plan == null) {
      return const Scaffold(
        body: Center(child: Text('No plan found', style: AppTextStyles.body)),
      );
    }

    // The effective selected ID: explicit selection or the last plan's id
    final effectiveId = selectedId ?? plan.id;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            automaticallyImplyLeading: false,
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

          // ── Plan switcher (only when multiple plans exist) ──────────────
          if (allPlans.length > 1)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(l10n.planYourPlans, style: AppTextStyles.label),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      children: allPlans.reversed.map((p) {
                        final isSelected = p.id == effectiveId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(selectedPlanIdProvider.notifier)
                                  .state = p.id;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.goalType.displayName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${p.totalWeeks}w · ${p.fitnessLevel.displayName}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.8)
                                          : AppColors.onSurfaceMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(
                      height: 1, color: AppColors.surfaceVariant, indent: 20),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          // ── Week list ──────────────────────────────────────────────────
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
