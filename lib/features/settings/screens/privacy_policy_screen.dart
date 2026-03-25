import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(l10n.settingsPrivacyPolicy, style: AppTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.background,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: _PrivacyContent(),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Section(
          title: 'Data Storage',
          body:
              'Running Trainer stores all your data locally on your device. '
              'Training plans, workout logs, and personal profile information '
              'never leave your device unless you explicitly share them.',
        ),
        _Section(
          title: 'Encrypted Data',
          body:
              'Your profile data (name, age, weight, height) is encrypted '
              'using AES-256 encryption. The encryption key is stored in your '
              'device\'s secure keychain and is never transmitted anywhere.',
        ),
        _Section(
          title: 'Claude AI (Optional)',
          body:
              'If you provide a Claude API key, workout data is sent to '
              'Anthropic\'s API to generate coaching descriptions and post-workout '
              'feedback. This is entirely optional — the app works fully offline '
              'without an API key. Your API key is encrypted and stored locally. '
              'Refer to Anthropic\'s privacy policy for how they handle API data.',
        ),
        _Section(
          title: 'No Accounts or Tracking',
          body:
              'Running Trainer requires no account, login, or registration. '
              'No analytics, crash reporting, or usage tracking is collected. '
              'No third-party SDKs with tracking capabilities are included.',
        ),
        _Section(
          title: 'Notifications',
          body:
              'Workout reminders are scheduled locally on your device. '
              'No notification data is sent to external servers.',
        ),
        _Section(
          title: 'Data Deletion',
          body:
              'You can delete all app data at any time via Settings → Reset All Data. '
              'Uninstalling the app removes all locally stored data.',
        ),
        const SizedBox(height: 8),
        Text(
          'Last updated: March 2026',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
