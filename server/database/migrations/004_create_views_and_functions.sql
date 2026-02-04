-- Migration 004: Create Views and Helper Functions
-- PostgreSQL + Supabase

-- ============================================
-- VIEW: active_bookings_dashboard
-- ============================================

CREATE OR REPLACE VIEW active_bookings_dashboard AS
SELECT 
    b.id AS booking_id,
    b.booking_date,
    b.start_time,
    b.end_time,
    b.status,
    b.equipment_station,
    b.total_price,
    u.id AS user_id,
    u.full_name AS customer_name,
    u.phone AS customer_phone,
    u.profile_image_url AS customer_image,
    g.id AS gym_id,
    g.name AS gym_name,
    g.address AS gym_address,
    e.name AS equipment_name,
    e.equipment_type,
    b.qr_code_url,
    b.checked_in_at,
    b.created_at
FROM bookings b
JOIN users u ON b.user_id = u.id
JOIN gyms g ON b.gym_id = g.id
LEFT JOIN equipment e ON b.equipment_id = e.id
WHERE b.status IN ('upcoming', 'active')
ORDER BY b.booking_date DESC, b.start_time ASC;

COMMENT ON VIEW active_bookings_dashboard IS 'Dashboard view for active and upcoming bookings';

-- ============================================
-- VIEW: gym_revenue_summary
-- ============================================

CREATE OR REPLACE VIEW gym_revenue_summary AS
SELECT 
    g.id AS gym_id,
    g.name AS gym_name,
    g.vendor_id,
    COUNT(DISTINCT b.id) AS total_bookings,
    COUNT(DISTINCT um.id) AS total_memberships,
    COALESCE(SUM(p.amount), 0) AS total_revenue,
    COALESCE(SUM(CASE WHEN p.payment_date >= CURRENT_DATE THEN p.amount ELSE 0 END), 0) AS today_revenue,
    COALESCE(SUM(CASE WHEN p.payment_date >= CURRENT_DATE - INTERVAL '7 days' THEN p.amount ELSE 0 END), 0) AS week_revenue,
    COALESCE(SUM(CASE WHEN p.payment_date >= CURRENT_DATE - INTERVAL '30 days' THEN p.amount ELSE 0 END), 0) AS month_revenue,
    COUNT(DISTINCT CASE WHEN b.booking_date = CURRENT_DATE THEN b.user_id END) AS today_checkins,
    COUNT(DISTINCT CASE WHEN b.status = 'active' THEN b.id END) AS active_sessions
FROM gyms g
LEFT JOIN bookings b ON g.id = b.gym_id
LEFT JOIN user_memberships um ON g.id = um.gym_id
LEFT JOIN payments p ON g.id = p.gym_id AND p.payment_status = 'paid'
GROUP BY g.id, g.name, g.vendor_id;

COMMENT ON VIEW gym_revenue_summary IS 'Revenue and booking statistics per gym';

-- ============================================
-- VIEW: member_attendance_stats
-- ============================================

CREATE OR REPLACE VIEW member_attendance_stats AS
SELECT 
    u.id AS user_id,
    u.full_name,
    u.profile_image_url,
    g.id AS gym_id,
    g.name AS gym_name,
    um.booking_id AS membership_id,
    um.status AS membership_status,
    um.payment_status,
    um.end_date AS membership_expiry,
    COUNT(a.id) AS total_checkins,
    COUNT(CASE WHEN a.check_in_time >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) AS checkins_last_30_days,
    MAX(a.check_in_time) AS last_checkin,
    ROUND(COUNT(a.id)::DECIMAL / NULLIF((CURRENT_DATE - um.start_date), 0) * 7, 1) AS avg_checkins_per_week
FROM users u
JOIN user_memberships um ON u.id = um.user_id
JOIN gyms g ON um.gym_id = g.id
LEFT JOIN attendance a ON u.id = a.user_id AND g.id = a.gym_id
WHERE u.user_type = 'customer'
GROUP BY u.id, u.full_name, u.profile_image_url, g.id, g.name, um.booking_id, um.status, um.payment_status, um.end_date, um.start_date;

COMMENT ON VIEW member_attendance_stats IS 'Member attendance statistics per gym';

-- ============================================
-- VIEW: equipment_utilization
-- ============================================

CREATE OR REPLACE VIEW equipment_utilization AS
SELECT 
    e.id AS equipment_id,
    e.name AS equipment_name,
    e.equipment_type,
    e.gym_id,
    g.name AS gym_name,
    e.total_units,
    e.active_units,
    e.base_price_per_hour,
    COUNT(DISTINCT ts.id) AS total_slots,
    COUNT(DISTINCT CASE WHEN ts.is_available = FALSE THEN ts.id END) AS fully_booked_slots,
    COALESCE(AVG(ts.booked_count), 0) AS avg_bookings_per_slot,
    COALESCE(SUM(b.total_price), 0) AS total_revenue,
    COUNT(DISTINCT b.id) AS total_bookings
FROM equipment e
JOIN gyms g ON e.gym_id = g.id
LEFT JOIN time_slots ts ON e.id = ts.equipment_id
LEFT JOIN bookings b ON e.id = b.equipment_id
GROUP BY e.id, e.name, e.equipment_type, e.gym_id, g.name, e.total_units, e.active_units, e.base_price_per_hour;

COMMENT ON VIEW equipment_utilization IS 'Equipment utilization and revenue statistics';

-- ============================================
-- VIEW: nearby_gyms_with_distance
-- ============================================

CREATE OR REPLACE VIEW nearby_gyms_with_distance AS
SELECT 
    g.id,
    g.name,
    g.description,
    g.logo_url,
    g.address,
    g.city,
    g.state,
    g.latitude,
    g.longitude,
    g.rating,
    g.total_reviews,
    g.is_verified,
    g.status,
    (SELECT image_url FROM gym_photos WHERE gym_id = g.id AND is_primary = TRUE LIMIT 1) AS primary_image,
    (SELECT MIN(price) FROM membership_passes WHERE gym_id = g.id AND is_active = TRUE) AS min_pass_price,
    (SELECT COUNT(*) FROM equipment WHERE gym_id = g.id) AS equipment_count,
    ARRAY_AGG(DISTINCT gf.facility_type) FILTER (WHERE gf.facility_type IS NOT NULL) AS facilities
FROM gyms g
LEFT JOIN gym_facilities gf ON g.id = gf.gym_id AND gf.is_available = TRUE
WHERE g.status = 'active'
GROUP BY g.id;

COMMENT ON VIEW nearby_gyms_with_distance IS 'Gym listing with aggregated data for search results';

-- ============================================
-- FUNCTION: search_gyms_by_location
-- ============================================

CREATE OR REPLACE FUNCTION search_gyms_by_location(
    user_lat DECIMAL(10,8),
    user_lng DECIMAL(11,8),
    search_radius_km DECIMAL DEFAULT 10.0,
    equipment_filter TEXT DEFAULT NULL
)
RETURNS TABLE (
    gym_id UUID,
    gym_name VARCHAR(255),
    gym_address TEXT,
    gym_rating DECIMAL(3,2),
    total_reviews INT,
    distance_km DECIMAL(10,2),
    min_price DECIMAL(10,2),
    logo_url TEXT,
    primary_image TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        g.id,
        g.name,
        g.address,
        g.rating,
        g.total_reviews,
        ROUND(
            (6371 * acos(
                cos(radians(user_lat)) * 
                cos(radians(g.latitude)) * 
                cos(radians(g.longitude) - radians(user_lng)) + 
                sin(radians(user_lat)) * 
                sin(radians(g.latitude))
            ))::NUMERIC, 
            2
        ) AS distance_km,
        (SELECT MIN(price) FROM membership_passes WHERE gym_id = g.id AND is_active = TRUE),
        g.logo_url,
        (SELECT image_url FROM gym_photos WHERE gym_id = g.id AND is_primary = TRUE LIMIT 1)
    FROM gyms g
    WHERE g.status = 'active'
        AND (equipment_filter IS NULL OR EXISTS (
            SELECT 1 FROM equipment e 
            WHERE e.gym_id = g.id 
            AND e.equipment_type ILIKE '%' || equipment_filter || '%'
        ))
    HAVING ROUND(
        (6371 * acos(
            cos(radians(user_lat)) * 
            cos(radians(g.latitude)) * 
            cos(radians(g.longitude) - radians(user_lng)) + 
            sin(radians(user_lat)) * 
            sin(radians(g.latitude))
        ))::NUMERIC, 
        2
    ) <= search_radius_km
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION search_gyms_by_location IS 'Search gyms by user location with distance calculation';

-- ============================================
-- FUNCTION: get_available_slots
-- ============================================

CREATE OR REPLACE FUNCTION get_available_slots(
    p_gym_id UUID,
    p_equipment_id UUID DEFAULT NULL,
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    slot_id UUID,
    start_time TIME,
    end_time TIME,
    capacity INT,
    booked_count INT,
    available_spots INT,
    base_price DECIMAL(10,2),
    final_price DECIMAL(10,2),
    is_surge_active BOOLEAN,
    surge_multiplier DECIMAL(3,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ts.id,
        ts.start_time,
        ts.end_time,
        ts.capacity,
        ts.booked_count,
        (ts.capacity - ts.booked_count) AS available_spots,
        ts.base_price,
        ROUND((ts.base_price * ts.surge_multiplier)::NUMERIC, 2) AS final_price,
        ts.is_surge_active,
        ts.surge_multiplier
    FROM time_slots ts
    WHERE ts.gym_id = p_gym_id
        AND ts.date = p_date
        AND ts.is_available = TRUE
        AND (p_equipment_id IS NULL OR ts.equipment_id = p_equipment_id)
    ORDER BY ts.start_time ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_available_slots IS 'Get available time slots for a gym/equipment on a specific date';

-- ============================================
-- FUNCTION: check_membership_validity
-- ============================================

CREATE OR REPLACE FUNCTION check_membership_validity(
    p_user_id UUID,
    p_gym_id UUID
)
RETURNS TABLE (
    is_valid BOOLEAN,
    membership_id UUID,
    booking_id VARCHAR(50),
    days_remaining INT,
    status membership_status_enum
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (um.end_date >= CURRENT_DATE AND um.status = 'active' AND um.payment_status = 'paid') AS is_valid,
        um.id,
        um.booking_id,
        (um.end_date - CURRENT_DATE) AS days_remaining,
        um.status
    FROM user_memberships um
    WHERE um.user_id = p_user_id
        AND um.gym_id = p_gym_id
        AND um.status = 'active'
    ORDER BY um.end_date DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_membership_validity IS 'Check if user has valid membership for a gym';

-- ============================================
-- FUNCTION: create_notification
-- ============================================

CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_title VARCHAR(255),
    p_message TEXT,
    p_type notification_type_enum,
    p_related_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    notification_id UUID;
BEGIN
    INSERT INTO notifications (user_id, title, message, notification_type, related_id)
    VALUES (p_user_id, p_title, p_message, p_type, p_related_id)
    RETURNING id INTO notification_id;
    
    RETURN notification_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_notification IS 'Helper function to create user notifications';

-- ============================================
-- FUNCTION: get_vendor_dashboard_stats
-- ============================================

CREATE OR REPLACE FUNCTION get_vendor_dashboard_stats(
    p_vendor_id UUID,
    p_gym_id UUID DEFAULT NULL
)
RETURNS TABLE (
    total_checkins_today INT,
    active_slots INT,
    daily_revenue DECIMAL(10,2),
    weekly_revenue DECIMAL(10,2),
    monthly_revenue DECIMAL(10,2),
    total_members INT,
    active_members INT,
    pending_payments INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(DISTINCT CASE WHEN a.check_in_time::DATE = CURRENT_DATE THEN a.id END)::INT,
        COUNT(DISTINCT CASE WHEN b.status = 'active' THEN b.id END)::INT,
        COALESCE(SUM(CASE WHEN p.payment_date::DATE = CURRENT_DATE AND p.payment_status = 'paid' THEN p.amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.payment_date >= CURRENT_DATE - INTERVAL '7 days' AND p.payment_status = 'paid' THEN p.amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN p.payment_date >= CURRENT_DATE - INTERVAL '30 days' AND p.payment_status = 'paid' THEN p.amount ELSE 0 END), 0),
        COUNT(DISTINCT um.user_id)::INT,
        COUNT(DISTINCT CASE WHEN um.status = 'active' AND um.end_date >= CURRENT_DATE THEN um.user_id END)::INT,
        COUNT(DISTINCT CASE WHEN um.payment_status = 'pending' THEN um.id END)::INT
    FROM gyms g
    LEFT JOIN attendance a ON g.id = a.gym_id
    LEFT JOIN bookings b ON g.id = b.gym_id
    LEFT JOIN payments p ON g.id = p.gym_id
    LEFT JOIN user_memberships um ON g.id = um.gym_id
    WHERE g.vendor_id = p_vendor_id
        AND (p_gym_id IS NULL OR g.id = p_gym_id);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_vendor_dashboard_stats IS 'Get dashboard statistics for vendor';

-- ============================================
-- Grant permissions for views and functions
-- ============================================

-- Grant SELECT on views to authenticated users
GRANT SELECT ON active_bookings_dashboard TO authenticated;
GRANT SELECT ON gym_revenue_summary TO authenticated;
GRANT SELECT ON member_attendance_stats TO authenticated;
GRANT SELECT ON equipment_utilization TO authenticated;
GRANT SELECT ON nearby_gyms_with_distance TO authenticated;

-- Grant EXECUTE on functions to authenticated users
GRANT EXECUTE ON FUNCTION search_gyms_by_location TO authenticated;
GRANT EXECUTE ON FUNCTION get_available_slots TO authenticated;
GRANT EXECUTE ON FUNCTION check_membership_validity TO authenticated;
GRANT EXECUTE ON FUNCTION create_notification TO authenticated;
GRANT EXECUTE ON FUNCTION get_vendor_dashboard_stats TO authenticated;
