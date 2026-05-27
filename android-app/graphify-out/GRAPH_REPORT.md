# Graph Report - .  (2026-05-27)

## Corpus Check
- 12 files · ~8,000 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 260 nodes · 252 edges · 44 communities detected
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 8 edges (avg confidence: 0.79)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_App Entry & ViewModels|App Entry & ViewModels]]
- [[_COMMUNITY_Main State & Onboarding VM|Main State & Onboarding VM]]
- [[_COMMUNITY_Domain Models & Pace Zones|Domain Models & Pace Zones]]
- [[_COMMUNITY_Enums & Insights Service|Enums & Insights Service]]
- [[_COMMUNITY_Onboarding Screens|Onboarding Screens]]
- [[_COMMUNITY_Home Screen & Skeleton|Home Screen & Skeleton]]
- [[_COMMUNITY_DI & Repositories|DI & Repositories]]
- [[_COMMUNITY_Hilt App Module|Hilt App Module]]
- [[_COMMUNITY_Claude HTTP Client|Claude HTTP Client]]
- [[_COMMUNITY_Prompt Builder Tests|Prompt Builder Tests]]
- [[_COMMUNITY_Response Parser Tests|Response Parser Tests]]
- [[_COMMUNITY_Claude Service Tests|Claude Service Tests]]
- [[_COMMUNITY_Plan Generator & Fixtures|Plan Generator & Fixtures]]
- [[_COMMUNITY_SSE Parser Tests|SSE Parser Tests]]
- [[_COMMUNITY_Room DB & Serialization|Room DB & Serialization]]
- [[_COMMUNITY_SSE Streaming Client|SSE Streaming Client]]
- [[_COMMUNITY_Progress Screen & Chart|Progress Screen & Chart]]
- [[_COMMUNITY_Pace Calculator Screen|Pace Calculator Screen]]
- [[_COMMUNITY_Settings Screen|Settings Screen]]
- [[_COMMUNITY_Claude Service|Claude Service]]
- [[_COMMUNITY_Settings Repo & Privacy|Settings Repo & Privacy]]
- [[_COMMUNITY_Response Parser|Response Parser]]
- [[_COMMUNITY_Prompt Builder|Prompt Builder]]
- [[_COMMUNITY_App Icons|App Icons]]
- [[_COMMUNITY_Workout Detail Screen|Workout Detail Screen]]
- [[_COMMUNITY_Stretch Data|Stretch Data]]
- [[_COMMUNITY_Stretching Screen|Stretching Screen]]
- [[_COMMUNITY_Application Class|Application Class]]
- [[_COMMUNITY_Build Scripts|Build Scripts]]
- [[_COMMUNITY_App Composable Root|App Composable Root]]
- [[_COMMUNITY_Theme|Theme]]
- [[_COMMUNITY_App Build Config|App Build Config]]
- [[_COMMUNITY_Settings Gradle|Settings Gradle]]
- [[_COMMUNITY_App Build KTS|App Build KTS]]
- [[_COMMUNITY_Workout Detail Test|Workout Detail Test]]
- [[_COMMUNITY_Navigation Destinations|Navigation Destinations]]
- [[_COMMUNITY_Run History Screen|Run History Screen]]
- [[_COMMUNITY_Typography|Typography]]
- [[_COMMUNITY_Room Entity|Room Entity]]
- [[_COMMUNITY_README|README]]
- [[_COMMUNITY_App README|App README]]
- [[_COMMUNITY_Training Plan Model|Training Plan Model]]
- [[_COMMUNITY_Pace Zone Rationale|Pace Zone Rationale]]
- [[_COMMUNITY_Color Palette|Color Palette]]

## God Nodes (most connected - your core abstractions)
1. `OnboardingViewModel` - 17 edges
2. `MainViewModel` - 16 edges
3. `PlanViewModel` - 11 edges
4. `AppModule` - 10 edges
5. `MainActivity` - 9 edges
6. `AppModule (Hilt DI)` - 9 edges
7. `ClaudePromptBuilderTest` - 8 edges
8. `PlanGenerator service` - 8 edges
9. `ClaudeResponseParserTest` - 7 edges
10. `SSEParserTest` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Rationale: Room stores plan as JSON blob (not normalized rows)` --rationale_for--> `MainViewModel`  [INFERRED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/ui/MainViewModel.kt
- `Rationale: native Android pilot — rule-engine behavior must match product-spec fixtures` --governs_design_constraint_on--> `PlanViewModel`  [INFERRED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/ui/PlanViewModel.kt
- `Rationale: MainActivity extends AppCompatActivity for locale switching on Android < 13` --rationale_for--> `MainActivity`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/MainActivity.kt
- `Rationale: no DI framework, manual AppContainer` --rationale_for--> `MainActivity`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/MainActivity.kt
- `PlanGenerator service` --semantically_similar_to--> `InsightsService`  [INFERRED] [semantically similar]
  app/src/main/java/com/runningtrainer/android/domain/service/PlanGenerator.kt → app/src/main/java/com/runningtrainer/android/domain/service/InsightsService.kt

## Hyperedges (group relationships)
- **Fixture Contract Testing: PlanGeneratorFixtureTest + product-spec fixtures + PlanGenerator** — plangeneratorfixture_plangeneratorfixture, product_spec_fixtures, domain_plangenerator, domain_plangenerationrequest [EXTRACTED 0.95]
- **Room JSON Blob Serialization Pipeline** — trainingplandao_trainingplandao, localrepositories_localtrainingplanrepository, serializablemodels_serializabletrainingplan, serializablemodels_toserializable [EXTRACTED 0.97]
- **Core Domain Model (TrainingPlan hierarchy)** — trainingmodels_trainingplan, trainingmodels_trainingweek, trainingmodels_workout, enums_workouttype [EXTRACTED 1.00]
- **Sub-ViewModel Navigation Bridge Pattern** — mainactivity_mainactivity, onboardingviewmodel_onboardingviewmodel, planviewmodel_planviewmodel, settingsviewmodel_settingsviewmodel, workoutlogviewmodel_workoutlogviewmodel, mainviewmodel_mainviewmodel [EXTRACTED 1.00]
- **Streaming Post-Workout Coaching Flow** — workoutlogviewmodel_workoutlogviewmodel, workoutlogviewmodel_workoutloguistate, workoutlogviewmodel_streamingjob, screens_workoutdetailscreen [EXTRACTED 1.00]
- **Shared Composable Utilities exported from HomeScreen** — screens_homescreen, screens_surfacecard, screens_workouttypelabel, screens_workouttypecolor, screens_zonedescription, screens_workoutdetailscreen, screens_pacecalculatorscreen, screens_progressscreen [EXTRACTED 1.00]

## Communities

### Community 0 - "App Entry & ViewModels"
Cohesion: 0.08
Nodes (13): MainActivity, MainViewModel, AppDestination, PlanUiState, PlanViewModel, Rationale: MainActivity extends AppCompatActivity for locale switching on Android < 13, Rationale: native Android pilot — rule-engine behavior must match product-spec fixtures, Rationale: no DI framework, manual AppContainer (+5 more)

### Community 1 - "Main State & Onboarding VM"
Cohesion: 0.15
Nodes (5): MainUiState, OnboardingScreensTest, OnboardingFormState, OnboardingUiState, OnboardingViewModel

### Community 2 - "Domain Models & Pace Zones"
Cohesion: 0.13
Nodes (13): CoachingInsight, InsightType, PaceDataPoint, PaceZone, ProgressStats, RpeDataPoint, TrainingPlan, TrainingWeek (+5 more)

### Community 3 - "Enums & Insights Service"
Cohesion: 0.23
Nodes (14): EffortLevel enum, FitnessLevel enum, GoalType enum, WorkoutFeeling enum, WorkoutType enum, InsightsService, NotificationService, PaceCalculatorService (+6 more)

### Community 4 - "Onboarding Screens"
Cohesion: 0.15
Nodes (0): 

### Community 5 - "Home Screen & Skeleton"
Cohesion: 0.15
Nodes (0): 

### Community 6 - "DI & Repositories"
Cohesion: 0.21
Nodes (12): AppDatabase (Room), AppModule (Hilt DI), InsightsService, LocalSettingsRepository, LocalSettingsStore (DataStore), LocalTrainingPlanRepository, NotificationService, PaceCalculatorService (+4 more)

### Community 7 - "Hilt App Module"
Cohesion: 0.18
Nodes (1): AppModule

### Community 8 - "Claude HTTP Client"
Cohesion: 0.24
Nodes (11): ClaudeHttpClient, ClaudePromptBuilder, ClaudePromptBuilderTest, ClaudeRequest, ClaudeResponseParser, ClaudeResponseParserTest, ClaudeServiceTest, SSEParserTest (+3 more)

### Community 9 - "Prompt Builder Tests"
Cohesion: 0.22
Nodes (1): ClaudePromptBuilderTest

### Community 10 - "Response Parser Tests"
Cohesion: 0.25
Nodes (1): ClaudeResponseParserTest

### Community 11 - "Claude Service Tests"
Cohesion: 0.25
Nodes (0): 

### Community 12 - "Plan Generator & Fixtures"
Cohesion: 0.29
Nodes (7): PlanGenerationRequest, PlanGenerator (domain service), ProgressStatsCalculator (domain service), PlanGeneratorFixtureTest, PlanGeneratorSmokeTest, product-spec/fixtures JSON files, ProgressStatsCalculatorTest

### Community 13 - "SSE Parser Tests"
Cohesion: 0.29
Nodes (1): SSEParserTest

### Community 14 - "Room DB & Serialization"
Cohesion: 0.33
Nodes (7): AppDatabase, LocalTrainingPlanRepository, SerializableTrainingPlan, SerializableWorkout, toSerializable() / toDomain() converters, TrainingPlanDao, TrainingPlanRepository (interface)

### Community 15 - "SSE Streaming Client"
Cohesion: 0.29
Nodes (2): ClaudeHttpClient, ClaudeRequest

### Community 16 - "Progress Screen & Chart"
Cohesion: 0.29
Nodes (0): 

### Community 17 - "Pace Calculator Screen"
Cohesion: 0.33
Nodes (0): 

### Community 18 - "Settings Screen"
Cohesion: 0.4
Nodes (0): 

### Community 19 - "Claude Service"
Cohesion: 0.4
Nodes (1): EnrichmentResult

### Community 20 - "Settings Repo & Privacy"
Cohesion: 0.67
Nodes (4): LocalSettingsRepository, LocalSettingsStore, PrivacyScreen, SettingsRepository (interface)

### Community 21 - "Response Parser"
Cohesion: 0.5
Nodes (1): ClaudeResponseParser

### Community 22 - "Prompt Builder"
Cohesion: 0.5
Nodes (1): ClaudePromptBuilder

### Community 23 - "App Icons"
Cohesion: 0.83
Nodes (4): Launcher Background Layer — solid deep navy / dark blue fill, App Launcher Icon (composite adaptive), Launcher Foreground Layer — running figure silhouette with bar-chart progress bars (navy + coral/red), symbolising training progress, App Launcher Icon Round (composite adaptive)

### Community 24 - "Workout Detail Screen"
Cohesion: 0.5
Nodes (0): 

### Community 25 - "Stretch Data"
Cohesion: 0.67
Nodes (3): postRunRoutine (static data), preRunRoutine (static data), StretchExercise

### Community 26 - "Stretching Screen"
Cohesion: 0.67
Nodes (0): 

### Community 27 - "Application Class"
Cohesion: 1.0
Nodes (1): RunningTrainerApplication

### Community 28 - "Build Scripts"
Cohesion: 1.0
Nodes (2): app/build.gradle.kts, build.gradle.kts (root)

### Community 29 - "App Composable Root"
Cohesion: 1.0
Nodes (0): 

### Community 30 - "Theme"
Cohesion: 1.0
Nodes (0): 

### Community 31 - "App Build Config"
Cohesion: 1.0
Nodes (0): 

### Community 32 - "Settings Gradle"
Cohesion: 1.0
Nodes (0): 

### Community 33 - "App Build KTS"
Cohesion: 1.0
Nodes (0): 

### Community 34 - "Workout Detail Test"
Cohesion: 1.0
Nodes (1): WorkoutDetailScreenTest

### Community 35 - "Navigation Destinations"
Cohesion: 1.0
Nodes (1): AppDestination enum

### Community 36 - "Run History Screen"
Cohesion: 1.0
Nodes (1): RunHistoryScreen

### Community 37 - "Typography"
Cohesion: 1.0
Nodes (1): Typography

### Community 38 - "Room Entity"
Cohesion: 1.0
Nodes (1): TrainingPlanEntity (Room)

### Community 39 - "README"
Cohesion: 1.0
Nodes (1): Android App README

### Community 40 - "App README"
Cohesion: 1.0
Nodes (1): app/README.md — Package Layout

### Community 41 - "Training Plan Model"
Cohesion: 1.0
Nodes (1): TrainingPlan (model)

### Community 42 - "Pace Zone Rationale"
Cohesion: 1.0
Nodes (1): Rationale: PaceZone.label kept as domain English strings for serialization/testing only

### Community 43 - "Color Palette"
Cohesion: 1.0
Nodes (0): 

## Knowledge Gaps
- **48 isolated node(s):** `OnboardingScreensTest`, `WorkoutDetailScreenTest`, `PlanGenerationRequest`, `ProgressStatsCalculator (domain service)`, `product-spec/fixtures JSON files` (+43 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Application Class`** (2 nodes): `RunningTrainerApplication.kt`, `RunningTrainerApplication`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Build Scripts`** (2 nodes): `app/build.gradle.kts`, `build.gradle.kts (root)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Composable Root`** (2 nodes): `RunningTrainerApp.kt`, `RunningTrainerApp()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Theme`** (2 nodes): `Theme.kt`, `RunningTrainerTheme()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Build Config`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Settings Gradle`** (1 nodes): `settings.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Build KTS`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Workout Detail Test`** (1 nodes): `WorkoutDetailScreenTest`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Navigation Destinations`** (1 nodes): `AppDestination enum`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Run History Screen`** (1 nodes): `RunHistoryScreen`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Typography`** (1 nodes): `Typography`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Room Entity`** (1 nodes): `TrainingPlanEntity (Room)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `README`** (1 nodes): `Android App README`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App README`** (1 nodes): `app/README.md — Package Layout`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Training Plan Model`** (1 nodes): `TrainingPlan (model)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Pace Zone Rationale`** (1 nodes): `Rationale: PaceZone.label kept as domain English strings for serialization/testing only`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Color Palette`** (1 nodes): `Color.kt`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OnboardingViewModel` connect `Main State & Onboarding VM` to `App Entry & ViewModels`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `MainViewModel` connect `App Entry & ViewModels` to `Main State & Onboarding VM`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `PlanViewModel` connect `App Entry & ViewModels` to `Main State & Onboarding VM`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **What connects `OnboardingScreensTest`, `WorkoutDetailScreenTest`, `PlanGenerationRequest` to the rest of the system?**
  _48 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `App Entry & ViewModels` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Domain Models & Pace Zones` be split into smaller, more focused modules?**
  _Cohesion score 0.13 - nodes in this community are weakly interconnected._