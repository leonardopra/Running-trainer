# Android App

Native Android implementation of Running Trainer, built with Kotlin + Jetpack Compose. This is the pilot platform for the Flutter → native migration.

## Stack

- Kotlin 2.0.21, Java 17
- Jetpack Compose (BOM 2024.09.03) + Material3
- Room 2.6.1 (plan storage as JSON blob)
- DataStore Preferences (user settings)
- kotlinx-serialization-json 1.7.3
- kotlinx-datetime 0.6.1
- AppCompat 1.7.0 (locale switching)
- Min SDK 26, target SDK 35

## Status

Full Day 1 parity with the Flutter reference. All P0 and P1 features are implemented.

## Screens

| Screen | Route | Notes |
|---|---|---|
| Onboarding | Goal → RaceConfig → Fitness → Days → Profile → Generating | Race-date or duration input |
| Home | `Home` | Greeting, insight strip, full multi-week plan with current week highlighted |
| Workout Detail | `WorkoutDetail` | Pace zones, AI coach note, coaching tip, log form, post-workout coaching |
| Progress | `Progress` | Stat grid, weekly bars, feeling/type breakdown, recent activity |
| Run History | `RunHistory` | Full list of completed workouts |
| Pace Calculator | `PaceCalc` | Goal distance selector, HH:MM:SS input, expandable pace zone cards, auto-saves goal time |
| Settings | `Settings` | Profile, AI key, language (EN/IT/DE), units, notifications, new plan, reset |
| Stretching | `Stretching` | Pre/post run, expandable exercise list, YouTube links |
| Privacy | `Privacy` | Data storage, AI, notifications, deletion policy |

## Running

```bash
./gradlew assembleDebug                                          # Build debug APK
./gradlew test                                                   # Run all JVM unit tests
./gradlew :app:testDebugUnitTest --tests "*.PlanGeneratorFixtureTest"
./gradlew connectedAndroidTest                                   # Instrumented tests (device/emulator required)
./gradlew lint
```

## Architecture

See `CLAUDE.md` for full architecture notes, key constraints, and gotchas.
