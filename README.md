# smart_freshness_sticker

# Smart Freshness Sticker

A cross-platform mobile application built with Flutter that uses computer vision to detect food freshness by analyzing colored stickers on food packages.

## Features

### 🎯 Core Functionality

- **Camera Scanning**: Scan colored freshness stickers with your phone camera
- **Color Detection**: Advanced color analysis to detect purple, green, and yellow stickers
- **Freshness Classification**: Automatically classify food as "Fresh", "Use Soon", or "Spoiled"
- **Local Storage**: Save scanned items locally with Hive database
- **Smart Notifications**: Get notified when items are about to expire

### 📱 User Interface

- **Material 3 Design**: Modern and intuitive user interface
- **Tabbed Navigation**: Organize items by freshness status
- **Real-time Camera Preview**: Live camera feed with scanning guides
- **Item Management**: Add, edit, and delete saved items

### 🔧 Technical Features

- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **Cross-platform**: Works on both Android and iOS
- **Offline-first**: No internet required, all data stored locally
- **Permission Management**: Handles camera and notification permissions gracefully

## Architecture

The app follows Clean Architecture principles:

```
lib/
├── core/
│   ├── services/          # Core services (notifications, color detection)
│   └── utils/            # Utility functions
├── data/
│   ├── datasources/      # Hive local database
│   ├── models/           # Data models with Hive annotations
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
└── presentation/
    ├── pages/           # App screens
    ├── providers/       # State management with Provider
    └── widgets/         # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.0 or later)
- Dart SDK (3.9.0 or later)
- Android Studio / VS Code with Flutter extensions
- Physical device or emulator (camera access required)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd smart_freshness_sticker
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code (Hive adapters)**

   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-specific Setup

#### Android

The app requires the following permissions (already configured):

- `CAMERA`: To scan stickers
- `POST_NOTIFICATIONS`: For expiry notifications
- `WRITE_EXTERNAL_STORAGE`: For image processing

#### iOS

Required permissions are configured in `ios/Runner/Info.plist`:

- `NSCameraUsageDescription`: Camera access for scanning
- `NSPhotoLibraryUsageDescription`: Photo library access

## Usage

### 1. Scanning Items

1. Tap the "Scan Sticker" button on the home screen
2. Point your camera at a colored freshness sticker
3. Position the sticker within the scanning frame
4. Tap the capture button to analyze the color
5. Review the detected freshness status
6. Save the item with a name and optional notes

### 2. Managing Items

- View all items in the "All" tab
- Filter by freshness status using the tabs (Fresh, Use Soon, Spoiled)
- Tap the menu on item cards to edit or delete
- Pull down to refresh the list

### 3. Notifications

- The app automatically schedules notifications for items nearing expiry
- Notifications are sent 1 day before the predicted spoilage date
- Manage notification permissions through device settings

## Color Detection Algorithm

The app uses advanced computer vision techniques:

1. **Image Preprocessing**: Converts camera input to processable format
2. **Region of Interest**: Analyzes the center region of the captured image
3. **Color Space Conversion**: RGB to HSV for better color analysis
4. **Color Classification**: Uses hue, saturation, and value thresholds
5. **Confidence Scoring**: Provides accuracy percentage for detection

### Supported Colors

- **Green**: Fresh items (7-day predicted shelf life)
- **Yellow**: Use Soon items (2-day predicted shelf life)
- **Purple**: Spoiled items (immediate consumption not recommended)

## Dependencies

### Core Flutter Dependencies

- `flutter`: Flutter SDK
- `provider`: State management
- `go_router`: Navigation and routing
- `camera`: Camera functionality
- `image`: Image processing

### Data & Storage

- `hive`: Local NoSQL database
- `hive_flutter`: Flutter integration for Hive
- `path_provider`: File system path access

### Notifications & Permissions

- `flutter_local_notifications`: Local push notifications
- `permission_handler`: Runtime permission requests
- `timezone`: Timezone handling for notifications

### Utilities

- `intl`: Date formatting and internationalization
- `equatable`: Value equality for models
- `uuid`: Unique identifier generation

## Development

### Code Generation

Run this command when you modify Hive models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Build Release

```bash
# Android APK
flutter build apk --release

# iOS IPA (requires Mac and Xcode)
flutter build ipa --release
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the excellent framework
- Hive team for the fast NoSQL database
- Camera plugin contributors for camera functionality
- Image processing library contributors

## Roadmap

### Upcoming Features

- [ ] Cloud synchronization
- [ ] Barcode integration
- [ ] Recipe suggestions based on expiring items
- [ ] Statistics and analytics
- [ ] Dark mode improvements
- [ ] Accessibility enhancements
- [ ] Multi-language support

### Known Issues

- Color detection accuracy may vary under different lighting conditions
- Camera performance may be slower on older devices
- Initial app startup time includes camera initialization

## Support

For support, bug reports, or feature requests, please open an issue on GitHub or contact the development team.

---

**Built with ❤️ using Flutter**
