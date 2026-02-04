-- Migration 002: Create Booking and Membership Tables
-- PostgreSQL + Supabase

-- ============================================
-- TABLE: user_memberships
-- ============================================

CREATE TABLE user_memberships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    pass_id UUID NOT NULL REFERENCES membership_passes(id) ON DELETE RESTRICT,
    booking_id VARCHAR(50) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status membership_status_enum DEFAULT 'active',
    payment_status payment_status_enum DEFAULT 'pending',
    amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid >= 0),
    qr_code_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for user_memberships
CREATE INDEX idx_memberships_user ON user_memberships(user_id);
CREATE INDEX idx_memberships_gym ON user_memberships(gym_id);
CREATE INDEX idx_memberships_status ON user_memberships(status);
CREATE INDEX idx_memberships_booking_id ON user_memberships(booking_id);
CREATE INDEX idx_memberships_dates ON user_memberships(start_date, end_date);

-- ============================================
-- TABLE: time_slots
-- ============================================

CREATE TABLE time_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    equipment_id UUID REFERENCES equipment(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    capacity INT NOT NULL CHECK (capacity >= 0),
    booked_count INT DEFAULT 0 CHECK (booked_count >= 0),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price >= 0),
    surge_multiplier DECIMAL(3,2) DEFAULT 1.0 CHECK (surge_multiplier >= 1.0),
    is_surge_active BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_booked_capacity CHECK (booked_count <= capacity),
    CONSTRAINT check_time_order CHECK (end_time > start_time)
);

-- Indexes for time_slots
CREATE INDEX idx_slots_gym_date ON time_slots(gym_id, date);
CREATE INDEX idx_slots_equipment_date ON time_slots(equipment_id, date);
CREATE INDEX idx_slots_availability ON time_slots(is_available, date);

-- ============================================
-- TABLE: bookings
-- ============================================

CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    equipment_id UUID REFERENCES equipment(id) ON DELETE SET NULL,
    slot_id UUID NOT NULL REFERENCES time_slots(id) ON DELETE RESTRICT,
    membership_id UUID REFERENCES user_memberships(id) ON DELETE SET NULL,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    equipment_station VARCHAR(50),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    status booking_status_enum DEFAULT 'upcoming',
    qr_code_url TEXT,
    checked_in_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_booking_time_order CHECK (end_time > start_time)
);

-- Indexes for bookings
CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_gym ON bookings(gym_id);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_slot ON bookings(slot_id);

-- ============================================
-- TABLE: attendance
-- ============================================

CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    membership_id UUID REFERENCES user_memberships(id) ON DELETE SET NULL,
    check_in_time TIMESTAMP WITH TIME ZONE NOT NULL,
    check_out_time TIMESTAMP WITH TIME ZONE,
    scanned_by_vendor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for attendance
CREATE INDEX idx_attendance_user ON attendance(user_id);
CREATE INDEX idx_attendance_gym ON attendance(gym_id);
CREATE INDEX idx_attendance_date ON attendance(check_in_time);
CREATE INDEX idx_attendance_booking ON attendance(booking_id);

-- ============================================
-- TABLE: payments
-- ============================================

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    gym_id UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    membership_id UUID REFERENCES user_memberships(id) ON DELETE SET NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method payment_method_enum NOT NULL,
    payment_status payment_status_enum DEFAULT 'pending',
    transaction_id VARCHAR(255) UNIQUE,
    card_last_four VARCHAR(4),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for payments
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_gym ON payments(gym_id);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_payments_transaction ON payments(transaction_id);

-- ============================================
-- Triggers for auto-updating updated_at
-- ============================================

CREATE TRIGGER update_user_memberships_updated_at BEFORE UPDATE ON user_memberships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Function to auto-update slot booked_count
-- ============================================

CREATE OR REPLACE FUNCTION update_slot_booked_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Increment booked_count when new booking is created
        UPDATE time_slots 
        SET booked_count = booked_count + 1
        WHERE id = NEW.slot_id;
        
        -- Mark slot as unavailable if fully booked
        UPDATE time_slots 
        SET is_available = FALSE
        WHERE id = NEW.slot_id AND booked_count >= capacity;
        
    ELSIF TG_OP = 'DELETE' THEN
        -- Decrement booked_count when booking is deleted
        UPDATE time_slots 
        SET booked_count = GREATEST(0, booked_count - 1),
            is_available = TRUE
        WHERE id = OLD.slot_id;
        
    ELSIF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        -- Handle booking cancellation
        IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
            UPDATE time_slots 
            SET booked_count = GREATEST(0, booked_count - 1),
                is_available = TRUE
            WHERE id = NEW.slot_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to bookings table
CREATE TRIGGER trigger_update_slot_booked_count
    AFTER INSERT OR UPDATE OR DELETE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_slot_booked_count();

-- ============================================
-- Function to generate booking ID
-- ============================================

CREATE OR REPLACE FUNCTION generate_booking_id()
RETURNS TEXT AS $$
DECLARE
    new_id TEXT;
    id_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate ID in format OK-XXXXX (5 random digits)
        new_id := 'OK-' || LPAD(FLOOR(RANDOM() * 100000)::TEXT, 5, '0');
        
        -- Check if ID already exists
        SELECT EXISTS(SELECT 1 FROM user_memberships WHERE booking_id = new_id) INTO id_exists;
        
        -- Exit loop if ID is unique
        EXIT WHEN NOT id_exists;
    END LOOP;
    
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Comments for documentation
-- ============================================

COMMENT ON TABLE user_memberships IS 'Customer memberships/passes purchased';
COMMENT ON TABLE time_slots IS 'Available time slots for equipment/gym bookings';
COMMENT ON TABLE bookings IS 'Individual equipment/slot bookings';
COMMENT ON TABLE attendance IS 'Attendance tracking for gym check-ins';
COMMENT ON TABLE payments IS 'Payment transactions';
