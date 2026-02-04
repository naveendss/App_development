# Complete Startup Guide - Openkora Gym Platform

## Prerequisites Check

```bash
# Check Python
python --version  # Should be 3.9+

# Check PostgreSQL
psql --version

# Check Flutter
flutter --version
```

## Step 1: Start Database

```bash
# Start PostgreSQL (Windows)
# Open Services and start PostgreSQL service

# Or use Docker
docker run --name openkora-db -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
```

## Step 2: Setup Backend

```bash
cd server/backend

# Create virtual environment (if not exists)
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Check .env file exists
cat .env

# Run migrations
cd ../database
python run_migrations.py

# Seed demo data (optional)
python seed_data.py

# Go back to backend
cd ../backend
```

## Step 3: Start Backend Server

```bash
# From server/backend directory
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Expected Output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**Test it:**
Open browser: http://localhost:8000/docs

## Step 4: Test Backend API

Open new terminal:

```bash
# Test health
curl http://localhost:8000/health

# Should return: {"status":"healthy"}

# Test register vendor
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "myvendor@gym.com",
    "password": "password123",
    "full_name": "My Gym Owner",
    "phone": "+1234567890",
    "user_type": "vendor"
  }'

# Save the access_token from response
```

## Step 5: Start Vendor App

```bash
cd vendor/vendor_app

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Or for web
flutter run -d chrome
```

## Step 6: Register Vendor in App

1. Open vendor app
2. Click "Sign Up"
3. Fill in details:
   - Name: Your Name
   - Email: vendor@test.com
   - Phone: +1234567890
   - Password: password123
4. Fill gym details:
   - Gym Name: FitZone Gym
   - Address: 123 Main Street
   - City: New York
   - State: NY
   - ZIP: 10001
5. Add Equipment:
   - Click "+" button
   - Select "Treadmills" from dropdown
   - Quantity: 10
   - Hourly Rate: 5.00
   - Click "Add Equipment"
6. Set Operating Hours:
   - Weekdays: 6:00 AM - 10:00 PM
   - Weekends: 8:00 AM - 8:00 PM
7. Click "Submit for Approval"

## Step 7: Verify Gym in Database

```bash
# Connect to database
psql -U postgres -d openkora_gym

# Check if gym was created
SELECT id, name, status, vendor_id FROM gyms;

# Check if equipment was created
SELECT id, name, gym_id, base_price_per_hour FROM equipment;

# If gym status is 'pending', update to 'active'
UPDATE gyms SET status = 'active' WHERE status = 'pending';

# Exit
\q
```

## Step 8: Start Customer App

```bash
cd client

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Or for web
flutter run -d chrome
```

## Step 9: Verify Customer Can See Gym

1. Open customer app
2. Skip onboarding or complete profile
3. On home screen, you should see "FitZone Gym" in the list
4. Click on gym to see details
5. You should see equipment (Treadmills) listed

## Troubleshooting

### Issue 1: Backend won't start

**Error:** `ModuleNotFoundError: No module named 'fastapi'`

**Fix:**
```bash
cd server/backend
pip install -r requirements.txt
```

### Issue 2: Database connection error

**Error:** `could not connect to server: Connection refused`

**Fix:**
```bash
# Check if PostgreSQL is running
# Windows: Check Services
# Mac: brew services start postgresql
# Linux: sudo systemctl start postgresql

# Check .env file has correct DATABASE_URL
cat server/backend/.env
```

### Issue 3: Gym not showing in customer app

**Possible causes:**
1. Backend not running
2. Gym status is 'pending' not 'active'
3. Customer app pointing to wrong URL

**Fix:**
```bash
# 1. Check backend is running
curl http://localhost:8000/health

# 2. Check gyms in database
psql -U postgres -d openkora_gym -c "SELECT id, name, status FROM gyms;"

# 3. Update gym to active
psql -U postgres -d openkora_gym -c "UPDATE gyms SET status = 'active';"

# 4. Test API directly
curl http://localhost:8000/api/v1/gyms

# Should return array with your gym
```

### Issue 4: Flutter app can't connect to backend

**For Android Emulator:**
Update `baseUrl` in both apps:
```dart
// client/lib/core/services/api_service.dart
// vendor/vendor_app/lib/core/services/api_service.dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

**For Physical Device:**
Find your computer's IP:
```bash
# Windows
ipconfig
# Look for IPv4 Address

# Mac/Linux
ifconfig
# Look for inet address
```

Then use:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api/v1';
```

### Issue 5: Login not working

**Error:** "Invalid email or password"

**Possible causes:**
1. User not registered
2. Wrong password
3. User type mismatch

**Fix:**
```bash
# Check if user exists
psql -U postgres -d openkora_gym -c "SELECT id, email, user_type FROM users WHERE email = 'vendor@test.com';"

# If user doesn't exist, register again through app or API
```

### Issue 6: Equipment not showing

**Fix:**
```bash
# Check equipment in database
psql -U postgres -d openkora_gym -c "SELECT id, name, gym_id FROM equipment;"

# If no equipment, add through vendor app or API
```

## Quick Verification Checklist

- [ ] PostgreSQL running
- [ ] Backend server running on port 8000
- [ ] Can access http://localhost:8000/docs
- [ ] Vendor registered successfully
- [ ] Gym created with status='active'
- [ ] Equipment added to gym
- [ ] Customer app can fetch gyms from API
- [ ] Gym shows in customer app home screen

## API Endpoints Reference

### Auth
- POST `/api/v1/auth/register` - Register user
- POST `/api/v1/auth/login` - Login user

### Gyms (Customer)
- GET `/api/v1/gyms` - List all active gyms
- GET `/api/v1/gyms/{gym_id}` - Get gym details

### Gyms (Vendor)
- POST `/api/v1/gyms` - Create gym
- GET `/api/v1/gyms/vendor/my-gyms` - Get my gyms
- PUT `/api/v1/gyms/{gym_id}` - Update gym

### Equipment (Vendor)
- POST `/api/v1/equipment` - Add equipment
- GET `/api/v1/equipment/gym/{gym_id}` - List gym equipment
- PUT `/api/v1/equipment/{equipment_id}` - Update equipment
- DELETE `/api/v1/equipment/{equipment_id}` - Delete equipment

### Bookings
- POST `/api/v1/bookings` - Create booking (Customer)
- GET `/api/v1/bookings/my-bookings` - My bookings (Customer)
- GET `/api/v1/bookings/gym/{gym_id}` - Gym bookings (Vendor)

### Time Slots
- POST `/api/v1/bookings/slots` - Create slot (Vendor)
- GET `/api/v1/bookings/slots/available` - Available slots (Customer)
- GET `/api/v1/bookings/slots/gym/{gym_id}` - All slots (Vendor)

## Success Indicators

✅ **Backend Working:**
- Can access http://localhost:8000/docs
- Health endpoint returns {"status":"healthy"}
- Can register and login users

✅ **Vendor App Working:**
- Can register vendor account
- Can create gym
- Can add equipment
- Can set operating hours

✅ **Customer App Working:**
- Can see gyms on home screen
- Gyms are fetched from backend (not mock data)
- Can view gym details
- Can see equipment list

✅ **Integration Working:**
- Vendor creates gym → Shows in customer app
- Vendor adds equipment → Shows in gym details
- Customer books slot → Shows in vendor dashboard
- Slot availability updates in real-time

## Next Steps After Setup

1. **Test Complete Flow:**
   - Vendor creates gym
   - Vendor adds equipment
   - Vendor creates time slots
   - Customer searches gyms
   - Customer books slot
   - Vendor sees booking

2. **Add More Data:**
   - Create multiple gyms
   - Add various equipment types
   - Create slots for different times
   - Test with multiple customers

3. **Test Edge Cases:**
   - Fully booked slots
   - Booking cancellation
   - Multiple concurrent bookings
   - Invalid data handling

## Support

If you're still having issues:

1. Check all logs for errors
2. Verify database has data
3. Test API endpoints directly with curl
4. Check network connectivity
5. Verify all environment variables are set
