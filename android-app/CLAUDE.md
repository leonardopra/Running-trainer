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

**`MainActivity` extends `AppCompatActivity`** (not `ComponentActivity`) — required so that `AppCompatDelegate.setApplicationLocales()` applies correctly on Android < 13 via the AppCompat `attachBaseContext()` path.

**Dependency injection:** Manual DI via `AppContainer` (created in `RunningTrainerApplication`). No Hilt/Koin. `MainViewModel` is wired via `ViewModelProvider.Factory` in `MainActivity`.

**Package layout:**
- `domain/model/` — pure Kotlin data models (`TrainingPlan`, `Workout`, enums, `UserPreferencesDto`)
- `domain/contracts/` — request/result types for plan generation (`PlanGenerationRequest`, `PlanGenerationResult`)
- `domain/service/` — pure business logic: `PlanGenerator`, `InsightsService`, `PaceCalculatorService`, `ProgressStatsCalculator`
- `data/local/` — Room (`AppDatabase`, `TrainingPlanEntity`, `TrainingPlanDao`) + DataStore (`LocalSettingsStore`)
- `data/repository/` — repository interfaces + `LocalTrainingPlanRepository`, `LocalSettingsRepository`
- `data/serialization/` — `@Serializable` mirror models used for JSON storage in Room (`payloadJson` column)
- `ui/screens/` — one Composable file per screen, all receiving `MainUiState` + lambdas. `HomeScreen.kt` also exports shared `@Composable` helpers used by other screens: `workoutTypeColor`, `WorkoutType.typeLabel()`, `WorkoutType.zoneDescription()`, `SurfaceCard`
- `ui/navigation/` — `AppDestination` enum only (Goal, RaceConfig, Fitness, Days, Profile, Generating, Home, WorkoutDetail, Progress, RunHistory, **PaceCalc**, Settings, Stretching, Privacy)

**Persistence:**
- `TrainingPlan` is stored as a single JSON blob (`payloadJson`) in a Room `training_plans` table. Only the active plan is used; `LocalTrainingPlanRepository` queries the most recent row.
- User preferences are stored via DataStore (unencrypted `preferences_pb`). The Claude API key is stored here in plaintext — no keychain.

**Plan generation** mirrors the Flutter rule engine:
- `PlanGenerator.generatePlan(PlanGenerationRequest)` is pure/deterministic (no coroutines, no I/O).
- Age-aware progression: under-50 = +9%/week, every 4th week recovery; 50+ = +7%/week, every 3rd week recovery.
- 3-week taper for race goals.

**AI features** (`ClaudeService`):
- `enrichPlan()` — called after plan generation if an API key is set; enriches each week with descriptions and coaching tips per workout.
- `generatePostWorkoutCoaching()` — called after saving a workout log; returns 2-3 sentences of feedback stored in `workout.postWorkoutCoaching`.
- Both results are displayed in `WorkoutDetailScreen`: enrichment fields above the log form, post-workout coaching below the action buttons.
- 401 → auth error surfaced to UI; 429 → exponential backoff (3 retries); other errors → silent skip.

**Pace calculator** (`PaceCalculatorService`):
- `calculate(goal, goalTimeSeconds)` returns VDOT-based `PaceZone` list for the 4 run types.
- `distanceKm(goal)` is public — used by `PaceCalculatorScreen` to display the distance label.
- `goalTimeSeconds` is persisted in DataStore via `MainViewModel.saveGoalTime()` and pre-fills the pace screen on re-entry.
- Bottom nav has **4 tabs**: Home / Progress / Pace / Settings. `PaceCalc` is the dedicated pace calculator screen.

**Localization** (`res/values`, `res/values-it`, `res/values-de`):
- Language is switched at runtime via `AppCompatDelegate.setApplicationLocales()` in `SettingsScreen` on Save.
- On cold start, `MainActivity.onCreate` re-applies the stored locale if `getApplicationLocales()` is empty.
- All UI strings use `stringResource()`. Workout-type labels and pace-zone descriptions are resolved at the Composable layer via `WorkoutType.typeLabel()` / `WorkoutType.zoneDescription()` — never from hardcoded Kotlin strings in domain models.

**Tests** are JVM-only (no Robolectric). `PlanGeneratorFixtureTest` loads JSON fixtures from `product-spec/fixtures/` (relative path from the test classpath root) and validates plan output against expected snapshots. Add fixture files there when adding new plan generation test cases.

## Key constraints

- This is the **native Android pilot** for migrating away from Flutter. All rule-engine behavior must remain in parity with `product-spec/fixtures` — fixture tests are the contract.
- Do not add a DI framework; keep `AppContainer` as the composition root.
- Room stores the plan as a JSON blob (not normalized rows) — this is intentional to keep schema migrations simple during the pilot phase.
- Do not re-add `hive_generator` or add Robolectric — see root-level memory for dependency constraints.
- `PaceZone.label` and `PaceZone.description` are domain-level English strings kept for serialization/testing. Always resolve display labels through `WorkoutType.typeLabel()` / `WorkoutType.zoneDescription()` in the UI layer, never directly.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
