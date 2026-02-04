-- Migration 001: Create Core Tables for Openkora Platform
-- PostgreSQL + Supabase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS for location features
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- ENUMS
-- ============================================

CREATE TYPE user_type_enum AS ENUM ('customer', 'vendor');
CREATE TYPE gender_enum AS ENUM ('male', 'female', 'non-binary', 'prefer-not-to-say');
CREATE TYPE fitness_level_enum AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE fitness_goal_enum AS ENUM ('weight-loss', 'muscle-gain', 'endurance', 'general-fitness');
CREATE TYPE gym_status_enum AS ENUM ('pending', 'active', 'suspended');
CREATE TYPE pass_type_enum AS ENUM ('daily', 'weekly', 'monthly', 'annual');
CREATE TYPE membership_status_enum AS ENUM ('active', 'expired', 'cancelled');
CREATE TYPE payment_status_enum AS ENUM ('pending', 'paid', 'failed', 'refunded');
CREATE TYPE booking_status_enum AS ENUM ('upcoming', 'active', 'completed', 'cancelled');
CREATE TYPE payment_method_enum AS ENUM ('visa', 'mastercard', 'apple_pay', 'google_pay', 'cash');
CREATE TYPE post_type_enum AS ENUM ('text', 'image', 'motivation', 'event');
CREATE TYPE notification_type_enum AS ENUM ('booking', 'payment', 'reminder', 'community', 'system');
CREATE TYPE day_type_enum AS ENUM ('weekday', 'weekend');

-- ============================================
-- TABLE: users
-- ============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    gender gender_enum,
    profile_image_url TEXT,
    user_type user_type_enum NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for users
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);

-- ============================================
-- TABLE: customer_profiles
-- ============================================

CREATE TABLE customer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    fitness_level fitness_level_enum,
    fitness_goal fitness_goal_enum,
    location_lat DECIMAL(10,8),
    location_lng DECIMAL(11,8),
    location_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for customer profiles
CREATE INDEX idx_customer_profiles_user ON customer_profiles(user_id);

-- ============================================
-- TABLE: gyms
-- ============================================

CREATE TABLE gyms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    logo_url TEXT,
    address TEXT NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'USA',
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    phone VARCHAR(20),
    email VARCHAR(255),
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    status gym_status_enum DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for gyms
CREATE INDEX idx_gyms_vendor ON gyms(vendor_id);
CREATE INDEX idx_gyms_status ON gyms(status);
CREATE INDEX idx_gyms_location ON gyms(latitude, longitude);

-- ============================================
-- TABLE: gym_photos
-- ============================================

CREATE TABLE gym_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for gym photos
CREATE INDEX idx_gym_photos_gym ON gym_photos(gym_id);

-- ============================================
-- TABLE: gym_facilities
-- ============================================

CREATE TABLE gym_facilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    facility_type VARCHAR(100) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for gym facilities
CREATE INDEX idx_gym_facilities_gym ON gym_facilities(gym_id);

-- ============================================
-- TABLE: gym_operating_hours
-- ============================================

CREATE TABLE gym_operating_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    day_type day_type_enum NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE
);

-- Index for gym operating hours
CREATE INDEX idx_gym_hours_gym ON gym_operating_hours(gym_id);

-- ============================================
-- TABLE: equipment
-- ============================================

CREATE TABLE equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    total_units INT NOT NULL CHECK (total_units >= 0),
    active_units INT NOT NULL CHECK (active_units >= 0),
    base_price_per_hour DECIMAL(10,2) NOT NULL CHECK (base_price_per_hour >= 0),
    daily_cap_price DECIMAL(10,2),
    equipment_type VARCHAR(100),
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_active_units CHECK (active_units <= total_units)
);

-- Indexes for equipment
CREATE INDEX idx_equipment_gym ON equipment(gym_id);
CREATE INDEX idx_equipment_type ON equipment(equipment_type);

-- ============================================
-- TABLE: membership_passes
-- ============================================

CREATE TABLE membership_passes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration_days INT NOT NULL CHECK (duration_days > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    pass_type pass_type_enum NOT NULL,
    includes_equipment BOOLEAN DEFAULT TRUE,
    max_bookings_per_day INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for membership passes
CREATE INDEX idx_membership_passes_gym ON membership_passes(gym_id);

-- ============================================
-- Auto-update updated_at trigger function
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customer_profiles_updated_at BEFORE UPDATE ON customer_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gyms_updated_at BEFORE UPDATE ON gyms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_updated_at BEFORE UPDATE ON equipment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_membership_passes_updated_at BEFORE UPDATE ON membership_passes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Comments for documentation
-- ============================================

COMMENT ON TABLE users IS 'Stores all users (customers and vendors)';
COMMENT ON TABLE customer_profiles IS 'Extended profile information for customers';
COMMENT ON TABLE gyms IS 'Gym/venue information owned by vendors';
COMMENT ON TABLE gym_photos IS 'Multiple photos for each gym';
COMMENT ON TABLE gym_facilities IS 'Facilities/amenities available at gyms';
COMMENT ON TABLE gym_operating_hours IS 'Operating hours for gyms';
COMMENT ON TABLE equipment IS 'Equipment available at gyms';
COMMENT ON TABLE membership_passes IS 'Membership pass types offered by gyms';
