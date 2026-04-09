-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- SELLER PERFORMANCE ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL SELLER PERFORMANCE
-- ============================================================

SELECT
    COUNT(DISTINCT seller_id) AS total_active_sellers,
    COUNT(*) AS total_items_sold,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS average_item_price
FROM warehouse.fact_order_items;


-- ============================================================
-- 2. TOP 20 SELLERS BY REVENUE
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(AVG(oi.price), 2) AS average_item_price

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY revenue DESC

LIMIT 20;


-- ============================================================
-- 3. TOP 20 SELLERS BY NUMBER OF ORDERS
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY total_orders DESC

LIMIT 20;


-- ============================================================
-- 4. TOP 20 SELLERS BY UNITS SOLD
-- ============================================================

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,

    COUNT(*) AS units_sold,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY units_sold DESC

LIMIT 20;


-- ============================================================
-- 5. SELLER REVENUE BY STATE
-- ============================================================

SELECT
    s.seller_state,

    COUNT(DISTINCT s.seller_id) AS total_sellers,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY s.seller_state

ORDER BY revenue DESC;


-- ============================================================
-- 6. SELLER PERFORMANCE BY CITY
-- ============================================================

SELECT
    s.seller_city,
    s.seller_state,

    COUNT(DISTINCT s.seller_id) AS total_sellers,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    s.seller_city,
    s.seller_state

ORDER BY revenue DESC

LIMIT 20;


-- ============================================================
-- 7. SELLER AVERAGE ORDER-ITEM VALUE
-- ============================================================

SELECT
    oi.seller_id,

    s.seller_city,

    s.seller_state,

    COUNT(*) AS items_sold,

    ROUND(AVG(oi.price), 2) AS average_item_value,

    ROUND(SUM(oi.price), 2) AS total_revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

ORDER BY average_item_value DESC

LIMIT 20;


-- ============================================================
-- 8. SELLERS WITH HIGH SALES VOLUME
-- ============================================================

SELECT
    oi.seller_id,

    s.seller_city,

    s.seller_state,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

HAVING COUNT(*) >= 100

ORDER BY units_sold DESC;


-- ============================================================
-- 9. SELLERS WITH HIGH REVENUE
-- ============================================================

SELECT
    oi.seller_id,

    s.seller_city,

    s.seller_state,

    COUNT(*) AS units_sold,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state

HAVING SUM(oi.price) >= 5000

ORDER BY revenue DESC;


-- ============================================================
-- 10. SELLER REVENUE CONTRIBUTION
-- ============================================================

WITH seller_revenue AS (

    SELECT
        oi.seller_id,
        SUM(oi.price) AS revenue

    FROM warehouse.fact_order_items oi

    GROUP BY oi.seller_id
)

SELECT
    seller_id,

    ROUND(revenue, 2) AS revenue,

    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_percentage

FROM seller_revenue

ORDER BY revenue DESC

LIMIT 20;