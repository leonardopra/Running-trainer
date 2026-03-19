import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings', style: AppTextStyles.heading3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile section
          Text('Profile', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Your name and physical data help personalise your plan.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Name',
            hint: 'e.g. Alex',
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  hint: 'e.g. 32',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _saveProfile(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  hint: 'e.g. 70',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _saveProfile(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'e.g. 175',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _saveProfile(),
          ),
          const SizedBox(height: 8),
          Text(
            'All profile data is encrypted and stored only on this device.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 32),
          // AI Coaching section
          Text('AI Coaching', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Enter your Claude API key to unlock AI-generated workout descriptions.',
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscureKey,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'sk-ant-...',
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
          // Units section
          Text('Units', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Use Kilometers', style: AppTextStyles.body),
                ),
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
          // Notifications section
          Text('Notifications', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          if (kIsWeb)
            Text(
              'Workout reminders are available on the Android app.',
              style: AppTextStyles.bodyMuted,
            )
          else ...[
            Text(
              'Get a reminder at your chosen time on each training day.',
              style: AppTextStyles.bodyMuted,
            ),
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
                      const Expanded(
                        child: Text('Workout Reminders',
                            style: AppTextStyles.body),
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
                        const Expanded(
                          child: Text('Reminder time',
                              style: AppTextStyles.body),
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
          // Data section
          Text('Data', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => _showResetDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reset All Data'),
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

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reset All Data', style: AppTextStyles.heading3),
        content: const Text(
          'This will delete your training plan, profile, and all progress. This cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(settingsProvider.notifier).resetAll();
              if (mounted) context.go('/onboarding/goal');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
