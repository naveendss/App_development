# Complete Project Structure

```
App_developement/
│
├── client/                          # Customer Mobile App (Flutter)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── models/
│   │   │   ├── router/
│   │   │   │   └── app_router.dart
│   │   │   ├── services/
│   │   │   ├── theme/
│   │   │   │   └── app_theme.dart
│   │   │   └── widgets/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   └── presentation/
│   │   │   │       ├── login_screen.dart
│   │   │   │       └── otp_screen.dart
│   │   │   ├── booking/
│   │   │   │   └── presentation/
│   │   │   │       ├── slot_selection_screen.dart
│   │   │   │       ├── booking_summary_screen.dart
│   │   │   │       └── booking_success_screen.dart
│   │   │   ├── community/                    # ✅ NEW
│   │   │   │   ├── models/
│   │   │   │   │   ├── post_model.dart
│   │   │   │   │   └── comment_model.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── post_card.dart
│   │   │   │   │   └── comment_card.dart
│   │   │   │   └── presentation/
│   │   │   │       ├── community_feed_screen.dart
│   │   │   │       ├── post_detail_screen.dart
│   │   │   │       └── create_post_screen.dart
│   │   │   ├── gym/
│   │   │   │   └── presentation/
│   │   │   │       ├── gym_listing_screen.dart
│   │   │   │       └── gym_detail_screen.dart
│   │   │   ├── home/
│   │   │   │   └── presentation/
│   │   │   │       └── home_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   └── presentation/
│   │   │   │       ├── physical_details_screen.dart
│   │   │   │       └── complete_profile_screen.dart
│   │   │   ├── profile/
│   │   │   │   └── presentation/
│   │   │   │       ├── profile_screen.dart
│   │   │   │       └── my_bookings_screen.dart
│   │   │   └── splash/
│   │   │       └── presentation/
│   │   │           └── splash_screen.dart
│   │   └── main.dart
│   ├── assets/
│   │   ├── icons/
│   │   └── images/
│   ├── pubspec.yaml
│   └── README.md
│
├── vendor/
│   ├── vendor_app/                  # Vendor Mobile App (Flutter) ✅ NEW
│   │   ├── lib/
│   │   │   ├── core/
│   │   │   │   ├── models/
│   │   │   │   ├── router/
│   │   │   │   │   └── app_router.dart
│   │   │   │   ├── services/
│   │   │   │   ├── theme/
│   │   │   │   │   └── app_theme.dart
│   │   │   │   └── widgets/
│   │   │   ├── features/
│   │   │   │   ├── auth/
│   │   │   │   │   └── presentation/
│   │   │   │   │       └── (TODO: vendor auth screens)
│   │   │   │   ├── dashboard/
│   │   │   │   │   └── presentation/
│   │   │   │   │       └── dashboard_screen.dart  ✅
│   │   │   │   ├── scanner/
│   │   │   │   │   └── presentation/
│   │   │   │   │       └── (TODO: QR scanner)
│   │   │   │   ├── gym_management/
│   │   │   │   │   └── presentation/
│   │   │   │   │       └── (TODO: gym management)
│   │   │   │   ├── members/
│   │   │   │   │   └── presentation/
│   │   │   │   │       └── (TODO: member management)
│   │   │   │   ├── analytics/
│   │   │   │   │   └── presentation/
│   │   │   │   │       └── (TODO: analytics)
│   │   │   │   └── community/
│   │   │   │       └── presentation/
│   │   │   │           └── (TODO: copy from customer app)
│   │   │   └── main.dart
│   │   ├── assets/
│   │   │   ├── icons/
│   │   │   └── images/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   └── vendor_ui/                   # UI Design References (HTML)
│       ├── community_feed/
│       ├── create_community_post_1/
│       ├── create_community_post_2/
│       ├── gym_business_details/
│       ├── member_attendance_&_list/
│       ├── member_profile_&_payment_details/
│       ├── onboarding_success_state/
│       ├── photos_&_final_submission/
│       ├── post_comments_view/
│       ├── qr_scanner_view/
│       ├── revenue_&_transactions/
│       ├── services_&_pricing_setup/
│       ├── slot_management_1/
│       ├── slot_management_2/
│       ├── vendor_account_creation/
│       └── vendor_home_&_scan/
│
├── server/                          # Backend API (Node.js + Express)
│   └── (TODO: Backend implementation)
│
├── PROJECT_ARCHITECTURE.md          # Complete technical architecture
├── IMPLEMENTATION_SUMMARY.md        # Current progress & next steps
├── PROJECT_STRUCTURE.md             # This file
└── README.md                        # Main project README
```

## Key Directories Explained

### `/client` - Customer Mobile App
- **Purpose:** End-users book gyms, manage bookings, participate in community
- **Status:** ✅ Fully implemented with mock data
- **New Feature:** Community feed with Reddit-like functionality

### `/vendor/vendor_app` - Vendor Mobile App
- **Purpose:** Gym owners manage business, scan QR codes, track analytics
- **Status:** ⏳ Structure created, dashboard implemented
- **Pending:** Auth, scanner, members, analytics, community screens

### `/vendor/vendor_ui` - Design References
- **Purpose:** HTML/CSS mockups of vendor screens
- **Usage:** Reference for implementing Flutter screens

### `/server` - Backend API
- **Purpose:** Single API serving both customer and vendor apps
- **Status:** ❌ Not started
- **Tech Stack:** Node.js, Express, PostgreSQL, Redis

## Shared Features

### Community Feature
- **Location (Customer):** `/client/lib/features/community`
- **Location (Vendor):** `/vendor/vendor_app/lib/features/community` (to be copied)
- **Shared:** Same UI, same backend endpoints
- **Difference:** Vendor posts show "VENDOR" badge

### Theme
- **Location (Customer):** `/client/lib/core/theme/app_theme.dart`
- **Location (Vendor):** `/vendor/vendor_app/lib/core/theme/app_theme.dart`
- **Status:** Identical theme in both apps

## File Counts

### Customer App
- **Total Screens:** ~15 screens
- **Community Screens:** 3 screens (feed, detail, create)
- **Status:** 100% complete (UI)

### Vendor App
- **Total Screens:** ~20 screens (estimated)
- **Implemented:** 1 screen (dashboard)
- **Pending:** ~19 screens
- **Status:** ~5% complete (UI)

### Backend
- **Endpoints:** ~30 endpoints (estimated)
- **Status:** 0% complete

## Dependencies

### Customer App (`client/pubspec.yaml`)
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  google_fonts: ^6.1.0
  http: ^1.1.0
  intl: ^0.18.1
```

### Vendor App (`vendor/vendor_app/pubspec.yaml`)
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  go_router: ^12.0.0
  google_fonts: ^6.1.0
  qr_code_scanner: ^1.0.1      # For QR scanning
  qr_flutter: ^4.1.0           # For QR generation
  image_picker: ^1.0.4         # For photo uploads
  http: ^1.1.0
  dio: ^5.3.3
  intl: ^0.18.1
```

### Backend (Planned)
```json
{
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.11.0",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0",
    "stripe": "^12.0.0",
    "socket.io": "^4.6.0",
    "qrcode": "^1.5.0",
    "multer": "^1.4.5",
    "aws-sdk": "^2.1400.0"
  }
}
```

## Navigation Flow

### Customer App
```
Splash → Login → Physical Details → Complete Profile → Home
                                                         ├─ Gym Listing → Gym Detail → Slot Selection → Booking Summary → Success
                                                         ├─ Community → Post Detail
                                                         │            └─ Create Post
                                                         └─ Profile → My Bookings
```

### Vendor App
```
Login → Dashboard
        ├─ QR Scanner → Check-in Success
        ├─ Members → Member Detail
        ├─ Analytics
        ├─ Community → Post Detail
        │            └─ Create Post (with VENDOR badge)
        └─ Settings → Gym Management
                   └─ Slot Management
```

## API Endpoints Structure

```
/api
├── /auth
│   ├── POST /register/customer
│   ├── POST /register/vendor
│   ├── POST /login
│   └── POST /refresh-token
├── /gyms
│   ├── GET /
│   ├── GET /:id
│   └── GET /:id/slots
├── /bookings
│   ├── POST /
│   ├── GET /my-bookings
│   └── GET /:id/qr-code
├── /vendors
│   ├── POST /gym
│   ├── PUT /gym/:id
│   ├── POST /services
│   ├── POST /slots
│   ├── GET /bookings
│   ├── POST /check-in
│   ├── GET /members
│   └── GET /analytics
└── /community
    ├── GET /feed
    ├── POST /posts
    ├── GET /posts/:id
    ├── POST /posts/:id/like
    └── POST /posts/:id/comments
```

## Database Tables

```
users
customers
vendors
gyms
services
slots
bookings
transactions
community_posts
comments
likes
```

See `PROJECT_ARCHITECTURE.md` for detailed schema.

---

**Last Updated:** February 3, 2026
