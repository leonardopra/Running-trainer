import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
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
      context.go('/home');
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
    final l10n = AppLocalizations.of(context)!;

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
                _getStatusText(state, l10n),
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getSubtitleText(state, l10n),
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
                  l10n.generatingWeekOf(state.enrichedWeeks, state.totalWeeks),
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(GenerationState state, AppLocalizations l10n) {
    switch (state.step) {
      case GenerationStep.generating: return l10n.generatingTitle;
      case GenerationStep.enriching:  return l10n.generatingAITitle;
      case GenerationStep.done:       return l10n.generatingDoneTitle;
      case GenerationStep.error:      return l10n.generatingErrorTitle;
      case GenerationStep.idle:       return l10n.generatingIdleTitle;
    }
  }

  String _getSubtitleText(GenerationState state, AppLocalizations l10n) {
    switch (state.step) {
      case GenerationStep.generating: return l10n.generatingSubtitle;
      case GenerationStep.enriching:  return l10n.generatingAISubtitle;
      case GenerationStep.done:       return l10n.generatingDoneSubtitle;
      case GenerationStep.error:      return state.errorMessage ?? l10n.generatingErrorFallback;
      case GenerationStep.idle:       return l10n.generatingIdleSubtitle;
    }
  }
}
