
# Graph Report - .  (2026-04-17)

## Corpus Check
- Corpus is ~20,051 words - fits in a single context window. You may not need a graph.

## Summary
- 324 nodes · 409 edges · 31 communities detected
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 13 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Data Layer & Repositories|Data Layer & Repositories]]
- [[_COMMUNITY_App Core & DI Wiring|App Core & DI Wiring]]
- [[_COMMUNITY_Domain Models & Services|Domain Models & Services]]
- [[_COMMUNITY_Navigation & Screen Routing|Navigation & Screen Routing]]
- [[_COMMUNITY_Home & Progress UI|Home & Progress UI]]
- [[_COMMUNITY_Plan Generation Contracts|Plan Generation Contracts]]
- [[_COMMUNITY_Workout Detail Tests|Workout Detail Tests]]
- [[_COMMUNITY_Onboarding UI Tests|Onboarding UI Tests]]
- [[_COMMUNITY_Plan Fixture Tests|Plan Fixture Tests]]
- [[_COMMUNITY_Claude AI Service|Claude AI Service]]
- [[_COMMUNITY_Plan Generator Smoke Tests|Plan Generator Smoke Tests]]
- [[_COMMUNITY_Room Database Layer|Room Database Layer]]
- [[_COMMUNITY_Notification System|Notification System]]
- [[_COMMUNITY_Pace Calculator Screen|Pace Calculator Screen]]
- [[_COMMUNITY_JSON Serialization Models|JSON Serialization Models]]
- [[_COMMUNITY_Progress Stats Tests|Progress Stats Tests]]
- [[_COMMUNITY_Stretch Routines Data|Stretch Routines Data]]
- [[_COMMUNITY_Settings Screen|Settings Screen]]
- [[_COMMUNITY_Stretching Screen|Stretching Screen]]
- [[_COMMUNITY_App Lifecycle|App Lifecycle]]
- [[_COMMUNITY_Root Build Config|Root Build Config]]
- [[_COMMUNITY_App Build Config|App Build Config]]
- [[_COMMUNITY_Project Settings|Project Settings]]
- [[_COMMUNITY_Color Theme|Color Theme]]
- [[_COMMUNITY_Typography|Typography]]
- [[_COMMUNITY_Stretch Data|Stretch Data]]
- [[_COMMUNITY_Android App Docs|Android App Docs]]
- [[_COMMUNITY_Architecture Notes|Architecture Notes]]
- [[_COMMUNITY_Package Layout Docs|Package Layout Docs]]
- [[_COMMUNITY_Rationale No DI Framework|Rationale: No DI Framework]]
- [[_COMMUNITY_Rationale AppCompat Locale|Rationale: AppCompat Locale]]

## God Nodes (most connected - your core abstractions)
1. `MainViewModel` - 39 edges
2. `PlanGenerator` - 26 edges
3. `LocalTrainingPlanRepository` - 16 edges
4. `ClaudeService` - 16 edges
5. `WorkoutDetailScreenTest` - 13 edges
6. `MainUiState` - 13 edges
7. `RunningTrainerApp()` - 13 edges
8. `TrainingPlanRepository` - 12 edges
9. `WorkoutType` - 12 edges
10. `InsightsService` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Rationale: PaceZone.label kept as domain English strings for serialization/testing only` --rationale_for--> `PaceZone`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/domain/model/TrainingModels.kt
- `Rationale: age-aware progression (50+ = 7%/3-week recovery vs <50 = 9%/4-week)` --rationale_for--> `PlanGenerator`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/domain/service/PlanGenerator.kt
- `Rationale: Room stores plan as JSON blob (not normalized rows)` --rationale_for--> `TrainingPlanEntity`  [EXTRACTED]
  CLAUDE.md → app/src/main/java/com/runningtrainer/android/data/local/TrainingPlanEntity.kt
- `SettingsScreen()` --semantically_similar_to--> `MainViewModel`  [INFERRED] [semantically similar]
  app/src/main/java/com/runningtrainer/android/ui/screens/SettingsScreen.kt → app/src/main/java/com/runningtrainer/android/ui/MainViewModel.kt
- `PlanGenerator` --semantically_similar_to--> `InsightsService`  [INFERRED] [semantically similar]
  app/src/main/java/com/runningtrainer/android/domain/service/PlanGenerator.kt → app/src/main/java/com/runningtrainer/android/domain/service/InsightsService.kt

## Hyperedges (group relationships)
- **Onboarding Flow: ViewModel State + Screen Navigation** — mainviewmodel_mainviewmodel, mainviewmodel_onboardingformstate, appdestination_appdestination, onboardingscreens_goalselectionscreen, onboardingscreens_raceconfigscreen, onboardingscreens_fitnessselectionscreen, onboardingscreens_trainingdaysscreen, onboardingscreens_profilescreen, onboardingscreens_generatingplanscreen [EXTRACTED 0.95]
- **AI Coaching Pipeline: ClaudeService, Workout, Repository** — domain_claudeservice, domain_workout, data_trainingplanrepository, mainviewmodel_mainviewmodel [EXTRACTED 0.90]
- **Fixture Contract Testing: PlanGeneratorFixtureTest + product-spec fixtures + PlanGenerator** — plangeneratorfixture_plangeneratorfixture, product_spec_fixtures, domain_plangenerator, domain_plangenerationrequest [EXTRACTED 0.95]
- **Manual DI Composition Root** — application_runningtrainerapplication, appcontainer_appcontainer, localrepositories_localtrainingplanrepository, localrepositories_localsettingsrepository, appdatabase_appdatabase, localsettingsstore_localsettingsstore [EXTRACTED 0.97]
- **Shared Composable Utilities exported from HomeScreen** — homescreen_surfacecard, homescreen_workouttypecolor, homescreen_workouttypelabel, homescreen_workoutzonedescription, pacecalculator_pacezonecardcomposable, progressscreen_progressscreen [EXTRACTED 0.95]
- **Room JSON Blob Serialization Pipeline** — trainingplandao_trainingplandao, localrepositories_localtrainingplanrepository, serializablemodels_serializabletrainingplan, serializablemodels_toserializable [EXTRACTED 0.97]
- **Plan Generation Pipeline** — plancontracts_plangenerationrequest, plangenerator_plangenerator, plancontracts_plangenerationresult, claudeservice_claudeservice [EXTRACTED 0.95]
- **Core Domain Model (TrainingPlan hierarchy)** — trainingmodels_trainingplan, trainingmodels_trainingweek, trainingmodels_workout, enums_workouttype [EXTRACTED 1.00]
- **Workout Analytics Services** — insightsservice_insightsservice, progressstatscalculator_progressstatscalculator, pacecalculatorservice_pacecalculatorservice [INFERRED 0.85]

## Communities

### Community 0 - "Data Layer & Repositories"
Cohesion: 0.05
Nodes (9): AppContainer, RunningTrainerApplication, LocalSettingsRepository, LocalTrainingPlanRepository, Keys, LocalSettingsStore, PrivacyScreen(), SettingsRepository (+1 more)

### Community 1 - "App Core & DI Wiring"
Cohesion: 0.06
Nodes (12): AppContainer, RunningTrainerApplication, SettingsRepository, TrainingPlanRepository, ClaudeService (domain), InsightsService (domain), PaceCalculatorService (domain), WorkoutLogInput (+4 more)

### Community 2 - "Domain Models & Services"
Cohesion: 0.1
Nodes (23): EffortLevel, GoalType, WorkoutFeeling, WorkoutType, InsightsService, PaceCalculatorService, ZoneMult, ProgressStatsCalculator (+15 more)

### Community 3 - "Navigation & Screen Routing"
Cohesion: 0.09
Nodes (22): AppDestination, CoachingInsight, PaceZone, ProgressStats, TrainingPlan, UserPreferencesDto, Workout, WorkoutFeeling (+14 more)

### Community 4 - "Home & Progress UI"
Cohesion: 0.1
Nodes (12): Color Palette (Color.kt), HomeScreen(), InsightChip(), SurfaceCard(), WorkoutTile(), workoutTypeColor(), WorkoutType.typeLabel(), PaceCalculatorScreen (+4 more)

### Community 5 - "Plan Generation Contracts"
Cohesion: 0.11
Nodes (6): FitnessLevel, PlanGenerationMetadata, PlanGenerationRequest, PlanGenerationResult, PlanGenerator, Rationale: age-aware progression (50+ = 7%/3-week recovery vs <50 = 9%/4-week)

### Community 6 - "Workout Detail Tests"
Cohesion: 0.14
Nodes (1): WorkoutDetailScreenTest

### Community 7 - "Onboarding UI Tests"
Cohesion: 0.18
Nodes (1): OnboardingScreensTest

### Community 8 - "Plan Fixture Tests"
Cohesion: 0.18
Nodes (5): FixedIdProvider, FixtureExpected, FixtureRequest, PlanFixture, PlanGeneratorFixtureTest

### Community 9 - "Claude AI Service"
Cohesion: 0.22
Nodes (4): ClaudeApiException, ClaudeService, EnrichmentResult, UserPreferencesDto

### Community 10 - "Plan Generator Smoke Tests"
Cohesion: 0.18
Nodes (7): PlanGenerationRequest, PlanGenerator (domain service), ProgressStatsCalculator (domain service), PlanGeneratorFixtureTest, PlanGeneratorSmokeTest, product-spec/fixtures JSON files, ProgressStatsCalculatorTest

### Community 11 - "Room Database Layer"
Cohesion: 0.2
Nodes (2): AppDatabase, TrainingPlanDao

### Community 12 - "Notification System"
Cohesion: 0.2
Nodes (2): NotificationService, WorkoutAlarmReceiver

### Community 13 - "Pace Calculator Screen"
Cohesion: 0.29
Nodes (0): 

### Community 14 - "JSON Serialization Models"
Cohesion: 0.47
Nodes (4): SerializableTrainingPlan, SerializableTrainingWeek, SerializableWorkout, toSerializable()

### Community 15 - "Progress Stats Tests"
Cohesion: 0.4
Nodes (2): ProgressStatsCalculatorTest, ProgressTestIdProvider

### Community 16 - "Stretch Routines Data"
Cohesion: 0.5
Nodes (3): postRunRoutine (static data), preRunRoutine (static data), StretchExercise

### Community 17 - "Settings Screen"
Cohesion: 0.5
Nodes (0): 

### Community 18 - "Stretching Screen"
Cohesion: 1.0
Nodes (2): StretchExerciseCard(), StretchingScreen()

### Community 19 - "App Lifecycle"
Cohesion: 0.67
Nodes (1): RunningTrainerApplication

### Community 20 - "Root Build Config"
Cohesion: 1.0
Nodes (1): Root build.gradle.kts

### Community 21 - "App Build Config"
Cohesion: 1.0
Nodes (0): 

### Community 22 - "Project Settings"
Cohesion: 1.0
Nodes (0): 

### Community 23 - "Color Theme"
Cohesion: 1.0
Nodes (0): 

### Community 24 - "Typography"
Cohesion: 1.0
Nodes (0): 

### Community 25 - "Stretch Data"
Cohesion: 1.0
Nodes (0): 

### Community 26 - "Android App Docs"
Cohesion: 1.0
Nodes (1): Android App README

### Community 27 - "Architecture Notes"
Cohesion: 1.0
Nodes (1): CLAUDE.md — Android architecture notes

### Community 28 - "Package Layout Docs"
Cohesion: 1.0
Nodes (1): app/README.md — Package Layout

### Community 29 - "Rationale: No DI Framework"
Cohesion: 1.0
Nodes (1): Rationale: no DI framework, manual AppContainer

### Community 30 - "Rationale: AppCompat Locale"
Cohesion: 1.0
Nodes (1): Rationale: MainActivity extends AppCompatActivity for locale switching on Android < 13

## Knowledge Gaps
- **25 isolated node(s):** `PlanFixture`, `FixtureExpected`, `SerializableTrainingWeek`, `Keys`, `ZoneMult` (+20 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Root Build Config`** (2 nodes): `build.gradle.kts`, `Root build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `App Build Config`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Project Settings`** (1 nodes): `settings.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Color Theme`** (1 nodes): `Color.kt`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Typography`** (1 nodes): `Type.kt`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Stretch Data`** (1 nodes): `StretchData.kt`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Android App Docs`** (1 nodes): `Android App README`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Architecture Notes`** (1 nodes): `CLAUDE.md — Android architecture notes`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Package Layout Docs`** (1 nodes): `app/README.md — Package Layout`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Rationale: No DI Framework`** (1 nodes): `Rationale: no DI framework, manual AppContainer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Rationale: AppCompat Locale`** (1 nodes): `Rationale: MainActivity extends AppCompatActivity for locale switching on Android < 13`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `MainViewModel` connect `App Core & DI Wiring` to `Plan Generator Smoke Tests`, `Navigation & Screen Routing`?**
  _High betweenness centrality (0.055) - this node is a cross-community bridge._
- **Why does `RunningTrainerApp()` connect `Navigation & Screen Routing` to `App Core & DI Wiring`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Why does `PlanGenerator` connect `Plan Generation Contracts` to `Domain Models & Services`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **What connects `PlanFixture`, `FixtureExpected`, `SerializableTrainingWeek` to the rest of the system?**
  _25 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Data Layer & Repositories` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `App Core & DI Wiring` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Domain Models & Services` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._