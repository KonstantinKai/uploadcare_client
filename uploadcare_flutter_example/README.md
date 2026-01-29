# uploadcare_flutter_example

Example Flutter application demonstrating the [uploadcare_client](https://pub.dev/packages/uploadcare_client) library capabilities.

## Features

- Upload files using different API versions (v0.5, v0.6, v0.7)
- Browse and manage uploaded files
- View project information
- Face detection on images
- Image transformations showcase (resize, rotate, color adjustments, blur, filters, overlays, format conversion)

## Getting Started

### Prerequisites

- Flutter SDK installed ([installation guide](https://docs.flutter.dev/get-started/install))
- An Uploadcare account with API keys ([sign up](https://uploadcare.com/accounts/signup/))

### Setup

1. Clone the repository and navigate to the example directory:

```bash
cd uploadcare_flutter_example
```

2. Create a `.env` file in the project root with your Uploadcare API keys:

```env
UPLOADCARE_PUBLIC_KEY=your_public_key_here
UPLOADCARE_PRIVATE_KEY=your_private_key_here
```

You can find your API keys in the [Uploadcare Dashboard](https://app.uploadcare.com/projects/-/api-keys/).

3. Install dependencies:

```bash
flutter pub get
```

### Running the App

Run on a connected device or emulator:

```bash
flutter run
```

Or specify a platform:

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# macOS
flutter run -d macos

# Web
flutter run -d chrome
```

## Project Structure

- `lib/main.dart` - App entry point
- `lib/screens/` - All screen implementations
  - `home_screen.dart` - Main navigation screen
  - `upload_screen.dart` - File upload functionality
  - `files_screen.dart` - File listing and management
  - `transformations_screen.dart` - Image transformations demo
  - `face_detect_screen.dart` - Face detection feature
  - `preview_screen.dart` - Image preview
  - `file_info_screen.dart` - File details view
  - `project_info_screen.dart` - Project information

## Resources

- [Uploadcare Documentation](https://uploadcare.com/docs/)
- [uploadcare_client on pub.dev](https://pub.dev/packages/uploadcare_client)
