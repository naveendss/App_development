# Backend Testing Guide - Vendor-Customer Integration

## Quick Test Scenarios

### Scenario 1: Vendor Posts Equipment → Customer Sees It

**Step 1: Vendor Creates Equipment**
```bash
POST http://localhost:8000/api/v1/equipment
Authorization: Bearer <vendor_token>
Content-Type: application/json

{
  "gym_id": "your-gym-uuid",
  "equipment_name": "Treadmill Pro",
  "equipment_type": "cardio",
  "quantity": 10,
  "available_quantity": 10,
  "hourly_rate": 15.00,
  "description": "Professional treadmills with heart rate monitor",
  "image_url": "https://example.com/treadmill.jpg"
}
```

**Expected Response:**
```json
{
  "id": "new-equipment-uuid",
  "gym_id": "your-gym-uuid",
  "equipment_name": "Treadmill Pro",
  "is_available": true,
  "quantity": 10,
  "available_quantity": 10
}
```

**Step 2: Customer Views Equipment**
```bash
GET http://localhost:8000/api/v1/equipment/gym/{gym_id}
```

**Expected:** Equipment appears immediately in the list

---

### Scenario 2: Vendor Creates Slots → Customer Can Book

**Step 1: Vendor Creates Time Slot**
```bash
POST http://localhost:8000/api/v1/bookings/slots
Authorization: Bearer <vendor_token>
Content-Type: application/json

{
  "gym_id": "your-gym-uuid",
  "equipment_id": "equipment-uuid",
  "date": "2026-02-10",
  "start_time": "09:00:00",
  "end_time": "10:00:00",
  "capacity": 5,
  "base_price": 15.00,
  "surge_multiplier": 1.0,
  "is_available": true
}
```

**Expected Response:**
```json
{
  "id": "slot-uuid",
  "capacity": 5,
  "booked_count": 0,
  "is_available": true
}
```

**Step 2: Customer Views Available Slots**
```bash
GET http://localhost:8000/api/v1/bookings/slots/available?gym_id={gym_id}&slot_date=2026-02-10&equipment_id={equipment_id}
```

**Expected:** Slot appears with `booked_count: 0` and `is_available: true`

---

### Scenario 3: Customer Books → Slot Updates → Vendor Sees Booking

**Step 1: Customer Creates Booking**
```bash
POST http://localhost:8000/api/v1/bookings
Authorization: Bearer <customer_token>
Content-Type: application/json

{
  "slot_id": "slot-uuid",
  "equipment_station": "Treadmill - Station 04"
}
```

**Expected Response:**
```json
{
  "id": "booking-uuid",
  "status": "upcoming",
  "total_price": 15.00,
  "qr_code_url": "https://..."
}
```

**Step 2: Check Slot Status (Customer View)**
```bash
GET http://localhost:8000/api/v1/bookings/slots/available?gym_id={gym_id}&slot_date=2026-02-10
```

**Expected:** Slot now shows `booked_count: 1`

**Step 3: Vendor Views Booking**
```bash
GET http://localhost:8000/api/v1/bookings/gym/{gym_id}?booking_date=2026-02-10
Authorization: Bearer <vendor_token>
```

**Expected:** Booking appears in vendor's list

**Step 4: Vendor Views Booking Details**
```bash
GET http://localhost:8000/api/v1/bookings/vendor/booking-details/{booking_id}
Authorization: Bearer <vendor_token>
```

**Expected:** Full booking details with customer information

---

### Scenario 4: Multiple Bookings → Slot Becomes Full

**Step 1-5: Create 5 Bookings (capacity = 5)**
```bash
# Repeat 5 times with different customer tokens
POST http://localhost:8000/api/v1/bookings
Authorization: Bearer <customer_token_1>
{ "slot_id": "slot-uuid" }

POST http://localhost:8000/api/v1/bookings
Authorization: Bearer <customer_token_2>
{ "slot_id": "slot-uuid" }

# ... repeat 3 more times
```

**Step 6: Check Slot Status**
```bash
GET http://localhost:8000/api/v1/bookings/slots/available?gym_id={gym_id}&slot_date=2026-02-10
```

**Expected:**
```json
{
  "capacity": 5,
  "booked_count": 5,
  "is_available": false  ← SLOT IS NOW FULL
}
```

**Step 7: Try to Book Again**
```bash
POST http://localhost:8000/api/v1/bookings
Authorization: Bearer <customer_token_6>
{ "slot_id": "slot-uuid" }
```

**Expected:** Error 400 - "Time slot is not available"

---

### Scenario 5: Customer Cancels → Slot Becomes Available

**Step 1: Customer Cancels Booking**
```bash
PUT http://localhost:8000/api/v1/bookings/{booking_id}/cancel
Authorization: Bearer <customer_token>
```

**Expected Response:**
```json
{
  "id": "booking-uuid",
  "status": "cancelled"
}
```

**Step 2: Check Slot Status**
```bash
GET http://localhost:8000/api/v1/bookings/slots/available?gym_id={gym_id}&slot_date=2026-02-10
```

**Expected:**
```json
{
  "capacity": 5,
  "booked_count": 4,  ← Decreased by 1
  "is_available": true  ← Available again
}
```

---

### Scenario 6: Vendor Views Dashboard Statistics

**Request:**
```bash
GET http://localhost:8000/api/v1/bookings/vendor/dashboard/{gym_id}
Authorization: Bearer <vendor_token>
```

**Expected Response:**
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

### Scenario 7: Vendor Creates Bulk Slots

**Request:**
```bash
POST http://localhost:8000/api/v1/bookings/slots/bulk?gym_id={gym_id}&start_date=2026-02-10&end_date=2026-02-17
Authorization: Bearer <vendor_token>
Content-Type: application/json

{
  "time_slots": [
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
    },
    {
      "start_time": "14:00:00",
      "end_time": "15:00:00",
      "capacity": 8,
      "base_price": 20.00
    }
  ]
}
```

**Expected Response:**
```json
{
  "message": "Created 24 time slots",
  "slots_created": 24,
  "date_range": {
    "start": "2026-02-10",
    "end": "2026-02-17"
  }
}
```

**Calculation:** 8 days × 3 slots per day = 24 slots

---

### Scenario 8: Vendor Views All Slots with Status

**Request:**
```bash
GET http://localhost:8000/api/v1/bookings/slots/gym/{gym_id}?slot_date=2026-02-10
Authorization: Bearer <vendor_token>
```

**Expected Response:**
```json
[
  {
    "id": "slot-1-uuid",
    "date": "2026-02-10",
    "start_time": "09:00:00",
    "end_time": "10:00:00",
    "capacity": 5,
    "booked_count": 5,
    "is_available": false  ← FULLY BOOKED
  },
  {
    "id": "slot-2-uuid",
    "date": "2026-02-10",
    "start_time": "10:00:00",
    "end_time": "11:00:00",
    "capacity": 5,
    "booked_count": 2,
    "is_available": true  ← AVAILABLE
  },
  {
    "id": "slot-3-uuid",
    "date": "2026-02-10",
    "start_time": "14:00:00",
    "end_time": "15:00:00",
    "capacity": 8,
    "booked_count": 0,
    "is_available": true  ← AVAILABLE
  }
]
```

---

## Testing Checklist

### ✅ Vendor → Customer Flow
- [ ] Vendor creates gym → Customer can search it
- [ ] Vendor adds equipment → Customer sees it in gym details
- [ ] Vendor creates time slot → Customer sees it in available slots
- [ ] Vendor updates equipment → Customer sees updated info

### ✅ Customer → Vendor Flow
- [ ] Customer books slot → Vendor sees booking
- [ ] Customer books slot → `booked_count` increases
- [ ] Customer fills capacity → Slot shows as unavailable
- [ ] Customer cancels → `booked_count` decreases
- [ ] Customer cancels → Slot becomes available again

### ✅ Real-time Synchronization
- [ ] Slot availability updates immediately after booking
- [ ] Vendor dashboard shows accurate statistics
- [ ] Multiple customers can't overbook a slot
- [ ] Concurrent bookings handled correctly

### ✅ Permission Checks
- [ ] Vendor can only see their own gyms
- [ ] Vendor can only see bookings for their gyms
- [ ] Customer can only see their own bookings
- [ ] Customer can only cancel their own bookings

---

## Common Issues & Solutions

### Issue: Equipment not showing for customers
**Solution:** Ensure gym status is 'active'
```bash
PUT http://localhost:8000/api/v1/gyms/{gym_id}
{ "status": "active" }
```

### Issue: Slots not appearing
**Solution:** Check slot date is today or future, and `is_available = true`

### Issue: Booking fails with "slot not available"
**Solution:** Check `booked_count < capacity` and `is_available = true`

### Issue: Vendor can't see bookings
**Solution:** Verify gym ownership and use correct gym_id

### Issue: Slot count not updating
**Solution:** Check database transaction completed successfully

---

## API Endpoint Quick Reference

### Vendor Endpoints
```
POST   /api/v1/gyms                                    - Create gym
POST   /api/v1/equipment                               - Add equipment
POST   /api/v1/bookings/slots                          - Create slot
POST   /api/v1/bookings/slots/bulk                     - Bulk create slots
GET    /api/v1/bookings/gym/{gym_id}                   - View bookings
GET    /api/v1/bookings/slots/gym/{gym_id}             - View slots
GET    /api/v1/bookings/vendor/dashboard/{gym_id}      - Dashboard stats
GET    /api/v1/bookings/vendor/booking-details/{id}    - Booking details
```

### Customer Endpoints
```
GET    /api/v1/gyms                                    - Search gyms
GET    /api/v1/equipment/gym/{gym_id}                  - View equipment
GET    /api/v1/bookings/slots/available                - View slots
POST   /api/v1/bookings                                - Create booking
GET    /api/v1/bookings/my-bookings                    - My bookings
PUT    /api/v1/bookings/{id}/cancel                    - Cancel booking
```

---

## Running Tests

### Start Backend Server
```bash
cd server/backend
python -m uvicorn app.main:app --reload --port 8000
```

### Test with curl
```bash
# Get auth token first
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+1234567890", "password": "password"}'

# Use token in subsequent requests
export TOKEN="your-token-here"

curl http://localhost:8000/api/v1/gyms \
  -H "Authorization: Bearer $TOKEN"
```

### Test with Postman
1. Import API collection
2. Set environment variables (base_url, vendor_token, customer_token)
3. Run test scenarios in order

### Test with Python
```python
import requests

BASE_URL = "http://localhost:8000/api/v1"
VENDOR_TOKEN = "your-vendor-token"

# Create equipment
response = requests.post(
    f"{BASE_URL}/equipment",
    headers={"Authorization": f"Bearer {VENDOR_TOKEN}"},
    json={
        "gym_id": "gym-uuid",
        "equipment_name": "Treadmill",
        "quantity": 10,
        "hourly_rate": 15.00
    }
)
print(response.json())
```

---

## Success Criteria

✅ **Integration is working when:**
1. Vendor posts equipment → Customer sees it within seconds
2. Vendor creates slots → Customer can book immediately
3. Customer books → Slot count updates automatically
4. Customer books → Vendor sees booking in dashboard
5. Slot shows "BOOKED" when capacity is reached
6. Customer cancels → Slot becomes available again
7. No overbooking occurs even with concurrent requests
8. All statistics are accurate and real-time

---

## Next Steps

1. **Frontend Integration:**
   - Update customer app to call new endpoints
   - Update vendor app to show real-time bookings
   - Add polling or WebSocket for live updates

2. **Performance Testing:**
   - Test with 100+ concurrent bookings
   - Test with 1000+ slots
   - Optimize database queries if needed

3. **Monitoring:**
   - Add logging for booking events
   - Track slot availability changes
   - Monitor API response times

4. **Enhancements:**
   - Add WebSocket support for real-time updates
   - Add push notifications
   - Add email confirmations
   - Add SMS reminders
