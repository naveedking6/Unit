# یونٹ ساتھی (Unit Saathi)

A simple, offline-first Urdu app for recording and calculating electricity meter units.

## Status: MVP scaffold

**Working now (pure Dart, fully tested):**
- Core calculation/validation logic (`lib/models/unit_record.dart`) — `کل یونٹ = آخری یونٹ − شروع کا یونٹ`, with the exact Urdu error messages from the spec.
- SQLite repository layer (`lib/db/database_helper.dart`) — name storage, record CRUD, monthly grouping/totals.
- Full screen flow: Splash → Name Entry → Home → Add Unit → Monthly Records (swipeable) → Calculator.
- White/black/red theme matching the app icon.
- Automated tests for every case listed in the spec (`test/unit_calculation_test.dart`).

**Stubbed, needs a real device to build out:**
- `lib/services/ocr_service.dart` — camera capture + on-device ML Kit OCR. Interface and Urdu messages are defined; the actual camera preview/capture UI needs a device/emulator to build and tune.
- PDF export (`pdf` + `printing` packages) — needs an Urdu-shaping font (e.g. Noto Nastaliq Urdu) bundled in `assets/fonts/`.
- Image export for WhatsApp sharing (`screenshot` + `share_plus`).
- App icon — architecture supports swapping `assets/icon/` freely; the icon in this repo is the one you provided.

## Getting this running locally

This was generated without a Flutter SDK available, so platform folders (`android/`, `ios/`) aren't included yet. To finish setup:

```bash
flutter create --org com.unitsaathi --project-name unit_saathi .
flutter pub get
flutter test
flutter run
```

`flutter create .` will scaffold `android/`, `ios/`, etc. around the existing `lib/`, `test/`, and `pubspec.yaml` without touching them.

## Architecture

```
UI (screens/)
  ↓
Repository (db/database_helper.dart)
  ↓
SQLite (sqflite)
```

Business logic (calculation/validation) is isolated in `models/unit_record.dart` with no UI or DB dependency, so it's fully unit-testable — see `test/unit_calculation_test.dart`.

No login, no accounts, no settings screen — matches the "extremely simple" requirement in the spec.
