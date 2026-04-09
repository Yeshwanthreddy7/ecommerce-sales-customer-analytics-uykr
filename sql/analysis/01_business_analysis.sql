-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- BUSINESS KPI ANALYSIS
-- ============================================================


-- ============================================================
-- 1. TOTAL CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS total_customers
FROM warehouse.dim_customers;


-- ============================================================
-- 2. UNIQUE CUSTOMERS
-- ============================================================

SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM warehouse.dim_customers;


-- ============================================================
-- 3. TOTAL ORDERS
-- ============================================================

SELECT
    COUNT(*) AS total_orders
FROM warehouse.fact_orders;


-- ============================================================
-- 4. TOTAL PRODUCTS
-- ============================================================

SELECT
    COUNT(*) AS total_products
FROM warehouse.dim_products;


-- ============================================================
-- 5. TOTAL SELLERS
-- ============================================================

SELECT
    COUNT(*) AS total_sellers
FROM warehouse.dim_sellers;


-- ============================================================
-- 6. TOTAL ORDER ITEMS
-- ============================================================

SELECT
    COUNT(*) AS total_order_items
FROM warehouse.fact_order_items;


-- ============================================================
-- 7. TOTAL REVENUE
-- ============================================================

SELECT
    SUM(price) AS total_revenue
FROM warehouse.fact_order_items;


-- ============================================================
-- 8. TOTAL FREIGHT VALUE
-- ============================================================

SELECT
    SUM(freight_value) AS total_freight
FROM warehouse.fact_order_items;


-- ============================================================
-- 9. TOTAL PAYMENT VALUE
-- ============================================================

SELECT
    SUM(payment_value) AS total_payment_value
FROM warehouse.fact_order_payments;


-- ============================================================
-- 10. AVERAGE ORDER VALUE
-- ============================================================

SELECT
    SUM(price) / COUNT(DISTINCT order_id) AS average_order_value
FROM warehouse.fact_order_items;


-- ============================================================
-- 11. AVERAGE REVIEW SCORE
-- ============================================================

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM warehouse.fact_order_reviews;








-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- BUSINESS ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL BUSINESS KPIs
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS total_products,
    COUNT(DISTINCT oi.seller_id) AS total_sellers,
    SUM(oi.price) AS total_product_sales,
    SUM(oi.freight_value) AS total_freight,
    SUM(oi.price + oi.freight_value) AS total_order_value,
    AVG(oi.price + oi.freight_value) AS average_order_item_value
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id;





-- ============================================================
-- 2. ORDERS BY STATUS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM warehouse.fact_orders
GROUP BY order_status
ORDER BY order_count DESC;









-- ============================================================
-- 3. MONTHLY SALES PERFORMANCE
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS product_sales,
    SUM(oi.freight_value) AS freight_value,
    SUM(oi.price + oi.freight_value) AS total_sales
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;








-- ============================================================
-- 4. TOP PRODUCT CATEGORIES
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    SUM(oi.price) AS product_sales,
    SUM(oi.price + oi.freight_value) AS total_sales
FROM warehouse.fact_order_items oi
JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id
LEFT JOIN warehouse.dim_product_category pc
    ON p.product_category_name = pc.product_category_name
GROUP BY
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    )
ORDER BY total_sales DESC;





-- ============================================================
-- 5. TOP 20 PRODUCTS BY SALES
-- ============================================================

SELECT
    oi.product_id,
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS items_sold,
    SUM(oi.price) AS product_sales,
    SUM(oi.price + oi.freight_value) AS total_sales
FROM warehouse.fact_order_items oi
JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id
LEFT JOIN warehouse.dim_product_category pc
    ON p.product_category_name = pc.product_category_name
GROUP BY
    oi.product_id,
    pc.product_category_name_english
ORDER BY total_sales DESC
LIMIT 20;






-- ============================================================
-- 6. TOP 20 SELLERS
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS items_sold,
    SUM(oi.price) AS product_sales,
    SUM(oi.price + oi.freight_value) AS total_sales
FROM warehouse.fact_order_items oi
JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_sales DESC
LIMIT 20;








-- ============================================================
-- 7. SALES BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    SUM(oi.price) AS product_sales,
    SUM(oi.price + oi.freight_value) AS total_sales
FROM warehouse.fact_orders o
JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_sales DESC;





-- ============================================================
-- 8. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    SUM(payment_value) AS total_payment_value,
    AVG(payment_value) AS average_payment_value
FROM warehouse.fact_order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;




-- ============================================================
-- 9. REVIEW SCORE ANALYSIS
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_reviews
FROM warehouse.fact_order_reviews
GROUP BY review_score
ORDER BY review_score;





-- ============================================================
-- 10. AVERAGE REVIEW SCORE
-- ============================================================

SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM warehouse.fact_order_reviews;




-- ============================================================
-- 11. DELIVERY PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM
                (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_days
FROM warehouse.fact_orders
WHERE order_delivered_customer_date IS NOT NULL;



-- ============================================================
-- 12. ACTUAL VS ESTIMATED DELIVERY
-- ============================================================

SELECT
    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM
                (
                    order_delivered_customer_date
                    - order_estimated_delivery_date
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_difference_days

FROM warehouse.fact_orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;