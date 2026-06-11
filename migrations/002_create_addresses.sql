-- Migration: 002_create_addresses.sql
-- Description: Creates the addresses table for storing user shipping/billing addresses.
-- Design Choices:
--   - FK to users with ON DELETE CASCADE to clean up orphaned addresses.
--   - is_default boolean to mark primary address per type (shipping/billing).
--   - TEXT fields for address lines to support international formats.
-- Scalability Notes:
--   - Index on user_id + is_default for fast checkout address selection.
--   - Consider geocoding columns (lat/lng) for delivery optimization.

CREATE TABLE IF NOT EXISTS addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    address_type VARCHAR(20) DEFAULT 'shipping' CHECK (address_type IN ('shipping', 'billing')),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Composite index for fetching default addresses quickly
CREATE INDEX idx_addresses_user_id_is_default ON addresses(user_id, is_default);
-- Index on user_id for listing all addresses
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
-- Index on postal_code for regional analytics
CREATE INDEX idx_addresses_postal_code ON addresses(postal_code);

COMMENT ON TABLE addresses IS 'Stores shipping and billing addresses for users.';
COMMENT ON COLUMN addresses.is_default IS 'Marks the primary address for a given type (shipping/billing).';
COMMENT ON COLUMN addresses.address_type IS 'Distinguishes between shipping and billing addresses.';
