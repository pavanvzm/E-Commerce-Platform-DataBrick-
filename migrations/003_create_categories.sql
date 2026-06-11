-- Migration: 003_create_categories.sql
-- Description: Creates the categories table for product categorization.
-- Design Choices:
--   - Self-referencing parent_id for hierarchical categories (e.g., Electronics > Phones).
--   - slug VARCHAR for SEO-friendly URLs.
--   - is_active to hide deprecated categories without breaking historical orders.
-- Scalability Notes:
--   - Index on parent_id for building category trees efficiently.
--   - Consider materialized paths or closure tables for deep hierarchies.

CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on parent_id for hierarchical queries
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
-- Index on slug for SEO lookups
CREATE INDEX idx_categories_slug ON categories(slug);
-- Index on is_active for filtering active categories
CREATE INDEX idx_categories_is_active ON categories(is_active);

COMMENT ON TABLE categories IS 'Hierarchical product categories with SEO-friendly slugs.';
COMMENT ON COLUMN categories.parent_id IS 'Self-reference for nested category structures.';
COMMENT ON COLUMN categories.slug IS 'URL-friendly identifier for SEO purposes.';
