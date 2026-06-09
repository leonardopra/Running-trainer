# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
./gradlew assembleDebug                                          # Build debug APK
./gradlew test                                                   # Run all JVM unit tests
./gradlew :app:testDebugUnitTest --tests "*.PlanGeneratorSmokeTest" # Run a single test class
./gradlew connectedAndroidTest                                   # Run instrumented tests (requires device/emulator)
./gradlew lint                                                   # Run lint checks
```

> Min SDK 26, target/compile SDK 35, Java 17, Kotlin 2.0.21, Compose BOM 2024.09.03. App ID / namespace `com.leopra.runningtrainer`.

## Architecture

**Single-activity, multiple ViewModels.** App state is split across five `@HiltViewModel` classes, all obtained in `MainActivity` via `by viewModels()`:

- `MainViewModel` — `MainUiState` (bootstrap, `currentDestination`, `isPreRunStretching`, onboarding mirror, plan generation flags, preferences, active plan). Owns navigation.
- `OnboardingViewModel` — onboarding form state + plan generation; schedules notifications after generating a plan.
- `PlanViewModel` — selected workout, progress stats, insights, pace zones, and AI plan enrichment (`isEnrichingPlan`, `enrichmentError`).
- `SettingsViewModel` — saves settings and goal time; re-schedules notifications on save.
- `WorkoutLogViewModel` — streaming post-workout coaching (`streamingCoaching`, `isStreaming`, `coachingAuthError`).

Sub-ViewModels publish navigation intents on a `navigationEvent: Channel<AppDestination>`; `MainActivity` collects them (inside `repeatOnLifecycle`) and forwards to `MainViewModel.navigateTo`, and likewise mirrors `OnboardingViewModel.uiState` into `MainViewModel`.

**Navigation** is ViewModel-driven via `currentDestination: MutableStateFlow<AppDestination>` — there is no Jetpack Navigation back stack. `RunningTrainerApp.kt` renders the matching screen with a `when(dest)` inside a `Scaffold` with a 4-tab bottom nav (Home / Progress / PaceCalc / Settings). `navigation-compose` is on the classpath but is **not** used.

**`MainActivity` extends `AppCompatActivity`** (not `ComponentActivity`) — required so `AppCompatDelegate.setApplicationLocales()` applies the stored locale (`en`/`it`/`de`, see `res/xml/locales_config.xml`) correctly, including on Android < 13. The stored locale is applied in `onCreate`.

**Dependency injection: Hilt is the sole composition root.**
- `RunningTrainerApplication` is annotated `@HiltAndroidApp`; `MainActivity` is `@AndroidEntryPoint` (with an `@Inject` `SettingsRepository`).
- A single module, `app/di/AppModule.kt` (`@InstallIn(SingletonComponent::class)`), provides `AppDatabase`, `Json`, `TrainingPlanRepository`, `SettingsRepository`, `PaceCalculatorService`, `InsightsService`, `ClaudeService`, and `NotificationService`.
- ViewModels are `@HiltViewModel` with `@Inject` constructors. There is no manual factory and no `AppContainer`.

**Package layout (`com.leopra.runningtrainer`):**
- `MainActivity.kt` — at the package root.
- `app/` — `RunningTrainerApplication`, `di/AppModule.kt`.
- `domain/model/` — pure Kotlin data models (`TrainingPlan`, `Workout`, enums, `UserPreferencesDto`, `StretchData`/`StretchExercise`).
- `domain/contracts/` — request/result types (`PlanGenerationRequest`, `PlanGenerationResult`).
- `domain/service/` — `PlanGenerator`, `InsightsService`, `PaceCalculatorService`, `ProgressStatsCalculator`, and the Claude stack (`ClaudeService`, `ClaudeHttpClient`, `ClaudePromptBuilder`, `ClaudeResponseParser`).
- `data/local/` — Room (`AppDatabase`, `TrainingPlanEntity`, `TrainingPlanDao`) + DataStore (`LocalSettingsStore`).
- `data/repository/` — repository interfaces + `LocalTrainingPlanRepository`, `LocalSettingsRepository`.
- `data/serialization/` — `@Serializable` mirror models used for JSON storage in Room (`payloadJson` column).
- `notifications/` — `NotificationService`, `WorkoutAlarmReceiver`.
- `ui/screens/` — one Composable file per screen. `HomeScreen.kt` exports shared helpers: `workoutTypeColor`, `WorkoutType.typeLabel()`, `WorkoutType.zoneDescription()`, `SurfaceCard`.
- `ui/navigation/` — `AppDestination` enum (Goal, RaceConfig, Fitness, Days, Profile, Generating, Home, WorkoutDetail, Progress, RunHistory, PaceCalc, Settings, Stretching, Privacy).
- `ui/` root — the five ViewModels + `RunningTrainerApp.kt`.

**Persistence:**
- `TrainingPlan` is stored as a single JSON blob (`payloadJson`) in a Room `training_plans` table. Only the active plan is used; `LocalTrainingPlanRepository` queries the most recent row.
- User preferences are stored via DataStore (unencrypted `preferences_pb`). The Claude API key is stored here in plaintext — no keychain.

## AI coaching

The Claude integration lives in `domain/service/`, split across `ClaudeService` (orchestration), `ClaudeHttpClient` (transport), `ClaudePromptBuilder`, and `ClaudeResponseParser`:
- `enrichPlan(...)` — enriches plan weeks; on an auth error it stops and returns the remaining weeks un-enriched, other errors skip silently keeping the original week.
- `generatePostWorkoutCoaching(...)` — blocking, returns `String?`.
- `streamPostWorkoutCoaching(...)` — SSE streaming `Flow<String>` (emits an auth-error sentinel on auth failure); used by `WorkoutLogViewModel` for live coaching.
- Transport: `https://api.anthropic.com/v1/messages` via `HttpURLConnection` with the `x-api-key` header. Model constant lives in `ClaudeHttpClient.kt` (currently `claude-opus-4-7`).

## Notifications

`NotificationService.scheduleForPlan(plan, hour, minute)` cancels existing alarms then schedules an exact `AlarmManager` alarm for each future, non-rest, non-completed workout (alarm id `weekIndex * 7 + dayOfWeek`, matching Flutter). It uses `setExactAndAllowWhileIdle`, falling back to `setAndAllowWhileIdle` when `canScheduleExactAlarms()` is false on Android 12+. `WorkoutAlarmReceiver` posts the reminder on the `workout_reminders` channel. Required permissions: `INTERNET`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`. Scheduling is invoked from `OnboardingViewModel` (after generation) and `SettingsViewModel` (on save).

## Testing

- **JVM unit tests** (`app/src/test`): `PlanGeneratorSmokeTest`, `PlanGeneratorFixtureTest` (the parity contract against `product-spec/fixtures`), `ProgressStatsCalculatorTest`, `ClaudePromptBuilderTest`, `ClaudeResponseParserTest`, `SSEParserTest`, and `ClaudeServiceTest` (MockK + `kotlinx-coroutines-test`).
- **Instrumented tests** (`app/src/androidTest`): `OnboardingScreensTest`, `WorkoutDetailScreenTest` (Compose UI).

Add fixture files alongside `PlanGeneratorFixtureTest` when adding new plan-generation test cases.

## Key constraints

- This is the **native Android pilot** for migrating away from Flutter. All rule-engine behavior must remain in parity with `product-spec/fixtures` — fixture tests are the contract.
- **Hilt is the composition root.** Add new dependencies through `app/di/AppModule.kt` (or appropriate Hilt modules); do not reintroduce a manual `AppContainer`.
- Room stores the plan as a JSON blob (not normalized rows) — intentional to keep schema migrations simple during the pilot phase.
- Do not re-add `hive_generator` or add Robolectric — see root-level memory for dependency constraints.
- `PaceZone.label` and `PaceZone.description` are domain-level English strings kept for serialization/testing. Always resolve display labels through `WorkoutType.typeLabel()` / `WorkoutType.zoneDescription()` in the UI layer, never directly.
- Plan progression is age-aware (50+ uses ~7% / 3-week recovery vs <50 ~9% / 4-week) — keep in parity with the fixtures.

## graphify

This project has a graphify knowledge graph at `graphify-out/`.

Rules:
- Before answering architecture or codebase questions, read `graphify-out/GRAPH_REPORT.md` for god nodes and community structure.
- If `graphify-out/wiki/index.md` exists, navigate it instead of reading raw files.
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost). The current graph predates the `com.leopra.runningtrainer` rename and is stale — regenerate it.
