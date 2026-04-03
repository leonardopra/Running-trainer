# Android App

Target:
- Kotlin
- Jetpack Compose
- Room for plans
- DataStore or EncryptedSharedPreferences for user settings
- WorkManager for reminder scheduling

Current status:
- Gradle/Compose scaffold added
- Kotlin domain models and plan generator ported
- fixture-driven JVM tests added against `product-spec/fixtures`
- Room and DataStore persistence added for active plan plus local settings
- onboarding now reaches real local plan generation
- home now loads the persisted plan from Android storage

Implementation order:
1. DTOs and contract models
2. local storage
3. onboarding
4. local plan generation
5. plan overview and workout detail
6. workout logging
7. settings
8. pace calculator
9. insights
10. notifications
11. AI enrichment

Rules:
- native Android becomes the pilot implementation for the migration
- all rule-engine parity is validated against `product-spec/fixtures`
- no backend dependency for generating a basic plan

Open next steps:
- port workout logging, progress, settings, and pace modules
- add race-date and duration choice to fully match Flutter onboarding
- replace enum-name placeholders with polished copy and localization
- replace the temporary home screen with actual product surfaces
