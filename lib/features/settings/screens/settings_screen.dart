import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:running_trainer_app/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _apiKeyController;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _nameController = TextEditingController(text: settings.name ?? '');
    _ageController = TextEditingController(
        text: settings.age != null ? settings.age.toString() : '');
    _weightController = TextEditingController(
        text: settings.weightKg != null ? settings.weightKg!.toStringAsFixed(0) : '');
    _heightController = TextEditingController(
        text: settings.heightCm != null ? settings.heightCm!.toStringAsFixed(0) : '');
    _apiKeyController = TextEditingController(text: settings.claudeApiKey ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final age = int.tryParse(_ageController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    ref.read(settingsProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      age: (age != null && age > 0 && age < 120) ? age : null,
      weightKg: (weight != null && weight > 0) ? weight : null,
      heightCm: (height != null && height > 0) ? height : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.settingsTitle, style: AppTextStyles.heading3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Profile ──────────────────────────────────────────────────────
          Text(l10n.settingsProfileSection, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(l10n.settingsProfileDesc, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: l10n.settingsFormName,
            hint: l10n.settingsFormNameHint,
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageController,
                  label: l10n.settingsFormAge,
                  hint: l10n.settingsFormAgeHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _saveProfile(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: l10n.settingsFormWeight,
                  hint: l10n.settingsFormWeightHint,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _saveProfile(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _heightController,
            label: l10n.settingsFormHeight,
            hint: l10n.settingsFormHeightHint,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 8),
          Text(l10n.settingsPrivacy, style: AppTextStyles.caption),
          const SizedBox(height: 32),

          // ── AI Coaching ───────────────────────────────────────────────────
          Text(l10n.settingsAISection, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(l10n.settingsAIDesc, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: l10n.settingsAIKeyHint,
              hintStyle: AppTextStyles.bodyMuted,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.onSurfaceMuted,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setApiKey(value);
            },
          ),
          const SizedBox(height: 32),

          // ── Units ─────────────────────────────────────────────────────────
          Text(l10n.settingsUnitsSection, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: Text(l10n.settingsUseKm, style: AppTextStyles.body)),
                Switch(
                  value: settings.useKilometers,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).setUseKilometers(value);
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Notifications ─────────────────────────────────────────────────
          Text(l10n.settingsNotificationsSection, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          if (kIsWeb)
            Text(l10n.settingsNotificationsWebMsg, style: AppTextStyles.bodyMuted)
          else ...[
            Text(l10n.settingsNotificationsDesc, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(l10n.settingsWorkoutReminders, style: AppTextStyles.body),
                      ),
                      Switch(
                        value: settings.notificationsEnabled,
                        onChanged: (value) async {
                          if (value) {
                            await NotificationService.requestPermissions();
                          }
                          await ref
                              .read(settingsProvider.notifier)
                              .setNotifications(enabled: value);
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (settings.notificationsEnabled) ...[
                    const Divider(color: AppColors.surfaceVariant, height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.settingsReminderTime, style: AppTextStyles.body),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: settings.notificationHour,
                                minute: settings.notificationMinute,
                              ),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.primary,
                                    surface: AppColors.surfaceVariant,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              await ref
                                  .read(settingsProvider.notifier)
                                  .setNotifications(
                                    enabled: true,
                                    hour: picked.hour,
                                    minute: picked.minute,
                                  );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.35)),
                            ),
                            child: Text(
                              TimeOfDay(
                                hour: settings.notificationHour,
                                minute: settings.notificationMinute,
                              ).format(context),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),

          // ── Language ──────────────────────────────────────────────────────
          Text(l10n.settingsLanguageSection, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          _LanguagePicker(
            currentCode: settings.localeCode,
            onChanged: (code) =>
                ref.read(settingsProvider.notifier).setLocale(code),
          ),
          const SizedBox(height: 32),

          // ── Data ──────────────────────────────────────────────────────────
          Text(l10n.settingsDataSection, style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => _showResetDialog(context, l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.settingsResetAll),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.body,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMuted,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.settingsResetDialogTitle, style: AppTextStyles.heading3),
        content: Text(l10n.settingsResetDialogBody, style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.btnCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(settingsProvider.notifier).resetAll();
              if (mounted) context.go('/onboarding/goal');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.btnReset),
          ),
        ],
      ),
    );
  }
}

// ── Language picker ────────────────────────────────────────────────────────

class _LanguagePicker extends StatelessWidget {
  final String currentCode;
  final ValueChanged<String> onChanged;

  const _LanguagePicker({
    required this.currentCode,
    required this.onChanged,
  });

  static const _languages = [
    ('en', '🇬🇧', 'English'),
    ('it', '🇮🇹', 'Italiano'),
    ('de', '🇩🇪', 'Deutsch'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _languages.map((lang) {
          final (code, flag, name) = lang;
          final isSelected = code == currentCode;
          final isLast = lang == _languages.last;

          return Column(
            children: [
              InkWell(
                onTap: () => onChanged(code),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Text(flag, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  color: AppColors.surfaceVariant,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
