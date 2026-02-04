-- Demo data for Openkora
-- Run this in Supabase SQL Editor

-- Create demo vendor
INSERT INTO users (phone, email, full_name, user_type) VALUES
('+919876543210', 'vendor@openkora.com', 'Demo Vendor', 'vendor')
ON CONFLICT (phone) DO NOTHING;

-- Create demo customer  
INSERT INTO users (phone, email, full_name, user_type) VALUES
('+919876543211', 'customer@openkora.com', 'Demo Customer', 'customer')
ON CONFLICT (phone) DO NOTHING;

-- Get vendor ID
DO $$
DECLARE
    vendor_id UUID;
    gym1_id UUID;
    gym2_id UUID;
    gym3_id UUID;
    gym4_id UUID;
    gym5_id UUID;
BEGIN
    SELECT id INTO vendor_id FROM users WHERE email = 'vendor@openkora.com';
    
    -- Gym 1: Iron Haven Fitness
    INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, contact_phone, contact_email, is_active)
    VALUES (vendor_id, 'Iron Haven Fitness', 'Premium gym with state-of-the-art equipment and expert trainers. Perfect for serious fitness enthusiasts.', '123 MG Road, Bandra West', 'Mumbai', 'Maharashtra', '400050', 19.0596, 72.8295, '+912226431234', 'info@ironhaven.com', true)
    RETURNING id INTO gym1_id;
    
    -- Gym 2: The Forge Studio
    INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, contact_phone, contact_email, is_active)
    VALUES (vendor_id, 'The Forge Studio', 'Boutique fitness studio specializing in HIIT, yoga, and cycling classes. Community-focused atmosphere.', '456 Linking Road, Khar West', 'Mumbai', 'Maharashtra', '400052', 19.0728, 72.8326, '+912226432345', 'hello@forgestudio.com', true)
    RETURNING id INTO gym2_id;
    
    -- Gym 3: Iron Paradise
    INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, contact_phone, contact_email, is_active)
    VALUES (vendor_id, 'Iron Paradise', '24/7 gym with extensive equipment selection. Open all day, every day for your convenience.', '789 SV Road, Andheri West', 'Mumbai', 'Maharashtra', '400058', 19.1136, 72.8697, '+912226433456', 'support@ironparadise.com', true)
    RETURNING id INTO gym3_id;
    
    -- Gym 4: Power Lift Center
    INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, contact_phone, contact_email, is_active)
    VALUES (vendor_id, 'Power Lift Center', 'Specialized powerlifting and CrossFit gym. Expert coaching and competition-grade equipment.', '321 Turner Road, Bandra West', 'Mumbai', 'Maharashtra', '400050', 19.0544, 72.8320, '+912226434567', 'info@powerlift.com', true)
    RETURNING id INTO gym4_id;
    
    -- Gym 5: Zenith Wellness
    INSERT INTO gyms (vendor_id, name, description, address, city, state, zip_code, latitude, longitude, contact_phone, contact_email, is_active)
    VALUES (vendor_id, 'Zenith Wellness', 'Holistic wellness center with gym, yoga, pilates, and spa facilities. Focus on mind-body balance.', '555 Juhu Tara Road, Juhu', 'Mumbai', 'Maharashtra', '400049', 19.0990, 72.8265, '+912226435678', 'wellness@zenith.com', true)
    RETURNING id INTO gym5_id;
    
    -- Add facilities for Gym 1
    INSERT INTO gym_facilities (gym_id, facility_name, is_available) VALUES
    (gym1_id, 'Cardio Zone', true),
    (gym1_id, 'Free Weights', true),
    (gym1_id, 'Power Racks', true),
    (gym1_id, 'Sauna', true),
    (gym1_id, 'Steam Room', true),
    (gym1_id, 'Locker Rooms', true);
    
    -- Add equipment for Gym 1
    INSERT INTO equipment (gym_id, equipment_name, equipment_type, brand, quantity, available_quantity, hourly_rate, is_available) VALUES
    (gym1_id, 'Treadmill', 'cardio', 'Life Fitness', 10, 10, 50, true),
    (gym1_id, 'Elliptical', 'cardio', 'Precor', 8, 8, 50, true),
    (gym1_id, 'Rowing Machine', 'cardio', 'Concept2', 5, 5, 60, true),
    (gym1_id, 'Bench Press', 'strength', 'Hammer Strength', 4, 4, 80, true),
    (gym1_id, 'Squat Rack', 'strength', 'Rogue', 3, 3, 100, true),
    (gym1_id, 'Dumbbells Set', 'strength', 'York', 20, 20, 40, true);
    
    -- Add membership passes for Gym 1
    INSERT INTO membership_passes (gym_id, name, pass_type, duration_days, price, max_bookings_per_day, is_active) VALUES
    (gym1_id, 'Daily Pass', 'daily', 1, 150, 1, true),
    (gym1_id, 'Weekly Pass', 'weekly', 7, 800, 2, true),
    (gym1_id, 'Monthly Pass', 'monthly', 30, 2500, NULL, true),
    (gym1_id, 'Quarterly Pass', 'quarterly', 90, 6500, NULL, true);
    
    -- Add facilities for Gym 2
    INSERT INTO gym_facilities (gym_id, facility_name, is_available) VALUES
    (gym2_id, 'Cycling Studio', true),
    (gym2_id, 'Yoga Room', true),
    (gym2_id, 'HIIT Zone', true),
    (gym2_id, 'Changing Rooms', true),
    (gym2_id, 'Showers', true);
    
    -- Add equipment for Gym 2
    INSERT INTO equipment (gym_id, equipment_name, equipment_type, brand, quantity, available_quantity, hourly_rate, is_available) VALUES
    (gym2_id, 'Spin Bike', 'cardio', 'Peloton', 15, 15, 70, true),
    (gym2_id, 'Yoga Mat', 'yoga', 'Manduka', 25, 25, 30, true),
    (gym2_id, 'Kettlebell', 'strength', 'Rogue', 15, 15, 40, true),
    (gym2_id, 'Battle Rope', 'functional', 'Onnit', 4, 4, 50, true);
    
    -- Add membership passes for Gym 2
    INSERT INTO membership_passes (gym_id, name, pass_type, duration_days, price, max_bookings_per_day, is_active) VALUES
    (gym2_id, 'Single Class', 'daily', 1, 200, 1, true),
    (gym2_id, '10 Class Pack', 'pack', 30, 1800, 1, true),
    (gym2_id, 'Unlimited Monthly', 'monthly', 30, 3500, NULL, true);
    
    -- Add facilities for Gym 3
    INSERT INTO gym_facilities (gym_id, facility_name, is_available) VALUES
    (gym3_id, 'Cardio Zone', true),
    (gym3_id, 'Free Weights', true),
    (gym3_id, 'Yoga Studio', true),
    (gym3_id, 'Sauna & Spa', true),
    (gym3_id, 'Cafe', true),
    (gym3_id, '24/7 Access', true);
    
    -- Add equipment for Gym 3
    INSERT INTO equipment (gym_id, equipment_name, equipment_type, brand, quantity, available_quantity, hourly_rate, is_available) VALUES
    (gym3_id, 'Treadmill', 'cardio', 'Matrix', 12, 12, 50, true),
    (gym3_id, 'Stair Climber', 'cardio', 'StairMaster', 6, 6, 60, true),
    (gym3_id, 'Cable Machine', 'strength', 'Life Fitness', 8, 8, 70, true),
    (gym3_id, 'Leg Press', 'strength', 'Hammer Strength', 4, 4, 80, true),
    (gym3_id, 'Smith Machine', 'strength', 'Cybex', 3, 3, 90, true);
    
    -- Add membership passes for Gym 3
    INSERT INTO membership_passes (gym_id, name, pass_type, duration_days, price, max_bookings_per_day, is_active) VALUES
    (gym3_id, 'Day Pass', 'daily', 1, 200, 1, true),
    (gym3_id, 'Monthly Unlimited', 'monthly', 30, 3000, NULL, true),
    (gym3_id, 'Annual Membership', 'annual', 365, 25000, NULL, true);
    
    -- Add facilities for Gym 4
    INSERT INTO gym_facilities (gym_id, facility_name, is_available) VALUES
    (gym4_id, 'Crossfit Box', true),
    (gym4_id, 'HIIT Zone', true),
    (gym4_id, 'Boxing Ring', true),
    (gym4_id, 'Olympic Lifting Platform', true),
    (gym4_id, 'Recovery Zone', true);
    
    -- Add equipment for Gym 4
    INSERT INTO equipment (gym_id, equipment_name, equipment_type, brand, quantity, available_quantity, hourly_rate, is_available) VALUES
    (gym4_id, 'Olympic Barbell', 'strength', 'Eleiko', 10, 10, 100, true),
    (gym4_id, 'Bumper Plates', 'strength', 'Rogue', 50, 50, 20, true),
    (gym4_id, 'Pull-up Bar', 'functional', 'Rogue', 8, 8, 40, true),
    (gym4_id, 'Assault Bike', 'cardio', 'Assault', 6, 6, 60, true),
    (gym4_id, 'Boxing Bag', 'functional', 'Everlast', 5, 5, 50, true);
    
    -- Add membership passes for Gym 4
    INSERT INTO membership_passes (gym_id, name, pass_type, duration_days, price, max_bookings_per_day, is_active) VALUES
    (gym4_id, 'Drop-in', 'daily', 1, 250, 1, true),
    (gym4_id, 'Weekly Pass', 'weekly', 7, 1200, 2, true),
    (gym4_id, 'Monthly Unlimited', 'monthly', 30, 4000, NULL, true);
    
    -- Add facilities for Gym 5
    INSERT INTO gym_facilities (gym_id, facility_name, is_available) VALUES
    (gym5_id, 'Yoga Studio', true),
    (gym5_id, 'Pilates Room', true),
    (gym5_id, 'Swimming Pool', true),
    (gym5_id, 'Spa', true),
    (gym5_id, 'Meditation Room', true),
    (gym5_id, 'Juice Bar', true);
    
    -- Add equipment for Gym 5
    INSERT INTO equipment (gym_id, equipment_name, equipment_type, brand, quantity, available_quantity, hourly_rate, is_available) VALUES
    (gym5_id, 'Reformer', 'pilates', 'Balanced Body', 10, 10, 100, true),
    (gym5_id, 'Yoga Mat', 'yoga', 'Lululemon', 30, 30, 30, true),
    (gym5_id, 'TRX Suspension', 'functional', 'TRX', 12, 12, 50, true),
    (gym5_id, 'Treadmill', 'cardio', 'Technogym', 8, 8, 50, true);
    
    -- Add membership passes for Gym 5
    INSERT INTO membership_passes (gym_id, name, pass_type, duration_days, price, max_bookings_per_day, is_active) VALUES
    (gym5_id, 'Single Session', 'daily', 1, 300, 1, true),
    (gym5_id, 'Monthly Wellness', 'monthly', 30, 5000, NULL, true),
    (gym5_id, 'Premium Annual', 'annual', 365, 45000, NULL, true);
    
END $$;

-- Success message
SELECT '✅ Demo data seeded successfully!' as message;
SELECT COUNT(*) as total_gyms FROM gyms;
SELECT COUNT(*) as total_equipment FROM equipment;
SELECT COUNT(*) as total_passes FROM membership_passes;
