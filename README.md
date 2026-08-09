# یونٹ ساتھی (Unit Saathi)

A simple, offline-first Urdu app for recording and calculating electricity meter units.

## Status: MVP scaffold

**Working now (pure Dart, fully tested):**
- Core calculation/validation logic (`lib/models/unit_record.dart`) — `کل یونٹ = آخری یونٹ − شروع کا یونٹ`, with the exact Urdu error messages from the spec.
- SQLite repository layer (`lib/db/database_helper.dart`) — name storage, record CRUD, monthly grouping/totals.
- Full screen flow: Splash → Name Entry → Home → Add Unit → Monthly Records (swipeable) → Calculator.
- White/black/red theme matching the app icon.
- Automated tests for every case listed in the spec (`test/unit_calculation_test.dart`).

**Also working now:**
- **PDF export** (`lib/services/export_service.dart`) — builds a proper Urdu RTL table (date / start / end / total + monthly total), using the bundled Noto Nastaliq Urdu font (`assets/fonts/NotoNastaliqUrdu.ttf`). Shares through the OS print/share sheet — fully offline.
- **Image export** (`lib/widgets/monthly_report_image_widget.dart`) — renders the same report as a styled PNG (white/black/red theme) and shares it via `share_plus`, ready for WhatsApp.
- App icon — the one you provided is saved at `assets/icon/app_icon.png`; architecture supports swapping it freely.

**Stubbed, needs a real device to build out:**
- `lib/services/ocr_service.dart` — camera capture + on-device ML Kit OCR. Interface and Urdu messages (`میٹر نمبر دوبارہ چیک کریں`, `تصویر لینے میں مسئلہ پیش آیا`) are defined; the camera preview/capture UI genuinely needs a device/emulator to build and tune, so it's left as a clean `TODO` rather than untested guesswork.

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
