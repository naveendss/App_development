# Openkora Gym Booking Backend

FastAPI backend for Openkora gym booking platform with PostgreSQL/Supabase.

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn app.main:app --reload

# Test API
python test_api.py
```

## API Documentation

- Swagger UI: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

## Complete Endpoints

### Authentication
- POST `/api/v1/auth/register` - Register user
- POST `/api/v1/auth/login` - Login user
- GET `/api/v1/auth/verify-token` - Verify JWT token

### Users
- GET `/api/v1/users/me` - Get current user
- PUT `/api/v1/users/me` - Update profile
- POST `/api/v1/users/customer-profile` - Create customer profile
- GET `/api/v1/users/customer-profile` - Get customer profile
- PUT `/api/v1/users/customer-profile` - Update customer profile

### Gyms
- POST `/api/v1/gyms` - Create gym (vendor)
- GET `/api/v1/gyms` - List all gyms
- GET `/api/v1/gyms/search` - Search gyms by location
- GET `/api/v1/gyms/{gym_id}` - Get gym details
- PUT `/api/v1/gyms/{gym_id}` - Update gym (vendor)
- DELETE `/api/v1/gyms/{gym_id}` - Delete gym (vendor)
- GET `/api/v1/gyms/vendor/my-gyms` - Get vendor's gyms

### Equipment
- POST `/api/v1/equipment` - Create equipment (vendor)
- GET `/api/v1/equipment/gym/{gym_id}` - List gym equipment
- GET `/api/v1/equipment/{equipment_id}` - Get equipment details
- PUT `/api/v1/equipment/{equipment_id}` - Update equipment (vendor)
- DELETE `/api/v1/equipment/{equipment_id}` - Delete equipment (vendor)

### Bookings
- POST `/api/v1/bookings` - Create booking (customer)
- GET `/api/v1/bookings/my-bookings` - Get customer bookings
- GET `/api/v1/bookings/gym/{gym_id}` - Get gym bookings (vendor)
- GET `/api/v1/bookings/{booking_id}` - Get booking details
- PUT `/api/v1/bookings/{booking_id}/cancel` - Cancel booking (customer)
- POST `/api/v1/bookings/slots` - Create time slot (vendor)
- GET `/api/v1/bookings/slots/available` - Get available slots

### Payments
- POST `/api/v1/payments` - Create payment (customer)
- GET `/api/v1/payments/my-payments` - Get customer payments
- GET `/api/v1/payments/gym/{gym_id}` - Get gym payments (vendor)
- GET `/api/v1/payments/{payment_id}` - Get payment details
- PUT `/api/v1/payments/{payment_id}/status` - Update payment status

### Memberships
- POST `/api/v1/memberships/passes` - Create membership pass (vendor)
- GET `/api/v1/memberships/passes/gym/{gym_id}` - List gym passes
- GET `/api/v1/memberships/passes/{pass_id}` - Get pass details
- PUT `/api/v1/memberships/passes/{pass_id}` - Update pass (vendor)
- POST `/api/v1/memberships/user-memberships` - Purchase membership (customer)
- GET `/api/v1/memberships/my-memberships` - Get customer memberships
- GET `/api/v1/memberships/user-memberships/{membership_id}` - Get membership details

### Attendance
- POST `/api/v1/attendance/check-in` - Check in (customer)
- PUT `/api/v1/attendance/{attendance_id}/check-out` - Check out (customer)
- GET `/api/v1/attendance/my-attendance` - Get customer attendance
- GET `/api/v1/attendance/gym/{gym_id}` - Get gym attendance (vendor)

### Reviews
- POST `/api/v1/reviews` - Create review (customer)
- GET `/api/v1/reviews/gym/{gym_id}` - Get gym reviews
- GET `/api/v1/reviews/my-reviews` - Get customer reviews
- GET `/api/v1/reviews/{review_id}` - Get review details
- PUT `/api/v1/reviews/{review_id}` - Update review (customer)
- DELETE `/api/v1/reviews/{review_id}` - Delete review (customer)

### Saved Gyms
- POST `/api/v1/saved-gyms` - Save gym (customer)
- GET `/api/v1/saved-gyms` - Get saved gyms (customer)
- DELETE `/api/v1/saved-gyms/{gym_id}` - Unsave gym (customer)

### Community
- POST `/api/v1/community/posts` - Create post
- GET `/api/v1/community/posts` - Get posts feed
- GET `/api/v1/community/posts/{post_id}` - Get post details
- DELETE `/api/v1/community/posts/{post_id}` - Delete post
- POST `/api/v1/community/posts/{post_id}/like` - Like post
- DELETE `/api/v1/community/posts/{post_id}/like` - Unlike post
- POST `/api/v1/community/posts/{post_id}/comments` - Create comment
- GET `/api/v1/community/posts/{post_id}/comments` - Get post comments
- GET `/api/v1/community/events` - Get events

### Notifications
- GET `/api/v1/notifications` - Get user notifications
- PUT `/api/v1/notifications/{notification_id}/read` - Mark as read
- PUT `/api/v1/notifications/read-all` - Mark all as read

## Features

- JWT authentication with customer/vendor separation
- Currency: INR (₹)
- QR code generation for bookings & memberships
- Distance-based gym search (Haversine formula)
- Fallback avatars (dicebear API)
- Auto-generated API documentation
- Clean architecture with proper separation of concerns
