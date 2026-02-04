# Vendor-Customer Backend Integration

## Overview
This document explains how the vendor and customer sides are connected through the backend, ensuring real-time synchronization of gyms, equipment, slots, and bookings.

---

## Key Integration Points

### 1. **Vendor Posts Equipment → Customer Sees It**

#### Vendor Side (POST Equipment)
```
POST /api/v1/equipment
Authorization: Bearer <vendor_token>

{
  "gym_id": "uuid",
  "equipment_name": "Treadmill",
  "equipment_type": "cardio",
  "quantity": 10,
  "available_quantity": 10,
  "hourly_rate": 15.00,
  "description": "High-quality treadmills",
  "image_url": "https://..."
}
```

**Backend Actions:**
- Validates gym ownership
- Ensures gym is active (status='active')
- Creates equipment record
- Equipment is immediately visible to customers

#### Customer Side (GET Equipment)
```
GET /api/v1/equipment/gym/{gym_id}
```

**Response:**
```json
[
  {
    "id": "uuid",
    "gym_id": "uuid",
    "equipment_name": "Treadmill",
    "equipment_type": "cardio",
    "quantity": 10,
    "available_quantity": 10,
    "hourly_rate": 15.00,
    "is_available": true
  }
]
```

---

### 2. **Vendor Creates Time Slots → Customer Can Book**

#### Vendor Side (POST Time Slot)
```
POST /api/v1/bookings/slots
Authorization: Bearer <vendor_token>

{
  "gym_id": "uuid",
  "equipment_id": "uuid",
  "date": "2026-02-10",
  "start_time": "09:00:00",
  "end_time": "10:00:00",
  "capacity": 5,
  "base_price": 15.00,
  "surge_multiplier": 1.0,
  "is_available": true
}
```

**Backend Actions:**
- Validates gym ownership
- Validates equipment exists
- Creates time slot with capacity tracking
- Slot is immediately available for booking

#### Vendor Side (Bulk Create Slots)
```
POST /api/v1/bookings/slots/bulk?gym_id=uuid&start_date=2026-02-10&end_date=2026-02-17
Authorization: Bearer <vendor_token>

time_slots: [
  {
    "start_time": "09:00:00",
    "end_time": "10:00:00",
    "capacity": 5,
    "base_price": 15.00
  },
  {
    "start_time": "10:00:00",
    "end_time": "11:00:00",
    "capacity": 5,
    "base_price": 15.00
  }
]
```

Creates slots for entire date range automatically.

#### Customer Side (GET Available Slots)
```
GET /api/v1/bookings/slots/available?gym_id=uuid&slot_date=2026-02-10&equipment_id=uuid
```

**Response:**
```json
[
  {
    "id": "uuid",
    "gym_id": "uuid",
    "equipment_id": "uuid",
    "date": "2026-02-10",
    "start_time": "09:00:00",
    "end_time": "10:00:00",
    "capacity": 5,
    "booked_count": 2,
    "base_price": 15.00,
    "is_available": true
  }
]
```

**Real-time Availability:**
- `booked_count` shows current bookings
- `is_available` = true only if `booked_count < capacity`
- Automatically updates when bookings are made

---

### 3. **Customer Books Slot → Vendor Sees Booking**

#### Customer Side (POST Booking)
```
POST /api/v1/bookings
Authorization: Bearer <customer_token>

{
  "slot_id": "uuid",
  "equipment_station": "Treadmill - Station 04"
}
```

**Backend Actions:**
1. Validates slot availability
2. Creates booking record
3. **CRITICAL:** Increments `slot.booked_count`
4. If `booked_count >= capacity`, sets `slot.is_available = false`
5. Generates QR code for check-in
6. Returns booking confirmation

**Response:**
```json
{
  "id": "uuid",
  "booking_date": "2026-02-10",
  "start_time": "09:00:00",
  "end_time": "10:00:00",
  "status": "upcoming",
  "total_price": 15.00,
  "qr_code_url": "https://..."
}
```

#### Vendor Side (GET Gym Bookings)
```
GET /api/v1/bookings/gym/{gym_id}?booking_date=2026-02-10&status_filter=upcoming
Authorization: Bearer <vendor_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "customer_uuid",
    "gym_id": "uuid",
    "equipment_id": "uuid",
    "booking_date": "2026-02-10",
    "start_time": "09:00:00",
    "end_time": "10:00:00",
    "equipment_station": "Treadmill - Station 04",
    "total_price": 15.00,
    "status": "upcoming",
    "qr_code_url": "https://...",
    "created_at": "2026-02-04T10:30:00Z"
  }
]
```

#### Vendor Side (GET Booking with Customer Details)
```
GET /api/v1/bookings/vendor/booking-details/{booking_id}
Authorization: Bearer <vendor_token>
```

**Response:**
```json
{
  "booking": {
    "id": "uuid",
    "booking_date": "2026-02-10",
    "start_time": "09:00:00",
    "status": "upcoming",
    "total_price": 15.00
  },
  "customer": {
    "id": "uuid",
    "full_name": "John Doe",
    "phone": "+1234567890",
    "email": "john@example.com",
    "profile_image_url": "https://..."
  },
  "gym": {
    "id": "uuid",
    "name": "FitZone Gym"
  },
  "equipment": {
    "name": "Treadmill"
  }
}
```

---

### 4. **Slot Availability Updates Automatically**

#### When Customer Books:
```
Before Booking:
- capacity: 5
- booked_count: 2
- is_available: true

After Booking:
- capacity: 5
- booked_count: 3
- is_available: true

After 5th Booking:
- capacity: 5
- booked_count: 5
- is_available: false  ← Slot now shows as BOOKED
```

#### When Customer Cancels:
```
PUT /api/v1/bookings/{booking_id}/cancel
Authorization: Bearer <customer_token>
```

**Backend Actions:**
1. Sets booking status to 'cancelled'
2. **CRITICAL:** Decrements `slot.booked_count`
3. Sets `slot.is_available = true`
4. Slot becomes available again for other customers

---

### 5. **Vendor Dashboard Statistics**

```
GET /api/v1/bookings/vendor/dashboard/{gym_id}
Authorization: Bearer <vendor_token>
```

**Response:**
```json
{
  "gym_id": "uuid",
  "gym_name": "FitZone Gym",
  "statistics": {
    "total_bookings": 150,
    "today_bookings": 12,
    "upcoming_bookings": 45,
    "active_bookings": 3,
    "total_revenue": 2250.00,
    "today_revenue": 180.00,
    "available_slots_today": 8,
    "fully_booked_slots_today": 4
  },
  "date": "2026-02-04"
}
```

---

### 6. **Vendor Views Slot Status**

```
GET /api/v1/bookings/slots/gym/{gym_id}?slot_date=2026-02-10
Authorization: Bearer <vendor_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "date": "2026-02-10",
    "start_time": "09:00:00",
    "end_time": "10:00:00",
    "capacity": 5,
    "booked_count": 5,
    "is_available": false  ← FULLY BOOKED
  },
  {
    "id": "uuid",
    "date": "2026-02-10",
    "start_time": "10:00:00",
    "end_time": "11:00:00",
    "capacity": 5,
    "booked_count": 2,
    "is_available": true  ← AVAILABLE
  }
]
```

---

## Data Flow Summary

### Vendor → Customer Flow:
1. **Vendor creates gym** → Customer can search and view gym
2. **Vendor adds equipment** → Customer sees equipment in gym details
3. **Vendor creates time slots** → Customer sees available slots
4. **Vendor updates pricing** → Customer sees updated prices

### Customer → Vendor Flow:
1. **Customer books slot** → Vendor sees booking in dashboard
2. **Customer books slot** → Slot `booked_count` increases
3. **Customer fills capacity** → Slot shows as "BOOKED" for everyone
4. **Customer cancels** → Slot becomes available again
5. **Customer checks in** → Vendor sees attendance record

---

## Key Backend Features

### ✅ Real-time Slot Availability
- `booked_count` automatically updates on booking/cancellation
- `is_available` flag prevents overbooking
- Capacity enforcement at database level

### ✅ Vendor-Customer Isolation
- Vendors only see their own gyms/bookings
- Customers see all active gyms
- Permission checks on all endpoints

### ✅ Automatic Synchronization
- No manual refresh needed
- Database transactions ensure consistency
- Slot status updates atomically with bookings

### ✅ Booking Lifecycle
```
upcoming → active → completed
         ↓
      cancelled
```

### ✅ QR Code Integration
- Generated on booking creation
- Used for check-in at gym
- Vendor scans to mark attendance

---

## API Endpoints Summary

### Vendor Endpoints:
- `POST /api/v1/gyms` - Create gym
- `POST /api/v1/equipment` - Add equipment
- `POST /api/v1/bookings/slots` - Create time slot
- `POST /api/v1/bookings/slots/bulk` - Bulk create slots
- `GET /api/v1/bookings/gym/{gym_id}` - View all bookings
- `GET /api/v1/bookings/slots/gym/{gym_id}` - View all slots with status
- `GET /api/v1/bookings/vendor/dashboard/{gym_id}` - Dashboard stats
- `GET /api/v1/bookings/vendor/booking-details/{booking_id}` - Booking with customer info

### Customer Endpoints:
- `GET /api/v1/gyms` - Search gyms
- `GET /api/v1/equipment/gym/{gym_id}` - View equipment
- `GET /api/v1/bookings/slots/available` - View available slots
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings/my-bookings` - View my bookings
- `PUT /api/v1/bookings/{booking_id}/cancel` - Cancel booking

### Shared Endpoints:
- `GET /api/v1/gyms/{gym_id}` - Gym details
- `GET /api/v1/equipment/{equipment_id}` - Equipment details
- `GET /api/v1/bookings/{booking_id}` - Booking details (with permission check)

---

## Testing the Integration

### 1. Vendor Creates Equipment:
```bash
curl -X POST http://localhost:8000/api/v1/equipment \
  -H "Authorization: Bearer <vendor_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "gym_id": "uuid",
    "equipment_name": "Treadmill",
    "quantity": 10,
    "hourly_rate": 15.00
  }'
```

### 2. Customer Views Equipment:
```bash
curl http://localhost:8000/api/v1/equipment/gym/{gym_id}
```

### 3. Vendor Creates Slots:
```bash
curl -X POST http://localhost:8000/api/v1/bookings/slots \
  -H "Authorization: Bearer <vendor_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "gym_id": "uuid",
    "equipment_id": "uuid",
    "date": "2026-02-10",
    "start_time": "09:00:00",
    "end_time": "10:00:00",
    "capacity": 5,
    "base_price": 15.00
  }'
```

### 4. Customer Books Slot:
```bash
curl -X POST http://localhost:8000/api/v1/bookings \
  -H "Authorization: Bearer <customer_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "slot_id": "uuid"
  }'
```

### 5. Vendor Views Booking:
```bash
curl http://localhost:8000/api/v1/bookings/gym/{gym_id} \
  -H "Authorization: Bearer <vendor_token>"
```

---

## Database Triggers (Automatic)

The backend automatically handles:
- ✅ Incrementing `booked_count` on booking creation
- ✅ Decrementing `booked_count` on booking cancellation
- ✅ Setting `is_available = false` when capacity is reached
- ✅ Setting `is_available = true` when slots become available
- ✅ Preventing double bookings with transaction locks

---

## Next Steps

1. **Frontend Integration:**
   - Customer app: Call `/api/v1/bookings/slots/available` to show slots
   - Vendor app: Call `/api/v1/bookings/gym/{gym_id}` to show bookings
   - Both: Poll or use WebSockets for real-time updates

2. **Real-time Updates:**
   - Consider adding WebSocket support for live slot updates
   - Push notifications when bookings are made

3. **Testing:**
   - Test concurrent bookings to ensure no overbooking
   - Test cancellation flow
   - Test vendor dashboard statistics

---

## Troubleshooting

### Slots not showing for customers?
- Check gym status is 'active'
- Check slot `is_available = true`
- Check slot date is today or future

### Bookings not appearing for vendor?
- Verify gym ownership
- Check booking `gym_id` matches vendor's gym
- Use status filter if needed

### Slot still showing available when full?
- Check `booked_count` vs `capacity`
- Ensure booking creation updates `booked_count`
- Check database transaction completed

---

## Summary

The vendor-customer integration is fully functional with:
- ✅ Vendor posts equipment → Customer sees it immediately
- ✅ Vendor creates slots → Customer can book immediately
- ✅ Customer books → Slot count updates automatically
- ✅ Customer books → Vendor sees booking in dashboard
- ✅ Slot shows as "BOOKED" when capacity is reached
- ✅ Real-time availability tracking
- ✅ Automatic synchronization between vendor and customer sides
