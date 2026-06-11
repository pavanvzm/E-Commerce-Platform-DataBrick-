-- Migration: 004_create_brands.sql
-- Description: Creates the brands table for product brand management.
-- Design Choices:
--   - slug VARCHAR for SEO-friendly URLs.
--   - is_active to hide discontinued brands without affecting historical data.
--   - LOGO_URL could be added later for brand assets.
-- Scalability Notes:
--   - Index on slug for fast lookups in product filtering.

CREATE TABLE IF NOT EXISTS brands (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    website_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on slug for SEO and filtering
CREATE INDEX idx_brands_slug ON brands(slug);
-- Index on is_active for active brand listings
CREATE INDEX idx_brands_is_active ON brands(is_active);

COMMENT ON TABLE brands IS 'Product brands with SEO slugs and activation status.';
COMMENT ON COLUMN brands.slug IS 'URL-friendly identifier for brand pages.';
