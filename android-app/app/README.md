# App Module — Package Layout

```
com.runningtrainer.android
├── app/                        RunningTrainerApplication, AppContainer (manual DI)
├── data/
│   ├── local/                  AppDatabase (Room), TrainingPlanDao, LocalSettingsStore (DataStore)
│   ├── repository/             TrainingPlanRepository, SettingsRepository + local impls
│   └── serialization/          @Serializable mirror models for Room JSON blob
├── domain/
│   ├── contracts/              PlanGenerationRequest, PlanGenerationResult
│   ├── model/                  TrainingPlan, Workout, PaceZone, enums, UserPreferencesDto, StretchExercise
│   └── service/                PlanGenerator, InsightsService, PaceCalculatorService, ProgressStatsCalculator, ClaudeService
├── notifications/              NotificationService, WorkoutAlarmReceiver
└── ui/
    ├── navigation/             AppDestination enum
    ├── screens/                One file per screen + shared helpers in HomeScreen.kt
    ├── theme/                  Color, Type, Theme
    ├── MainActivity.kt         extends AppCompatActivity
    ├── MainViewModel.kt
    └── RunningTrainerApp.kt    Scaffold, 4-tab bottom nav, screen routing
```

## Shared Composable helpers (HomeScreen.kt)

These are package-level and used across multiple screens:

- `workoutTypeColor(type)` — returns the Color for a WorkoutType
- `WorkoutType.typeLabel()` — localized display name via `workout_type_*` string resources
- `WorkoutType.zoneDescription()` — localized pace zone description via `pace_zone_*_desc` string resources
- `SurfaceCard` — bordered card composable used throughout the app
