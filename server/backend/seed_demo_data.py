"""
Seed demo data for Openkora gym booking platform
Run: python seed_demo_data.py
"""

import asyncio
import sys
from datetime import datetime, timedelta, time
from decimal import Decimal
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base

# Import all models to ensure relationships work
from app.models.user import User
from app.models.customer_profile import CustomerProfile
from app.models.gym import Gym
from app.models.equipment import Equipment
from app.models.membership import MembershipPass, UserMembership
from app.models.time_slot import TimeSlot
from app.models.booking import Booking
from app.models.payment import Payment
from app.models.community import CommunityPost, CommunityEvent, PostLike, PostComment
from app.models.other import GymPhoto, GymFacility, GymOperatingHours, Review, Attendance, Notification, SavedGym
from app.core.security import get_password_hash

def create_demo_data():
    """Create demo gyms, equipment, and passes"""
    db = SessionLocal()
    
    try:
        print("🌱 Seeding demo data...")
        
        # Create or get demo vendor
        print("\n1️⃣ Creating demo vendor...")
        vendor = db.query(User).filter(User.phone == "+919876543210").first()
        if not vendor:
            vendor = User(
                phone="+919876543210",
                email="vendor@openkora.com",
                full_name="Demo Vendor",
                user_type="vendor"
            )
            db.add(vendor)
            db.commit()
            db.refresh(vendor)
            print(f"✅ Vendor created: {vendor.email}")
        else:
            print(f"✅ Vendor exists: {vendor.email}")
        
        # Create or get demo customer
        print("\n2️⃣ Creating demo customer...")
        customer = db.query(User).filter(User.phone == "+919876543211").first()
        if not customer:
            customer = User(
                phone="+919876543211",
                email="customer@openkora.com",
                full_name="Demo Customer",
                user_type="customer"
            )
            db.add(customer)
            db.commit()
            db.refresh(customer)
            print(f"✅ Customer created: {customer.email}")
        else:
            print(f"✅ Customer exists: {customer.email}")
        
        # Demo gyms data
        gyms_data = [
            {
                "name": "Iron Haven Fitness",
                "description": "Premium gym with state-of-the-art equipment and expert trainers. Perfect for serious fitness enthusiasts.",
                "address": "123 MG Road, Bandra West",
                "city": "Mumbai",
                "state": "Maharashtra",
                "zip_code": "400050",
                "latitude": 19.0596,
                "longitude": 72.8295,
                "contact_phone": "+912226431234",
                "contact_email": "info@ironhaven.com",
                "facilities": ["Cardio Zone", "Free Weights", "Power Racks", "Sauna", "Steam Room", "Locker Rooms"],
                "equipment": [
                    {"name": "Treadmill", "type": "cardio", "brand": "Life Fitness", "quantity": 10, "rate": 50},
                    {"name": "Elliptical", "type": "cardio", "brand": "Precor", "quantity": 8, "rate": 50},
                    {"name": "Rowing Machine", "type": "cardio", "brand": "Concept2", "quantity": 5, "rate": 60},
                    {"name": "Bench Press", "type": "strength", "brand": "Hammer Strength", "quantity": 4, "rate": 80},
                    {"name": "Squat Rack", "type": "strength", "brand": "Rogue", "quantity": 3, "rate": 100},
                    {"name": "Dumbbells Set", "type": "strength", "brand": "York", "quantity": 20, "rate": 40},
                ],
                "passes": [
                    {"name": "Daily Pass", "type": "daily", "days": 1, "price": 150, "max_day": 1},
                    {"name": "Weekly Pass", "type": "weekly", "days": 7, "price": 800, "max_day": 2},
                    {"name": "Monthly Pass", "type": "monthly", "days": 30, "price": 2500, "max_day": None},
                    {"name": "Annual Pass", "type": "annual", "days": 365, "price": 20000, "max_day": None},
                ],
            },
            {
                "name": "The Forge Studio",
                "description": "Boutique fitness studio specializing in HIIT, yoga, and cycling classes. Community-focused atmosphere.",
                "address": "456 Linking Road, Khar West",
                "city": "Mumbai",
                "state": "Maharashtra",
                "zip_code": "400052",
                "latitude": 19.0728,
                "longitude": 72.8326,
                "contact_phone": "+912226432345",
                "contact_email": "hello@forgestudio.com",
                "facilities": ["Cycling Studio", "Yoga Room", "HIIT Zone", "Changing Rooms", "Showers"],
                "equipment": [
                    {"name": "Spin Bike", "type": "cardio", "brand": "Peloton", "quantity": 15, "rate": 70},
                    {"name": "Yoga Mat", "type": "yoga", "brand": "Manduka", "quantity": 25, "rate": 30},
                    {"name": "Kettlebell", "type": "strength", "brand": "Rogue", "quantity": 15, "rate": 40},
                    {"name": "Battle Rope", "type": "functional", "brand": "Onnit", "quantity": 4, "rate": 50},
                ],
                "passes": [
                    {"name": "Single Class", "type": "daily", "days": 1, "price": 200, "max_day": 1},
                    {"name": "Weekly Pass", "type": "weekly", "days": 7, "price": 1400, "max_day": 2},
                    {"name": "Unlimited Monthly", "type": "monthly", "days": 30, "price": 3500, "max_day": None},
                ],
            },
            {
                "name": "Iron Paradise",
                "description": "24/7 gym with extensive equipment selection. Open all day, every day for your convenience.",
                "address": "789 SV Road, Andheri West",
                "city": "Mumbai",
                "state": "Maharashtra",
                "zip_code": "400058",
                "latitude": 19.1136,
                "longitude": 72.8697,
                "contact_phone": "+912226433456",
                "contact_email": "support@ironparadise.com",
                "facilities": ["Cardio Zone", "Free Weights", "Yoga Studio", "Sauna & Spa", "Cafe", "24/7 Access"],
                "equipment": [
                    {"name": "Treadmill", "type": "cardio", "brand": "Matrix", "quantity": 12, "rate": 50},
                    {"name": "Stair Climber", "type": "cardio", "brand": "StairMaster", "quantity": 6, "rate": 60},
                    {"name": "Cable Machine", "type": "strength", "brand": "Life Fitness", "quantity": 8, "rate": 70},
                    {"name": "Leg Press", "type": "strength", "brand": "Hammer Strength", "quantity": 4, "rate": 80},
                    {"name": "Smith Machine", "type": "strength", "brand": "Cybex", "quantity": 3, "rate": 90},
                ],
                "passes": [
                    {"name": "Day Pass", "type": "daily", "days": 1, "price": 200, "max_day": 1},
                    {"name": "Monthly Unlimited", "type": "monthly", "days": 30, "price": 3000, "max_day": None},
                    {"name": "Annual Membership", "type": "annual", "days": 365, "price": 25000, "max_day": None},
                ],
            },
            {
                "name": "Power Lift Center",
                "description": "Specialized powerlifting and CrossFit gym. Expert coaching and competition-grade equipment.",
                "address": "321 Turner Road, Bandra West",
                "city": "Mumbai",
                "state": "Maharashtra",
                "zip_code": "400050",
                "latitude": 19.0544,
                "longitude": 72.8320,
                "contact_phone": "+912226434567",
                "contact_email": "info@powerlift.com",
                "facilities": ["Crossfit Box", "HIIT Zone", "Boxing Ring", "Olympic Lifting Platform", "Recovery Zone"],
                "equipment": [
                    {"name": "Olympic Barbell", "type": "strength", "brand": "Eleiko", "quantity": 10, "rate": 100},
                    {"name": "Bumper Plates", "type": "strength", "brand": "Rogue", "quantity": 50, "rate": 20},
                    {"name": "Pull-up Bar", "type": "functional", "brand": "Rogue", "quantity": 8, "rate": 40},
                    {"name": "Assault Bike", "type": "cardio", "brand": "Assault", "quantity": 6, "rate": 60},
                    {"name": "Boxing Bag", "type": "functional", "brand": "Everlast", "quantity": 5, "rate": 50},
                ],
                "passes": [
                    {"name": "Drop-in", "type": "daily", "days": 1, "price": 250, "max_day": 1},
                    {"name": "Weekly Pass", "type": "weekly", "days": 7, "price": 1200, "max_day": 2},
                    {"name": "Monthly Unlimited", "type": "monthly", "days": 30, "price": 4000, "max_day": None},
                ],
            },
            {
                "name": "Zenith Wellness",
                "description": "Holistic wellness center with gym, yoga, pilates, and spa facilities. Focus on mind-body balance.",
                "address": "555 Juhu Tara Road, Juhu",
                "city": "Mumbai",
                "state": "Maharashtra",
                "zip_code": "400049",
                "latitude": 19.0990,
                "longitude": 72.8265,
                "contact_phone": "+912226435678",
                "contact_email": "wellness@zenith.com",
                "facilities": ["Yoga Studio", "Pilates Room", "Swimming Pool", "Spa", "Meditation Room", "Juice Bar"],
                "equipment": [
                    {"name": "Reformer", "type": "pilates", "brand": "Balanced Body", "quantity": 10, "rate": 100},
                    {"name": "Yoga Mat", "type": "yoga", "brand": "Lululemon", "quantity": 30, "rate": 30},
                    {"name": "TRX Suspension", "type": "functional", "brand": "TRX", "quantity": 12, "rate": 50},
                    {"name": "Treadmill", "type": "cardio", "brand": "Technogym", "quantity": 8, "rate": 50},
                ],
                "passes": [
                    {"name": "Single Session", "type": "daily", "days": 1, "price": 300, "max_day": 1},
                    {"name": "Monthly Wellness", "type": "monthly", "days": 30, "price": 5000, "max_day": None},
                    {"name": "Premium Annual", "type": "annual", "days": 365, "price": 45000, "max_day": None},
                ],
            },
        ]
        
        print("\n3️⃣ Creating gyms...")
        for gym_data in gyms_data:
            # Create gym
            gym = Gym(
                vendor_id=vendor.id,
                name=gym_data["name"],
                description=gym_data["description"],
                address=gym_data["address"],
                city=gym_data["city"],
                state=gym_data["state"],
                zip_code=gym_data["zip_code"],
                latitude=gym_data["latitude"],
                longitude=gym_data["longitude"],
                phone=gym_data["contact_phone"],
                email=gym_data["contact_email"],
                status='active'
            )
            db.add(gym)
            db.commit()
            db.refresh(gym)
            print(f"  ✅ {gym.name}")
            
            # Add facilities
            for facility_name in gym_data["facilities"]:
                facility = GymFacility(
                    gym_id=gym.id,
                    facility_type=facility_name,
                    is_available=True
                )
                db.add(facility)
            
            # Add operating hours (weekday and weekend)
            weekday_hours = GymOperatingHours(
                gym_id=gym.id,
                day_type='weekday',
                open_time=time(6, 0),
                close_time=time(22, 0),
                is_closed=False
            )
            db.add(weekday_hours)
            
            weekend_hours = GymOperatingHours(
                gym_id=gym.id,
                day_type='weekend',
                open_time=time(7, 0),
                close_time=time(21, 0),
                is_closed=False
            )
            db.add(weekend_hours)
            
            # Add equipment
            for eq_data in gym_data["equipment"]:
                equipment = Equipment(
                    gym_id=gym.id,
                    name=eq_data["name"],
                    equipment_type=eq_data["type"],
                    total_units=eq_data["quantity"],
                    active_units=eq_data["quantity"],
                    base_price_per_hour=Decimal(str(eq_data["rate"]))
                )
                db.add(equipment)
                db.commit()
                db.refresh(equipment)
                
                # Create time slots for next 7 days
                for day_offset in range(7):
                    slot_date = datetime.now().date() + timedelta(days=day_offset)
                    
                    # Create slots from 6 AM to 9 PM (1-hour slots)
                    for hour in range(6, 21):
                        slot = TimeSlot(
                            gym_id=gym.id,
                            equipment_id=equipment.id,
                            date=slot_date,
                            start_time=time(hour, 0),
                            end_time=time(hour + 1, 0),
                            capacity=eq_data["quantity"],
                            booked_count=0,
                            base_price=Decimal(str(eq_data["rate"])),
                            surge_multiplier=Decimal("1.0"),
                            is_available=True
                        )
                        db.add(slot)
            
            # Add membership passes
            for pass_data in gym_data["passes"]:
                membership_pass = MembershipPass(
                    gym_id=gym.id,
                    name=pass_data["name"],
                    pass_type=pass_data["type"],
                    duration_days=pass_data["days"],
                    price=Decimal(str(pass_data["price"])),
                    max_bookings_per_day=pass_data["max_day"],
                    is_active=True
                )
                db.add(membership_pass)
            
            db.commit()
        
        print("\n✅ Demo data seeded successfully!")
        print("\n📊 Summary:")
        print(f"  - Gyms: {len(gyms_data)}")
        print(f"  - Vendor: {vendor.phone} / {vendor.email}")
        print(f"  - Customer: {customer.phone} / {customer.email}")
        print("\n🚀 You can now:")
        print("  1. Login as vendor to manage gyms")
        print("  2. Login as customer to book equipment")
        print("  3. View gyms at: http://localhost:8000/api/v1/gyms")
        print("  4. API Docs: http://localhost:8000/api/docs")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    print("🌱 Openkora Demo Data Seeder")
    print("=" * 50)
    
    # Check if tables exist
    try:
        create_demo_data()
    except Exception as e:
        print(f"\n❌ Failed to seed data: {e}")
        print("\nMake sure:")
        print("  1. Database is running")
        print("  2. Migrations are applied")
        print("  3. Backend is configured correctly")
        sys.exit(1)
