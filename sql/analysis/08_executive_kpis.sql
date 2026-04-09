-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- EXECUTIVE KPI & ADVANCED ANALYSIS
-- ============================================================


-- ============================================================
-- 1. EXECUTIVE KPI SUMMARY
-- ============================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    COUNT(DISTINCT oi.product_id) AS total_products,

    COUNT(DISTINCT oi.seller_id) AS total_sellers,

    ROUND(SUM(oi.price), 2) AS total_revenue,

    ROUND(SUM(oi.freight_value), 2) AS total_freight,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_sales,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,

    ROUND(
        AVG(r.review_score),
        2
    ) AS average_review_score

FROM warehouse.fact_orders o

JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

LEFT JOIN warehouse.fact_order_reviews r
    ON o.order_id = r.order_id;


-- ============================================================
-- 2. CUSTOMER RETENTION SUMMARY
-- ============================================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE order_count = 1
    ) AS one_time_customers,

    COUNT(*) FILTER (
        WHERE order_count > 1
    ) AS repeat_customers,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_count > 1
        ) * 100.0 /
        COUNT(*),
        2
    ) AS repeat_customer_percentage

FROM customer_orders;


-- ============================================================
-- 3. REVENUE BY CUSTOMER TYPE
-- ============================================================

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,

        CASE
            WHEN COUNT(DISTINCT o.order_id) = 1
                THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
)

SELECT
    co.customer_type,

    COUNT(DISTINCT co.customer_unique_id)
        AS customers,

    COUNT(DISTINCT o.order_id)
        AS orders,

    ROUND(SUM(oi.price), 2)
        AS revenue

FROM customer_orders co

JOIN warehouse.dim_customers c
    ON co.customer_unique_id = c.customer_unique_id

JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

GROUP BY co.customer_type

ORDER BY revenue DESC;


-- ============================================================
-- 4. MONTHLY EXECUTIVE PERFORMANCE
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::date AS month,

    COUNT(DISTINCT o.order_id)
        AS total_orders,

    COUNT(DISTINCT c.customer_unique_id)
        AS unique_customers,

    ROUND(SUM(oi.price), 2)
        AS revenue,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM warehouse.fact_orders o

JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

GROUP BY month

ORDER BY month;


-- ============================================================
-- 5. CUSTOMER REVENUE SEGMENTS
-- ============================================================

WITH customer_revenue AS (

    SELECT
        c.customer_unique_id,

        SUM(oi.price) AS revenue

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    JOIN warehouse.fact_order_items oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
)

SELECT
    CASE

        WHEN revenue < 100
            THEN 'Low Value (<100)'

        WHEN revenue < 500
            THEN 'Medium Value (100-499)'

        WHEN revenue < 1000
            THEN 'High Value (500-999)'

        ELSE 'Very High Value (1000+)'

    END AS customer_segment,

    COUNT(*) AS customers,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(AVG(revenue), 2) AS average_customer_revenue

FROM customer_revenue

GROUP BY customer_segment

ORDER BY
    MIN(
        CASE
            WHEN revenue < 100 THEN 1
            WHEN revenue < 500 THEN 2
            WHEN revenue < 1000 THEN 3
            ELSE 4
        END
    );


-- ============================================================
-- 6. TOP 10% CUSTOMERS BY REVENUE
-- ============================================================

WITH customer_revenue AS (

    SELECT
        c.customer_unique_id,

        SUM(oi.price) AS revenue

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    JOIN warehouse.fact_order_items oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
),

ranked_customers AS (

    SELECT
        customer_unique_id,
        revenue,

        NTILE(10) OVER (
            ORDER BY revenue DESC
        ) AS revenue_decile

    FROM customer_revenue
)

SELECT
    COUNT(*) AS top_10_percent_customers,

    ROUND(SUM(revenue), 2)
        AS top_10_percent_revenue

FROM ranked_customers

WHERE revenue_decile = 1;


-- ============================================================
-- 7. TOP 10% REVENUE CONTRIBUTION
-- ============================================================

WITH customer_revenue AS (

    SELECT
        c.customer_unique_id,

        SUM(oi.price) AS revenue

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    JOIN warehouse.fact_order_items oi
        ON o.order_id = oi.order_id

    GROUP BY c.customer_unique_id
),

ranked_customers AS (

    SELECT
        customer_unique_id,
        revenue,

        NTILE(10) OVER (
            ORDER BY revenue DESC
        ) AS revenue_decile

    FROM customer_revenue
)

SELECT

    ROUND(
        SUM(
            CASE
                WHEN revenue_decile = 1
                THEN revenue
                ELSE 0
            END
        ) * 100.0
        / SUM(revenue),
        2
    ) AS top_10_percent_revenue_share

FROM ranked_customers;


-- ============================================================
-- 8. MONTHLY CUSTOMER ACQUISITION
-- ============================================================

WITH first_purchase AS (

    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_unique_id
)

SELECT
    DATE_TRUNC(
        'month',
        first_purchase_date
    )::date AS first_purchase_month,

    COUNT(*) AS new_customers

FROM first_purchase

GROUP BY
    DATE_TRUNC(
        'month',
        first_purchase_date
    )::date

ORDER BY first_purchase_month;


-- ============================================================
-- 9. MONTHLY CUSTOMER & REVENUE KPIs
-- ============================================================

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::date AS month,

    COUNT(DISTINCT c.customer_unique_id)
        AS customers,

    COUNT(DISTINCT o.order_id)
        AS orders,

    ROUND(SUM(oi.price), 2)
        AS revenue,

    ROUND(
        SUM(oi.price) /
        NULLIF(
            COUNT(DISTINCT c.customer_unique_id),
            0
        ),
        2
    ) AS revenue_per_customer,

    ROUND(
        SUM(oi.price) /
        NULLIF(
            COUNT(DISTINCT o.order_id),
            0
        ),
        2
    ) AS average_order_value

FROM warehouse.fact_orders o

JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

GROUP BY month

ORDER BY month;


-- ============================================================
-- 10. BUSINESS PERFORMANCE BY STATE
-- ============================================================

SELECT
    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id)
        AS customers,

    COUNT(DISTINCT o.order_id)
        AS orders,

    ROUND(SUM(oi.price), 2)
        AS revenue,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM warehouse.dim_customers c

JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

GROUP BY c.customer_state

ORDER BY revenue DESC;


-- ============================================================
-- 11. FINAL CUSTOMER VALUE RANKING
-- ============================================================

SELECT
    c.customer_unique_id,

    c.customer_city,

    c.customer_state,

    COUNT(DISTINCT o.order_id)
        AS total_orders,

    ROUND(SUM(oi.price), 2)
        AS lifetime_revenue,

    ROUND(
        SUM(oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM warehouse.dim_customers c

JOIN warehouse.fact_orders o
    ON c.customer_id = o.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

GROUP BY
    c.customer_unique_id,
    c.customer_city,
    c.customer_state

ORDER BY lifetime_revenue DESC

LIMIT 50;


-- ============================================================
-- 12. FINAL PRODUCT CATEGORY RANKING
-- ============================================================

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT oi.order_id)
        AS orders,

    COUNT(*)
        AS units_sold,

    ROUND(SUM(oi.price), 2)
        AS revenue

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id

LEFT JOIN warehouse.dim_product_category pc
    ON p.product_category_name =
       pc.product_category_name

GROUP BY
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    )

ORDER BY revenue DESC

LIMIT 20;