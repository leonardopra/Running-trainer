# Graph Report - .  (2026-05-27)

## Corpus Check
- Corpus is ~27,733 words - fits in a single context window. You may not need a graph.

## Summary
- 255 nodes · 309 edges · 34 communities detected
- Extraction: 95% EXTRACTED · 5% INFERRED · 0% AMBIGUOUS · INFERRED: 15 edges (avg confidence: 0.82)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_UI Layer & Navigation|UI Layer & Navigation]]
- [[_COMMUNITY_Domain Enums|Domain Enums]]
- [[_COMMUNITY_Onboarding Flow|Onboarding Flow]]
- [[_COMMUNITY_Claude HTTP + Prompts|Claude HTTP + Prompts]]
- [[_COMMUNITY_DI & Local Storage|DI & Local Storage]]
- [[_COMMUNITY_Home Screen|Home Screen]]
- [[_COMMUNITY_Hilt AppModule|Hilt AppModule]]
- [[_COMMUNITY_PromptBuilder Tests|PromptBuilder Tests]]
- [[_COMMUNITY_ResponseParser Tests|ResponseParser Tests]]
- [[_COMMUNITY_ClaudeService Tests|ClaudeService Tests]]
- [[_COMMUNITY_ClaudeService Logic|ClaudeService Logic]]
- [[_COMMUNITY_Plan Generation|Plan Generation]]
- [[_COMMUNITY_SSE Parser Tests|SSE Parser Tests]]
- [[_COMMUNITY_Room Database Layer|Room Database Layer]]
- [[_COMMUNITY_ClaudeHttpClient|ClaudeHttpClient]]
- [[_COMMUNITY_Pace Calculator Screen|Pace Calculator Screen]]
- [[_COMMUNITY_Progress Screen|Progress Screen]]
- [[_COMMUNITY_WorkoutDetail Screen|WorkoutDetail Screen]]
- [[_COMMUNITY_Settings & Privacy|Settings & Privacy]]
- [[_COMMUNITY_Response Parser|Response Parser]]
- [[_COMMUNITY_Prompt Builder|Prompt Builder]]
- [[_COMMUNITY_App Icon Assets|App Icon Assets]]
- [[_COMMUNITY_Material Theme|Material Theme]]
- [[_COMMUNITY_Stretch Data|Stretch Data]]
- [[_COMMUNITY_Stretching Screen|Stretching Screen]]
- [[_COMMUNITY_Application Entry Point|Application Entry Point]]
- [[_COMMUNITY_Gradle Build Scripts|Gradle Build Scripts]]
- [[_COMMUNITY_Root Build Gradle|Root Build Gradle]]
- [[_COMMUNITY_Settings Gradle|Settings Gradle]]
- [[_COMMUNITY_App Build Gradle|App Build Gradle]]
- [[_COMMUNITY_AppDestination Enum|AppDestination Enum]]
- [[_COMMUNITY_Run History Screen|Run History Screen]]
- [[_COMMUNITY_Android App README|Android App README]]
- [[_COMMUNITY_Package Layout Docs|Package Layout Docs]]

## God Nodes (most connected - your core abstractions)
1. `OnboardingViewModel` - 19 edges
2. `MainViewModel` - 18 edges
3. `PlanViewModel` - 14 edges
4. `RunningTrainerApp()` - 11 edges
5. `PlanGenerator service` - 11 edges
6. `MainActivity` - 10 edges
7. `AppModule` - 10 edges
8. `WorkoutType enum` - 10 edges
9. `ClaudeService` - 10 edges
10. `AppModule (Hilt DI)` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Rationale: Room stores plan as JSON blob (not normalized rows)` --rationale_for--> `MainViewModel`  [INFERRED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/ui/MainViewModel.kt
- `Rationale: native Android pilot — rule-engine behavior must match product-spec fixtures` --governs_design_constraint_on--> `PlanViewModel`  [INFERRED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/ui/PlanViewModel.kt
- `Rationale: MainActivity extends AppCompatActivity for locale switching on Android < 13` --rationale_for--> `MainActivity`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/MainActivity.kt
- `Rationale: no DI framework, manual AppContainer` --rationale_for--> `MainActivity`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/MainActivity.kt
- `Rationale: PaceZone.label kept as domain English strings for serialization/testing only` --rationale_for--> `WorkoutType.typeLabel() (shared extension)`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/ui/screens/HomeScreen.kt

## Hyperedges (group relationships)
- **Fixture Contract Testing: PlanGeneratorFixtureTest + product-spec fixtures + PlanGenerator** — plangeneratorfixture_plangeneratorfixture, product_spec_fixtures, domain_plangenerator, domain_plangenerationrequest [EXTRACTED 0.95]
- **Room JSON Blob Serialization Pipeline** — trainingplandao_trainingplandao, localrepositories_localtrainingplanrepository, serializablemodels_serializabletrainingplan, serializablemodels_toserializable [EXTRACTED 0.97]
- **Core Domain Model (TrainingPlan hierarchy)** — trainingmodels_trainingplan, trainingmodels_trainingweek, trainingmodels_workout, enums_workouttype [EXTRACTED 1.00]
- **Sub-ViewModel Navigation Bridge Pattern** — mainactivity_mainactivity, onboardingviewmodel_onboardingviewmodel, planviewmodel_planviewmodel, settingsviewmodel_settingsviewmodel, workoutlogviewmodel_workoutlogviewmodel, mainviewmodel_mainviewmodel [EXTRACTED 1.00]
- **Streaming Post-Workout Coaching Flow** — workoutlogviewmodel_workoutlogviewmodel, workoutlogviewmodel_workoutloguistate, workoutlogviewmodel_streamingjob, screens_workoutdetailscreen [EXTRACTED 1.00]
- **Shared Composable Utilities exported from HomeScreen** — screens_homescreen, screens_surfacecard, screens_workouttypelabel, screens_workouttypecolor, screens_zonedescription, screens_workoutdetailscreen, screens_pacecalculatorscreen, screens_progressscreen [EXTRACTED 1.00]

## Communities

### Community 0 - "UI Layer & Navigation"
Cohesion: 0.08
Nodes (24): MainActivity, MainViewModel, AppDestination, PlanUiState, PlanViewModel, Rationale: MainActivity extends AppCompatActivity for locale switching on Android < 13, Rationale: native Android pilot — rule-engine behavior must match product-spec fixtures, Rationale: no DI framework, manual AppContainer (+16 more)

### Community 1 - "Domain Enums"
Cohesion: 0.15
Nodes (28): EffortLevel enum, FitnessLevel enum, GoalType enum, WorkoutFeeling enum, WorkoutType enum, InsightsService, NotificationService, PaceCalculatorService (+20 more)

### Community 2 - "Onboarding Flow"
Cohesion: 0.11
Nodes (11): MainUiState, FitnessSelectionScreen, GeneratingPlanScreen, GoalSelectionScreen, ProfileScreen, RaceConfigScreen, TrainingDaysScreen, OnboardingScreensTest (+3 more)

### Community 3 - "Claude HTTP + Prompts"
Cohesion: 0.26
Nodes (14): ClaudeApiException, ClaudeHttpClient, ClaudePromptBuilder, ClaudePromptBuilderTest, ClaudeRequest, ClaudeResponseParser, ClaudeResponseParserTest, ClaudeService (+6 more)

### Community 4 - "DI & Local Storage"
Cohesion: 0.21
Nodes (12): AppDatabase (Room), AppModule (Hilt DI), InsightsService, LocalSettingsRepository, LocalSettingsStore (DataStore), LocalTrainingPlanRepository, NotificationService, PaceCalculatorService (+4 more)

### Community 5 - "Home Screen"
Cohesion: 0.18
Nodes (0): 

### Community 6 - "Hilt AppModule"
Cohesion: 0.18
Nodes (1): AppModule

### Community 7 - "PromptBuilder Tests"
Cohesion: 0.22
Nodes (1): ClaudePromptBuilderTest

### Community 8 - "ResponseParser Tests"
Cohesion: 0.25
Nodes (1): ClaudeResponseParserTest

### Community 9 - "ClaudeService Tests"
Cohesion: 0.25
Nodes (0): 

### Community 10 - "ClaudeService Logic"
Cohesion: 0.25
Nodes (3): ClaudeApiException, ClaudeService, EnrichmentResult

### Community 11 - "Plan Generation"
Cohesion: 0.29
Nodes (7): PlanGenerationRequest, PlanGenerator (domain service), ProgressStatsCalculator (domain service), PlanGeneratorFixtureTest, PlanGeneratorSmokeTest, product-spec/fixtures JSON files, ProgressStatsCalculatorTest

### Community 12 - "SSE Parser Tests"
Cohesion: 0.29
Nodes (1): SSEParserTest

### Community 13 - "Room Database Layer"
Cohesion: 0.33
Nodes (7): AppDatabase, LocalTrainingPlanRepository, SerializableTrainingPlan, SerializableWorkout, toSerializable() / toDomain() converters, TrainingPlanDao, TrainingPlanRepository (interface)

### Community 14 - "ClaudeHttpClient"
Cohesion: 0.29
Nodes (2): ClaudeHttpClient, ClaudeRequest

### Community 15 - "Pace Calculator Screen"
Cohesion: 0.33
Nodes (0): 

### Community 16 - "Progress Screen"
Cohesion: 0.33
Nodes (0): 

### Community 17 - "WorkoutDetail Screen"
Cohesion: 0.4
Nodes (2): WorkoutDetailScreen(), WorkoutDetailScreenTest

### Community 18 - "Settings & Privacy"
Cohesion: 0.67
Nodes (4): LocalSettingsRepository, LocalSettingsStore, PrivacyScreen, SettingsRepository (interface)

### Community 19 - "Response Parser"
Cohesion: 0.5
Nodes (1): ClaudeResponseParser

### Community 20 - "Prompt Builder"
Cohesion: 0.5
Nodes (1): ClaudePromptBuilder

### Community 21 - "App Icon Assets"
Cohesion: 0.83
Nodes (4): Launcher Background Layer — solid deep navy / dark blue fill, App Launcher Icon (composite adaptive), Launcher Foreground Layer — running figure silhouette with bar-chart progress bars (navy + coral/red), symbolising training progress, App Launcher Icon Round (composite adaptive)

### Community 22 - "Material Theme"
Cohesion: 0.67
Nodes (3): Color Palette (Color.kt), RunningTrainerTheme, Typography

### Community 23 - "Stretch Data"
Cohesion: 0.67
Nodes (3): postRunRoutine (static data), preRunRoutine (static data), StretchExercise

### Community 24 - "Stretching Screen"
Cohesion: 1.0
Nodes (2): StretchExerciseCard, StretchingScreen

### Community 25 - "Application Entry Point"
Cohesion: 1.0
Nodes (1): RunningTrainerApplication

### Community 26 - "Gradle Build Scripts"
Cohesion: 1.0
Nodes (2): app/build.gradle.kts, build.gradle.kts (root)

### Community 27 - "Root Build Gradle"
Cohesion: 1.0
Nodes (0): 

### Community 28 - "Settings Gradle"
Cohesion: 1.0
Nodes (0): 

### Community 29 - "App Build Gradle"
Cohesion: 1.0
Nodes (0): 

### Community 30 - "AppDestination Enum"
Cohesion: 1.0
Nodes (1): AppDestination enum

### Community 31 - "Run History Screen"
Cohesion: 1.0
Nodes (1): RunHistoryScreen

### Community 32 - "Android App README"
Cohesion: 1.0
Nodes (1): Android App README

### Community 33 - "Package Layout Docs"
Cohesion: 1.0
Nodes (1): app/README.md — Package Layout

## Knowledge Gaps
- **43 isolated node(s):** `WorkoutDetailScreenTest`, `PlanGenerationRequest`, `ProgressStatsCalculator (domain service)`, `product-spec/fixtures JSON files`, `AppDestination enum` (+38 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Stretching Screen`** (2 nodes): `StretchExerciseCard`, `StretchingScreen`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Application Entry Point`** (2 nodes): `RunningTrainerApplication.kt`, `RunningTrainerApplication`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Gradle Build Scripts`** (2 nodes): `app/build.gradle.kts`, `build.gradle.kts (root)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Root Build Gradle`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Settings Gradle`** (1 nodes): `settings.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Build Gradle`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `AppDestination Enum`** (1 nodes): `AppDestination enum`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Run History Screen`** (1 nodes): `RunHistoryScreen`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Android App README`** (1 nodes): `Android App README`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Package Layout Docs`** (1 nodes): `app/README.md — Package Layout`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OnboardingViewModel` connect `Onboarding Flow` to `UI Layer & Navigation`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `MainViewModel` connect `UI Layer & Navigation` to `Onboarding Flow`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Why does `PlanViewModel` connect `UI Layer & Navigation` to `Onboarding Flow`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `MainViewModel` (e.g. with `SettingsScreen` and `Rationale: Room stores plan as JSON blob (not normalized rows)`) actually correct?**
  _`MainViewModel` has 2 INFERRED edges - model-reasoned connections that need verification._
- **Are the 3 inferred relationships involving `PlanViewModel` (e.g. with `WorkoutDetailScreen` and `ProgressScreen`) actually correct?**
  _`PlanViewModel` has 3 INFERRED edges - model-reasoned connections that need verification._
- **What connects `WorkoutDetailScreenTest`, `PlanGenerationRequest`, `ProgressStatsCalculator (domain service)` to the rest of the system?**
  _43 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `UI Layer & Navigation` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._