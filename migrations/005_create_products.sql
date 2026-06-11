-- Migration: 005_create_products.sql
-- Description: Creates the products table for storing product catalog data.
-- Design Choices:
--   - DECIMAL(12,2) for price to avoid floating-point precision issues.
--   - FK to categories and brands with SET NULL on delete to preserve historical orders.
--   - is_active to hide products without removing them from order history.
--   - stock_quantity for basic inventory tracking (consider separate inventory service for scale).
-- Scalability Notes:
--   - Partition by category_id or created_at if product count exceeds 50M.
--   - Add full-text search indexes on name/description for search functionality.
--   - Consider read replicas for product listing queries.

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    compare_at_price DECIMAL(12,2) CHECK (compare_at_price >= 0 OR compare_at_price IS NULL),
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    brand_id BIGINT REFERENCES brands(id) ON DELETE SET NULL,
    sku VARCHAR(100) UNIQUE,
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on category_id for category browsing
CREATE INDEX idx_products_category_id ON products(category_id);
-- Index on brand_id for brand filtering
CREATE INDEX idx_products_brand_id ON products(brand_id);
-- Index on slug for SEO product pages
CREATE INDEX idx_products_slug ON products(slug);
-- Index on price for price-range filtering
CREATE INDEX idx_products_price ON products(price);
-- Index on is_active for active product listings
CREATE INDEX idx_products_is_active ON products(is_active);
-- Index on sku for inventory lookups
CREATE INDEX idx_products_sku ON products(sku);

COMMENT ON TABLE products IS 'Main product catalog with pricing, inventory, and categorization.';
COMMENT ON COLUMN products.compare_at_price IS 'Original price for displaying discounts/sales.';
COMMENT ON COLUMN products.is_active IS 'Controls product visibility in storefront.';
