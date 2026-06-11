# Running Trainer

A cross-platform running training app (iOS, Android, Web) that generates personalised multi-week training plans using a rule-based engine, then enriches each workout with descriptions and coaching tips from Claude AI.

All data stays on-device — no account, no backend, no subscription.

> **⚠️ The native Android app has moved.** Active development continues in the standalone repo [leonardopra/running-trainer-android](https://github.com/leonardopra/running-trainer-android) (extracted June 2026, see `docs/adr/0001-single-native-android-app.md` in that repo). The `android-app/` folder here is kept for history only.

---

## Repository structure

| Folder | Description |
|---|---|
| *(root)* | Flutter app — golden reference during migration |
| `android-app/` | Native Android (Kotlin + Jetpack Compose) — **moved to [running-trainer-android](https://github.com/leonardopra/running-trainer-android)**, kept here for history |
| `ios-app/` | Native iOS (Swift + SwiftUI) — full P0+P1 |
| `web-app/` | Web frontend |
| `backend-services/` | Backend services |
| `product-spec/` | Shared fixtures and contracts (parity contract for all platforms) |
| `flutter-reference/` | Documents the Flutter root as the intentional migration reference |

---

## Try it now

| Platform | Link |
|---|---|
| **Web** | [leonardopra.github.io/Running-trainer](https://leonardopra.github.io/Running-trainer/) |
| **Android APK** | [Latest release](https://github.com/leonardopra/Running-trainer/releases/latest) → download `app-release.apk` |

> **Android install note:** Since the APK is not distributed via the Play Store, you'll need to enable "Install from unknown sources" on your device. Go to **Settings → Apps → Special app access → Install unknown apps**, then allow your browser or file manager to install it.

---

## How it works

**Onboarding (5 screens):** Pick a goal (5K → Marathon or General Fitness), set a race date or choose a duration, select your fitness level, toggle which days of the week you can train, and enter your profile (age, weight, height).

**Plan generation:** A deterministic rule engine builds the full training schedule immediately — correct mileage progression, age-aware recovery weeks, and taper baked in. The plan is saved locally before any AI call, so it's usable even without an API key.

**AI enrichment (optional):** If you add a Claude API key in Settings, the app sends each week's workouts to `claude-sonnet-4-6` in a single batch call and writes personalised workout descriptions and coaching tips back to every session.

**Workout logging:** After each session you can log your actual distance, duration, and notes. Completed workouts show a badge on the plan screen.

**Insights:** A coaching strip on the home screen surfaces contextual tips — upcoming race countdown, taper and recovery week notices, easy-pace reminders, long-run alerts, streak celebrations, and more.

**Pace calculator:** Enter your goal time and the app computes your VDOT-based pace zones (Easy, Long Run, Tempo, Interval) using the Jack Daniels method.

---

## Training plan logic

| Fitness level | Base weekly mileage |
|---|---|
| Beginner | 20 km |
| Intermediate | 35 km |
| Advanced | 55 km |

- **Progression (under 50):** ~9% increase per week, recovery every 4th week (−20%)
- **Progression (50+):** ~7% increase per week, recovery every 3rd week (−20%)
- **Taper:** last 3 weeks at 70% / 50% / 30% of peak (race goals only)
- **Workout mix:** 80/20 easy-to-quality ratio distributed across 3–6 training days; each week always contains exactly 7 entries

Default plan lengths: 5K = 8 weeks, 10K = 10 weeks, Half Marathon = 12 weeks, Marathon = 16 weeks. A custom race date overrides these.

---

## Features at a glance

| Feature | Detail |
|---|---|
| Training plans | Rule-based, age-aware, fully offline |
| AI coaching | Claude enriches every workout with personalised tips |
| Workout logging | Log actual distance, duration, and notes per session |
| Insights strip | 11 coaching insight categories, priority-sorted |
| Pace calculator | VDOT zones for Easy, Long Run, Tempo, Interval |
| Progress screen | Completion rate, total distance, streaks |
| Localisation | English, Italian, German |
| Notifications | Scheduled reminders per workout (Android) |

---

## Stack

### Flutter (reference app)

| Layer | Choice |
|---|---|
| Framework | Flutter 3 |
| State | Riverpod (NotifierProvider) |
| Storage | Hive (local only, IndexedDB on Web), AES-256 encrypted preferences |
| HTTP | Dio |
| Routing | go_router (ShellRoute with persistent bottom nav) |
| AI | Anthropic Claude API (`claude-sonnet-4-6`) |
| Localisation | Flutter ARB (en, it, de) |

### Android (native)

| Layer | Choice |
|---|---|
| Language | Kotlin 2.0.21 |
| UI | Jetpack Compose (BOM 2024.09.03) + Material3 |
| Storage | Room 2.6.1 (JSON blob), DataStore Preferences |
| AI | Anthropic Claude API (`claude-sonnet-4-6`) |
| Localisation | Android string resources (en, it, de) |

### iOS (native)

| Layer | Choice |
|---|---|
| Language | Swift |
| UI | SwiftUI |
| Storage | UserDefaults (JSON blob), Keychain (API key) |
| AI | Anthropic Claude API (`claude-sonnet-4-6`) |

---

## Getting started

```bash
flutter pub get
flutter run -d chrome      # web
flutter run -d macos       # macOS desktop
flutter run                # pick from connected devices
```

To enable AI coaching, open **Settings** in the app and paste your [Anthropic API key](https://console.anthropic.com/). The key is stored locally on your device and never leaves it.

---

## Running tests

```bash
flutter test
```

The test suite covers the plan generator (week count, mileage progression, taper, workout distribution), the pace calculator (VDOT zones), the insights engine (priority ordering, category logic), and key widgets.
