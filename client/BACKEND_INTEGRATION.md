# Backend Integration Guide

## Overview

The Flutter customer app is now connected to the FastAPI backend with complete API services.

## Services Created

### 1. AuthService (`lib/core/services/auth_service.dart`)
Handles user authentication and profile management.

**Methods:**
- `register()` - Register new customer
- `login()` - Login with email/password
- `verifyToken()` - Check if token is valid
- `logout()` - Clear authentication
- `getCurrentUser()` - Get current user profile
- `updateProfile()` - Update user info
- `createCustomerProfile()` - Create customer profile with fitness data
- `updateCustomerProfile()` - Update customer profile

### 2. GymService (`lib/core/services/gym_service.dart`)
Manages gym data and operations.

**Methods:**
- `getGyms()` - Get all gyms (paginated)
- `searchGyms()` - Search gyms by location (lat/lng + radius)
- `getGymDetails()` - Get detailed gym info
- `getGymEquipment()` - Get equipment list for gym
- `getGymReviews()` - Get gym reviews
- `createReview()` - Create review for gym
- `saveGym()` - Save/favorite a gym
- `unsaveGym()` - Remove from favorites
- `getSavedGyms()` - Get user's saved gyms

### 3. BookingService (`lib/core/services/booking_service.dart`)
Handles bookings and attendance.

**Methods:**
- `getAvailableSlots()` - Get available time slots
- `createBooking()` - Create new booking
- `getMyBookings()` - Get user's bookings (with status filter)
- `getBookingDetails()` - Get booking details
- `cancelBooking()` - Cancel a booking
- `checkIn()` - Check in to gym
- `checkOut()` - Check out from gym
- `getMyAttendance()` - Get attendance history

### 4. PaymentService (`lib/core/services/payment_service.dart`)
Manages payments.

**Methods:**
- `createPayment()` - Create payment record
- `getMyPayments()` - Get payment history
- `getPaymentDetails()` - Get payment details
- `updatePaymentStatus()` - Update payment status

### 5. MembershipService (`lib/core/services/membership_service.dart`)
Handles membership passes.

**Methods:**
- `getGymPasses()` - Get available passes for gym
- `getPassDetails()` - Get pass details
- `purchaseMembership()` - Purchase a membership
- `getMyMemberships()` - Get user's memberships
- `getMembershipDetails()` - Get membership details

## Updated Models

### User Model
Updated to match backend schema with fields:
- `id`, `fullName`, `email`, `phoneNumber`, `userType`
- `profileImageUrl`, `isActive`, `createdAt`, `updatedAt`
- Customer profile: `age`, `gender`, `heightCm`, `weightKg`, `fitnessGoal`
- Helper: `avatarUrl` (fallback to dicebear)

### Gym Model
Updated to match backend schema with fields:
- `id`, `name`, `description`, `logoUrl`, `address`
- `city`, `state`, `zipCode`, `latitude`, `longitude`
- `contactPhone`, `contactEmail`, `rating`, `totalReviews`
- `isActive`, `createdAt`, `updatedAt`
- Computed: `distance`, `facilities`, `status`
- Helpers: `location`, `imageUrl`, `displayRating`, `displayDistance`

### Booking Model
Updated to match backend schema with fields:
- `id`, `userId`, `gymId`, `equipmentId`, `slotId`, `membershipId`
- `bookingDate`, `startTime`, `endTime`, `equipmentStation`
- `totalPrice`, `status`, `qrCodeUrl`, `checkedInAt`
- `createdAt`, `updatedAt`
- Display fields: `gymName`, `gymImage`, `equipmentType`
- Helpers: `isActive`, `isPast`, `isUpcoming`, `canCancel`, `canCheckIn`, `timeSlot`, `displayPrice`

## Backend URL Configuration

### Android Emulator
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

### iOS Simulator
```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

### Physical Device
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:8000/api/v1';
```

Find your IP:
- Windows: `ipconfig` (look for IPv4)
- Mac/Linux: `ifconfig` or `ip addr`

## Usage Examples

### 1. Register & Login

```dart
import 'package:openkora_gym/core/services/auth_service.dart';

final authService = AuthService();

// Register
try {
  final result = await authService.register(
    email: 'user@example.com',
    password: 'Password123!',
    fullName: 'John Doe',
    phoneNumber: '+919876543210',
  );
  print('Registered: ${result['user']['full_name']}');
} catch (e) {
  print('Error: $e');
}

// Login
try {
  final result = await authService.login(
    email: 'user@example.com',
    password: 'Password123!',
  );
  print('Logged in: ${result['user']['full_name']}');
} catch (e) {
  print('Error: $e');
}

// Get current user
try {
  final user = await authService.getCurrentUser();
  print('User: ${user.fullName}');
} catch (e) {
  print('Error: $e');
}
```

### 2. Search Gyms

```dart
import 'package:openkora_gym/core/services/gym_service.dart';

final gymService = GymService();

// Search gyms near location
try {
  final gyms = await gymService.searchGyms(
    latitude: 19.0760,
    longitude: 72.8777,
    radius: 5.0, // 5 km radius
  );
  
  for (var gym in gyms) {
    print('${gym.name} - ${gym.displayDistance} - ₹${gym.rating}');
  }
} catch (e) {
  print('Error: $e');
}

// Get gym details
try {
  final gym = await gymService.getGymDetails('gym-id-here');
  print('Gym: ${gym.name}');
  print('Address: ${gym.address}');
  print('Rating: ${gym.displayRating}');
} catch (e) {
  print('Error: $e');
}
```

### 3. Create Booking

```dart
import 'package:openkora_gym/core/services/booking_service.dart';

final bookingService = BookingService();

// Get available slots
try {
  final slots = await bookingService.getAvailableSlots(
    gymId: 'gym-id-here',
    date: '2026-02-05',
    equipmentId: 'equipment-id-here',
  );
  
  for (var slot in slots) {
    print('${slot['start_time']} - ${slot['end_time']} (₹${slot['base_price']})');
  }
} catch (e) {
  print('Error: $e');
}

// Create booking
try {
  final booking = await bookingService.createBooking(
    slotId: 'slot-id-here',
    equipmentStation: 'Station 4',
  );
  
  print('Booking created: ${booking.id}');
  print('QR Code: ${booking.qrCodeUrl}');
} catch (e) {
  print('Error: $e');
}

// Get my bookings
try {
  final bookings = await bookingService.getMyBookings(
    statusFilter: 'upcoming',
  );
  
  for (var booking in bookings) {
    print('${booking.gymName} - ${booking.timeSlot} - ${booking.displayPrice}');
  }
} catch (e) {
  print('Error: $e');
}
```

### 4. Check In/Out

```dart
// Check in
try {
  final attendance = await bookingService.checkIn('booking-id-here');
  print('Checked in at: ${attendance['check_in_time']}');
} catch (e) {
  print('Error: $e');
}

// Check out
try {
  final attendance = await bookingService.checkOut('attendance-id-here');
  print('Checked out at: ${attendance['check_out_time']}');
} catch (e) {
  print('Error: $e');
}
```

### 5. Memberships

```dart
import 'package:openkora_gym/core/services/membership_service.dart';

final membershipService = MembershipService();

// Get gym passes
try {
  final passes = await membershipService.getGymPasses('gym-id-here');
  
  for (var pass in passes) {
    print('${pass['name']} - ₹${pass['price']} - ${pass['duration_days']} days');
  }
} catch (e) {
  print('Error: $e');
}

// Purchase membership
try {
  final membership = await membershipService.purchaseMembership('pass-id-here');
  print('Membership purchased: ${membership['id']}');
  print('Valid until: ${membership['end_date']}');
} catch (e) {
  print('Error: $e');
}

// Get my memberships
try {
  final memberships = await membershipService.getMyMemberships(activeOnly: true);
  
  for (var membership in memberships) {
    print('${membership['pass_id']} - Active: ${membership['is_active']}');
  }
} catch (e) {
  print('Error: $e');
}
```

## Integration Steps

### Step 1: Start Backend
```bash
cd server/backend
uvicorn app.main:app --reload
```

### Step 2: Update Base URL
Edit each service file and update the `baseUrl` constant based on your device:
- Android Emulator: `http://10.0.2.2:8000/api/v1`
- iOS Simulator: `http://localhost:8000/api/v1`
- Physical Device: `http://YOUR_IP:8000/api/v1`

### Step 3: Test Connection
Create a test in your app:

```dart
import 'package:openkora_gym/core/services/auth_service.dart';

Future<void> testConnection() async {
  final authService = AuthService();
  
  try {
    // Try to verify token (will fail if not logged in, but tests connection)
    await authService.verifyToken();
    print('✅ Backend connected!');
  } catch (e) {
    print('❌ Connection error: $e');
  }
}
```

### Step 4: Update UI Components
Replace mock data with real API calls in your screens:

**Example: Home Screen**
```dart
// Before (mock data)
final gyms = MockDataService.getGyms();

// After (real API)
final gymService = GymService();
final gyms = await gymService.getGyms();
```

## Error Handling

All services include error handling that returns user-friendly messages:

```dart
try {
  final result = await authService.login(email: email, password: password);
  // Success
} catch (e) {
  // e will be a String with user-friendly error message
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(e.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## Token Management

Tokens are automatically:
- Saved to SharedPreferences on login/register
- Added to all API requests via interceptor
- Cleared on logout or 401 error

## Next Steps

1. ✅ Backend services created
2. ✅ Models updated to match backend
3. ⏳ Update UI screens to use real API
4. ⏳ Add loading states
5. ⏳ Add error handling UI
6. ⏳ Test all flows end-to-end
7. ⏳ Add image upload functionality
8. ⏳ Implement QR code scanning
9. ⏳ Add push notifications

## Testing Checklist

- [ ] Register new user
- [ ] Login existing user
- [ ] View gym list
- [ ] Search gyms by location
- [ ] View gym details
- [ ] View available slots
- [ ] Create booking
- [ ] View my bookings
- [ ] Cancel booking
- [ ] Check in to gym
- [ ] Check out from gym
- [ ] View membership passes
- [ ] Purchase membership
- [ ] View my memberships
- [ ] Create review
- [ ] Save/unsave gym
- [ ] Update profile
- [ ] Logout

## Troubleshooting

### Connection Refused
- Check backend is running: `http://localhost:8000/api/docs`
- Verify correct IP address for physical device
- Check firewall settings

### 401 Unauthorized
- Token expired or invalid
- Login again to get new token

### 404 Not Found
- Check endpoint URL is correct
- Verify backend has the endpoint

### Network Error
- Check internet connection
- Verify backend URL is accessible
- Check CORS settings if using web
