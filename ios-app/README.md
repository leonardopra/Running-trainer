# iOS App

Native iOS implementation of Running Trainer, built with Swift + SwiftUI. Pilot platform alongside Android for the Flutter → native migration.

## Stack

- Swift, SwiftUI
- UserDefaults (plan storage as JSON blob, mirrors Android approach)
- Keychain via Security framework (API key)
- Min deployment target: iOS 17

## Status

Full parity with the Flutter reference. All P0 and P1 features are implemented.

## Screens

| Screen | Notes |
|---|---|
| Onboarding | Goal → RaceConfig → Fitness → Days → Profile → Generating |
| Home | Greeting, insight strip, full multi-week plan with current week highlighted |
| Workout Detail | Pace zones, AI coach note, log form, post-workout coaching |
| Progress | Stat grid, weekly bars, recent activity |
| Run History | Full list of completed workouts |
| Pace Calculator | Goal distance selector, HH:MM:SS input, VDOT pace zone cards |
| Settings | Profile, AI key, units, new plan, reset |
| Stretching | Pre/post run, expandable exercise list |
| Privacy | Data storage, AI, notifications, deletion policy |

## Running

Open `ios-app/RunningTrainerNative/RunningTrainer.xcodeproj` in Xcode and run on a simulator or device.

## Architecture

- Single `AppViewModel` (`@Observable`) holds the entire app state — mirrors `MainViewModel` on Android
- Navigation driven by `AppViewModel.currentDestination` (no NavigationStack back stack management for main flow)
- Storage repositories (`TrainingPlanStore`, `SettingsStore`) are isolated behind the ViewModel
- Plan generation is pure/deterministic, parity-tested against `product-spec/fixtures`
