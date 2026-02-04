# Openkora - Gym Equipment & Pass Booking Platform

A Flutter mobile application (Android-first) for booking gym equipment and passes. Built with clean architecture, Riverpod state management, and modern UI/UX design.

## Features

### 🎯 Core Functionality
- **Authentication**: Mobile OTP-based login with dummy validation
- **Onboarding**: Physical details and profile completion flow
- **Home Dashboard**: Location-based gym discovery with category filters
- **Gym Listings**: Search and filter gyms by price, rating, and equipment
- **Gym Details**: View facilities, equipment, and pass options
- **Slot Booking**: Date and time slot selection with availability status
- **Booking Management**: View active and past bookings
- **User Profile**: Manage account and preferences

### 🎨 Design
- **Dark Theme**: Professional fitness-focused UI with lime-yellow accent (#D4E93E)
- **Lexend Font**: Clean, modern typography
- **Material Design 3**: Latest Flutter design system
- **Responsive**: Optimized for Android devices

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod 2.4.9
- **Navigation**: GoRouter 12.1.3
- **Networking**: Dio 5.4.0 (API-ready)
- **UI**: Google Fonts, Cached Network Image
- **Architecture**: Clean Architecture with feature-based structure

## Project Structure

```
lib/
├── core/
│   ├── models/          # Data models (Gym, Booking, User)
│   ├── services/        # API service & mock data
│   ├── theme/           # App theme configuration
│   ├── router/          # Navigation setup
│   └── widgets/         # Reusable components (GymCard, SlotTile, etc.)
├── features/
│   ├── splash/          # Splash screen
│   ├── auth/            # Login & OTP screens
│   ├── onboarding/      # Profile setup screens
│   ├── home/            # Home dashboard
│   ├── gym/             # Gym listing & details
│   ├── booking/         # Booking flow screens
│   └── profile/         # User profile & bookings
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd openkora_gym
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build APK
```bash
flutter build apk --release
```

## API Integration

The app is structured to easily connect to a FastAPI backend:

### Endpoints Structure
```
/api/v1/auth/send-otp
/api/v1/auth/verify-otp
/api/v1/gyms
/api/v1/gyms/:id
/api/v1/bookings
/api/v1/bookings/user/:userId
/api/v1/passes/:gymId
```

### Configuration
Update the base URL in `lib/core/services/api_service.dart`:
```dart
static const String baseUrl = 'YOUR_API_URL/api/v1';
```

## Mock Data

Currently uses dummy data from `MockDataService` for:
- Gym listings with images, ratings, and facilities
- Time slot availability
- User bookings (active & past)
- Fitness goals and categories

## Screens

1. **Splash Screen** - App branding
2. **Login Screen** - Mobile number input
3. **OTP Screen** - 6-digit OTP verification
4. **Physical Details** - Height, weight, gender
5. **Complete Profile** - Name, age, fitness goal
6. **Home Screen** - Location, search, categories, nearby gyms
7. **Gym Listing** - Filtered gym results
8. **Gym Detail** - Facilities, passes, equipment
9. **Slot Selection** - Date picker, time slots
10. **Booking Summary** - Review booking details
11. **Booking Success** - Confirmation with booking ID
12. **Profile** - User info and menu
13. **My Bookings** - Active and past bookings

## Key Components

### Reusable Widgets
- **GymCard**: Displays gym info with image, rating, price
- **CategoryChip**: Filter chips for equipment categories
- **SlotTile**: Time slot selection with availability states

### State Management
- Riverpod providers for routing and future state management
- Ready for user authentication, booking, and gym data providers

## Design System

### Colors
- **Primary**: #D4E93E (Lime Yellow)
- **Background**: #000000 (Pure Black)
- **Surface**: #121212 (Dark Gray)
- **Card**: #1A1A1A

### Typography
- **Font Family**: Lexend
- **Sizes**: 10px - 32px
- **Weights**: 300 - 900

## Future Enhancements

- [ ] Payment gateway integration (Razorpay/Stripe)
- [ ] Real-time slot availability
- [ ] Push notifications
- [ ] Location services & maps
- [ ] Favorites/wishlist
- [ ] Reviews and ratings
- [ ] Social login (Google, Apple)
- [ ] Workout tracking
- [ ] Pass management

## License

This project is proprietary and confidential.

## Support

For issues or questions, contact the development team.
