-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- POWER BI ANALYTICAL VIEWS
-- ============================================================


-- ============================================================
-- 1. SALES FACT VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_sales AS

SELECT
    o.order_id,
    o.customer_id,

    c.customer_unique_id,
    c.customer_city,
    c.customer_state,

    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    p.product_category_name,

    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    oi.price,
    oi.freight_value,

    oi.price + oi.freight_value AS total_item_value,

    EXTRACT(
        EPOCH FROM
        (
            o.order_delivered_customer_date
            - o.order_purchase_timestamp
        )
    ) / 86400 AS delivery_days,

    CASE
        WHEN o.order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN o.order_delivered_customer_date
             <= o.order_estimated_delivery_date
            THEN 'On Time'

        ELSE 'Late'
    END AS delivery_status

FROM warehouse.fact_orders o

JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id

JOIN warehouse.fact_order_items oi
    ON o.order_id = oi.order_id

LEFT JOIN warehouse.dim_products p
    ON oi.product_id = p.product_id

LEFT JOIN warehouse.dim_product_category pc
    ON p.product_category_name =
       pc.product_category_name;


-- ============================================================
-- 2. CUSTOMER KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_customer_kpis AS

WITH customer_orders AS (

    SELECT
        c.customer_unique_id,

        c.customer_city,

        c.customer_state,

        COUNT(DISTINCT o.order_id) AS total_orders,

        MIN(o.order_purchase_timestamp)
            AS first_purchase_date,

        MAX(o.order_purchase_timestamp)
            AS last_purchase_date,

        SUM(oi.price) AS total_revenue

    FROM warehouse.dim_customers c

    JOIN warehouse.fact_orders o
        ON c.customer_id = o.customer_id

    JOIN warehouse.fact_order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_unique_id,
        c.customer_city,
        c.customer_state
)

SELECT
    customer_unique_id,
    customer_city,
    customer_state,

    total_orders,

    ROUND(total_revenue, 2)
        AS total_revenue,

    ROUND(
        total_revenue /
        NULLIF(total_orders, 0),
        2
    ) AS average_order_value,

    first_purchase_date,

    last_purchase_date,

    CASE
        WHEN total_orders = 1
            THEN 'One-Time Customer'

        ELSE 'Repeat Customer'

    END AS customer_type

FROM customer_orders;


-- ============================================================
-- 3. MONTHLY KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_monthly_kpis AS

SELECT
    DATE_TRUNC(
        'month',
        o.order_purchase_timestamp
    )::date AS month,

    COUNT(DISTINCT o.order_id)
        AS total_orders,

    COUNT(DISTINCT c.customer_unique_id)
        AS unique_customers,

    COUNT(DISTINCT oi.product_id)
        AS unique_products,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS freight_value,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_sales,

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
-- 4. CATEGORY KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_category_kpis AS

SELECT
    COALESCE(
        pc.product_category_name_english,
        'Unknown'
    ) AS product_category,

    COUNT(DISTINCT oi.order_id)
        AS total_orders,

    COUNT(*)
        AS units_sold,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS freight_value,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_sales,

    ROUND(
        AVG(oi.price),
        2
    ) AS average_product_price

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
    );


-- ============================================================
-- 5. SELLER KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_seller_kpis AS

SELECT
    oi.seller_id,

    s.seller_city,

    s.seller_state,

    COUNT(DISTINCT oi.order_id)
        AS total_orders,

    COUNT(*)
        AS units_sold,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS freight_value,

    ROUND(
        AVG(oi.price),
        2
    ) AS average_item_price

FROM warehouse.fact_order_items oi

JOIN warehouse.dim_sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state;


-- ============================================================
-- 6. PAYMENT KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_payment_kpis AS

SELECT
    payment_type,

    COUNT(DISTINCT order_id)
        AS total_orders,

    COUNT(*)
        AS payment_records,

    ROUND(
        SUM(payment_value),
        2
    ) AS payment_value,

    ROUND(
        AVG(payment_value),
        2
    ) AS average_payment_value

FROM warehouse.fact_order_payments

GROUP BY payment_type;


-- ============================================================
-- 7. CUSTOMER EXPERIENCE VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_customer_experience AS

SELECT
    r.review_id,

    r.order_id,

    r.review_score,

    o.customer_id,

    c.customer_unique_id,

    c.customer_city,

    c.customer_state,

    o.order_purchase_timestamp,

    o.order_delivered_customer_date,

    o.order_estimated_delivery_date,

    CASE

        WHEN o.order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN o.order_delivered_customer_date
             <= o.order_estimated_delivery_date
            THEN 'On Time'

        ELSE 'Late'

    END AS delivery_status,

    CASE

        WHEN o.order_delivered_customer_date IS NOT NULL

        THEN ROUND(
            EXTRACT(
                EPOCH FROM
                (
                    o.order_delivered_customer_date
                    - o.order_purchase_timestamp
                )
            ) / 86400,
            2
        )

        ELSE NULL

    END AS delivery_days

FROM warehouse.fact_order_reviews r

JOIN warehouse.fact_orders o
    ON r.order_id = o.order_id

JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id;


-- ============================================================
-- 8. EXECUTIVE KPI VIEW
-- ============================================================

CREATE OR REPLACE VIEW warehouse.vw_executive_kpis AS

SELECT

    COUNT(DISTINCT o.order_id)
        AS total_orders,

    COUNT(DISTINCT c.customer_unique_id)
        AS total_customers,

    COUNT(DISTINCT oi.product_id)
        AS total_products,

    COUNT(DISTINCT oi.seller_id)
        AS total_sellers,

    ROUND(
        SUM(oi.price),
        2
    ) AS total_revenue,

    ROUND(
        SUM(oi.freight_value),
        2
    ) AS total_freight,

    ROUND(
        SUM(oi.price + oi.freight_value),
        2
    ) AS total_sales,

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
    ON o.order_id = oi.order_id;



SELECT table_name
FROM information_schema.views
WHERE table_schema = 'warehouse'
ORDER BY table_name;

SELECT * FROM warehouse.vw_executive_kpis;

SELECT * FROM warehouse.vw_monthly_kpis ORDER BY month;