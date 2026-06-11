-- Migration: 009_create_order_items.sql
-- Description: Creates the order_items table for storing line items in orders.
-- Design Choices:
--   - Denormalized product_name and price_at_purchase to preserve historical accuracy.
--     Even if product is deleted or price changes, order record remains accurate.
--   - FK to orders with ON DELETE CASCADE; FK to products with SET NULL (denormalized data preserved).
--   - DECIMAL(12,2) for all monetary values.
-- Scalability Notes:
--   - High-volume table; partition by order_id or created_at.
--   - Consider archiving old order items with orders.

CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(100),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(12,2) NOT NULL CHECK (price_at_purchase >= 0),
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on order_id for fetching order details
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
-- Index on product_id for sales analytics by product
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

COMMENT ON TABLE order_items IS 'Line items within orders; denormalized for historical accuracy.';
COMMENT ON COLUMN order_items.product_name IS 'Snapshot of product name at time of purchase.';
COMMENT ON COLUMN order_items.price_at_purchase IS 'Snapshot of product price at time of purchase.';
COMMENT ON COLUMN order_items.subtotal IS 'quantity * price_at_purchase for this line item.';
