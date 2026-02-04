-- Migration: Add max_bookings_per_week column to membership_passes table
-- Date: 2026-02-04

ALTER TABLE membership_passes 
ADD COLUMN IF NOT EXISTS max_bookings_per_week INTEGER;

COMMENT ON COLUMN membership_passes.max_bookings_per_week IS 'Maximum number of bookings allowed per week for this membership pass';
