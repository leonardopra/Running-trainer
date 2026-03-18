import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/plan_generation_provider.dart';

class PlanGeneratingScreen extends ConsumerStatefulWidget {
  const PlanGeneratingScreen({super.key});

  @override
  ConsumerState<PlanGeneratingScreen> createState() => _PlanGeneratingScreenState();
}

class _PlanGeneratingScreenState extends ConsumerState<PlanGeneratingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start generation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGeneration());
  }

  Future<void> _startGeneration() async {
    final plan = await ref.read(generationProvider.notifier).generatePlan();
    if (mounted && plan != null) {
      context.go('/plan');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(generationProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: AppColors.primary,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _getStatusText(state),
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getSubtitleText(state),
                style: AppTextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
              if (state.step == GenerationStep.enriching) ...[
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Week ${state.enrichedWeeks} of ${state.totalWeeks}',
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(GenerationState state) {
    switch (state.step) {
      case GenerationStep.generating:
        return 'Building your plan...';
      case GenerationStep.enriching:
        return 'Adding AI coaching...';
      case GenerationStep.done:
        return 'Plan ready!';
      case GenerationStep.error:
        return 'Something went wrong';
      case GenerationStep.idle:
        return 'Preparing...';
    }
  }

  String _getSubtitleText(GenerationState state) {
    switch (state.step) {
      case GenerationStep.generating:
        return 'Calculating your training schedule';
      case GenerationStep.enriching:
        return 'Claude is writing your workout descriptions';
      case GenerationStep.done:
        return 'Redirecting to your plan...';
      case GenerationStep.error:
        return state.errorMessage ?? 'Please try again';
      case GenerationStep.idle:
        return 'Getting things ready';
    }
  }
}
