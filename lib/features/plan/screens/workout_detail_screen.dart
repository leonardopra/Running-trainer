import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/l10n_helpers.dart';
import '../../../models/workout.dart';
import '../../../models/enums.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/training_plan_provider.dart';
import '../../../services/claude_service.dart';
import '../../../services/pace_calculator_service.dart';
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
  int? _rpe;
  WorkoutFeeling? _feeling;
  String? _postWorkoutCoaching;
  bool _loadingCoaching = false;
  bool _coachingError = false;

  bool get _useKm => ref.read(settingsProvider).useKilometers;

  @override
  void initState() {
    super.initState();
    final w = widget.workout;
    if (w.actualDistanceKm != null) {
      final val = _useKm
          ? w.actualDistanceKm!
          : w.actualDistanceKm! * 0.621371;
      _distanceCtrl.text = val.toStringAsFixed(2);
    }
    if (w.actualDurationMinutes != null) {
      _durationCtrl.text = w.actualDurationMinutes.toString();
    }
    if (w.notes != null) {
      _notesCtrl.text = w.notes!;
    }
    _rpe = w.rpe;
    _feeling = w.feeling;
    _postWorkoutCoaching = w.postWorkoutCoaching;
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
    final rawDist = double.tryParse(_distanceCtrl.text.trim());
    final dur  = int.tryParse(_durationCtrl.text.trim());
    w.actualDistanceKm = rawDist == null
        ? null
        : (_useKm ? rawDist : rawDist / 0.621371);
    w.actualDurationMinutes = dur;
    w.notes                 = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();
    w.rpe                   = _rpe;
    w.feeling               = _feeling;
    w.isCompleted           = true;
    w.completedAt           ??= DateTime.now();
    await w.save();
    ref.invalidate(activePlanProvider);
    setState(() => _saving = false);
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.workoutLoggedSnackbar),
          backgroundColor: AppColors.secondary,
          duration: const Duration(seconds: 2),
        ),
      );
      if (w.rpe != null || w.feeling != null) {
        _fetchCoaching();
      }
    }
  }

  Future<void> _fetchCoaching() async {
    final apiKey = ref.read(settingsProvider).claudeApiKey;
    if (apiKey == null || apiKey.isEmpty) return;
    final w = widget.workout;
    setState(() { _loadingCoaching = true; _coachingError = false; });
    final settings = ref.read(settingsProvider);
    final coaching = await ClaudeService().generatePostWorkoutCoaching(
      workout: w,
      apiKey: apiKey,
      rpe: w.rpe,
      feeling: w.feeling,
      actualDistanceKm: w.actualDistanceKm,
      actualDurationMinutes: w.actualDurationMinutes,
      notes: w.notes,
      age: settings.age,
    );
    if (!mounted) return;
    if (coaching != null) {
      w.postWorkoutCoaching = coaching;
      await w.save();
      setState(() { _postWorkoutCoaching = coaching; _loadingCoaching = false; });
    } else {
      setState(() { _coachingError = true; _loadingCoaching = false; });
    }
  }

  Future<void> _unmarkComplete() async {
    final w = widget.workout;
    w.isCompleted           = false;
    w.completedAt           = null;
    w.actualDistanceKm      = null;
    w.actualDurationMinutes = null;
    w.notes                 = null;
    w.rpe                   = null;
    w.feeling               = null;
    w.postWorkoutCoaching   = null;
    _distanceCtrl.clear();
    _durationCtrl.clear();
    _notesCtrl.clear();
    await w.save();
    ref.invalidate(activePlanProvider);
    setState(() {
      _rpe = null;
      _feeling = null;
      _postWorkoutCoaching = null;
      _coachingError = false;
    });
  }

  Widget _buildCoachFeedbackCard(
      Workout w, AppLocalizations l10n, String? apiKey) {
    Widget content;

    if (apiKey == null || apiKey.isEmpty) {
      content = Row(
        children: [
          const Icon(Icons.lock_outline,
              color: AppColors.onSurfaceMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l10n.workoutCoachFeedbackNoKey,
                style: AppTextStyles.bodyMuted),
          ),
        ],
      );
    } else if (_loadingCoaching) {
      content = Row(
        children: [
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)),
          const SizedBox(width: 10),
          Text(l10n.workoutCoachFeedbackLoading, style: AppTextStyles.bodyMuted),
        ],
      );
    } else if (_postWorkoutCoaching != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_postWorkoutCoaching!, style: AppTextStyles.body),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _fetchCoaching,
            child: Text(l10n.workoutCoachFeedbackRefresh,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      );
    } else if (_coachingError) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.workoutCoachFeedbackError, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _fetchCoaching,
            child: Text(l10n.workoutCoachFeedbackRefresh,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      );
    } else {
      content = Row(
        children: [
          const Icon(Icons.psychology_outlined,
              color: AppColors.onSurfaceMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l10n.workoutCoachFeedbackHint,
                style: AppTextStyles.bodyMuted),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(l10n.workoutCoachFeedback,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  String _feelingEmoji(WorkoutFeeling f) {
    switch (f) {
      case WorkoutFeeling.great:   return '😄';
      case WorkoutFeeling.good:    return '🙂';
      case WorkoutFeeling.ok:      return '😐';
      case WorkoutFeeling.tired:   return '😴';
      case WorkoutFeeling.injured: return '🤕';
    }
  }

  String _feelingLabel(WorkoutFeeling f, AppLocalizations l10n) {
    switch (f) {
      case WorkoutFeeling.great:   return l10n.feelingGreat;
      case WorkoutFeeling.good:    return l10n.feelingGood;
      case WorkoutFeeling.ok:      return l10n.feelingOk;
      case WorkoutFeeling.tired:   return l10n.feelingTired;
      case WorkoutFeeling.injured: return l10n.feelingInjured;
    }
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
    final l10n = AppLocalizations.of(context)!;
    final distUnit = _useKm ? 'km' : 'mi';

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
            title: Text(w.type.localizedName(l10n), style: AppTextStyles.heading3),
            actions: [
              if (w.isCompleted)
                IconButton(
                  icon: const Icon(Icons.check_circle, color: AppColors.secondary),
                  tooltip: l10n.btnMarkNotDoneTooltip,
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
                          label: l10n.workoutStatDistance,
                          value: _useKm
                              ? '${w.distanceKm!.toStringAsFixed(1)} km'
                              : '${(w.distanceKm! * 0.621371).toStringAsFixed(1)} mi',
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (w.durationMinutes != null) ...[
                        _StatCard(
                          label: l10n.workoutStatDuration,
                          value: '${w.durationMinutes} min',
                          color: typeColor,
                        ),
                        const SizedBox(width: 12),
                      ],
                      _StatCard(
                        label: l10n.workoutStatEffort,
                        value: w.effortLevel.localizedName(l10n),
                        color: Color(w.effortLevel.colorValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description
                  if (w.description != null) ...[
                    Text(l10n.workoutOverview, style: AppTextStyles.heading3),
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
                        Text(l10n.workoutCoachTip, style: AppTextStyles.heading3),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha:0.3),
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
                            child: Text(l10n.workoutNoAI, style: AppTextStyles.bodyMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Target Pace ─────────────────────────────────────────
                  if (!isRest) _TargetPaceSection(workout: w),

                  EffortBadge(effort: w.effortLevel),

                  // ── Log This Run ────────────────────────────────────────
                  if (!isRest) ...[
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Text(l10n.workoutLogTitle, style: AppTextStyles.heading3),
                        const SizedBox(width: 8),
                        if (w.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(l10n.workoutLogCompleted,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                )),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.workoutLogDesc, style: AppTextStyles.bodyMuted),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: w.isCompleted
                              ? AppColors.secondary.withValues(alpha:0.35)
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
                                  label: '${l10n.workoutLogDistance.replaceAll('(km)', '')} ($distUnit)',
                                  hint: w.distanceKm != null
                                      ? (_useKm
                                          ? w.distanceKm!.toStringAsFixed(1)
                                          : (w.distanceKm! * 0.621371).toStringAsFixed(1))
                                      : '0.0',
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _LogField(
                                  controller: _durationCtrl,
                                  label: l10n.workoutLogDuration,
                                  hint: w.durationMinutes?.toString() ?? '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _LogField(
                            controller: _notesCtrl,
                            label: l10n.workoutLogNotes,
                            hint: l10n.workoutLogNotesHint,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          // RPE Slider
                          Row(
                            children: [
                              Text(l10n.rpeLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurfaceMuted,
                                  )),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha:0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _rpe != null ? '${_rpe}' : '—',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            min: 1,
                            max: 10,
                            divisions: 9,
                            value: (_rpe ?? 5).toDouble(),
                            activeColor: AppColors.primary,
                            onChanged: (v) =>
                                setState(() => _rpe = v.round()),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(l10n.rpeEasy,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceMuted)),
                                Text(l10n.rpeMax,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceMuted)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Feeling Picker
                          Text(l10n.feelingLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceMuted,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: WorkoutFeeling.values.map((f) {
                              final selected = _feeling == f;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _feeling = selected ? null : f),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.secondary.withValues(alpha:0.2)
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.secondary
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _feelingEmoji(f),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _feelingLabel(f, l10n),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: selected
                                              ? AppColors.secondary
                                              : AppColors.onSurfaceMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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
                                      w.isCompleted ? l10n.btnUpdateLog : l10n.btnMarkDone,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCoachFeedbackCard(w, l10n,
                        ref.read(settingsProvider).claudeApiKey),
                    const SizedBox(height: 8),
                  ],

                  // ── Stretching Routines ─────────────────────────────────
                  if (!isRest) ...[
                    const SizedBox(height: 8),
                    Text(l10n.workoutStretchingRoutines, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(l10n.workoutStretchingDesc, style: AppTextStyles.bodyMuted),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StretchButton(
                            label: l10n.workoutPreRunBtn,
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
                            label: l10n.workoutPostRunBtn,
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

class _TargetPaceSection extends ConsumerWidget {
  final Workout workout;
  const _TargetPaceSection({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalTimeSecs = ref.watch(settingsProvider).goalTimeSeconds;
    final plan = ref.watch(activePlanProvider);

    if (goalTimeSecs == null || plan == null) return const SizedBox.shrink();

    // Only show for workout types that have a pace zone
    const paceTypes = {
      WorkoutType.easyRun,
      WorkoutType.longRun,
      WorkoutType.tempoRun,
      WorkoutType.intervalRun,
    };
    if (!paceTypes.contains(workout.type)) return const SizedBox.shrink();

    final zones = PaceCalculatorService.calculate(
      goal: plan.goalType,
      goalTimeSeconds: goalTimeSecs,
    );
    if (zones.isEmpty) return const SizedBox.shrink();

    final zone = zones.firstWhere(
      (z) => z.type == workout.type,
      orElse: () => zones.first,
    );

    final color = _typeColor(workout.type);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.speed, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(l10n.workoutTargetPace, style: AppTextStyles.heading3),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha:0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.paceRange,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.workoutTargetPaceSub(
                        plan.goalType.localizedName(l10n),
                        PaceCalculatorService.formatGoalTime(goalTimeSecs),
                      ),
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Color _typeColor(WorkoutType type) {
    switch (type) {
      case WorkoutType.easyRun:     return AppColors.easyRun;
      case WorkoutType.tempoRun:    return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun:     return AppColors.longRun;
      default:                      return AppColors.primary;
    }
  }
}

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
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.3)),
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
          color: color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.3)),
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
