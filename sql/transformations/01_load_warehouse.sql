-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- LOAD STAGING → WAREHOUSE
-- ============================================================


-- ============================================================
-- 1. DIMENSION: CUSTOMERS
-- ============================================================

INSERT INTO warehouse.dim_customers (
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM staging.customers;


-- ============================================================
-- 2. DIMENSION: PRODUCTS
-- ============================================================

INSERT INTO warehouse.dim_products (
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
SELECT
    product_id,
    product_category_name,
    product_name_lenght AS product_name_length,
    product_description_lenght AS product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM staging.products;


-- ============================================================
-- 3. DIMENSION: SELLERS
-- ============================================================

INSERT INTO warehouse.dim_sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM staging.sellers;


-- ============================================================
-- 4. DIMENSION: PRODUCT CATEGORY
-- ============================================================

INSERT INTO warehouse.dim_product_category (
    product_category_name,
    product_category_name_english
)
SELECT
    product_category_name,
    product_category_name_english
FROM staging.product_category_translation;


-- ============================================================
-- 5. FACT: ORDERS
-- ============================================================

INSERT INTO warehouse.fact_orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM staging.orders;


-- ============================================================
-- 6. FACT: ORDER ITEMS
-- ============================================================

INSERT INTO warehouse.fact_order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
)
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM staging.order_items;


-- ============================================================
-- 7. FACT: ORDER PAYMENTS
-- ============================================================

INSERT INTO warehouse.fact_order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
)
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM staging.order_payments;


-- ============================================================
-- 8. FACT: ORDER REVIEWS
-- ============================================================

INSERT INTO warehouse.fact_order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
)
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM staging.order_reviews;