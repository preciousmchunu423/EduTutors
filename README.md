# EduTutors — Flutter MVVM project

This folder contains the complete Dart application source supplied in the original `edututors_lib.zip`, reorganised into a first-phase MVVM structure, plus a Flutter `pubspec.yaml` so it can be opened as a project in Visual Studio Code.

## Open in Visual Studio Code

1. Download and extract `EduTutors_MVVM_Complete_Project.zip` (do not try to open the ZIP as a folder).
2. Open Visual Studio Code.
3. Select **File → Open Folder...**
4. Select the extracted folder named `EduTutors_MVVM_Complete_Project`.
5. If prompted, install the recommended **Flutter** and **Dart** extensions.
6. Open **Terminal → New Terminal** in VS Code.

## Create the platform folders

The uploaded source archive contained `lib/` and a README, but did not include the generated Android/iOS/web platform folders. In the VS Code terminal, run:

```bash
flutter create . --platforms=android,web
```

This creates the Flutter platform scaffolding in this folder. If you also need Windows desktop support, use:

```bash
flutter create . --platforms=android,web,windows
```

## Install packages and run

Run these commands in the VS Code terminal, one at a time:

```bash
flutter doctor
flutter pub get
flutter analyze
flutter run
```

For Android, start an Android emulator or connect an Android phone with USB debugging enabled before `flutter run`. For a browser run:

```bash
flutter run -d chrome
```

## Project structure

```text
lib/
  main.dart
  models/
  repositories/
  viewmodels/
  views/
    screens/
    widgets/
  data/
  theme/
```

- **Views** display screens and collect user input.
- **ViewModels** manage observable state and coordinate UI operations.
- **Models** represent application data.
- **Repositories** handle local persistence.
- **Services** can be added as external integrations are introduced.

## Important notes

- The original upload contained only the Dart `lib/` source and README, not a full generated Flutter project. This package adds the Flutter package manifest and VS Code recommendations; platform folders are generated on your computer using `flutter create .`.
- This is the Phase 1 refactor. It keeps the existing screen code and moves the existing provider logic into ViewModels and repositories.
- Authentication and bookings still use local `SharedPreferences`; this is not production-grade server authentication or multi-device synchronisation.
- I checked that relative Dart imports in the refactored source resolve within `lib/`. I could not run Flutter/Dart analysis in this environment, so run `flutter analyze` locally and share any errors for correction.

## Tutor workspace screens

The tutor dashboard now opens dedicated screens for:
- My Profile (bio, qualifications, subjects and hourly rate)
- Availability (days and daily time window)
- Upload Content (saved learning-resource details and optional resource links)
- Live Sessions (upcoming booked sessions)
- Earnings (estimated value from completed and upcoming bookings)

Tutor profile, availability and resource metadata are stored locally on the device through SharedPreferences using a tutor-specific repository and ViewModel. These are frontend/local prototypes: actual file uploads, live video meetings, payment processing and payout settlement require a backend and external services. The earnings page uses the booking price as an estimate, not proof of payment.
