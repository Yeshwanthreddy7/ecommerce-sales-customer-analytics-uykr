-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- CUSTOMER ANALYSIS
-- ============================================================


-- ============================================================
-- 1. CUSTOMERS BY STATE
-- ============================================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM warehouse.dim_customers
GROUP BY customer_state
ORDER BY unique_customers DESC;


-- ============================================================
-- 2. CUSTOMERS BY CITY
-- ============================================================

SELECT
    customer_city,
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM warehouse.dim_customers
GROUP BY
    customer_city,
    customer_state
ORDER BY unique_customers DESC
LIMIT 20;


-- ============================================================
-- 3. ORDERS PER CUSTOMER
-- ============================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 20;


-- ============================================================
-- 4. REPEAT CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM warehouse.dim_customers c
    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) AS repeat_customer_list;


-- ============================================================
-- 5. ONE-TIME CUSTOMERS
-- ============================================================

SELECT
    COUNT(*) AS one_time_customers
FROM (
    SELECT
        c.customer_unique_id
    FROM warehouse.dim_customers c
    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) = 1
) AS one_time_customer_list;


-- ============================================================
-- 6. CUSTOMER REVENUE
-- ============================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_spent
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 20;


-- ============================================================
-- 7. TOP 20 CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_unique_id,
    c.customer_city,
    c.customer_state
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 8. CUSTOMER LIFETIME VALUE
-- ============================================================

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS lifetime_value
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC
LIMIT 20;


-- ============================================================
-- 9. AVERAGE SPENDING PER CUSTOMER
-- ============================================================

SELECT
    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS average_customer_spending
FROM warehouse.dim_customers c
JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id
JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id;


-- ============================================================
-- 10. CUSTOMER ORDER FREQUENCY
-- ============================================================

SELECT
    order_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM warehouse.dim_customers c
    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders
GROUP BY order_count
ORDER BY order_count;