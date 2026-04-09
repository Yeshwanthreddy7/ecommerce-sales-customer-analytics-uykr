-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- SALES & REVENUE ANALYSIS
-- ============================================================


-- ============================================================
-- 1. TOTAL REVENUE
-- ============================================================

SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM warehouse.fact_order_items;


-- ============================================================
-- 2. TOTAL FREIGHT REVENUE
-- ============================================================

SELECT
    ROUND(SUM(freight_value), 2) AS total_freight
FROM warehouse.fact_order_items;


-- ============================================================
-- 3. TOTAL SALES INCLUDING FREIGHT
-- ============================================================

SELECT
    ROUND(SUM(price + freight_value), 2) AS total_sales
FROM warehouse.fact_order_items;


-- ============================================================
-- 4. MONTHLY REVENUE
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;


-- ============================================================
-- 5. MONTHLY ORDERS
-- ============================================================

SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT order_id) AS total_orders
FROM warehouse.fact_orders
GROUP BY month
ORDER BY month;


-- ============================================================
-- 6. MONTHLY REVENUE + ORDERS
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;


-- ============================================================
-- 7. AVERAGE ORDER VALUE (AOV)
-- ============================================================

SELECT
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM warehouse.fact_order_items oi;


-- ============================================================
-- 8. MONTHLY AVERAGE ORDER VALUE
-- ============================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;


-- ============================================================
-- 9. REVENUE BY ORDER STATUS
-- ============================================================

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY revenue DESC;


-- ============================================================
-- 10. TOP 20 ORDERS BY VALUE
-- ============================================================

SELECT
    oi.order_id,
    ROUND(SUM(oi.price), 2) AS order_value
FROM warehouse.fact_order_items oi
GROUP BY oi.order_id
ORDER BY order_value DESC
LIMIT 20;


-- ============================================================
-- 11. TOP 20 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(*) AS units_sold
FROM warehouse.fact_order_items oi
JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    p.product_category_name
ORDER BY revenue DESC
LIMIT 20;


-- ============================================================
-- 12. TOP 20 PRODUCTS BY UNITS SOLD
-- ============================================================

SELECT
    oi.product_id,
    p.product_category_name,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.fact_order_items oi
JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id
GROUP BY
    oi.product_id,
    p.product_category_name
ORDER BY units_sold DESC
LIMIT 20;


-- ============================================================
-- 13. REVENUE BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- ============================================================
-- 14. ORDERS BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- ============================================================
-- 15. REVENUE GROWTH BY MONTH
-- ============================================================

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
        SUM(oi.price) AS revenue
    FROM warehouse.fact_orders o
    JOIN warehouse.fact_order_items oi
        ON o.order_id = oi.order_id
    GROUP BY month
)

SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        LAG(revenue) OVER (ORDER BY month),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            (revenue - LAG(revenue) OVER (ORDER BY month))
            /
            NULLIF(LAG(revenue) OVER (ORDER BY month), 0)
        ) * 100,
        2
    ) AS revenue_growth_percentage
FROM monthly_sales
ORDER BY month;


-- ============================================================
-- 16. YEARLY REVENUE
-- ============================================================

SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY year
ORDER BY year;


-- ============================================================
-- 17. REVENUE BY DAY OF WEEK
-- ============================================================

SELECT
    TO_CHAR(
        o.order_purchase_timestamp,
        'Day'
    ) AS day_of_week,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM warehouse.fact_orders o
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY day_of_week
ORDER BY revenue DESC;


-- ============================================================
-- 18. REVENUE BY PAYMENT TYPE
-- ============================================================

SELECT
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS payment_value
FROM warehouse.fact_order_payments p
GROUP BY p.payment_type
ORDER BY payment_value DESC;