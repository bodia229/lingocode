# LingoCode

[![Build](https://github.com/bodia229/lingocode/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/bodia229/lingocode/actions/workflows/build.yml)
[![Last commit](https://img.shields.io/github/last-commit/bodia229/lingocode?logo=github)](https://github.com/bodia229/lingocode/commits/main)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20Web%20%7C%20Windows-purple)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Offline-first learning app for **English tech vocabulary** and **Python
programming**. Built with Flutter — runs on Android, Web (PWA) and Windows
desktop from a single codebase.

> Daily 5–10 minutes is enough. Spaced repetition handles the rest.

## Features

- **Spaced repetition (SM-2)** for English flashcards. The same algorithm
  Anki and SuperMemo use — each review schedules the next based on how well
  you recalled the card.
- **Interactive Python lessons** with three exercise types:
  - **Write output** — predict what code prints
  - **Fill in the blank** — complete a snippet
  - **Multiple choice** — pick the right answer
- **Streak & XP** to keep you coming back daily.
- **Text-to-speech** for English pronunciations (Android / web).
- **Offline-first** — everything works without internet; data is stored
  locally in SQLite.
- **50 seeded English tech-words** covering Python basics, OOP, async, web,
  databases and DevOps vocabulary.
- **10 seeded Python lessons** from `print()` to list comprehensions and
  imports.

## Screens

- **Home** — daily review counter, streak, XP, jump-off points
- **Review** — flashcards with Again/Hard/Good/Easy grading
- **Lessons** — list of Python lessons with progress bars
- **Lesson** — exercise runner with instant feedback
- **Stats** — long-term progress

## Architecture

```
lib/
├── main.dart                 # entry point + db init + seed
├── theme.dart                # Material 3 theme
├── models/
│   ├── flashcard.dart        # English card + SRS state
│   └── lesson.dart           # Python lesson + exercise types
├── services/
│   ├── database.dart         # SQLite (sqflite + ffi for desktop/web)
│   ├── srs.dart              # SM-2 spaced repetition algorithm
│   ├── streak.dart           # streak + XP tracking
│   ├── seed.dart             # seed flashcards from JSON
│   ├── lesson_repo.dart      # load lessons from asset JSON
│   └── checker.dart          # exercise answer normalisation
└── screens/
    ├── home_screen.dart
    ├── review_screen.dart
    ├── lesson_list_screen.dart
    ├── lesson_screen.dart
    └── stats_screen.dart

assets/data/
├── english_cards.json        # 50 tech-English flashcards
└── python_lessons.json       # 10 Python lessons (~35 exercises)

test/
└── widget_test.dart          # SRS unit tests
```

## Getting started

### Prerequisites

- **Flutter SDK 3.24+** ([install](https://flutter.dev/setup/))
- For Android builds: **JDK 17** (recommended) and Android SDK 34+
- For Web: any modern browser
- For Windows desktop: Visual Studio 2022 with C++ desktop workload + nuget.exe in PATH

### Run on the web

```bash
flutter pub get
flutter run -d chrome
```

### Run on Android (USB-attached device)

```bash
flutter pub get
flutter run -d <device-id>     # see `flutter devices`
```

### Build releases

```bash
# Android APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# Web (PWA)
flutter build web --release
# → build/web/   (serve any static host)
```

## Install on Android

1. Build the APK with `flutter build apk --release`
2. Transfer `build/app/outputs/flutter-apk/app-release.apk` to your phone
3. Enable "Install unknown apps" for your file manager and open the APK

## Install as PWA on Windows / Android

1. Host `build/web/` on any static host (Netlify, GitHub Pages, Render)
2. Open the URL in Chrome/Edge
3. Click the install icon in the address bar (or browser menu → "Install
   LingoCode"). The app installs with its own icon and runs in its own
   window.

## How SRS works (SM-2)

After each card you tap one of four buttons:

| Button | Quality | Effect |
| --- | --- | --- |
| Again | 0 | Card resets, shown again in 1 day, lapse counter +1 |
| Hard | 3 | Small ease decrease, interval grows slowly |
| Good | 4 | Standard interval growth (1d → 6d → 6d × ease …) |
| Easy | 5 | Larger ease increase, longer interval |

The minimum ease is 1.3 — a deliberate floor so even brutal cards don't
spiral into thousand-year intervals. Every card carries its own
`ease`, `intervalDays`, `repetitions`, `nextReview`, `lapses`.

## Adding new content

Drop new cards into `assets/data/english_cards.json`:

```json
{ "front": "decorator", "back": "декоратор",
  "example": "Use @property as a decorator.",
  "topic": "advanced" }
```

Or a new Python lesson into `assets/data/python_lessons.json`. Three
exercise kinds are supported: `writeOutput`, `fillBlank`,
`multipleChoice`.

Cards are seeded into the local DB only on first launch (when the cards
table is empty). To re-seed, delete the database or call
`Seeder.seedIfEmpty` after clearing the table.

## Tech stack

- **Flutter 3.24** + **Dart 3.5**
- **sqflite** (with `sqflite_common_ffi` + `sqflite_common_ffi_web` for
  desktop and web)
- **path_provider** for cross-platform DB location
- **flutter_tts** for English pronunciations
- **Material 3** with dynamic color seed

## Roadmap

- Per-topic decks (only Web vocabulary, only OOP, etc.)
- Cloud sync (FastAPI backend with the same SRS schema)
- AI-generated cards from selected paragraphs (Claude API)
- Audio listening exercises (transcribe English audio)
- Real Python execution via Pyodide on web, sandbox on Android

## License

MIT — see [LICENSE](LICENSE).
