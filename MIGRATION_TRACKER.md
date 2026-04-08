# Native Migration Tracker

This file is the working tracker for the migration from the Flutter reference app to separate native platform projects.

Legend:
- `[x]` done
- `[ ]` not done
- `P0` critical for native Day 1 parity
- `P1` important follow-up after core parity
- `P2` nice-to-have or later expansion

## Current Snapshot

Reference baseline:
- `[x]` Flutter at repo root remains the golden reference
- `[x]` Shared contracts and fixtures exist in `product-spec/`

Native targets:
- `[x]` `android-app/` started
- `[ ]` `web-app/` implemented
- `[ ]` `ios-app/` implemented
- `[ ]` `backend-services/` implemented

Recent Android verification:
- `[x]` `env JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home' ./gradlew testDebugUnitTest`

## Parity Matrix

| Feature Area | Flutter Reference | Android | Web | iOS | Priority | Notes |
|---|---|---|---|---|---|---|
| Golden reference behavior | Complete | In use | In use | In use | P0 | Flutter remains source of truth |
| Shared contracts | Complete | In use | Planned | Planned | P0 | `product-spec/` |
| Fixture-driven parity tests | Complete | Partial | Planned | Planned | P0 | Android has JVM parity tests |
| Onboarding core flow | Complete | Partial | Not started | Not started | P0 | Android missing race-date/duration parity |
| Local plan generation | Complete | Complete | Not started | Not started | P0 | Android matched to fixtures |
| Local plan persistence | Complete | Complete | Not started | Not started | P0 | Room/DataStore on Android |
| Home screen | Complete | Partial | Not started | Not started | P0 | Android still simplified |
| Plan overview | Complete | Complete | Not started | Not started | P0 | All weeks shown inline on HomeScreen |
| Workout detail | Complete | Partial | Not started | Not started | P0 | Android logging exists, UI still basic |
| Workout logging | Complete | Complete | Not started | Not started | P0 | No AI coaching yet on Android |
| Progress dashboard | Complete | Complete | Not started | Not started | P0 | Stat grid, feeling/type breakdown, recent activity, run history |
| Settings | Complete | Complete | Not started | Not started | P0 | Profile, units, API key (obscured), new plan, reset all with dialogs |
| Pace calculator | Complete | Complete | Not started | Not started | P0 | Android ported, shown in WorkoutDetail |
| Insights engine | Complete | Complete | Not started | Not started | P0 | Android ported, shown on HomeScreen |
| Localization | Complete | Not started | Not started | Not started | P1 | Android still uses hardcoded strings |
| Notifications | Partial | Not started | Not started | Not started | P1 | Android notifications still missing |
| AI enrichment | Complete | Complete | Not started | Not started | P1 | Direct client integration via Anthropic API |
| Post-workout AI coaching | Complete | Complete | Not started | Not started | P1 | |
| Run history | Complete | Complete | Not started | Not started | P1 | Android RunHistoryScreen with type filters |
| Stretching | Complete | Not started | Not started | Not started | P2 | |
| Privacy screen | Complete | Not started | Not started | Not started | P2 | |

## Shared Foundation

### Completed
- `[x] P0` Defined `product-spec/` structure for contracts, fixtures, parity matrix, and golden behavior
- `[x] P0` Added OpenAPI contracts
- `[x] P0` Added JSON schema contracts
- `[x] P0` Added canonical fixtures for plan generation
- `[x] P0` Added sample enrichment and workout log fixtures
- `[x] P0` Added Flutter contract tests against canonical fixtures
- `[x] P0` Documented Flutter as the intentional reference app

### Next
- `[ ] P0` Add shared fixtures for progress stats parity
- `[ ] P0` Add shared fixtures for workout log update and clear-log flows
- `[ ] P0` Add fixtures for race-date-based plan generation
- `[ ] P1` Add pace calculator contracts and fixtures
- `[ ] P1` Add insights contracts, categories, and fixtures
- `[ ] P1` Add localization mapping guidance for native clients
- `[ ] P2` Add UX notes for desktop web adaptations

## Android

### Completed
- `[x] P0` Created Gradle-based native Android project
- `[x] P0` Added Compose app shell
- `[x] P0` Added Android application bootstrap and dependency container
- `[x] P0` Ported domain models to Kotlin
- `[x] P0` Ported plan generator to Kotlin
- `[x] P0` Matched plan generator behavior against shared fixtures
- `[x] P0` Added Room persistence for training plans
- `[x] P0` Added DataStore persistence for user settings
- `[x] P0` Added onboarding core steps:
  - goal
  - fitness level
  - training days
  - profile
  - generating
  - home
- `[x] P0` Added local plan generation and persistence
- `[x] P0` Added workout logging support
- `[x] P0` Added progress stats computation
- `[x] P0` Added basic settings screen for profile, units, and API key
- `[x] P0` Added JVM tests for plan generator parity
- `[x] P0` Added JVM tests for progress stats

### In Progress
- `[ ] P0` Full Android Day 1 parity with Flutter

### Next
- `[x] P0` Add race-date and duration selection to onboarding
- `[x] P0` Add full multi-week plan overview, not only first-week summary
- `[x] P0` Improve workout detail UX and validation
- `[x] P0` Add run history screen
- `[x] P0` Port pace calculator
- `[x] P0` Port insights engine
- `[x] P0` Improve progress dashboard presentation
- `[x] P0` Expand settings to match Flutter more closely
- `[x] P1` Add local notifications scheduling
- `[x] P1` Add AI week enrichment
- `[x] P1` Add post-workout AI coaching
- `[ ] P1` Add localization support
- `[ ] P1` Add instrumentation/UI tests for onboarding and workout logging
- `[ ] P2` Add stretching screen
- `[ ] P2` Add privacy screen

## Web

### Completed
- `[x] P0` Created `web-app/` scaffold folder
- `[x] P0` Added initial migration documentation for web

### Next
- `[ ] P0` Choose stack and bootstrap app
- `[ ] P0` Port shared DTOs/contracts into web runtime
- `[ ] P0` Implement local persistence with IndexedDB
- `[ ] P0` Port onboarding flow
- `[ ] P0` Port local plan generation
- `[ ] P0` Build plan overview and workout detail
- `[ ] P0` Build workout logging
- `[ ] P0` Build progress and settings
- `[ ] P0` Add fixture-driven parity tests
- `[ ] P1` Add desktop-first layout refinements
- `[ ] P1` Add pace calculator
- `[ ] P1` Add insights
- `[ ] P1` Add AI enrichment
- `[ ] P2` Add PWA/offline polish
- `[ ] P2` Add optional web notifications

## iOS

### Completed
- `[x] P0` Created `ios-app/` scaffold folder
- `[x] P0` Added initial migration documentation for iOS

### Next
- `[ ] P0` Create SwiftUI app project
- `[ ] P0` Port DTOs and domain models
- `[ ] P0` Port local plan generator to Swift
- `[ ] P0` Add local persistence
- `[ ] P0` Implement onboarding
- `[ ] P0` Implement home, plan, workout detail
- `[ ] P0` Implement workout logging
- `[ ] P0` Implement progress and settings
- `[ ] P0` Add fixture-driven parity tests
- `[ ] P1` Add pace calculator
- `[ ] P1` Add insights
- `[ ] P1` Add notifications
- `[ ] P1` Add secure storage and AI integration
- `[ ] P1` Add localization
- `[ ] P2` Add stretching and privacy screens

## Backend Services

### Completed
- `[x] P1` Created `backend-services/` scaffold folder
- `[x] P1` Reserved `POST /v1/ai/enrich-week` in shared contracts

### Next
- `[ ] P1` Choose backend framework/runtime
- `[ ] P1` Implement AI enrichment endpoint
- `[ ] P1` Add vendor abstraction and retry handling
- `[ ] P1` Add response mapping aligned with shared contracts
- `[ ] P1` Keep backend behavior optional and non-blocking for clients
- `[ ] P2` Explore future sync/export endpoints

## Recommended Working Order

- `[ ] P0` Finish Android onboarding parity
- `[ ] P0` Finish Android Day 1 product parity
- `[ ] P0` Refine shared `product-spec/` from Android learnings
- `[ ] P0` Start `web-app/` implementation
- `[ ] P0` Start `ios-app/` implementation
- `[ ] P1` Add backend AI enrichment service

## Notes

- Flutter should not be decommissioned until Android, Web, and iOS pass the shared parity bar for the core flow.
- Android currently has the strongest implementation and should continue to be the pilot platform for refining contracts and fixtures.
- AGP currently warns about `compileSdk = 35`, but Android builds and unit tests are passing.
