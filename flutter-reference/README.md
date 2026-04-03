# Flutter Reference

The Flutter application at the repository root remains the current golden reference during the migration to native platform-specific apps.

Why this folder exists:
- it marks Flutter as an intentional reference product, not accidental legacy
- it documents that the root app is still the source of truth for current behavior
- it avoids a risky physical move of the existing Flutter project during the first migration phase

Current rule:
- all parity checks for `android-app`, `web-app`, and `ios-app` should be validated against the behavior implemented in the root Flutter app

Reference areas to preserve:
- onboarding redirect flow
- plan generation rules
- week enrichment fallback behavior
- workout logging semantics
- progress statistics
- settings persistence
- notification scheduling behavior
- localized product copy
