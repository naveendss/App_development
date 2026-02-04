# Quick Start Guide

## Run the App in 3 Steps

### 1️⃣ Install Dependencies
```bash
flutter pub get
```

### 2️⃣ Run the App
```bash
flutter run
```

### 3️⃣ Test the Flow
1. **Splash** → Auto-navigates to Login (2 seconds)
2. **Login** → Enter any phone number → Click "Send OTP"
3. **OTP** → Enter any 6 digits → Click "Verify & Continue"
4. **Physical Details** → Fill height, weight, gender → Continue
5. **Complete Profile** → Fill name, age, fitness goal → Continue
6. **Home** → Browse gyms, tap on a gym card
7. **Gym Detail** → Click "Secure Your Spot"
8. **Slot Selection** → Pick a date and time slot → Proceed
9. **Booking Summary** → Review details → Confirm & Pay
10. **Success** → View booking ID → Go to My Bookings

## Navigation Shortcuts

### From Home Screen:
- **Search Bar** → Gym Listing
- **Gym Card** → Gym Detail
- **Profile Icon** → Profile Screen
- **Bottom Nav** → Switch between sections

### From Profile:
- **My Bookings** → View active and past bookings
- **Logout** → Back to Login

## Test Credentials

**Phone Number**: Any 10-digit number (e.g., 1234567890)
**OTP**: Any 6 digits (e.g., 123456)

## Build APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Issue: "Waiting for another flutter command to release the startup lock"
```bash
killall -9 dart
flutter run
```

### Issue: Gradle build failed
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working
Press `R` (capital R) for hot restart instead of `r`

## Key Features to Test

✅ **Splash Animation** - 2 second delay
✅ **OTP Input** - Auto-focus next field
✅ **Date Picker** - Horizontal scroll
✅ **Slot Selection** - Available/Booked/Selected states
✅ **Bottom Navigation** - Center floating button
✅ **Image Loading** - Cached network images
✅ **Empty States** - Past bookings tab
✅ **Form Validation** - All input screens

## Design Elements to Notice

🎨 **Primary Color**: Lime yellow (#D4E93E)
🎨 **Dark Theme**: Pure black background
🎨 **Lexend Font**: Google Fonts
🎨 **Rounded Corners**: 12-24px radius
🎨 **Material Icons**: Outlined style
🎨 **Smooth Animations**: Page transitions

## Next Steps

1. **Connect Backend**: Update API base URL in `lib/core/services/api_service.dart`
2. **Add Real Data**: Replace `MockDataService` with API calls
3. **Add Payment**: Integrate Razorpay/Stripe
4. **Add Firebase**: Push notifications and analytics
5. **Test on Device**: Deploy to physical Android device

## Useful Commands

```bash
# Check Flutter setup
flutter doctor

# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Hot reload
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Quit
Press 'q' in terminal

# Clear cache
flutter clean

# Analyze code
flutter analyze
```

## Support

For issues or questions:
1. Check `SETUP.md` for detailed setup instructions
2. Check `PROJECT_SUMMARY.md` for architecture details
3. Check `README.md` for feature documentation

---

**Happy Coding! 🚀**
