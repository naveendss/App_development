# Seed Demo Data

## Quick Seed

Run this to populate the database with demo gyms:

```bash
cd server/backend
python seed_demo_data.py
```

## What Gets Created

### Demo Accounts

**Vendor Account:**
- Email: `vendor@openkora.com`
- Password: `Vendor123!`
- Can manage all demo gyms

**Customer Account:**
- Email: `customer@openkora.com`
- Password: `Customer123!`
- Can book equipment and passes

### 5 Demo Gyms

#### 1. Iron Haven Fitness (Bandra West)
- **Location**: 123 MG Road, Bandra West, Mumbai
- **Facilities**: Cardio Zone, Free Weights, Power Racks, Sauna, Steam Room
- **Equipment**: 10 Treadmills, 8 Ellipticals, 5 Rowing Machines, 4 Bench Press, 3 Squat Racks, 20 Dumbbells
- **Passes**: Daily (₹150), Weekly (₹800), Monthly (₹2,500), Quarterly (₹6,500)

#### 2. The Forge Studio (Khar West)
- **Location**: 456 Linking Road, Khar West, Mumbai
- **Facilities**: Cycling Studio, Yoga Room, HIIT Zone
- **Equipment**: 15 Spin Bikes, 25 Yoga Mats, 15 Kettlebells, 4 Battle Ropes
- **Passes**: Single Class (₹200), 10 Class Pack (₹1,800), Unlimited Monthly (₹3,500)

#### 3. Iron Paradise (Andheri West)
- **Location**: 789 SV Road, Andheri West, Mumbai
- **Facilities**: Cardio Zone, Free Weights, Yoga Studio, Sauna & Spa, Cafe, 24/7 Access
- **Equipment**: 12 Treadmills, 6 Stair Climbers, 8 Cable Machines, 4 Leg Press, 3 Smith Machines
- **Passes**: Day Pass (₹200), Monthly Unlimited (₹3,000), Annual (₹25,000)

#### 4. Power Lift Center (Bandra West)
- **Location**: 321 Turner Road, Bandra West, Mumbai
- **Facilities**: Crossfit Box, HIIT Zone, Boxing Ring, Olympic Lifting Platform
- **Equipment**: 10 Olympic Barbells, 50 Bumper Plates, 8 Pull-up Bars, 6 Assault Bikes, 5 Boxing Bags
- **Passes**: Drop-in (₹250), Weekly (₹1,200), Monthly Unlimited (₹4,000)

#### 5. Zenith Wellness (Juhu)
- **Location**: 555 Juhu Tara Road, Juhu, Mumbai
- **Facilities**: Yoga Studio, Pilates Room, Swimming Pool, Spa, Meditation Room, Juice Bar
- **Equipment**: 10 Reformers, 30 Yoga Mats, 12 TRX Suspension, 8 Treadmills
- **Passes**: Single Session (₹300), Monthly Wellness (₹5,000), Premium Annual (₹45,000)

### Additional Data

- **Operating Hours**: All gyms open Mon-Sun, 6 AM - 10 PM
- **Time Slots**: Created for next 7 days, 6 AM - 9 PM (1-hour slots)
- **Equipment Availability**: All equipment available for booking
- **Facilities**: Each gym has 4-6 facilities
- **Reviews**: None yet (you can add via API)

## Usage

### 1. Seed the Data
```bash
python seed_demo_data.py
```

### 2. Test with Customer Account
```bash
# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "customer@openkora.com",
    "password": "Customer123!"
  }'

# Get gyms
curl http://localhost:8000/api/v1/gyms

# Search gyms near Bandra (19.0596, 72.8295)
curl "http://localhost:8000/api/v1/gyms/search?latitude=19.0596&longitude=72.8295&radius=5"
```

### 3. Test with Vendor Account
```bash
# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@openkora.com",
    "password": "Vendor123!"
  }'

# Get my gyms
curl http://localhost:8000/api/v1/gyms/vendor/my-gyms \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Use in Flutter App

The Flutter app will now show these 5 gyms when you:
- Open the home screen
- Search for gyms
- View gym details
- Book equipment

## Reseed Data

To clear and reseed:

```bash
# Option 1: Drop and recreate tables in Supabase SQL Editor
# Then run migrations again and seed

# Option 2: Delete data manually
# DELETE FROM gyms WHERE vendor_id = (SELECT id FROM users WHERE email = 'vendor@openkora.com');
# DELETE FROM users WHERE email IN ('vendor@openkora.com', 'customer@openkora.com');

# Then reseed
python seed_demo_data.py
```

## Customize

Edit `seed_demo_data.py` to:
- Add more gyms
- Change locations
- Modify equipment
- Update prices
- Add different facilities

## Notes

- All gyms are in Mumbai (different areas)
- Coordinates are real Mumbai locations
- Prices are in INR (₹)
- Time slots created for next 7 days
- All equipment available for booking
- No bookings created (start fresh)
