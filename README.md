# Fast Health Check App

A wellness tracking app built with Flutter that allows users to monitor their calorie intake, exercise, and water consumption. It also provides an onboarding flow for user setup and data persistence.

---

## Features

- Track daily calorie intake and burned calories through exercises.
- Monitor water intake with visual progress indicators.
- Personalized user profiles with activity goals.
- Interactive onboarding flow for new users.
- Data persistence with local storage.

---

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your system.
- A working installation of [Dart](https://dart.dev/get-dart).
- Either:
  - Chrome browser for web-based testing.
  - Windows environment for desktop testing.

---

## Setup Instructions

### 1. Install Flutter

Follow the [official Flutter installation guide](https://flutter.dev/docs/get-started/install) for your operating system.

Once installed, verify your setup by running:

```bash
flutter doctor
```

### 2. Clone the Repository

Clone the project from your version control platform:

```bash
git clone <repository-url>
cd <repository-folder>
```

### 3. Install Dependencies

Navigate to the project directory and run:

```bash
flutter pub get
```

This command will fetch all the required packages listed in `pubspec.yaml`.

### 4. Set Up Your Development Environment

> You can use Visual Studio Code's Flutter Extension for a more streamlined development experience when using Flutter. Select your build target from the status bar at the bottom of the window and press F5 to run the app.

#### Web (Chrome)

Enable web support by running:

```bash
flutter config --enable-web
```

Run the project in Chrome with:

    flutter run -d chrome

#### Desktop (Windows)

Enable Windows desktop support:

```bash
flutter config --enable-windows-desktop
```

Run the project in Windows desktop mode with:

```bash
flutter run -d windows
```

### Development Commands

Run the app:

```bash
flutter run
```

Analyze code:

```bash
flutter analyze
```

Format code:

```bash
flutter format .
```

Build release version:

Web:

```bash
flutter build web
```

Windows:

```bash
flutter build windows
```

### 5. Environment Variables

Create a `.env` file in the root directory and add the following environment variables:

```bash
API_BASE_URL=http://localhost:3000
```
