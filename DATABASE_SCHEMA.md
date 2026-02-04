# Openkora Gym Booking Platform - Database Schema

## Overview
This database schema supports both **Customer** and **Vendor** applications for the Openkora gym booking platform. The schema is designed to handle gym management, equipment booking, membership passes, slot management, payments, community features, and attendance tracking.

---

## Core Tables

### 1. **users**
Stores all users (both customers and vendors).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique user identifier |
| phone | VARCHAR(20) | UNIQUE, NOT NULL | Phone number for login |
| email | VARCHAR(255) | UNIQUE | Email address |
| full_name | VARCHAR(255) | NOT NULL | User's full name |
| date_of_birth | DATE | | Date of birth |
| gender | ENUM | 'male', 'female', 'non-binary', 'prefer-not-to-say' | Gender |
| profile_image_url | TEXT | | Profile picture URL |
| user_type | ENUM | NOT NULL | 'customer', 'vendor' |
| created_at | TIMESTAMP | DEFAULT NOW() | Account creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update timestamp |

**Indexes:**
- `idx_users_phone` on `phone`
- `idx_users_email` on `email`
- `idx_users_type` on `user_type`

---

### 2. **customer_profiles**
Extended profile information for customers.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Profile ID |
| user_id | UUID | FOREIGN KEY → users(id), UNIQUE | Reference to user |
| weight_kg | DECIMAL(5,2) | | Weight in kilograms |
| height_cm | DECIMAL(5,2) | | Height in centimeters |
| fitness_level | ENUM | 'beginner', 'intermediate', 'advanced' | Fitness level |
| fitness_goal | ENUM | 'weight-loss', 'muscle-gain', 'endurance', 'general-fitness' | Primary fitness goal |
| location_lat | DECIMAL(10,8) | | Current latitude |
| location_lng | DECIMAL(11,8) | | Current longitude |
| location_name | VARCHAR(255) | | Location name (e.g., "Downtown") |
| created_at | TIMESTAMP | DEFAULT NOW() | Profile creation |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

---

### 3. **gyms**
Stores gym/venue information (vendor-owned).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Gym ID |
| vendor_id | UUID | FOREIGN KEY → users(id), NOT NULL | Gym owner |
| name | VARCHAR(255) | NOT NULL | Gym name |
| description | TEXT | | Gym description |
| logo_url | TEXT | | Gym logo image |
| address | TEXT | NOT NULL | Full address |
| city | VARCHAR(100) | | City |
| state | VARCHAR(100) | | State/Province |
| zip_code | VARCHAR(20) | | Postal code |
| country | VARCHAR(100) | DEFAULT 'USA' | Country |
| latitude | DECIMAL(10,8) | | Gym latitude |
| longitude | DECIMAL(11,8) | | Gym longitude |
| phone | VARCHAR(20) | | Contact phone |
| email | VARCHAR(255) | | Contact email |
| rating | DECIMAL(3,2) | DEFAULT 0.0 | Average rating (0-5) |
| total_reviews | INT | DEFAULT 0 | Total review count |
| is_verified | BOOLEAN | DEFAULT FALSE | Verification status |
| status | ENUM | DEFAULT 'pending' | 'pending', 'active', 'suspended' |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

**Indexes:**
- `idx_gyms_vendor` on `vendor_id`
- `idx_gyms_location` on `latitude, longitude`
- `idx_gyms_status` on `status`

---

### 4. **gym_photos**
Multiple photos for each gym.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Photo ID |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Reference to gym |
| image_url | TEXT | NOT NULL | Photo URL |
| display_order | INT | DEFAULT 0 | Display order |
| is_primary | BOOLEAN | DEFAULT FALSE | Primary photo flag |
| uploaded_at | TIMESTAMP | DEFAULT NOW() | Upload timestamp |

---

### 5. **gym_facilities**
Facilities/amenities available at gyms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Facility ID |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Reference to gym |
| facility_type | VARCHAR(100) | NOT NULL | e.g., 'WiFi', 'Parking', 'Showers', 'Lockers' |
| is_available | BOOLEAN | DEFAULT TRUE | Availability status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

---

### 6. **gym_operating_hours**
Operating hours for gyms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Hours ID |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Reference to gym |
| day_type | ENUM | NOT NULL | 'weekday', 'weekend' |
| open_time | TIME | NOT NULL | Opening time |
| close_time | TIME | NOT NULL | Closing time |
| is_closed | BOOLEAN | DEFAULT FALSE | Closed on this day type |

---

### 7. **equipment**
Equipment available at gyms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Equipment ID |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Reference to gym |
| name | VARCHAR(255) | NOT NULL | Equipment name (e.g., "Treadmills") |
| description | TEXT | | Equipment description |
| image_url | TEXT | | Equipment image |
| total_units | INT | NOT NULL | Total available units |
| active_units | INT | NOT NULL | Currently active units |
| base_price_per_hour | DECIMAL(10,2) | NOT NULL | Base hourly rate |
| daily_cap_price | DECIMAL(10,2) | | Maximum daily price |
| equipment_type | VARCHAR(100) | | e.g., 'cardio', 'strength', 'cycling' |
| is_premium | BOOLEAN | DEFAULT FALSE | Premium equipment flag |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

**Indexes:**
- `idx_equipment_gym` on `gym_id`
- `idx_equipment_type` on `equipment_type`

---

### 8. **membership_passes**
Membership pass types offered by gyms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Pass ID |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Reference to gym |
| name | VARCHAR(255) | NOT NULL | Pass name (e.g., "Starter Pass") |
| description | TEXT | | Pass description |
| duration_days | INT | NOT NULL | Duration in days |
| price | DECIMAL(10,2) | NOT NULL | Pass price |
| pass_type | ENUM | NOT NULL | 'daily', 'weekly', 'monthly', 'annual' |
| includes_equipment | BOOLEAN | DEFAULT TRUE | Equipment access included |
| max_bookings_per_day | INT | | Max bookings per day |
| is_active | BOOLEAN | DEFAULT TRUE | Active status |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

---

### 9. **user_memberships**
Customer memberships/passes purchased.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Membership ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Customer reference |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym reference |
| pass_id | UUID | FOREIGN KEY → membership_passes(id), NOT NULL | Pass type |
| booking_id | VARCHAR(50) | UNIQUE, NOT NULL | Booking ID (e.g., "OK-88291") |
| start_date | DATE | NOT NULL | Membership start date |
| end_date | DATE | NOT NULL | Membership end date |
| status | ENUM | DEFAULT 'active' | 'active', 'expired', 'cancelled' |
| payment_status | ENUM | DEFAULT 'pending' | 'pending', 'paid', 'failed' |
| amount_paid | DECIMAL(10,2) | NOT NULL | Amount paid |
| qr_code_url | TEXT | | QR code for scanning |
| created_at | TIMESTAMP | DEFAULT NOW() | Purchase timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

**Indexes:**
- `idx_memberships_user` on `user_id`
- `idx_memberships_gym` on `gym_id`
- `idx_memberships_status` on `status`
- `idx_memberships_booking_id` on `booking_id`

---

### 10. **time_slots**
Available time slots for equipment/gym bookings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Slot ID |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym reference |
| equipment_id | UUID | FOREIGN KEY → equipment(id), NULL | Equipment reference (NULL for general gym) |
| date | DATE | NOT NULL | Slot date |
| start_time | TIME | NOT NULL | Start time |
| end_time | TIME | NOT NULL | End time |
| capacity | INT | NOT NULL | Total capacity |
| booked_count | INT | DEFAULT 0 | Current bookings |
| base_price | DECIMAL(10,2) | NOT NULL | Base price for slot |
| surge_multiplier | DECIMAL(3,2) | DEFAULT 1.0 | Surge pricing multiplier |
| is_surge_active | BOOLEAN | DEFAULT FALSE | Surge pricing active |
| is_available | BOOLEAN | DEFAULT TRUE | Slot availability |
| created_at | TIMESTAMP | DEFAULT NOW() | Creation timestamp |

**Indexes:**
- `idx_slots_gym_date` on `gym_id, date`
- `idx_slots_equipment_date` on `equipment_id, date`

---

### 11. **bookings**
Individual equipment/slot bookings.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Booking ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Customer reference |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym reference |
| equipment_id | UUID | FOREIGN KEY → equipment(id), NULL | Equipment reference |
| slot_id | UUID | FOREIGN KEY → time_slots(id), NOT NULL | Time slot reference |
| membership_id | UUID | FOREIGN KEY → user_memberships(id), NULL | Associated membership |
| booking_date | DATE | NOT NULL | Booking date |
| start_time | TIME | NOT NULL | Start time |
| end_time | TIME | NOT NULL | End time |
| equipment_station | VARCHAR(50) | | Specific station (e.g., "Treadmill - Station 04") |
| total_price | DECIMAL(10,2) | NOT NULL | Total booking price |
| status | ENUM | DEFAULT 'upcoming' | 'upcoming', 'active', 'completed', 'cancelled' |
| qr_code_url | TEXT | | QR code for check-in |
| checked_in_at | TIMESTAMP | | Check-in timestamp |
| created_at | TIMESTAMP | DEFAULT NOW() | Booking creation |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

**Indexes:**
- `idx_bookings_user` on `user_id`
- `idx_bookings_gym` on `gym_id`
- `idx_bookings_date` on `booking_date`
- `idx_bookings_status` on `status`

---

### 12. **attendance**
Attendance tracking for gym check-ins.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Attendance ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Customer reference |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym reference |
| booking_id | UUID | FOREIGN KEY → bookings(id), NULL | Associated booking |
| membership_id | UUID | FOREIGN KEY → user_memberships(id), NULL | Associated membership |
| check_in_time | TIMESTAMP | NOT NULL | Check-in timestamp |
| check_out_time | TIMESTAMP | | Check-out timestamp |
| scanned_by_vendor_id | UUID | FOREIGN KEY → users(id), NULL | Vendor who scanned |
| created_at | TIMESTAMP | DEFAULT NOW() | Record creation |

**Indexes:**
- `idx_attendance_user` on `user_id`
- `idx_attendance_gym` on `gym_id`
- `idx_attendance_date` on `check_in_time`

---

### 13. **payments**
Payment transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Payment ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Customer reference |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym reference |
| booking_id | UUID | FOREIGN KEY → bookings(id), NULL | Associated booking |
| membership_id | UUID | FOREIGN KEY → user_memberships(id), NULL | Associated membership |
| amount | DECIMAL(10,2) | NOT NULL | Payment amount |
| currency | VARCHAR(3) | DEFAULT 'USD' | Currency code |
| payment_method | ENUM | NOT NULL | 'visa', 'mastercard', 'apple_pay', 'google_pay' |
| payment_status | ENUM | DEFAULT 'pending' | 'pending', 'completed', 'failed', 'refunded' |
| transaction_id | VARCHAR(255) | UNIQUE | External transaction ID |
| card_last_four | VARCHAR(4) | | Last 4 digits of card |
| payment_date | TIMESTAMP | DEFAULT NOW() | Payment timestamp |
| created_at | TIMESTAMP | DEFAULT NOW() | Record creation |

**Indexes:**
- `idx_payments_user` on `user_id`
- `idx_payments_gym` on `gym_id`
- `idx_payments_status` on `payment_status`

---

### 14. **community_posts**
Community feed posts (text, image, motivation, events).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Post ID |
| author_id | UUID | FOREIGN KEY → users(id), NOT NULL | Post author |
| gym_id | UUID | FOREIGN KEY → gyms(id), NULL | Associated gym (for vendor posts) |
| post_type | ENUM | NOT NULL | 'text', 'image', 'motivation', 'event' |
| content | TEXT | | Post text content |
| image_url | TEXT | | Post image URL |
| likes_count | INT | DEFAULT 0 | Total likes |
| comments_count | INT | DEFAULT 0 | Total comments |
| shares_count | INT | DEFAULT 0 | Total shares |
| is_vendor_post | BOOLEAN | DEFAULT FALSE | Posted by vendor |
| created_at | TIMESTAMP | DEFAULT NOW() | Post creation |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

**Indexes:**
- `idx_posts_author` on `author_id`
- `idx_posts_gym` on `gym_id`
- `idx_posts_created` on `created_at DESC`

---

### 15. **community_events**
Event-specific details for event posts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Event ID |
| post_id | UUID | FOREIGN KEY → community_posts(id), UNIQUE | Associated post |
| event_name | VARCHAR(255) | NOT NULL | Event name |
| event_date | TIMESTAMP | NOT NULL | Event date and time |
| location | VARCHAR(255) | NOT NULL | Event location |
| ticket_price | DECIMAL(10,2) | DEFAULT 0.0 | Ticket price |
| banner_image_url | TEXT | | Event banner image |
| description | TEXT | | Event description |
| max_attendees | INT | | Maximum attendees |
| current_attendees | INT | DEFAULT 0 | Current registrations |
| created_at | TIMESTAMP | DEFAULT NOW() | Event creation |

---

### 16. **post_likes**
Likes on community posts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Like ID |
| post_id | UUID | FOREIGN KEY → community_posts(id), NOT NULL | Post reference |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | User who liked |
| created_at | TIMESTAMP | DEFAULT NOW() | Like timestamp |

**Unique Constraint:** `UNIQUE(post_id, user_id)`

---

### 17. **post_comments**
Comments on community posts.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Comment ID |
| post_id | UUID | FOREIGN KEY → community_posts(id), NOT NULL | Post reference |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Commenter |
| comment_text | TEXT | NOT NULL | Comment content |
| created_at | TIMESTAMP | DEFAULT NOW() | Comment timestamp |

---

### 18. **saved_gyms**
Customer's saved/favorite gyms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Save ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Customer reference |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym reference |
| created_at | TIMESTAMP | DEFAULT NOW() | Save timestamp |

**Unique Constraint:** `UNIQUE(user_id, gym_id)`

---

### 19. **reviews**
Customer reviews for gyms.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Review ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Reviewer |
| gym_id | UUID | FOREIGN KEY → gyms(id), NOT NULL | Gym being reviewed |
| rating | INT | NOT NULL, CHECK (rating >= 1 AND rating <= 5) | Rating (1-5) |
| review_text | TEXT | | Review content |
| created_at | TIMESTAMP | DEFAULT NOW() | Review timestamp |
| updated_at | TIMESTAMP | DEFAULT NOW() | Last update |

**Indexes:**
- `idx_reviews_gym` on `gym_id`
- `idx_reviews_user` on `user_id`

---

### 20. **notifications**
User notifications.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Notification ID |
| user_id | UUID | FOREIGN KEY → users(id), NOT NULL | Recipient |
| title | VARCHAR(255) | NOT NULL | Notification title |
| message | TEXT | NOT NULL | Notification message |
| notification_type | ENUM | NOT NULL | 'booking', 'payment', 'reminder', 'community', 'system' |
| is_read | BOOLEAN | DEFAULT FALSE | Read status |
| related_id | UUID | | Related entity ID |
| created_at | TIMESTAMP | DEFAULT NOW() | Notification timestamp |

**Indexes:**
- `idx_notifications_user` on `user_id`
- `idx_notifications_read` on `is_read`

---

## Relationships Summary

### Customer Flow:
1. **User** → **Customer Profile** (1:1)
2. **User** → **User Memberships** (1:N) - purchases passes
3. **User** → **Bookings** (1:N) - books equipment/slots
4. **User** → **Attendance** (1:N) - check-ins tracked
5. **User** → **Payments** (1:N) - payment history
6. **User** → **Saved Gyms** (1:N) - favorites
7. **User** → **Reviews** (1:N) - gym reviews
8. **User** → **Community Posts** (1:N) - creates posts

### Vendor Flow:
1. **User (Vendor)** → **Gyms** (1:N) - owns gyms
2. **Gym** → **Equipment** (1:N) - has equipment
3. **Gym** → **Membership Passes** (1:N) - offers passes
4. **Gym** → **Time Slots** (1:N) - manages availability
5. **Gym** → **Bookings** (1:N) - receives bookings
6. **Gym** → **Attendance** (1:N) - tracks check-ins
7. **Gym** → **Payments** (1:N) - receives payments
8. **Gym** → **Community Posts** (1:N) - vendor posts

### Booking Flow:
**Customer** → selects **Gym** → chooses **Equipment** → picks **Time Slot** → creates **Booking** → makes **Payment** → receives **QR Code** → **Attendance** tracked at check-in

---

## Key Features Supported

### Customer App:
- ✅ User authentication (phone/email)
- ✅ Profile setup (physical details, fitness goals)
- ✅ Gym search by location
- ✅ Equipment browsing
- ✅ Slot selection with availability
- ✅ Membership pass purchase
- ✅ Booking management
- ✅ QR code for check-in
- ✅ Payment processing
- ✅ Booking history
- ✅ Saved gyms
- ✅ Community feed
- ✅ Reviews and ratings

### Vendor App:
- ✅ Gym registration and onboarding
- ✅ Equipment management
- ✅ Pricing and pass configuration
- ✅ Slot management (capacity, surge pricing)
- ✅ QR code scanning for check-ins
- ✅ Member list and attendance
- ✅ Payment tracking
- ✅ Revenue analytics
- ✅ Community posts (vendor badge)
- ✅ Operating hours management

---

## Notes

1. **UUID** is used for all primary keys for better scalability and security
2. **ENUM** types should be replaced with appropriate database-specific types
3. **Timestamps** use UTC timezone
4. **Indexes** are suggested for frequently queried columns
5. **Soft deletes** can be added with `deleted_at` columns if needed
6. **Audit trails** can be added with `created_by` and `updated_by` columns
7. **File storage** URLs point to external storage (S3, Cloudinary, etc.)
8. **QR codes** are generated and stored as URLs or base64 strings
9. **Surge pricing** is calculated dynamically based on `surge_multiplier`
10. **Distance calculations** use latitude/longitude with PostGIS or similar

---

## Next Steps

1. Choose database system (PostgreSQL recommended)
2. Create migration scripts
3. Set up foreign key constraints
4. Implement database triggers for:
   - Auto-updating `booked_count` in `time_slots`
   - Auto-calculating gym `rating` from reviews
   - Auto-updating `likes_count`, `comments_count` in posts
5. Create database views for:
   - Active bookings dashboard
   - Revenue reports
   - Attendance statistics
6. Set up database backups and replication
7. Implement caching layer (Redis) for frequently accessed data
