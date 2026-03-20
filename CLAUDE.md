# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                    # Install dependencies
flutter run -d chrome                             # Run on web (fastest iteration)
flutter run -d macos                              # Run on macOS desktop
flutter test                                      # Run all tests
flutter test test/plan_generator_test.dart        # Run a single test file
dart run build_runner build --delete-conflicting-outputs  # Regenerate .g.dart files (only needed if models change)
```

## Architecture

**State management:** Riverpod with `NotifierProvider`. All providers live in `lib/providers/`. Use `ref.read` (not `ref.watch`) inside async methods and services.

**Storage:** Hive boxes opened once in `main.dart`, accessed via `StorageService` (`lib/services/storage_service.dart`).
- `training_plans` — keyed by plan UUID, unencrypted
- `user_preferences` — single key `'prefs'`, AES-256 encrypted via `HiveAesCipher`

`EncryptionService` (`lib/services/encryption_service.dart`) generates a 256-bit key once and stores it in the OS keychain (`flutter_secure_storage`). If decryption fails on open (old unencrypted data), it wipes and reinitializes the box.

**Folder structure:** Feature-based under `lib/features/{home,plan,progress,settings,pace,stretching,onboarding}/screens/` and `widgets/`. Shared models in `lib/models/`, services in `lib/services/`, constants in `lib/core/constants/`.

**Navigation flow:**
```
App start → router redirect checks hasCompletedOnboarding
  false → /onboarding/goal → /race-date → /fitness → /days → /profile → /generating → /home
  true  → /home
```
The redirect guard is in `lib/router/app_router.dart`. `hasCompletedOnboarding` is set only after the plan is saved to Hive (inside `GenerationNotifier.generatePlan()`), not after the form is filled, to prevent redirect loops. Main routes: `/home`, `/plan`, `/plan/workout/:id` (WorkoutDetail via `state.extra: Workout`), `/progress`, `/pace`, `/settings`.

**Plan generation flow** (`lib/providers/plan_generation_provider.dart`):
1. `PlanGeneratorService.generatePlan()` → deterministic rule-based skeleton (age-aware)
2. Save skeleton to Hive immediately (app works without Claude)
3. For each week: `ClaudeService.enrichWeek()` → update Hive on success
4. Set `isClaudeEnriched = true`, schedule notifications, mark onboarding complete, navigate to `/home`

**Age-aware rule engine** (`lib/services/plan_generator_service.dart`):
- Base mileage: beginner=20km, intermediate=35km, advanced=55km/week
- Runners **under 50**: +9%/week progression, recovery every 4th week (−20%)
- Runners **50+**: +7%/week progression, recovery every 3rd week (−20%)
- 3-week taper for race goals (70%/50%/30% of peak)
- 80/20 easy/quality rule across 3–6 training days; each week always has exactly 7 `Workout` entries
- `maxHR = 220 - age` is passed to Claude for HR zone guidance

**Hive models** (`lib/models/`): All `.g.dart` adapter files are hand-written (not generated). TypeIds: Workout=1, TrainingWeek=2, TrainingPlan=3, UserPreferences=4, enums start at 10. If you add/change `@HiveField` annotations, manually update the corresponding `.g.dart` file — do not run `build_runner` unless you intend to regenerate all adapters. `Workout` includes logging fields: `actualDistanceKm`, `actualDurationMinutes`, `notes`, `isCompleted`, `completedAt`.

Non-Hive models: `ProgressStats` (computed from plan), `CoachingInsight` (priority + type), `StretchExercise`.

**Claude integration** (`lib/services/claude_service.dart`): Uses `claude-sonnet-4-6`. One API call per week (batch), not per workout. Strips markdown code fences before JSON parsing. 401 → auth error, 429 → exponential backoff up to 3 retries, any other failure → silently skip (plan remains usable without enrichment). Profile data (age, weight, height) passed for personalized coaching.

**Insights engine** (`lib/services/insights_service.dart`): 11 rule-based insight categories sorted by priority (1–15). Categories include race countdown, taper/recovery week notices, completion rate warnings, easy pace coaching, long-run-skipped alerts, and streak celebrations. Displayed as a scrollable strip on HomeScreen.

**Notifications** (`lib/services/notification_service.dart`): One scheduled notification per future non-rest workout at user-set time. ID scheme: `(weekIndex * 7) + dayOfWeek`. Android-only (skipped on web via `kIsWeb`). Rescheduled whenever settings change.

**Pace calculator** (`lib/services/pace_calculator_service.dart`): VDOT-based pace zones (Jack Daniels method). 4 zones (EasyRun, LongRun, TempoRun, IntervalRun) with multipliers per goal type. Validates goal time between 10 min and 10 hours. Stores computed `goalTimeSeconds` in encrypted UserPreferences.

**Localization:** ARB files for English (`en`), Italian (`it`), German (`de`) in `lib/l10n/`. Active locale from `settingsProvider.localeCode`. All user-facing strings must go through `AppLocalizations`.
