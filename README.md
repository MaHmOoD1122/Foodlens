# Foodlens

A Flutter nutrition tracking, meal scanning, and allergen-awareness application structured around three distinct roles (**User / Patient**, **Doctor / Clinician**, and **Admin**).

## Key Features

* **Role-Based Access & Navigation:**
  * **User / Patient:** Onboarding flow (allergies, goals, body profile, and optional clinician connection), meal & allergen scanning (`scanner.dart`, `analysis_screen.dart`, `allergy_alert_screen.dart`), food search, daily meal logging, diary, stats, and profile.
  * **Doctor / Clinician:** Patient monitoring, nutrition protocols, clinical alerts, target adjustments, registration flow, clinician profile, and logout.
  * **Admin:** Clinician approvals, clinician directory, platform user management, admin profile, and logout.
* **Dynamic Per-User State:** New accounts start with empty meal/scan logs and dynamic daily calorie/macro targets based on the active user.
* **Local Mock Data:** Uses local JSON assets under `assets/data/` (`mock_db.json` and `scan_mock_db.json`) for development and testing.

## Project Structure

```text
lib/
├── main.dart
├── theme.dart
├── models.dart
├── common.dart
├── widgets.dart
├── state.dart
├── services/
│   ├── local_auth_service.dart
│   └── allergen_scan_service.dart
└── screens/
    ├── auth/
    │   ├── login.dart
    │   └── sign_up.dart
    ├── user_screens/
    │   ├── main_tabs.dart
    │   ├── home_page.dart
    │   ├── diary_page.dart
    │   ├── scanner.dart
    │   ├── analysis_screen.dart
    │   ├── allergy_alert_screen.dart
    │   ├── food_search.dart
    │   ├── stats_page.dart
    │   ├── profile_page.dart
    │   ├── allergies_page.dart
    │   ├── goal_page.dart
    │   ├── body_profile_page.dart
    │   ├── connect_doctor_page.dart
    │   └── done_page.dart
    ├── doctor_screens/
    │   ├── doctor_shell.dart
    │   ├── doctor_profile_page.dart
    │   ├── patients_page.dart
    │   ├── protocols_page.dart
    │   ├── alerts_page.dart
    │   ├── targets_sheet.dart
    │   └── register_page.dart
    └── admin_screens/
        ├── admin_shell.dart
        ├── admin_profile_screen.dart
        ├── clinician_approvals_screen.dart
        ├── clinician_directory_screen.dart
        └── platform_users_screen.dart
```

## How to Run the Project

### 1. Prerequisites

* Flutter SDK installed and added to PATH (`flutter --version`)
* Dart SDK (included with Flutter)
* An IDE (**VS Code** or **Android Studio**) with Flutter & Dart extensions installed
* At least one target device:
  * Android Emulator / iOS Simulator
  * Physical Android or iOS device (with USB Debugging enabled)
  * Chrome (Web) or Windows/macOS/Linux Desktop

Verify your setup before running:

```bash
flutter doctor
```

### 2. Clone & Install Dependencies

1. **Clone the repository:**

   ```bash
   git clone [https://github.com/MaHmOoD1122/Foodlens.git](https://github.com/MaHmOoD1122/Foodlens.git)
   cd Foodlens
   ```

2. **Fetch Flutter packages:**

   ```bash
   flutter pub get
   ```

### 3. Running Methods

#### Method A: Using the Terminal (CLI)

* **Run on the default connected device / emulator:**

  ```bash
  flutter run
  ```

* **List all available devices and choose one:**

  ```bash
  flutter devices
  flutter run -d <device_id>
  ```

* **Run on specific platforms:**

  ```bash
  # Android Emulator or connected Android phone
  flutter run -d android

  # iOS Simulator (macOS only)
  flutter run -d ios

  # Google Chrome (Web)
  flutter run -d chrome

  # Windows Desktop
  flutter run -d windows
  ```

#### Method B: Using VS Code

1. Open the cloned project folder in **VS Code**.
2. Open `lib/main.dart`.
3. Select your target device from the bottom-right status bar (e.g., Android Emulator, Chrome, or Windows).
4. Press **`F5`** (Run with Debugging) or **`Ctrl + F5`** (Run without Debugging).

#### Method C: Using Android Studio

1. Open Android Studio and select **Open**, then choose the project folder.
2. Wait for Gradle and Flutter indexing to finish, and run **Pub get** if prompted.
3. Select an emulator or connected device from the top toolbar.
4. Click the green **Run (`▶`)** button (or press **`Shift + F10`**).

### 4. Useful Troubleshooting Commands

* **Fix dependency or build cache issues:**

  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

* **Check code for warnings or errors:**

  ```bash
  flutter analyze
  ```
