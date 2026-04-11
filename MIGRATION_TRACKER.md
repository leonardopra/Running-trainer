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
- `[x]` `web-app/` bootstrapped (domain layer + full UI in progress)
- `[x]` `ios-app/` implemented (P0 feature set + AI + stretching + privacy)
- `[ ]` `backend-services/` implemented

Recent Android verification:
- `[x]` `env JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home' ./gradlew testDebugUnitTest` — all JVM unit tests pass
- `[x]` `env JAVA_HOME='/Applications/Android Studio.app/Contents/jbr/Contents/Home' ./gradlew compileDebugKotlin` — clean compile after pace calculator + i18n fixes

## Parity Matrix

| Feature Area | Flutter Reference | Android | Web | iOS | Priority | Notes |
|---|---|---|---|---|---|---|
| Golden reference behavior | Complete | In use | In use | In use | P0 | Flutter remains source of truth |
| Shared contracts | Complete | In use | In use | In use | P0 | `product-spec/` |
| Fixture-driven parity tests | Complete | Complete | Complete | Complete | P0 | iOS: XCTest fixture parity tests |
| Onboarding core flow | Complete | Complete | Complete | Complete | P0 | iOS: goal→race-config→fitness→days→profile→generating |
| Local plan generation | Complete | Complete | Complete | Complete | P0 | iOS: Swift port matched to fixtures |
| Local plan persistence | Complete | Complete | Complete | Complete | P0 | iOS: UserDefaults JSON blob + Keychain for API key |
| Home screen | Complete | Complete | Complete | Complete | P0 | iOS: greeting, insight strip, all-week plan overview with type bars |
| Plan overview | Complete | Complete | Complete | Complete | P0 | iOS: all weeks with color-coded type bars + current week highlight |
| Workout detail | Complete | Complete | Complete | Complete | P0 | iOS: type badge, AI fields, pace zones, feeling chips, RPE slider |
| Workout logging | Complete | Complete | Complete | Complete | P0 | iOS: full log form with clear-log support |
| Progress dashboard | Complete | Complete | Complete | Complete | P0 | iOS: stat grid, weekly bars, feeling/type breakdown, recent activity |
| Settings | Complete | Complete | Complete | Complete | P0 | iOS: profile, units, language, API key (secure), new plan, reset all |
| Pace calculator | Complete | Complete | Complete | Complete | P0 | iOS: dedicated 4th tab, wheel picker HH:MM:SS, expandable zone cards |
| Insights engine | Complete | Complete | Complete | Complete | P0 | iOS: Swift port, 13 rule categories, shown on HomeScreen |
| Localization | Complete | Complete | Partial | Partial | P1 | iOS: language selector in Settings, full i18n pending |
| Notifications | Complete | Complete | Not started | Not started | P1 | iOS: UNUserNotificationCenter not yet wired |
| AI enrichment | Complete | Complete | Not started | Complete | P1 | iOS: ClaudeService.enrichPlan() async |
| Post-workout AI coaching | Complete | Complete | Not started | Complete | P1 | iOS: ClaudeService.generatePostWorkoutCoaching() |
| Run history | Complete | Complete | Not started | Complete | P1 | iOS: RunHistoryView with full log details |
| Stretching | Complete | Complete | Not started | Complete | P2 | iOS: StretchingView, pre/post run, expandable |
| Privacy screen | Complete | Complete | Not started | Complete | P2 | iOS: PrivacyView with delete-all action |

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
- `[x] P0` Aligned UI design system to Flutter reference:
  - Color palette: primary `#00E5FF`, secondary `#76FF03`, surface `#13131A`, surfaceVariant `#1E1E2A`
  - Custom typography matching Flutter sizes/weights
  - Border-based card styling (no elevation), 16dp radius
  - Workout type color palette across all screens
  - Bottom navigation bar for Home / Progress / Pace / Settings (4 tabs)
  - Onboarding: progress indicator, selection cards, filled text fields, 56dp CTA buttons
  - Insight chips and plan chips with primary color tint
  - Stat cards with per-metric accent borders
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

### Completed (continued)
- `[x] P0` Add dedicated pace calculator screen (4th bottom-nav tab: goal selector, HH:MM:SS input, expandable zone cards, auto-save goal time)
- `[x] P0` Highlight current week in plan overview (derived from `plan.startDate`)
- `[x] P0` Display AI enrichment fields in workout detail (`description`, `coachingTip`, `postWorkoutCoaching`)
- `[x] P0` Full i18n: all UI strings via `stringResource()`; workout-type labels and pace-zone descriptions resolved at Composable layer
- `[x] P1` Fix language switching (`MainActivity` extends `AppCompatActivity` so `AppCompatDelegate.setApplicationLocales()` applies on all API levels)
- `[x] P2` Add stretching screen (expandable exercise list, pre/post run, YouTube tutorial links, EN/IT/DE strings)
- `[x] P2` Add privacy screen (data storage, AI, notifications, deletion sections)

### In Progress
- none

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
- `[x] P1` Add localization support
- `[x] P1` Add instrumentation/UI tests for onboarding and workout logging
- `[x] P2` Add stretching screen
- `[x] P2` Add privacy screen

## Web

### Completed
- `[x] P0` Created `web-app/` scaffold folder
- `[x] P0` Added initial migration documentation for web

### Completed
- `[x] P0` Chose stack: React + Vite + TypeScript + Dexie
- `[x] P0` Ported shared DTOs/models to TypeScript (`src/domain/models.ts`)
- `[x] P0` Ported plan generator to TypeScript (`src/domain/planGenerator.ts`)
- `[x] P0` Added fixture-driven parity tests (vitest, reads `product-spec/fixtures/`)
- `[x] P0` Implemented local persistence: Dexie/IndexedDB for plans, localStorage for prefs
- `[x] P0` Implemented onboarding flow (goal → race config → fitness → days → profile → generating)
- `[x] P0` Built home screen with insight strip, week overview, workout type bars
- `[x] P0` Built workout detail with type-colored header, pace zones, logging form
- `[x] P0` Built workout logging with feeling chips, RPE slider, notes, clear-log support
- `[x] P0` Built progress dashboard with stat grid, weekly bars, type/feeling breakdown
- `[x] P0` Built settings screen with profile, units, API key, new-plan/reset dialogs
- `[x] P0` Ported insights engine to TypeScript
- `[x] P0` Ported pace calculator to TypeScript
- `[x] P0` Ported progress stats calculator to TypeScript

### Next
- `[ ] P1` Add desktop-first layout refinements (max-width container, sidebar nav)
- `[ ] P1` Add AI enrichment (Claude API key wired, call Anthropic on plan generate)
- `[ ] P1` Add post-workout AI coaching
- `[ ] P2` Add PWA manifest and service worker for offline use
- `[ ] P2` Add web notifications (Notification API)

## iOS

### Completed
- `[x] P0` Created `ios-app/` scaffold folder
- `[x] P0` Added initial migration documentation for iOS
- `[x] P0` Created SwiftUI app project (source + `project.yml` for xcodegen)
- `[x] P0` Ported DTOs and domain models to Swift (`Workout`, `TrainingWeek`, `TrainingPlan`, `UserPreferences`, enums)
- `[x] P0` Ported local plan generator to Swift (age-aware progression, taper, 7-per-week constraint)
- `[x] P0` Added local persistence (`TrainingPlanStore` via UserDefaults JSON blob, `SettingsStore` with Keychain for API key)
- `[x] P0` Implemented onboarding flow (goal → race config → fitness → days → profile → generating → home)
- `[x] P0` Implemented home screen (greeting, insight strip, week cards with type bars, workout rows)
- `[x] P0` Implemented workout detail (AI fields, pace zones, log form, feeling chips, RPE slider, clear log)
- `[x] P0` Implemented workout logging (full log with actual distance/duration/notes/RPE/feeling)
- `[x] P0` Implemented progress dashboard (stat grid, weekly bars, type breakdown, feeling breakdown, recent activity)
- `[x] P0` Implemented run history screen
- `[x] P0` Implemented settings (profile, units, language selector, notifications, API key, new plan, reset)
- `[x] P0` Added fixture-driven parity tests (`PlanGeneratorFixtureTests`)
- `[x] P1` Added pace calculator (goal selector, HH:MM:SS wheel picker, expandable zone cards, save goal time)
- `[x] P1` Added insights engine port (`InsightsService.swift`, 13 rule categories)
- `[x] P1` Added secure storage — Keychain for API key
- `[x] P1` Added AI integration (plan enrichment + post-workout coaching via `ClaudeService.swift`)
- `[x] P2` Added stretching screen (pre/post run, expandable exercise list)
- `[x] P2` Added privacy screen (data storage, AI, notifications, delete data sections)

### Next
- `[ ] P1` Add local notifications scheduling (UNUserNotificationCenter)
- `[ ] P1` Add full localization (EN/IT/DE via String Catalog or .strings files)
- `[ ] P1` Add `xcodegen generate` to CI / verify clean build
- `[ ] P2` Add instrumentation/UI tests for onboarding and workout logging

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

- `[x] P0` Finish Android onboarding parity
- `[x] P0` Finish Android Day 1 product parity
- `[x] P0` Refine shared `product-spec/` from Android learnings
- `[x] P0` Start `web-app/` implementation (P0 feature set complete)
- `[ ] P0` Verify web-app builds and passes fixture tests (`npm install && npm test`)
- `[ ] P0` Start `ios-app/` implementation
- `[ ] P1` Add backend AI enrichment service

## Notes

- Flutter should not be decommissioned until Android, Web, and iOS pass the shared parity bar for the core flow.
- Android currently has the strongest implementation and should continue to be the pilot platform for refining contracts and fixtures.
- AGP currently warns about `compileSdk = 35`, but Android builds and unit tests are passing.
