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

**Storage:** Hive boxes are opened once in `main.dart` and accessed everywhere via `StorageService` (`lib/services/storage_service.dart`). Two boxes: `training_plans` (keyed by plan UUID) and `user_preferences` (single key `'prefs'`).

**Navigation flow:**
```
App start → router redirect checks hasCompletedOnboarding
  false → /onboarding/goal → /race-date → /fitness → /days → /generating → /plan
  true  → /plan
```
The redirect guard is in `lib/router/app_router.dart`. `hasCompletedOnboarding` is set only after the plan is saved to Hive (inside `GenerationNotifier.generatePlan()`), not after the form is filled, to prevent redirect loops.

**Plan generation flow** (`lib/providers/plan_generation_provider.dart`):
1. `PlanGeneratorService.generatePlan()` → deterministic rule-based skeleton
2. Save skeleton to Hive immediately (app works without Claude)
3. For each week: `ClaudeService.enrichWeek()` → update Hive on success
4. Set `isClaudeEnriched = true`, mark onboarding complete, navigate to `/plan`

**Hive models** (`lib/models/`): All `.g.dart` adapter files are hand-written (not generated). TypeIds: Workout=1, TrainingWeek=2, TrainingPlan=3, UserPreferences=4, enums start at 10. If you add/change `@HiveField` annotations, manually update the corresponding `.g.dart` file — do not run `build_runner` unless you intend to regenerate all adapters.

**Claude integration** (`lib/services/claude_service.dart`): Uses `claude-sonnet-4-6`. One API call per week (batch), not per workout. Strips markdown code fences before JSON parsing. 401 → auth error, 429 → exponential backoff up to 3 retries, any other failure → silently skip (plan remains usable without enrichment).

**Rule engine** (`lib/services/plan_generator_service.dart`): Base mileage: beginner=20km, intermediate=35km, advanced=55km/week. Progression: +9%/week, recovery every 4th week (−20%), 3-week taper for race goals (70%/50%/30% of peak). Workout distribution follows 80/20 easy/quality rule across 3–6 training days. Each week always has exactly 7 `Workout` entries (rest days explicit).
