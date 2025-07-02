# Vonova Radiant

An app for Vonova Radiant for patient data entry.

## Project Overview

This Flutter application is designed for patient data management. It includes features for handling patient information, likely with connectivity to a backend service.

## Key Features & Dependencies

*   **Web Content:** Uses `flutter_inappwebview` to display web content within the app.
*   **Connectivity:** Checks for internet connectivity using `internet_connection_checker_plus`.
*   **Local Storage:** Utilizes `shared_preferences` and `hive_flutter` for data persistence.
*   **State Management:** Employs `get` for state management.
*   **UI:** Incorporates `cupertino_icons` and `fluentui_system_icons` for iconography.
*   **HTTP Requests:** Makes use of `http` and `dio` for network requests.
*   **File & Device Access:** Leverages `path_provider`, `permission_handler`, `open_file`, `package_info_plus`, and `device_info_plus` for system interactions.

## Assets

*   `assets/app_logo.png`
*   `assets/Liver_Aid.png`
*   `assets/No_Internet_Connection.png`

## Getting Started

To get started with this project, ensure you have the Flutter SDK installed. Then, run the following commands:

```bash
flutter pub get
flutter run
```