-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- CREATE WAREHOUSE TABLES
-- ============================================================

-- ============================================================
-- DIMENSION: CUSTOMERS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.dim_customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state CHAR(2),
    PRIMARY KEY (customer_id)
);


-- ============================================================
-- DIMENSION: PRODUCTS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.dim_products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,
    PRIMARY KEY (product_id)
);


-- ============================================================
-- DIMENSION: SELLERS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.dim_sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state CHAR(2),
    PRIMARY KEY (seller_id)
);


-- ============================================================
-- DIMENSION: CATEGORY TRANSLATION
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.dim_product_category (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    PRIMARY KEY (product_category_name)
);


-- ============================================================
-- FACT: ORDERS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.fact_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    PRIMARY KEY (order_id)
);


-- ============================================================
-- FACT: ORDER ITEMS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.fact_order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2)
);


-- ============================================================
-- FACT: PAYMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.fact_order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2)
);


-- ============================================================
-- FACT: REVIEWS
-- ============================================================

CREATE TABLE IF NOT EXISTS warehouse.fact_order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);