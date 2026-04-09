-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- PRODUCT & CATEGORY ANALYSIS
-- ============================================================


-- ============================================================
-- 1. PRODUCT CATEGORY PERFORMANCE
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight_value,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_sales

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

ORDER BY revenue DESC;


-- ============================================================
-- 2. TOP 20 PRODUCT CATEGORIES BY REVENUE
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue

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

ORDER BY revenue DESC

LIMIT 20;


-- ============================================================
-- 3. TOP 20 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    oi.product_id,

    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(AVG(oi.price), 2) AS average_price

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id

LEFT JOIN warehouse.dim_product_category pc
    ON p.product_category_name = pc.product_category_name

GROUP BY
    oi.product_id,
    pc.product_category_name_english

ORDER BY revenue DESC

LIMIT 20;


-- ============================================================
-- 4. TOP 20 PRODUCTS BY UNITS SOLD
-- ============================================================

SELECT
    oi.product_id,

    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(AVG(oi.price), 2) AS average_price

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id

LEFT JOIN warehouse.dim_product_category pc
    ON p.product_category_name = pc.product_category_name

GROUP BY
    oi.product_id,
    pc.product_category_name_english

ORDER BY units_sold DESC

LIMIT 20;


-- ============================================================
-- 5. AVERAGE PRODUCT PRICE BY CATEGORY
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(*) AS units_sold,

    ROUND(AVG(oi.price), 2) AS average_product_price,

    ROUND(MIN(oi.price), 2) AS minimum_price,

    ROUND(MAX(oi.price), 2) AS maximum_price

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

ORDER BY average_product_price DESC;


-- ============================================================
-- 6. CATEGORY MARKET SHARE
-- ============================================================

WITH category_sales AS (

    SELECT
        COALESCE(
            pc.product_category_name_english,
            'Unknown'
        ) AS product_category,

        SUM(oi.price) AS revenue

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
)

SELECT
    product_category,

    ROUND(revenue, 2) AS revenue,

    ROUND(
        revenue * 100.0 /
        SUM(revenue) OVER (),
        2
    ) AS revenue_percentage

FROM category_sales

ORDER BY revenue DESC;


-- ============================================================
-- 7. CATEGORY FREIGHT ANALYSIS
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    ROUND(SUM(oi.price), 2) AS product_revenue,

    ROUND(SUM(oi.freight_value), 2) AS freight_value,

    ROUND(
        SUM(oi.freight_value) /
        NULLIF(SUM(oi.price), 0) * 100,
        2
    ) AS freight_percentage

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

ORDER BY freight_percentage DESC;


-- ============================================================
-- 8. PRODUCTS WITH HIGH SALES VOLUME
-- ============================================================

SELECT
    oi.product_id,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

GROUP BY oi.product_id

HAVING COUNT(*) >= 100

ORDER BY units_sold DESC;


-- ============================================================
-- 9. PRODUCTS WITH HIGH REVENUE
-- ============================================================

SELECT
    oi.product_id,

    COUNT(*) AS units_sold,

    ROUND(SUM(oi.price), 2) AS revenue

FROM warehouse.fact_order_items oi

GROUP BY oi.product_id

HAVING SUM(oi.price) >= 5000

ORDER BY revenue DESC;


-- ============================================================
-- 10. CATEGORY PERFORMANCE BY ORDER COUNT
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS units_sold

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

ORDER BY total_orders DESC;