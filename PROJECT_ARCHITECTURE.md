# Openkora Gym Booking Platform - Complete Architecture

## Project Overview
Openkora is a comprehensive gym booking and community platform with **TWO separate mobile applications** sharing a **SINGLE backend API**.

---

## 📱 Applications Structure

### 1. **Customer App** (`/client`)
**Purpose:** End-users book gym slots, browse gyms, manage bookings, and participate in community

**Key Features:**
- User authentication & profile management
- Gym search & discovery
- Slot booking & payment
- My bookings management
- QR code pass for gym check-in
- Community feed access (shared with vendors)
- Physical details setup (height, weight, fitness goals)

**Screens:**
- Login/Onboarding
- Home Dashboard
- Gym Search Results
- Gym Details
- Slot Selection
- Booking Summary
- Booking Pass Detail (QR Code)
- My Bookings List
- User Profile
- Complete Profile
- Physical Details Setup
- **Community Feed** (shared)

---

### 2. **Vendor App** (`/vendor`)
**Purpose:** Gym owners manage their business, track members, scan QR codes, and engage with community

**Key Features:**
- Vendor account creation & authentication
- Gym business management
- QR code scanner for check-ins
- Member attendance tracking
- Member profile & payment details
- Revenue & transactions analytics
- Services & pricing setup
- Slot management
- Community posting (tagged as "VENDOR")
- Event creation

**Screens:**
- Vendor Account Creation
- Vendor Home & Scan Dashboard
- QR Scanner View
- Gym Business Details
- Services & Pricing Setup
- Slot Management (2 screens)
- Member Attendance & List
- Member Profile & Payment Details
- Revenue & Transactions
- Photos & Final Submission
- Onboarding Success State
- **Community Feed** (shared)
- **Create Community Post** (2 screens)
- **Post Comments View** (shared)

---

## 🌐 Community Feature (Reddit-like)

### Shared Between Customer & Vendor Apps

**Post Types:**
1. **Text Posts** - Simple thoughts, achievements, questions
2. **Image Posts** - Gym photos, progress pics, equipment showcases
3. **Motivational Posts** - Full-screen background image with quote
4. **Event Posts** - Workshops, competitions, special sessions

**Key Features:**
- Feed with tabs: Feed / Following / Events
- Like & comment system
- Vendor posts are **tagged with "VENDOR" badge**
- Vendors can reply to comments (highlighted differently)
- Create posts (text, image, or event)
- Share functionality
- Real-time engagement metrics

**Navigation:**
- Accessible from bottom nav "Community" tab in both apps
- Customers: Home → Explore → Community
- Vendors: Dashboard → Community tab

**Vendor Differentiation:**
- Vendor posts show yellow "VENDOR" badge
- Vendor profile icons show gym logo
- Vendor comments are highlighted with badge
- Vendors can create EVENT posts (special styling)

---

## 🏗️ Backend Architecture (Single Shared API)

### Technology Stack (Recommended)
- **Runtime:** Node.js with Express.js
- **Database:** PostgreSQL (relational data) + Redis (caching)
- **Authentication:** JWT tokens with role-based access
- **File Storage:** AWS S3 or Cloudinary (images, QR codes)
- **Real-time:** Socket.io (community feed updates)
- **Payment:** Stripe integration

### Database Schema (Key Tables)

#### Users Table
```
- id (UUID)
- email
- password_hash
- role (ENUM: 'customer', 'vendor')
- full_name
- phone
- profile_image_url
- created_at
- updated_at
```

#### Customers Table (extends Users)
```
- user_id (FK)
- height
- weight
- fitness_goals
- membership_tier
- member_since
```

#### Vendors Table (extends Users)
```
- user_id (FK)
- business_name
- business_license
- verification_status
- is_verified
```

#### Gyms Table
```
- id (UUID)
- vendor_id (FK)
- name
- description
- address
- latitude
- longitude
- rating
- amenities (JSON)
- photos (JSON array)
- operating_hours (JSON)
- created_at
```

#### Services Table
```
- id (UUID)
- gym_id (FK)
- name (e.g., "Day Pass", "Monthly Membership")
- price
- duration_minutes
- description
```

#### Slots Table
```
- id (UUID)
- gym_id (FK)
- service_id (FK)
- start_time
- end_time
- capacity
- booked_count
- status (ENUM: 'available', 'full', 'cancelled')
```

#### Bookings Table
```
- id (UUID)
- customer_id (FK)
- gym_id (FK)
- slot_id (FK)
- service_id (FK)
- booking_date
- qr_code_url
- status (ENUM: 'pending', 'confirmed', 'checked_in', 'completed', 'cancelled')
- payment_status
- payment_id
- total_amount
- created_at
```

#### Community Posts Table
```
- id (UUID)
- author_id (FK to Users)
- author_type (ENUM: 'customer', 'vendor')
- post_type (ENUM: 'text', 'image', 'motivation', 'event')
- content (TEXT)
- image_url
- event_date (for event posts)
- event_location
- likes_count
- comments_count
- created_at
- updated_at
```

#### Comments Table
```
- id (UUID)
- post_id (FK)
- author_id (FK to Users)
- author_type (ENUM: 'customer', 'vendor')
- content (TEXT)
- parent_comment_id (FK, for replies)
- likes_count
- created_at
```

#### Transactions Table
```
- id (UUID)
- booking_id (FK)
- vendor_id (FK)
- customer_id (FK)
- amount
- payment_method
- stripe_payment_id
- status
- created_at
```

---

## 🔐 Authentication & Authorization

### JWT Token Structure
```json
{
  "userId": "uuid",
  "email": "user@example.com",
  "role": "customer" | "vendor",
  "iat": 1234567890,
  "exp": 1234567890
}
```

### Role-Based Access Control (RBAC)

**Customer Permissions:**
- Browse gyms
- Book slots
- View own bookings
- Generate QR codes
- Post to community
- Like/comment on posts

**Vendor Permissions:**
- Manage gym profile
- Create/edit services
- Manage slots
- Scan QR codes
- View member list
- View analytics/revenue
- Post to community (with VENDOR badge)
- Create EVENT posts

---

## 📡 API Endpoints Structure

### Authentication
```
POST   /api/auth/register/customer
POST   /api/auth/register/vendor
POST   /api/auth/login
POST   /api/auth/refresh-token
POST   /api/auth/logout
```

### Customer Endpoints
```
GET    /api/gyms                    # Search gyms
GET    /api/gyms/:id                # Gym details
GET    /api/gyms/:id/slots          # Available slots
POST   /api/bookings                # Create booking
GET    /api/bookings/my-bookings    # User's bookings
GET    /api/bookings/:id/qr-code    # Get QR code
PUT    /api/customers/profile       # Update profile
```

### Vendor Endpoints
```
POST   /api/vendors/gym             # Create gym
PUT    /api/vendors/gym/:id         # Update gym
POST   /api/vendors/services        # Add service
PUT    /api/vendors/services/:id    # Update service
POST   /api/vendors/slots           # Create slots
GET    /api/vendors/bookings        # View bookings
POST   /api/vendors/check-in        # Scan QR & check-in
GET    /api/vendors/members         # Member list
GET    /api/vendors/analytics       # Revenue & stats
```

### Community Endpoints (Shared)
```
GET    /api/community/feed          # Get posts (paginated)
GET    /api/community/following     # Following feed
GET    /api/community/events        # Event posts
POST   /api/community/posts         # Create post
GET    /api/community/posts/:id     # Get post details
POST   /api/community/posts/:id/like
POST   /api/community/posts/:id/comments
POST   /api/community/comments/:id/like
DELETE /api/community/posts/:id     # Delete own post
```

---

## 🎨 Design System

### Colors
- **Primary:** `#f9f506` (Lime Yellow)
- **Background Dark:** `#000000` (Pure Black)
- **Surface Dark:** `#121212` / `#1A1A1A`
- **Card Dark:** `#1C1C1C`
- **Border:** `#262626` / `rgba(255,255,255,0.05)`

### Typography
- **Font Family:** Lexend (primary), Inter (community)
- **Weights:** 300, 400, 500, 600, 700, 900

### Border Radius
- Small: `8px`
- Medium: `12px`
- Large: `16px`
- XL: `20px`
- Full: `9999px`

---

## 🚀 Deployment Strategy

### Frontend (Flutter Apps)
- **Customer App:** Deploy to App Store & Google Play
- **Vendor App:** Separate deployment to App Store & Google Play
- **Web Version:** Optional web build for both apps

### Backend (Node.js API)
- **Hosting:** AWS EC2, DigitalOcean, or Heroku
- **Database:** AWS RDS (PostgreSQL)
- **Cache:** Redis Cloud or AWS ElastiCache
- **Storage:** AWS S3 for images/QR codes
- **CDN:** CloudFront for static assets

### CI/CD Pipeline
- GitHub Actions or GitLab CI
- Automated testing
- Staging environment
- Production deployment

---

## 📊 Key Integrations

1. **Payment Gateway:** Stripe
2. **Maps:** Google Maps API (location, geocoding)
3. **Push Notifications:** Firebase Cloud Messaging
4. **Analytics:** Google Analytics / Mixpanel
5. **QR Code Generation:** qrcode library (Node.js)
6. **Image Processing:** Sharp (Node.js) or Cloudinary
7. **Email Service:** SendGrid or AWS SES

---

## 🔄 Real-time Features

### Socket.io Events
- `community:new_post` - New post in feed
- `community:new_comment` - New comment on post
- `community:like` - Real-time like updates
- `booking:confirmed` - Booking confirmation
- `vendor:check_in` - Customer checked in

---

## 📱 Mobile App Structure (Flutter)

### Customer App (`/client/lib`)
```
lib/
├── core/
│   ├── models/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── home/
│   ├── gym/
│   ├── booking/
│   ├── profile/
│   ├── community/        # NEW
│   └── onboarding/
└── main.dart
```

### Vendor App (`/vendor/lib`) - TO BE CREATED
```
lib/
├── core/
│   ├── models/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── gym_management/
│   ├── members/
│   ├── analytics/
│   ├── scanner/
│   ├── community/        # SHARED
│   └── onboarding/
└── main.dart
```

---

## ✅ Implementation Checklist

### Phase 1: Backend Setup
- [ ] Initialize Node.js project
- [ ] Set up PostgreSQL database
- [ ] Create database schema & migrations
- [ ] Implement authentication (JWT)
- [ ] Build customer endpoints
- [ ] Build vendor endpoints
- [ ] Build community endpoints
- [ ] Integrate Stripe payment
- [ ] QR code generation
- [ ] Deploy to staging

### Phase 2: Customer App
- [ ] Already implemented (current `/client`)
- [ ] Add community feature
- [ ] Integrate with backend API
- [ ] Payment integration
- [ ] QR code display
- [ ] Testing & bug fixes

### Phase 3: Vendor App
- [ ] Create new Flutter project
- [ ] Implement vendor authentication
- [ ] Dashboard with stats
- [ ] QR scanner functionality
- [ ] Member management
- [ ] Analytics & revenue
- [ ] Community integration
- [ ] Testing & bug fixes

### Phase 4: Community Feature
- [ ] Backend API (posts, comments, likes)
- [ ] Real-time updates (Socket.io)
- [ ] Customer app integration
- [ ] Vendor app integration
- [ ] Vendor badge system
- [ ] Event posts
- [ ] Image uploads

### Phase 5: Testing & Launch
- [ ] End-to-end testing
- [ ] Security audit
- [ ] Performance optimization
- [ ] App Store submission (Customer)
- [ ] App Store submission (Vendor)
- [ ] Production deployment

---

## 🎯 Next Steps

1. **Confirm architecture** - Review and approve this structure
2. **Set up backend** - Initialize Node.js project with database
3. **Create vendor Flutter app** - Separate project for vendor features
4. **Implement community** - Add to both customer and vendor apps
5. **API integration** - Connect both apps to backend
6. **Testing** - Comprehensive testing of all features
7. **Deployment** - Launch to production

---

**Questions to Address:**
1. Do you want to start with backend implementation first?
2. Should we create the vendor Flutter app structure?
3. Any specific features you want to prioritize?
4. Do you have preferences for hosting/cloud providers?
