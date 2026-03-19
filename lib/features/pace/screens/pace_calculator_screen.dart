import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/enums.dart';
import '../../../providers/storage_provider.dart';
import '../../../services/pace_calculator_service.dart';

class PaceCalculatorScreen extends ConsumerStatefulWidget {
  const PaceCalculatorScreen({super.key});

  @override
  ConsumerState<PaceCalculatorScreen> createState() =>
      _PaceCalculatorScreenState();
}

class _PaceCalculatorScreenState extends ConsumerState<PaceCalculatorScreen> {
  final _hCtrl = TextEditingController();
  final _mCtrl = TextEditingController();
  final _sCtrl = TextEditingController();

  GoalType _goalType = GoalType.tenK;
  List<PaceZone> _zones = [];

  @override
  void initState() {
    super.initState();
    // Pre-select the goal from the active plan
    final plan = ref.read(storageServiceProvider).getActivePlan();
    if (plan != null) _goalType = plan.goalType;
    _hCtrl.addListener(_recalculate);
    _mCtrl.addListener(_recalculate);
    _sCtrl.addListener(_recalculate);
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _mCtrl.dispose();
    _sCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    final h = int.tryParse(_hCtrl.text) ?? 0;
    final m = int.tryParse(_mCtrl.text) ?? 0;
    final s = int.tryParse(_sCtrl.text) ?? 0;
    final total = h * 3600 + m * 60 + s;
    setState(() {
      _zones = PaceCalculatorService.calculate(
        goal: _goalType,
        goalTimeSeconds: total,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final distKm = PaceCalculatorService.distanceKm(_goalType);
    final distLabel = distKm == distKm.truncateToDouble()
        ? '${distKm.toInt()} km'
        : '${distKm.toStringAsFixed(1)} km';

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
            title: Text('Pace Zones', style: AppTextStyles.heading3),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Goal distance selector ──────────────────────────────
                  Text('Race Distance', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: GoalType.values.map((g) {
                        final selected = g == _goalType;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _goalType = g);
                              _recalculate();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withOpacity(0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                ),
                              ),
                              child: Text(
                                g.displayName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.onSurfaceMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Goal time input ─────────────────────────────────────
                  Text('Goal Time', style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your target finish time for $distLabel.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _TimeField(
                          ctrl: _hCtrl, label: 'h', maxVal: 9),
                      const _TimeSep(),
                      _TimeField(
                          ctrl: _mCtrl, label: 'min', maxVal: 59),
                      const _TimeSep(),
                      _TimeField(
                          ctrl: _sCtrl, label: 'sec', maxVal: 59),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Zones ───────────────────────────────────────────────
                  if (_zones.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              color: AppColors.onSurfaceMuted, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enter your goal time above to see your training pace zones.',
                              style: AppTextStyles.bodyMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text('Training Zones', style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(
                      'Based on ${_goalType.displayName} goal · $distLabel',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 14),
                    ..._zones.map((z) => _PaceZoneCard(zone: z)),
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

// ── Time input field ───────────────────────────────────────────────────────
class _TimeField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final int maxVal;

  const _TimeField(
      {required this.ctrl, required this.label, required this.maxVal});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          TextField(
            controller: ctrl,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '00',
              hintStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceMuted,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxValueFormatter(maxVal),
            ],
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceMuted)),
        ],
      ),
    );
  }
}

class _TimeSep extends StatelessWidget {
  const _TimeSep();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 22, left: 6, right: 6),
      child: Text(':',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceMuted)),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  const _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    if (next.text.isEmpty) return next;
    final val = int.tryParse(next.text);
    if (val == null || val > max) return old;
    return next;
  }
}

// ── Pace zone card ─────────────────────────────────────────────────────────
class _PaceZoneCard extends StatefulWidget {
  final PaceZone zone;
  const _PaceZoneCard({required this.zone});

  @override
  State<_PaceZoneCard> createState() => _PaceZoneCardState();
}

class _PaceZoneCardState extends State<_PaceZoneCard> {
  bool _expanded = false;

  Color get _color {
    switch (widget.zone.type) {
      case WorkoutType.easyRun:    return AppColors.easyRun;
      case WorkoutType.tempoRun:   return AppColors.tempoRun;
      case WorkoutType.intervalRun: return AppColors.intervalRun;
      case WorkoutType.longRun:    return AppColors.longRun;
      default:                     return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _expanded
                  ? color.withOpacity(0.5)
                  : AppColors.surfaceVariant,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Color bar
                    Container(
                      width: 4,
                      height: 40,
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
                          Text(widget.zone.label,
                              style: AppTextStyles.label),
                          const SizedBox(height: 2),
                          Text(widget.zone.paceRange,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: color,
                              )),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              if (_expanded)
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(34, 0, 16, 16),
                  child: Text(widget.zone.description,
                      style: AppTextStyles.bodyMuted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
