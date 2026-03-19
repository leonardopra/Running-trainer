import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import '../widgets/effort_badge.dart';
import '../../stretching/screens/stretching_screen.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  final _distanceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final w = widget.workout;
    if (w.actualDistanceKm != null) {
      _distanceCtrl.text = w.actualDistanceKm!.toStringAsFixed(1);
    }
    if (w.actualDurationMinutes != null) {
      _durationCtrl.text = w.actualDurationMinutes.toString();
    }
    if (w.notes != null) {
      _notesCtrl.text = w.notes!;
    }
  }

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveLog() async {
    setState(() => _saving = true);
    final w = widget.workout;
    final dist = double.tryParse(_distanceCtrl.text.trim());
    final dur  = int.tryParse(_durationCtrl.text.trim());
    w.actualDistanceKm      = dist;
    w.actualDurationMinutes = dur;
    w.notes                 = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    w.isCompleted           = true;
    w.completedAt           ??= DateTime.now();
    await w.save();
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout logged!'),
          backgroundColor: AppColors.secondary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _unmarkComplete() async {
    final w = widget.workout;
    w.isCompleted           = false;
    w.completedAt           = null;
    w.actualDistanceKm      = null;
    w.actualDurationMinutes = null;
    w.notes                 = null;
    _distanceCtrl.clear();
    _durationCtrl.clear();
    _notesCtrl.clear();
    await w.save();
    setState(() {});
  }

  Color _getTypeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun:    return AppColors.easyRun;
      case WorkoutType.tempoRun:   return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun:    return AppColors.longRun;
      case WorkoutType.crossTrain: return AppColors.crossTrain;
      case WorkoutType.rest:       return AppColors.rest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.workout;
    final typeColor = _getTypeColor(w.type);
    final isRest = w.type == WorkoutType.rest;

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
            title: Text(w.type.displayName, style: AppTextStyles.heading3),
            actions: [
              if (w.isCompleted)
                IconButton(
                  icon: const Icon(Icons.check_circle, color: AppColors.secondary),
                  tooltip: 'Mark as not done',
                  onPressed: _unmarkComplete,
                ),
            ],
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
                      if (w.distanceKm != null) ...[
                        _StatCard(
                          label: 'Distance',
                          value: '${w.distanceKm!.toStringAsFixed(1)} km',
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (w.durationMinutes != null) ...[
                        _StatCard(
                          label: 'Duration',
                          value: '${w.durationMinutes} min',
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                      ],
                      _StatCard(
                        label: 'Effort',
                        value: w.effortLevel.displayName,
                        color: Color(w.effortLevel.colorValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description
                  if (w.description != null) ...[
                    Text('Workout Overview', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(w.description!, style: AppTextStyles.body),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Coaching tip
                  if (w.coachingTip != null) ...[
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
                      child: Text(w.coachingTip!, style: AppTextStyles.body),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // No Claude data fallback
                  if (w.description == null && w.coachingTip == null) ...[
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

                  EffortBadge(effort: w.effortLevel),

                  // ── Log This Run ────────────────────────────────────────
                  if (!isRest) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text('Log This Run', style: AppTextStyles.heading3),
                        const SizedBox(width: 8),
                        if (w.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Completed',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                )),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record your actual distance, time, and notes.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: w.isCompleted
                              ? AppColors.secondary.withOpacity(0.35)
                              : AppColors.surfaceVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _LogField(
                                  controller: _distanceCtrl,
                                  label: 'Distance (km)',
                                  hint: w.distanceKm != null
                                      ? w.distanceKm!.toStringAsFixed(1)
                                      : '0.0',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LogField(
                                  controller: _durationCtrl,
                                  label: 'Duration (min)',
                                  hint: w.durationMinutes?.toString() ?? '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _LogField(
                            controller: _notesCtrl,
                            label: 'Notes (optional)',
                            hint: 'How did it feel?',
                            maxLines: 2,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _saveLog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      height: 18, width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.background))
                                  : Text(
                                      w.isCompleted ? 'Update Log' : 'Mark as Done',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Stretching Routines ─────────────────────────────────
                  if (!isRest) ...[
                    const SizedBox(height: 8),
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

// ── Widgets ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

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

class _LogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;

  const _LogField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceMuted,
        )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.onSurfaceMuted),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
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
