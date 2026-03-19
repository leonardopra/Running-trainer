import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/stretch_data.dart';
import '../widgets/stretch_exercise_card.dart';

class StretchingScreen extends StatelessWidget {
  final bool isPreRun;

  const StretchingScreen({super.key, required this.isPreRun});

  @override
  Widget build(BuildContext context) {
    final exercises = isPreRun ? preRunRoutine : postRunRoutine;
    final title = isPreRun ? 'Pre-Run Warm-Up' : 'Post-Run Cool-Down';
    final accentColor = isPreRun ? AppColors.primary : AppColors.secondary;
    final summaryText = isPreRun
        ? '~8 min  •  Activates muscles & prevents injury'
        : '~12 min  •  Speeds recovery & reduces soreness';
    final summaryIcon = isPreRun ? Icons.local_fire_department : Icons.spa;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(title, style: AppTextStyles.heading3),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: accentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(summaryIcon, color: accentColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPreRun ? 'Dynamic Warm-Up' : 'Static Cool-Down',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(summaryText,
                                  style: AppTextStyles.bodyMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
                    child: Text(
                      'Tap any exercise to see instructions and a tutorial.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  // Exercise list
                  ...exercises.map(
                    (e) => StretchExerciseCard(
                      exercise: e,
                      isPreRun: isPreRun,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
