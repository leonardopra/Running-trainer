# Running Trainer

A cross-platform running training app (iOS, Android, Web) that generates personalised multi-week training plans using a rule-based engine, then enriches each workout with descriptions and coaching tips from Claude AI.

Built with Flutter. All data stays on-device — no account, no backend, no subscription.

---

## Try it now

| Platform | Link |
|---|---|
| **Web** | [leonardopra.github.io/Running-trainer](https://leonardopra.github.io/Running-trainer/) |
| **Android APK** | [Latest release](https://github.com/leonardopra/Running-trainer/releases/latest) → download `app-release.apk` |

> **Android install note:** Since the APK is not distributed via the Play Store, you'll need to enable "Install from unknown sources" on your device. Go to **Settings → Apps → Special app access → Install unknown apps**, then allow your browser or file manager to install it.

---

## How it works

**Onboarding (4 screens):** Pick a goal (5K → Marathon or General Fitness), set a race date or choose a duration, select your fitness level, and toggle which days of the week you can train.

**Plan generation:** A deterministic rule engine builds the full training schedule immediately — correct mileage progression, recovery weeks, and taper baked in. The plan is saved locally before any AI call, so it's usable even without an API key.

**AI enrichment (optional):** If you add a Claude API key in Settings, the app sends each week's workouts to `claude-sonnet-4-6` in a single batch call and writes personalised workout descriptions and coaching tips back to every session.

---

## Training plan logic

| Fitness level | Base weekly mileage |
|---|---|
| Beginner | 20 km |
| Intermediate | 35 km |
| Advanced | 55 km |

- **Progression:** ~9% increase per week
- **Recovery:** every 4th week drops to 80% of the previous load
- **Taper:** last 3 weeks at 70% / 50% / 30% of peak (race goals only)
- **Workout mix:** 80/20 easy-to-quality ratio distributed across 3–6 training days

Default plan lengths: 5K = 8 weeks, 10K = 10 weeks, Half Marathon = 12 weeks, Marathon = 16 weeks. A custom race date overrides these.

---

## Stack

| Layer | Choice |
|---|---|
| Framework | Flutter 3 |
| State | Riverpod (NotifierProvider) |
| Storage | Hive (local only, IndexedDB on Web) |
| HTTP | Dio |
| Routing | go_router |
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

The test suite covers the plan generator: week count, mileage progression, taper behaviour, and workout distribution by training days.
