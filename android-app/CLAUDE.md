# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
./gradlew assembleDebug                                          # Build debug APK
./gradlew test                                                   # Run all JVM unit tests
./gradlew :app:testDebugUnitTest --tests "*.PlanGeneratorFixtureTest"  # Run a single test class
./gradlew connectedAndroidTest                                   # Run instrumented tests (requires device/emulator)
./gradlew lint                                                   # Run lint checks
```

> Minimum SDK 26, target SDK 35, Java 17, Kotlin 2.0.21, Compose BOM 2024.09.03.

## Architecture

**Single-activity, single-ViewModel.** `MainViewModel` holds the entire app state (`MainUiState`) as a single `StateFlow`, combining flows from repositories with in-memory onboarding form state. Navigation is driven by `currentDestination: MutableStateFlow<AppDestination>` — there is no Jetpack Navigation back stack; all screen transitions are ViewModel-controlled.

**Dependency injection:** Manual DI via `AppContainer` (created in `RunningTrainerApplication`). No Hilt/Koin. `MainViewModel` is wired via `ViewModelProvider.Factory` in `MainActivity`.

**Package layout:**
- `domain/model/` — pure Kotlin data models (`TrainingPlan`, `Workout`, enums, `UserPreferencesDto`)
- `domain/contracts/` — request/result types for plan generation (`PlanGenerationRequest`, `PlanGenerationResult`)
- `domain/service/` — pure business logic: `PlanGenerator`, `InsightsService`, `PaceCalculatorService`, `ProgressStatsCalculator`
- `data/local/` — Room (`AppDatabase`, `TrainingPlanEntity`, `TrainingPlanDao`) + DataStore (`LocalSettingsStore`)
- `data/repository/` — repository interfaces + `LocalTrainingPlanRepository`, `LocalSettingsRepository`
- `data/serialization/` — `@Serializable` mirror models used for JSON storage in Room (`payloadJson` column)
- `ui/screens/` — one Composable file per screen, all receiving `MainUiState` + lambdas
- `ui/navigation/` — `AppDestination` enum only

**Persistence:**
- `TrainingPlan` is stored as a single JSON blob (`payloadJson`) in a Room `training_plans` table. Only the active plan is used; `LocalTrainingPlanRepository` queries the most recent row.
- User preferences are stored via DataStore (unencrypted `preferences_pb`). The Claude API key is stored here in plaintext — no keychain.

**Plan generation** mirrors the Flutter rule engine:
- `PlanGenerator.generatePlan(PlanGenerationRequest)` is pure/deterministic (no coroutines, no I/O).
- Age-aware progression: under-50 = +9%/week, every 4th week recovery; 50+ = +7%/week, every 3rd week recovery.
- 3-week taper for race goals.
- AI enrichment is not yet implemented in this app (Claude API key is stored but unused).

**Tests** are JVM-only (no Robolectric). `PlanGeneratorFixtureTest` loads JSON fixtures from `product-spec/fixtures/` (relative path from the test classpath root) and validates plan output against expected snapshots. Add fixture files there when adding new plan generation test cases.

## Key constraints

- This is the **native Android pilot** for migrating away from Flutter. All rule-engine behavior must remain in parity with `product-spec/fixtures` — fixture tests are the contract.
- Do not add a DI framework; keep `AppContainer` as the composition root.
- Room stores the plan as a JSON blob (not normalized rows) — this is intentional to keep schema migrations simple during the pilot phase.
