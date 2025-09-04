# Guide App 📘

A flexible educational guide app for structuring and displaying tutorial content (game/service/product) with chapters, search, quizzes, and user progress tracking.

> **Note**: This README is customizable depending on your project needs. Sections are included for screenshots and links.

---

## Table of Contents

* [Features](#features)
* [Screenshots](#screenshots)
* [Project Structure](#project-structure)
* [Architecture & Tech Stack](#architecture--tech-stack)
* [Quick Start](#quick-start)
* [Development Setup](#development-setup)
* [Environment Config](#environment-config)
* [Data & Models](#data--models)
* [Localization](#localization)
* [Accessibility](#accessibility)
* [Testing](#testing)
* [Quality & Tools](#quality--tools)
* [CI/CD](#cicd)
* [Build & Release](#build--release)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)

---

## Features

* 🧭 **Hierarchical content**: Sections ⟶ Lessons ⟶ Steps/Media.
* 🔎 **In-app search** with local indexing.
* 🧠 **Quizzes** with results and achievement badges.
* 📶 **Offline mode**: Download full chapters for offline use.
* 📝 **Notes & bookmarks** for users.
* 👤 **User account** (optional: login with Firebase Auth).
* ☁️ **Cloud sync** for notes and progress (optional Firestore).
* 🎨 **Light/Dark theme** and multilingual support (EN/AR).

---

## Screenshots

Insert your app screenshots here:

| Screen         | Image                             |
| -------------- | --------------------------------- |
| Home           | ![home](docs/images/home.png)     |
| Lesson Details | ![lesson](docs/images/lesson.png) |
| Quiz           | ![quiz](docs/images/quiz.png)     |

> Save screenshots inside `docs/images/` and update the paths.

---

## Project Structure

```text
lib/
 ├─ core/
 │   ├─ config/            # Constants, theme, keys
 │   ├─ utils/             # Helpers, extensions
 │   ├─ routing/           # GoRouter/Route settings
 │   ├─ widgets/           # Shared widgets
 │   └─ error/             # Error handling
 ├─ features/
 │   ├─ onboarding/
 │   ├─ catalog/           # Sections and lessons
 │   ├─ search/
 │   ├─ bookmarks/
 │   ├─ quiz/
 │   ├─ progress/
 │   └─ settings/
 ├─ data/
 │   ├─ models/            # Data models
 │   ├─ sources/           # Remote/Local data sources
 │   └─ repositories/      # Interfaces & repositories
 ├─ app.dart               # MaterialApp/Theme
 └─ main.dart              # Entry point

a ssets/
 ├─ content/               # JSON/YAML files for content
 ├─ i18n/                  # Localization files
 └─ images/

docs/
 └─ images/
```

> You can follow a `feature-first` or `layered` structure.

---

## Architecture & Tech Stack

* **State Management**: `flutter_bloc` (recommended) or `Riverpod`.
* **Networking**: `dio` + Interceptors + Retry.
* **Local Storage**: `hive` for notes, bookmarks, and progress.
* **Remote (optional)**: `Firebase (Auth, Firestore, Storage)`.
* **Routing**: `go_router` with deep links.
* **DI**: `get_it` or `riverpod`.
* **Analytics**: `firebase_analytics` (optional).
* **Crash Reporting**: `firebase_crashlytics` (optional).

Basic flow:

```mermaid
flowchart TD
  UI[Presentation (Widgets/Pages)] --> BLoC[BLoC/Cubit]
  BLoC --> Repo[Repository]
  Repo --> Local[(Hive/Cache)]
  Repo --> Remote[(API/Firebase)]
```

---

## Quick Start

### 1) Clone & Run

```bash
git clone <REPO_URL> guide_app
cd guide_app
flutter pub get
flutter run
```

### 2) Add dependencies

```bash
flutter pub add flutter_bloc go_router dio hive hive_flutter get_it
# Optional (Firebase)
flutter pub add firebase_core firebase_auth cloud_firestore firebase_crashlytics firebase_analytics
```

### 3) Hive setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Hive.registerAdapter(...);
  runApp(const GuideApp());
}
```

### 4) (Optional) Firebase setup

Follow FlutterFire CLI guide:

```bash
flutter pub add firebase_core
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## Development Setup

* **Rust/LLVM** (required for Windows builds).
* **VS Code** with extensions: Flutter, Dart, Bloc, Error Lens.
* **Android Studio/Xcode** for platform builds.
* **FVM** for Flutter version management.

Useful commands:

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter build apk --release
flutter build ipa --export-options-plist=ios/exportOptions.plist
```

---

## Environment Config

Use `.env` files with `flutter_dotenv`:

```bash
flutter pub add flutter_dotenv
```

`.env`:

```env
API_BASE_URL=https://api.example.com
SENTRY_DSN=...
```

Usage:

```dart
await dotenv.load(fileName: ".env");
final baseUrl = dotenv.env['API_BASE_URL'];
```

> Use flavors: `dev`, `staging`, `prod` with `main_*.dart`.

---

## Data & Models

* Content format: Prefer `JSON` or `YAML` in `assets/content`.
* Example `lesson.json`:

```json
{
  "id": "intro-01",
  "title": "Introduction",
  "section": "Basics",
  "body": "Lesson text...",
  "media": [{"type": "image", "src": "assets/images/intro.png"}]
}
```

---

## Localization

* Use `flutter_localizations` + `intl`.
* Example:

```
assets/i18n/
 ├─ ar.json
 └─ en.json
```

* Enable in `MaterialApp`:

```dart
return MaterialApp(
  supportedLocales: const [Locale('ar'), Locale('en')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
);
```

---

## Accessibility

* Dynamic text scaling, high contrast colors, Semantics labels.
* Support for screen readers and keyboard navigation.

---

## Testing

* **Unit**: Repositories & BLoCs.
* **Widget**: Screens & components.
* **Integration**: Full flows.

Commands:

```bash
flutter test
flutter test --coverage
```

Example BLoC test:

```dart
blocTest<MyCubit, MyState>(
  'should load lessons',
  build: () => MyCubit(repo),
  act: (c) => c.loadLessons(),
  expect: () => [isA<Loading>(), isA<Success>()],
);
```

---

## Quality & Tools

* **Linting**: `flutter_lints` + `very_good_analysis` (optional).
* **Formatting**: `dart format .`
* **Pre-commit hooks**: `dart run import_sorter:main`, `flutter analyze`.

---

## CI/CD

Example **GitHub Actions**:

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release
```

---

## Build & Release

* **Android**: Sign release with `key.properties` + `build.gradle`.
* **iOS**: Configure `Bundle ID`, signing, and `ExportOptions.plist`.
* **Web/Desktop**: Enable platforms as needed: `flutter config --enable-web`.

---

## Roadmap

* [ ] Advanced quiz bank with difficulty levels.
* [ ] Lesson recommendations based on progress.
* [ ] Cross-device sync.
* [ ] Built-in content editor (light CMS).

---

## Contributing

Contributions are welcome! Open an **Issue** or **Pull Request**.

Guidelines:

* Follow code style (lint rules).
* Add tests for new features.
* Update docs/screenshots when needed.

---

## License

This project is licensed under MIT unless otherwise noted. See `LICENSE` file.

---

## Contact

* Owner/Team: *Mahmoud Elbanna*
* Email: *[example@email.com](mailto:mhbana2020@email.com)*
* Twitter/LinkedIn: *Optional links*
