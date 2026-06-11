-- Migration: 008_create_orders.sql
-- Description: Creates the orders table for storing customer order records.
-- Design Choices:
--   - DECIMAL(12,2) for all monetary values to ensure precision.
--   - status ENUM-like CHECK constraint for order lifecycle management.
--   - FK to users and addresses; addresses are copied (not referenced) in production, 
--     but here we reference for simplicity. In high-scale systems, denormalize address data.
--   - UNIQUE transaction_id for idempotency in payment processing.
-- Scalability Notes:
--   - Partition by created_at (range) or user_id (hash) for large order volumes.
--   - Archive completed orders older than 2 years to cold storage.
--   - Add read replicas for order history queries.

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(12,2) DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount DECIMAL(12,2) DEFAULT 0 CHECK (shipping_amount >= 0),
    discount_amount DECIMAL(12,2) DEFAULT 0 CHECK (discount_amount >= 0),
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    shipping_address_id BIGINT REFERENCES addresses(id) ON DELETE SET NULL,
    billing_address_id BIGINT REFERENCES addresses(id) ON DELETE SET NULL,
    transaction_id VARCHAR(255) UNIQUE,
    payment_status VARCHAR(30) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on user_id for order history
CREATE INDEX idx_orders_user_id ON orders(user_id);
-- Index on order_number for lookup
CREATE INDEX idx_orders_order_number ON orders(order_number);
-- Index on status for order processing queues
CREATE INDEX idx_orders_status ON orders(status);
-- Index on created_at for date-range queries
CREATE INDEX idx_orders_created_at ON orders(created_at);
-- Index on transaction_id for payment reconciliation
CREATE INDEX idx_orders_transaction_id ON orders(transaction_id);

COMMENT ON TABLE orders IS 'Customer order records with financial breakdown and status tracking.';
COMMENT ON COLUMN orders.order_number IS 'Human-readable unique identifier for customer support.';
COMMENT ON COLUMN orders.transaction_id IS 'Payment gateway transaction reference for idempotency.';
COMMENT ON COLUMN orders.status IS 'Order fulfillment lifecycle status.';
