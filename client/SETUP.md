# Setup Guide

## Quick Start

### 1. Install Flutter Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
# For Android
flutter run

# For specific device
flutter devices
flutter run -d <device-id>
```

### 3. Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --split-per-abi
```

## Development Workflow

### Hot Reload
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Code Generation (if needed in future)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

## Testing

### Run Tests
```bash
flutter test
```

### Check Code Quality
```bash
flutter analyze
```

## Troubleshooting

### Common Issues

**1. Gradle Build Failed**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**2. Package Version Conflicts**
```bash
flutter pub upgrade
```

**3. Android License Issues**
```bash
flutter doctor --android-licenses
```

**4. Cache Issues**
```bash
flutter pub cache repair
```

## Environment Setup

### Android Studio
1. Install Android Studio
2. Install Flutter & Dart plugins
3. Configure Android SDK (API 21+)
4. Create AVD (Android Virtual Device)

### VS Code
1. Install Flutter extension
2. Install Dart extension
3. Configure Flutter SDK path
4. Use `Ctrl+Shift+P` → "Flutter: New Project"

## App Configuration

### Change App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
    ...>
```

### Change Package Name
Use `change_app_package_name` package or manually update:
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/.../MainActivity.kt`

### App Icon
1. Place icon in `assets/icons/app_icon.png`
2. Use `flutter_launcher_icons` package
3. Run: `flutter pub run flutter_launcher_icons`

## Backend Integration

### Update API Base URL
Edit `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-api.com/api/v1';
```

### Add Authentication Token
Modify `ApiService` to include auth headers:
```dart
_dio.options.headers['Authorization'] = 'Bearer $token';
```

## Performance Optimization

### Enable Obfuscation
```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Reduce APK Size
- Use `--split-per-abi`
- Remove unused resources
- Enable ProGuard/R8 in `android/app/build.gradle`

## Deployment

### Google Play Store
1. Create keystore: `keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key`
2. Configure `android/key.properties`
3. Update `android/app/build.gradle`
4. Build: `flutter build appbundle --release`
5. Upload to Play Console

### Firebase (Optional)
1. Add `google-services.json` to `android/app/`
2. Update `android/build.gradle` and `android/app/build.gradle`
3. Initialize Firebase in `main.dart`

## Useful Commands

```bash
# Check Flutter installation
flutter doctor -v

# List connected devices
flutter devices

# Run with specific flavor
flutter run --flavor dev

# Generate app bundle
flutter build appbundle

# Profile app performance
flutter run --profile

# Check app size
flutter build apk --analyze-size
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)
