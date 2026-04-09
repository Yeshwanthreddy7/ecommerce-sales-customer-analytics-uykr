-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- WAREHOUSE DATA QUALITY CHECKS
-- ============================================================


-- ============================================================
-- 1. ROW COUNT CHECK
-- ============================================================

SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count
FROM warehouse.dim_customers

UNION ALL

SELECT 'dim_products', COUNT(*)
FROM warehouse.dim_products

UNION ALL

SELECT 'dim_sellers', COUNT(*)
FROM warehouse.dim_sellers

UNION ALL

SELECT 'dim_product_category', COUNT(*)
FROM warehouse.dim_product_category

UNION ALL

SELECT 'fact_orders', COUNT(*)
FROM warehouse.fact_orders

UNION ALL

SELECT 'fact_order_items', COUNT(*)
FROM warehouse.fact_order_items

UNION ALL

SELECT 'fact_order_payments', COUNT(*)
FROM warehouse.fact_order_payments

UNION ALL

SELECT 'fact_order_reviews', COUNT(*)
FROM warehouse.fact_order_reviews;



-- ============================================================
-- 2. DUPLICATE CHECKS
-- ============================================================

-- Customers
SELECT customer_id, COUNT(*) AS duplicate_count
FROM warehouse.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Products
SELECT product_id, COUNT(*) AS duplicate_count
FROM warehouse.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Sellers
SELECT seller_id, COUNT(*) AS duplicate_count
FROM warehouse.dim_sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- Orders
SELECT order_id, COUNT(*) AS duplicate_count
FROM warehouse.fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 3. NULL CHECK - CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_zip_code,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS null_state
FROM warehouse.dim_customers;


-- ============================================================
-- NULL CHECK - PRODUCTS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_category,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS null_weight,
    COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS null_length,
    COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS null_height,
    COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS null_width
FROM warehouse.dim_products;


-- ============================================================
-- NULL CHECK - ORDERS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS null_order_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_purchase_timestamp
FROM warehouse.fact_orders;


-- ============================================================
-- 4. ORPHAN CHECK - ORDERS → CUSTOMERS
-- ============================================================

SELECT
    o.order_id,
    o.customer_id
FROM warehouse.fact_orders o
LEFT JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- ============================================================
-- ORDER ITEMS → PRODUCTS
-- ============================================================

SELECT
    oi.order_id,
    oi.product_id
FROM warehouse.fact_order_items oi
LEFT JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- ============================================================
-- ORDER ITEMS → SELLERS
-- ============================================================

SELECT
    oi.order_id,
    oi.seller_id
FROM warehouse.fact_order_items oi
LEFT JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- ============================================================
-- 5. ORDER PAYMENTS → ORDERS
-- ============================================================

SELECT
    p.order_id
FROM warehouse.fact_order_payments p
LEFT JOIN warehouse.fact_orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 6. ORDER REVIEWS → ORDERS
-- ============================================================

SELECT
    r.review_id,
    r.order_id
FROM warehouse.fact_order_reviews r
LEFT JOIN warehouse.fact_orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- ============================================================
-- 7. REVIEW SCORE VALIDATION
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count
FROM warehouse.fact_order_reviews
GROUP BY review_score
ORDER BY review_score;

SELECT *
FROM warehouse.fact_order_reviews
WHERE review_score < 1
   OR review_score > 5;


-- ============================================================
-- 8. NEGATIVE VALUE CHECK
-- ============================================================

-- Order Items
SELECT *
FROM warehouse.fact_order_items
WHERE price < 0
   OR freight_value < 0;
-- Payments
SELECT *
FROM warehouse.fact_order_payments
WHERE payment_value < 0;