# CLAUDE.md — iOS Native App

## Setup

```bash
# Generate Xcode project (requires xcodegen)
brew install xcodegen
xcodegen generate

# Open in Xcode
open RunningTrainer.xcodeproj

# Or open directly from Xcode: File > Open > select RunningTrainerNative/
```

After `xcodegen generate`, open `RunningTrainer.xcodeproj` in Xcode and run on a Simulator (iOS 17+).

## Architecture

**Single ViewModel.** `AppViewModel` (@Observable) holds all app state and drives navigation via `destination: AppDestination` (enum). No navigation stack back-stack — destination changes are immediate.

**Navigation:** `AppDestination` enum covers all screens. `AppRootView` switches between onboarding flow and `MainTabView`. `MainTabView` has 4 tabs: Home / Progress / Pace / Settings.

**Package layout:**
- `Domain/Models/` — pure Swift structs/enums: `Workout`, `TrainingWeek`, `TrainingPlan`, `UserPreferences`, `PaceZone`, `CoachingInsight`, enums
- `Domain/Contracts/` — `PlanGenerationRequest`, `PlanGenerationResult`, `PlanGenerationMetadata`
- `Domain/Services/` — pure business logic: `PlanGenerator`, `InsightsService`, `PaceCalculatorService`, `ProgressStatsCalculator`, `ClaudeService`
- `Data/` — `TrainingPlanStore` (UserDefaults JSON blob), `SettingsStore` (UserDefaults + Keychain for API key)
- `Features/` — one `.swift` file per feature group; feature directories match Android
- `Core/` — `Theme.swift` (colors, reusable components: `SurfaceCard`, `PrimaryButton`, `SelectionCard`, etc.)

**Persistence:**
- `TrainingPlan` → stored as single JSON blob in `UserDefaults`, key `com.runningtrainer.ios.active_plan`
- `UserPreferences` → `UserDefaults`, key `com.runningtrainer.ios.preferences` (API key excluded)
- Claude API key → iOS **Keychain** (service: `com.runningtrainer.ios`, account: `claudeApiKey`)

**Plan generation** mirrors the Flutter/Android rule engine exactly:
- Age-aware progression: under-50 = +9%/week, every 4th week recovery; 50+ = +7%/week, every 3rd week recovery
- 3-week taper for all race goals
- 7 `Workout` entries per week always (rest days fill the remainder)
- Base mileage: beginner=20km, intermediate=35km, advanced=55km/week

**AI features** (`ClaudeService`):
- `enrichPlan()` — async, called after plan generation if API key is set
- `generatePostWorkoutCoaching()` — async, called after saving a workout log
- 401 → auth error shown in UI; 429 → exponential backoff (3 retries); other errors → silent skip
- Model: `claude-sonnet-4-6`

**Minimum iOS target:** iOS 17.0 (required for `@Observable` macro)

## Key constraints

- This is the **native iOS pilot** for the platform migration.
- All rule-engine behavior must remain in parity with `product-spec/fixtures` — fixture tests are the contract.
- Do NOT add SwiftData or CoreData — UserDefaults JSON blob is intentional to keep schema migrations simple.
- Do not add external package dependencies (SPM or CocoaPods) — keep the project zero-dependency.
- `PaceZone.description` is an English domain-level string kept for testing. Resolve display labels through `WorkoutType.displayName` / `WorkoutType.zoneDescription` in views, never from domain models.

## Tests

```bash
# After xcodegen generate, run tests in Xcode via Cmd+U
# Or from CLI (requires simulator booted):
xcodebuild test -project RunningTrainer.xcodeproj -scheme RunningTrainer -destination 'platform=iOS Simulator,name=iPhone 15'
```

Fixture tests in `RunningTrainerTests/PlanGeneratorFixtureTests.swift` load JSON from `product-spec/fixtures/` and validate plan output. Add fixture files there when adding new test cases.
