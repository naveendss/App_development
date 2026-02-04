import psycopg2
import os
from dotenv import load_dotenv
from datetime import datetime, timedelta
import random

load_dotenv()

def seed_data():
    conn = psycopg2.connect(os.getenv('DATABASE_URL'))
    cur = conn.cursor()
    
    try:
        print('🌱 Starting seeding...\n')
        
        # Vendors
        print('👤 Creating vendors...')
        cur.execute("""
            INSERT INTO users (phone, email, full_name, user_type, profile_image_url)
            VALUES ('+1-555-0101', 'vendor1@openkora.com', 'Iron Paradise Owner', 'vendor', 'https://i.pravatar.cc/150?img=12')
            RETURNING id;
        """)
        vendor_id1 = cur.fetchone()[0]
        
        cur.execute("""
            INSERT INTO users (phone, email, full_name, user_type, profile_image_url)
            VALUES ('+1-555-0102', 'vendor2@openkora.com', 'Elite Fitness Owner', 'vendor', 'https://i.pravatar.cc/150?img=33')
            RETURNING id;
        """)
        vendor_id2 = cur.fetchone()[0]
        
        # Customers
        print('👥 Creating customers...')
        customers = []
        customer_data = [
            ('+1-555-1001', 'alex@example.com', 'Alex Johnson', 'male', '1995-03-15'),
            ('+1-555-1002', 'sarah@example.com', 'Sarah Jenkins', 'female', '1992-07-22'),
            ('+1-555-1003', 'marcus@example.com', 'Marcus Sterling', 'male', '1988-11-10'),
            ('+1-555-1004', 'elena@example.com', 'Elena Rodriguez', 'female', '1997-05-18'),
            ('+1-555-1005', 'david@example.com', 'David Chen', 'male', '1990-09-25')
        ]
        
        for phone, email, name, gender, dob in customer_data:
            cur.execute("""
                INSERT INTO users (phone, email, full_name, user_type, gender, date_of_birth, profile_image_url)
                VALUES (%s, %s, %s, 'customer', %s, %s, %s)
                RETURNING id;
            """, (phone, email, name, gender, dob, f'https://i.pravatar.cc/150?img={random.randint(1,70)}'))
            customers.append(cur.fetchone()[0])
        
        # Customer Profiles
        print('📋 Creating profiles...')
        for customer_id in customers:
            cur.execute("""
                INSERT INTO customer_profiles (user_id, weight_kg, height_cm, fitness_level, fitness_goal, location_lat, location_lng, location_name)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s);
            """, (customer_id, 70 + random.random() * 30, 160 + random.random() * 30,
                  random.choice(['beginner', 'intermediate', 'advanced']),
                  random.choice(['weight-loss', 'muscle-gain', 'endurance', 'general-fitness']),
                  40.7128 + (random.random() - 0.5) * 0.1, -74.0060 + (random.random() - 0.5) * 0.1, 'Downtown'))
        
        # Gyms
        print('🏋️ Creating gyms...')
        cur.execute("""
            INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, phone, email, rating, total_reviews, is_verified, status, logo_url)
            VALUES (%s, 'Iron Haven Gym', 'Premium strength training', '123 Fitness Ave', 'New York', 'NY', '10001', 40.7128, -74.0060, '+1-555-2001', 'info@ironhaven.com', 4.9, 142, true, 'active', 'https://i.pravatar.cc/300?img=50')
            RETURNING id;
        """, (vendor_id1,))
        gym_id1 = cur.fetchone()[0]
        
        cur.execute("""
            INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, phone, email, rating, total_reviews, is_verified, status, logo_url)
            VALUES (%s, 'The Forge Studio', 'Modern cardio studio', '456 Wellness Blvd', 'New York', 'NY', '10002', 40.7200, -74.0100, '+1-555-2002', 'hello@forge.com', 4.7, 98, true, 'active', 'https://i.pravatar.cc/300?img=51')
            RETURNING id;
        """, (vendor_id2,))
        gym_id2 = cur.fetchone()[0]
        
        # Gym Photos
        print('📸 Adding photos...')
        cur.execute("""
            INSERT INTO gym_photos (gym_id, image_url, display_order, is_primary)
            VALUES 
                (%s, 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800', 1, true),
                (%s, 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800', 1, true);
        """, (gym_id1, gym_id2))
        
        # Facilities
        print('🏢 Adding facilities...')
        facilities = ['WiFi', 'Parking', 'Showers', 'Lockers', 'Towel Service']
        for gym_id in [gym_id1, gym_id2]:
            for facility in facilities:
                cur.execute("INSERT INTO gym_facilities (gym_id, facility_type) VALUES (%s, %s);", (gym_id, facility))
        
        # Operating Hours
        print('⏰ Setting hours...')
        for gym_id in [gym_id1, gym_id2]:
            cur.execute("""
                INSERT INTO gym_operating_hours (gym_id, day_type, open_time, close_time)
                VALUES (%s, 'weekday', '06:00', '22:00'), (%s, 'weekend', '08:00', '20:00');
            """, (gym_id, gym_id))
        
        # Equipment
        print('💪 Adding equipment...')
        equipment_data = [
            ('Treadmills', 'cardio', 10, 8, 12.00, 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=400'),
            ('Spin Cycles', 'cycling', 15, 12, 15.00, 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=400'),
            ('Squat Racks', 'strength', 8, 6, 10.00, 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400'),
            ('Rowing Machines', 'cardio', 6, 5, 10.00, 'https://images.unsplash.com/photo-1519505907962-0a6cb0167c73?w=400')
        ]
        
        equipment = []
        for gym_id in [gym_id1, gym_id2]:
            for name, type_, total, active, price, img in equipment_data:
                cur.execute("""
                    INSERT INTO equipment (gym_id, name, equipment_type, total_units, active_units, base_price_per_hour, daily_cap_price, image_url)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id;
                """, (gym_id, name, type_, total, active, price, price * 5, img))
                equipment.append(cur.fetchone()[0])
        
        # Membership Passes
        print('🎫 Creating passes...')
        pass_data = [
            ('Starter Pass', 7, 45.00, 'weekly'),
            ('Pro Monthly', 30, 89.00, 'monthly'),
            ('Elite Annual', 365, 899.00, 'annual'),
            ('One-Day Pass', 1, 15.00, 'daily')
        ]
        
        for gym_id in [gym_id1, gym_id2]:
            for name, days, price, type_ in pass_data:
                cur.execute("""
                    INSERT INTO membership_passes (gym_id, name, duration_days, price, pass_type)
                    VALUES (%s, %s, %s, %s, %s);
                """, (gym_id, name, days, price, type_))
        
        # Time Slots
        print('📅 Creating slots...')
        for day in range(7):
            date = (datetime.now() + timedelta(days=day)).date()
            for eq_id in equipment[:4]:
                for hour in range(6, 22):
                    is_surge = hour in [7, 8, 9, 17, 18, 19]
                    cur.execute("""
                        INSERT INTO time_slots (gym_id, equipment_id, date, start_time, end_time, capacity, booked_count, base_price, surge_multiplier, is_surge_active)
                        VALUES (%s, %s, %s, %s, %s, 10, %s, 12.00, %s, %s);
                    """, (gym_id1, eq_id, date, f'{hour:02d}:00', f'{hour+1:02d}:00', random.randint(0, 5), 1.2 if is_surge else 1.0, is_surge))
        
        # User Memberships
        print('💳 Creating memberships...')
        for i, customer_id in enumerate(customers):
            booking_id = f'OK-{88000 + i}'
            cur.execute("""
                INSERT INTO user_memberships (user_id, gym_id, pass_id, booking_id, start_date, end_date, status, payment_status, amount_paid, qr_code_url)
                SELECT %s, %s, id, %s, CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 'active', 'paid', 89.00, 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=' || %s
                FROM membership_passes WHERE gym_id = %s AND pass_type = 'monthly' LIMIT 1;
            """, (customer_id, gym_id1 if i % 2 == 0 else gym_id2, booking_id, booking_id, gym_id1 if i % 2 == 0 else gym_id2))
        
        # Reviews
        print('⭐ Adding reviews...')
        reviews = ['Great gym!', 'Clean facilities.', 'Best gym in area!', 'Good value.', 'Amazing experience!']
        for i in range(10):
            cur.execute("""
                INSERT INTO reviews (user_id, gym_id, rating, review_text)
                VALUES (%s, %s, %s, %s);
            """, (customers[i % len(customers)], gym_id1 if i % 2 == 0 else gym_id2, random.randint(4, 5), reviews[i % 5]))
        
        conn.commit()
        print('\n✅ Seeding completed!')
        
    except Exception as e:
        print(f'❌ Error: {e}')
        conn.rollback()
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    seed_data()
