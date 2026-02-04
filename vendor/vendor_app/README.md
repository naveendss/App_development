# Openkora Vendor App

Gym management application for gym owners and operators.

## Features

### 1. Authentication
- Vendor account creation (4-step onboarding)
- Login with email/password
- Password recovery

### 2. Dashboard
- Today's summary (check-ins, active slots, revenue)
- Upcoming bookings list
- Quick access to QR scanner
- Real-time statistics

### 3. QR Scanner
- Scan customer QR codes for check-in
- Validate bookings
- Mark attendance
- View customer details

### 4. Gym Management
- Business details setup
- Services & pricing configuration
- Slot management (create, edit, delete)
- Photos & gallery management
- Operating hours setup

### 5. Members
- Member list with search
- Member profiles
- Payment history
- Attendance tracking
- Membership status

### 6. Analytics
- Revenue & transactions
- Daily/weekly/monthly reports
- Popular time slots
- Member growth charts
- Booking trends

### 7. Community (Shared with Customer App)
- Create posts (text, image, event)
- Posts tagged with "VENDOR" badge
- Engage with customer posts
- Event creation & management
- Community feed

## Screens to Implement

### Auth Flow
- [ ] `vendor_account_creation_screen.dart` - Step 1: Basic info
- [ ] `business_details_screen.dart` - Step 2: Business info
- [ ] `services_pricing_screen.dart` - Step 3: Services setup
- [ ] `photos_submission_screen.dart` - Step 4: Photos
- [ ] `onboarding_success_screen.dart` - Success state
- [ ] `login_screen.dart` - Vendor login

### Dashboard
- [ ] `dashboard_screen.dart` - Main vendor home
- [ ] `upcoming_bookings_screen.dart` - Detailed bookings list

### Scanner
- [ ] `qr_scanner_screen.dart` - QR code scanner
- [ ] `check_in_success_screen.dart` - Check-in confirmation

### Gym Management
- [ ] `gym_profile_screen.dart` - View/edit gym details
- [ ] `slot_management_screen.dart` - Manage time slots
- [ ] `services_management_screen.dart` - Manage services

### Members
- [ ] `members_list_screen.dart` - All members
- [ ] `member_detail_screen.dart` - Individual member profile
- [ ] `member_attendance_screen.dart` - Attendance history

### Analytics
- [ ] `analytics_screen.dart` - Revenue & stats dashboard
- [ ] `transactions_screen.dart` - Transaction history

### Community (Copy from Customer App)
- [ ] `community_feed_screen.dart` - Shared feed
- [ ] `create_post_screen.dart` - Create posts (with vendor badge)
- [ ] `post_detail_screen.dart` - Post comments

## Project Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── vendor_model.dart
│   │   ├── booking_model.dart
│   │   ├── member_model.dart
│   │   └── transaction_model.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── qr_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── widgets/
│       ├── stat_card.dart
│       ├── booking_card.dart
│       └── member_card.dart
├── features/
│   ├── auth/
│   │   └── presentation/
│   ├── dashboard/
│   │   └── presentation/
│   ├── scanner/
│   │   └── presentation/
│   ├── gym_management/
│   │   └── presentation/
│   ├── members/
│   │   └── presentation/
│   ├── analytics/
│   │   └── presentation/
│   └── community/
│       └── presentation/
└── main.dart
```

## Setup Instructions

1. Install dependencies:
```bash
cd vendor/vendor_app
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Key Differences from Customer App

1. **Role**: Vendor (gym owner) vs Customer
2. **Main Feature**: QR Scanner for check-ins
3. **Dashboard**: Business metrics instead of workout tracking
4. **Community**: Posts tagged with "VENDOR" badge
5. **Navigation**: Dashboard-centric instead of gym discovery

## Next Steps

1. ✅ Create project structure
2. ✅ Set up theme and routing
3. ⏳ Implement authentication screens
4. ⏳ Build dashboard with stats
5. ⏳ Add QR scanner functionality
6. ⏳ Create member management
7. ⏳ Implement analytics
8. ⏳ Copy community feature from customer app
9. ⏳ Connect to backend API
10. ⏳ Testing & deployment
