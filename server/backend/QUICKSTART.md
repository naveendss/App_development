# Backend Quick Start Guide

## 1. Install Dependencies

```bash
cd server/backend
pip install -r requirements.txt
```

## 2. Run Server

```bash
uvicorn app.main:app --reload
```

Server will start at: http://localhost:8000

## 3. Test API

Open browser: http://localhost:8000/api/docs

## 4. Quick Test Flow

### Register Vendor
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@example.com",
    "password": "Vendor123!",
    "full_name": "Test Vendor",
    "phone_number": "+919876543210",
    "user_type": "vendor"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@example.com",
    "password": "Vendor123!"
  }'
```

Copy the `access_token` from response.

### Create Gym (use token)
```bash
curl -X POST http://localhost:8000/api/v1/gyms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "name": "Test Gym",
    "description": "A great gym",
    "address": "123 Main St, Mumbai",
    "city": "Mumbai",
    "state": "Maharashtra",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "contact_phone": "+919876543210"
  }'
```

## 5. Use Swagger UI (Easier)

1. Go to http://localhost:8000/api/docs
2. Click "Authorize" button (top right)
3. Enter token: `Bearer YOUR_TOKEN_HERE`
4. Click "Authorize"
5. Now you can test all endpoints with the UI

## All Endpoints

- **Auth**: `/api/v1/auth/*`
- **Users**: `/api/v1/users/*`
- **Gyms**: `/api/v1/gyms/*`
- **Equipment**: `/api/v1/equipment/*`
- **Bookings**: `/api/v1/bookings/*`
- **Payments**: `/api/v1/payments/*`
- **Memberships**: `/api/v1/memberships/*`
- **Attendance**: `/api/v1/attendance/*`
- **Reviews**: `/api/v1/reviews/*`
- **Saved Gyms**: `/api/v1/saved-gyms/*`
- **Community**: `/api/v1/community/*`
- **Notifications**: `/api/v1/notifications/*`

## Database

Database is already set up in Supabase with all migrations applied.

Connection: `postgresql://postgres.tjycgeecmltheaorcci:Openkora2026@aws-1-ap-south-1.pooler.supabase.com:5432/postgres`

## Troubleshooting

### Port already in use
```bash
# Kill process on port 8000
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac:
lsof -ti:8000 | xargs kill -9
```

### Database connection error
- Check `.env` file has correct DATABASE_URL
- Verify Supabase database is not paused
- Check internet connection

### Import errors
```bash
pip install -r requirements.txt --upgrade
```
