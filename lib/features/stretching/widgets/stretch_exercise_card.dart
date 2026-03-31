import 'package:flutter/material.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/stretch_exercise.dart';

class StretchExerciseCard extends StatefulWidget {
  final StretchExercise exercise;
  final bool isPreRun;

  const StretchExerciseCard({
    super.key,
    required this.exercise,
    required this.isPreRun,
  });

  @override
  State<StretchExerciseCard> createState() => _StretchExerciseCardState();
}

class _StretchExerciseCardState extends State<StretchExerciseCard> {
  bool _expanded = false;

  Color get _accentColor =>
      widget.isPreRun ? AppColors.primary : AppColors.secondary;

  Future<void> _openTutorial() async {
    final query = Uri.encodeComponent(widget.exercise.youtubeQuery);
    final url = Uri.parse('https://www.youtube.com/results?search_query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _expanded
                  ? _accentColor.withValues(alpha:0.4)
                  : AppColors.surfaceVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.exercise.icon,
                        color: _accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.exercise.name,
                            style: AppTextStyles.heading3),
                        const SizedBox(height: 2),
                        Text(widget.exercise.durationLabel,
                            style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.onSurfaceMuted, size: 20),
                  ),
                ],
              ),
              // Muscle group chips
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.exercise.muscleGroups
                    .map((m) => _MuscleChip(label: m, color: _accentColor))
                    .toList(),
              ),
              // Expanded content
              if (_expanded) ...[
                const SizedBox(height: 14),
                const Divider(color: AppColors.surfaceVariant, height: 1),
                const SizedBox(height: 14),
                Text(widget.exercise.description, style: AppTextStyles.body),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openTutorial,
                    icon: const Icon(Icons.play_circle_outline, size: 18),
                    label: Text(AppLocalizations.of(context)!.stretchWatchTutorial),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accentColor,
                      side: BorderSide(color: _accentColor.withValues(alpha:0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MuscleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha:0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
