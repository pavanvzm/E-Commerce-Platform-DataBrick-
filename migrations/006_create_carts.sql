-- Migration: 006_create_carts.sql
-- Description: Creates the carts table for storing user shopping cart sessions.
-- Design Choices:
--   - One-to-one relationship with users (one active cart per user).
--   - UNIQUE constraint on user_id to enforce single cart policy.
--   - is_active flag to support abandoned cart recovery workflows.
-- Scalability Notes:
--   - Archive old carts to a separate table/partition after 90 days of inactivity.
--   - Consider Redis for active cart caching to reduce DB load.

CREATE TABLE IF NOT EXISTS carts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on is_active for finding active carts
CREATE INDEX idx_carts_is_active ON carts(is_active);

COMMENT ON TABLE carts IS 'User shopping carts; one active cart per user.';
COMMENT ON COLUMN carts.is_active IS 'Indicates if cart is currently in use or abandoned.';
