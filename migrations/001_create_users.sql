-- Migration: 001_create_users.sql
-- Description: Creates the users table for storing customer and admin accounts.
-- Design Choices:
--   - BIGINT for IDs to support high-volume growth (billions of records).
--   - VARCHAR(255) for email/name balances storage vs flexibility.
--   - TEXT for password_hash to accommodate various hashing algorithms (bcrypt, argon2).
--   - is_active boolean for soft-deletion/account suspension without data loss.
-- Scalability Notes:
--   - Consider partitioning by created_at (range) if user count exceeds 100M.
--   - Add read replicas for authentication queries under heavy load.

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'vendor')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on email for fast login lookups
CREATE INDEX idx_users_email ON users(email);
-- Index on phone for account recovery
CREATE INDEX idx_users_phone ON users(phone);
-- Index on role for admin dashboards
CREATE INDEX idx_users_role ON users(role);
-- Index on created_at for analytics
CREATE INDEX idx_users_created_at ON users(created_at);

COMMENT ON TABLE users IS 'Stores all user accounts (customers, admins, vendors).';
COMMENT ON COLUMN users.role IS 'Role-based access control: customer, admin, vendor.';
COMMENT ON COLUMN users.is_active IS 'Soft-delete flag; false means account is suspended/deleted.';
