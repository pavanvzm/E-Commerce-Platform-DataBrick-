-- Migration: 007_create_cart_items.sql
-- Description: Creates the cart_items table for storing items in user carts.
-- Design Choices:
--   - Composite UNIQUE constraint on (cart_id, product_id) to prevent duplicates.
--   - FK to products with ON DELETE CASCADE to remove items if product is deleted.
--   - price_at_add DECIMAL(12,2) to capture price at time of adding (for audit).
-- Scalability Notes:
--   - High-write table; consider partitioning by cart_id if needed.
--   - Clean up abandoned cart items via scheduled job.

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price_at_add DECIMAL(12,2) NOT NULL CHECK (price_at_add >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    UNIQUE (cart_id, product_id)
);

-- Index on cart_id for fetching cart contents
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
-- Index on product_id for inventory/availability checks
CREATE INDEX idx_cart_items_product_id ON cart_items(product_id);

COMMENT ON TABLE cart_items IS 'Individual items within user shopping carts.';
COMMENT ON COLUMN cart_items.price_at_add IS 'Snapshot of product price when added to cart.';
COMMENT ON CONSTRAINT cart_items_cart_id_product_id_key ON cart_items IS 'Prevents duplicate product entries in same cart.';
