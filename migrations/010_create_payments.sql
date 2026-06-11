-- Migration: 010_create_payments.sql
-- Description: Creates the payments table for storing payment transaction records.
-- Design Choices:
--   - UNIQUE transaction_id for idempotency and reconciliation.
--   - DECIMAL(12,2) for amount precision.
--   - status CHECK constraint for payment lifecycle tracking.
--   - method VARCHAR to support multiple payment gateways (stripe, paypal, etc.).
--   - FK to orders with ON DELETE RESTRICT to prevent orphaned payments.
-- Scalability Notes:
--   - Partition by created_at for high-volume payment processing.
--   - Add indexes on status for failed payment retry jobs.
--   - Consider PCI compliance; never store raw card data.

CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    transaction_id VARCHAR(255) NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) DEFAULT 'USD',
    method VARCHAR(50) NOT NULL,
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded', 'partially_refunded')),
    gateway_response JSONB,
    failure_reason TEXT,
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP AT TIME ZONE 'UTC'
);

-- Index on order_id for fetching payment details
CREATE INDEX idx_payments_order_id ON payments(order_id);
-- Index on transaction_id for reconciliation
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
-- Index on status for payment processing jobs
CREATE INDEX idx_payments_status ON payments(status);
-- Index on created_at for date-range reporting
CREATE INDEX idx_payments_created_at ON payments(created_at);

COMMENT ON TABLE payments IS 'Payment transaction records linked to orders.';
COMMENT ON COLUMN payments.gateway_response IS 'JSONB storage for flexible gateway-specific data.';
COMMENT ON COLUMN payments.transaction_id IS 'Unique payment gateway reference for idempotency.';
COMMENT ON COLUMN payments.status IS 'Payment processing lifecycle status.';
