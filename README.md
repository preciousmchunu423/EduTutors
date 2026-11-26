# EduTutors

EduTutors is a mobile-first educational tutoring platform built with Flutter and Supabase. It aims to connect learners, parents and tutors through an accessible learning environment.

## Live Demo

[Click here to open EduTutors](https://6b07120d5cf65cddc9ff7414--edututors-3oi4.netlify.app)

## Project Overview

The application is developed using Flutter and Dart, following an MVVM-inspired architecture.

### Main Features

- Learner, parent and tutor dashboards
- User registration and authentication
- Tutor discovery and profiles
- Tutor availability management
- Booking and session management
- Study materials and learning resources
- Tutor qualification document management
- Organisation administration and tutor approval
- Learner progress tracking
- Payments and tutor earnings interfaces

## Technology Stack

- **Frontend:** Flutter and Dart
- **Backend and Authentication:** Supabase
- **Architecture:** Model-View-ViewModel (MVVM)
- **State Management:** Provider
- **Database:** Supabase PostgreSQL
- **Storage:** Supabase Storage

## Project Structure

```text
lib/
  main.dart
  data/
  models/
  repositories/
  viewmodels/
  theme/
  views/
    screens/
      admin/
      dashboards/
    widgets/

web/
test/
pubspec.yaml
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Visual Studio Code
- Flutter and Dart VS Code extensions

### Installation

Clone the repository:

```bash
git clone https://github.com/preciousmchunu423/EduTutors.git
cd EduTutors
```

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run the application:

```bash
flutter run -d chrome
```

### Build for Web

```bash
flutter build web --release
```

The production web files are generated in:

```text
build/web
```

## Tutor Workspace

The tutor workspace includes dedicated screens for:

- My Profile
- Availability
- Upload Content
- Live Sessions
- Earnings
- Qualification Documents

## Supabase Configuration

EduTutors uses Supabase for authentication, database operations and file storage.

Configure the appropriate Supabase project URL and public client key in the application before running it.

Never expose a Supabase service-role key or database password in the Flutter application or public repository.

## Development Status

EduTutors is an ongoing development project. Some features may require additional backend integration, testing and production configuration before being used commercially.
