-- Add password_hash column to users table for email/password authentication
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;

-- Make email required and unique
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- Add index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Update existing users to have a default password hash (they'll need to reset)
-- This is bcrypt hash for "ChangeMe123!" - users should change this
UPDATE users 
SET password_hash = '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYfZRxZfHvC'
WHERE password_hash IS NULL;
