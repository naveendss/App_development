# Deployment Guide

## Pre-Deployment Checklist

### 1. Update App Configuration

#### App Name
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Openkora"
    ...>
```

#### Package Name
Current: `com.example.openkora_gym`
To change, update:
- `android/app/build.gradle` → `applicationId`
- `android/app/src/main/AndroidManifest.xml` → `package`
- `android/app/src/main/kotlin/com/example/openkora_gym/MainActivity.kt` → package path

#### Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+buildNumber
```

### 2. Configure App Icon

1. Place your app icon (1024x1024 PNG) in `assets/icons/app_icon.png`
2. Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/icons/app_icon.png"
```
3. Run: `flutter pub run flutter_launcher_icons`

### 3. Setup Signing (Required for Release)

#### Create Keystore
```bash
keytool -genkey -v -keystore ~/openkora-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias openkora
```

#### Configure Signing
Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=openkora
storeFile=/path/to/openkora-key.jks
```

Edit `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

## Build Commands

### Debug Build (Testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build (Production)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs (Smaller Size)
```bash
flutter build apk --split-per-abi
```
Generates separate APKs for:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit x86)

### App Bundle (Google Play)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Obfuscated Build (Security)
```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols
```

## Google Play Store Deployment

### 1. Create Google Play Console Account
- Go to https://play.google.com/console
- Pay $25 one-time registration fee
- Complete account setup

### 2. Create App
1. Click "Create app"
2. Fill in app details:
   - App name: Openkora
   - Default language: English
   - App type: App
   - Category: Health & Fitness
   - Free/Paid: Free

### 3. Complete Store Listing
- **App details**: Name, short description, full description
- **Graphics**: Icon, feature graphic, screenshots
- **Categorization**: Health & Fitness
- **Contact details**: Email, website, privacy policy
- **Store presence**: Countries/regions

### 4. Content Rating
- Complete questionnaire
- Get rating (likely Everyone or Teen)

### 5. App Content
- Privacy policy URL (required)
- Ads declaration
- Target audience
- Data safety

### 6. Release Setup

#### Internal Testing (Optional)
1. Create internal testing release
2. Upload AAB file
3. Add testers via email
4. Test thoroughly

#### Production Release
1. Go to "Production" → "Create new release"
2. Upload `app-release.aab`
3. Add release notes
4. Review and rollout

### 7. Review Process
- Google reviews app (1-7 days)
- Fix any issues if rejected
- App goes live after approval

## Firebase Setup (Optional)

### 1. Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create new project
3. Add Android app

### 2. Download Configuration
- Download `google-services.json`
- Place in `android/app/`

### 3. Update Gradle Files

`android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

`android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

### 4. Initialize in App
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}
```

## Backend Integration

### 1. Update API Base URL
Edit `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'https://api.openkora.com/api/v1';
```

### 2. Environment Configuration
Create environment files:

`lib/core/config/env_dev.dart`:
```dart
class Environment {
  static const String apiUrl = 'https://dev-api.openkora.com/api/v1';
  static const String environment = 'development';
}
```

`lib/core/config/env_prod.dart`:
```dart
class Environment {
  static const String apiUrl = 'https://api.openkora.com/api/v1';
  static const String environment = 'production';
}
```

### 3. Build with Environment
```bash
flutter build apk --release --dart-define=ENV=production
```

## Performance Optimization

### 1. Enable R8/ProGuard
`android/app/build.gradle`:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Optimize Images
- Use WebP format
- Compress images
- Use appropriate resolutions

### 3. Code Optimization
```bash
flutter build apk --release --target-platform android-arm64
```

## Testing Before Release

### 1. Test on Real Devices
- Test on multiple Android versions (API 21+)
- Test on different screen sizes
- Test on low-end devices

### 2. Performance Testing
```bash
flutter run --profile
```

### 3. Check APK Size
```bash
flutter build apk --analyze-size
```

### 4. Test Flows
- [ ] Complete onboarding flow
- [ ] Browse and search gyms
- [ ] Book equipment slot
- [ ] Book pass
- [ ] View bookings
- [ ] Profile management
- [ ] Logout and login

## Post-Deployment

### 1. Monitor Crashes
- Setup Firebase Crashlytics
- Monitor Play Console crash reports

### 2. Analytics
- Setup Firebase Analytics
- Track user flows
- Monitor conversion rates

### 3. User Feedback
- Monitor Play Store reviews
- Respond to user feedback
- Plan updates based on feedback

### 4. Updates
- Regular bug fixes
- Feature updates
- Security patches

## Rollback Plan

If issues occur after release:

1. **Immediate**: Halt rollout in Play Console
2. **Fix**: Address critical issues
3. **Test**: Thorough testing of fix
4. **Release**: New version with fix
5. **Monitor**: Watch for issues

## Compliance

### Privacy Policy
Required for Play Store. Include:
- Data collection practices
- Data usage
- Third-party services
- User rights
- Contact information

### Terms of Service
Include:
- User responsibilities
- Service limitations
- Liability disclaimers
- Termination conditions

### GDPR Compliance (if applicable)
- User consent for data collection
- Right to data deletion
- Data portability
- Privacy by design

## Support Channels

Setup:
- Support email
- FAQ page
- In-app help
- Social media channels

## Monitoring Tools

Recommended:
- Firebase Crashlytics (crash reporting)
- Firebase Analytics (user behavior)
- Firebase Performance (app performance)
- Play Console (reviews, ratings, installs)

## Version Management

Semantic versioning: MAJOR.MINOR.PATCH+BUILD

Example:
- `1.0.0+1` - Initial release
- `1.0.1+2` - Bug fix
- `1.1.0+3` - New feature
- `2.0.0+4` - Major update

Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

---

## Quick Deployment Checklist

- [ ] Update app name and package
- [ ] Configure app icon
- [ ] Setup signing keystore
- [ ] Build release APK/AAB
- [ ] Test on real devices
- [ ] Create Play Console account
- [ ] Complete store listing
- [ ] Upload app bundle
- [ ] Submit for review
- [ ] Monitor for issues
- [ ] Respond to feedback

**Good luck with your deployment! 🚀**
