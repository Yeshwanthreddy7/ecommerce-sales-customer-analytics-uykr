-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- PAYMENT ANALYSIS
-- ============================================================


-- ============================================================
-- 1. OVERALL PAYMENT SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_payment_records,

    COUNT(DISTINCT order_id) AS total_paid_orders,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value

FROM warehouse.fact_order_payments;


-- ============================================================
-- 2. PAYMENT TYPE PERFORMANCE
-- ============================================================

SELECT
    payment_type,

    COUNT(*) AS payment_records,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value

FROM warehouse.fact_order_payments

GROUP BY payment_type

ORDER BY total_payment_value DESC;


-- ============================================================
-- 3. PAYMENT TYPE MARKET SHARE
-- ============================================================

SELECT
    payment_type,

    ROUND(SUM(payment_value), 2) AS payment_value,

    ROUND(
        SUM(payment_value) * 100.0 /
        SUM(SUM(payment_value)) OVER (),
        2
    ) AS payment_percentage

FROM warehouse.fact_order_payments

GROUP BY payment_type

ORDER BY payment_value DESC;


-- ============================================================
-- 4. PAYMENT TYPE BY NUMBER OF ORDERS
-- ============================================================

SELECT
    payment_type,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        SUM(COUNT(DISTINCT order_id)) OVER (),
        2
    ) AS order_percentage

FROM warehouse.fact_order_payments

GROUP BY payment_type

ORDER BY total_orders DESC;


-- ============================================================
-- 5. CREDIT CARD INSTALLMENT ANALYSIS
-- ============================================================

SELECT
    payment_installments,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(SUM(payment_value), 2) AS payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value

FROM warehouse.fact_order_payments

WHERE payment_type = 'credit_card'

GROUP BY payment_installments

ORDER BY payment_installments;


-- ============================================================
-- 6. CREDIT CARD INSTALLMENT DISTRIBUTION
-- ============================================================

SELECT
    payment_installments,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        SUM(COUNT(DISTINCT order_id)) OVER (),
        2
    ) AS percentage_of_orders

FROM warehouse.fact_order_payments

WHERE payment_type = 'credit_card'

GROUP BY payment_installments

ORDER BY total_orders DESC;


-- ============================================================
-- 7. PAYMENT VALUE BY INSTALLMENT
-- ============================================================

SELECT
    payment_installments,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value

FROM warehouse.fact_order_payments

WHERE payment_type = 'credit_card'

GROUP BY payment_installments

ORDER BY payment_installments;


-- ============================================================
-- 8. PAYMENT TYPE BY CUSTOMER STATE
-- ============================================================

SELECT
    c.customer_state,

    p.payment_type,

    COUNT(DISTINCT p.order_id) AS total_orders,

    ROUND(SUM(p.payment_value), 2) AS payment_value

FROM warehouse.fact_order_payments p

JOIN warehouse.fact_orders o
    ON p.order_id = o.order_id

JOIN warehouse.dim_customers c
    ON o.customer_id = c.customer_id

GROUP BY
    c.customer_state,
    p.payment_type

ORDER BY
    c.customer_state,
    payment_value DESC;


-- ============================================================
-- 9. HIGH-VALUE PAYMENT ORDERS
-- ============================================================

SELECT
    order_id,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    COUNT(*) AS payment_records

FROM warehouse.fact_order_payments

GROUP BY order_id

ORDER BY total_payment_value DESC

LIMIT 20;


-- ============================================================
-- 10. MULTIPLE PAYMENT TYPES IN ONE ORDER
-- ============================================================

SELECT
    order_id,

    COUNT(DISTINCT payment_type) AS payment_type_count,

    STRING_AGG(
        DISTINCT payment_type,
        ', '
    ) AS payment_types,

    ROUND(SUM(payment_value), 2) AS total_payment_value

FROM warehouse.fact_order_payments

GROUP BY order_id

HAVING COUNT(DISTINCT payment_type) > 1

ORDER BY total_payment_value DESC

LIMIT 20;


-- ============================================================
-- 11. PAYMENT VALUE DISTRIBUTION
-- ============================================================

SELECT
    CASE

        WHEN payment_value < 50
            THEN 'Under 50'

        WHEN payment_value < 100
            THEN '50-99'

        WHEN payment_value < 250
            THEN '100-249'

        WHEN payment_value < 500
            THEN '250-499'

        WHEN payment_value < 1000
            THEN '500-999'

        ELSE '1000+'

    END AS payment_value_bucket,

    COUNT(*) AS payment_count,

    ROUND(SUM(payment_value), 2) AS total_value

FROM warehouse.fact_order_payments

GROUP BY payment_value_bucket

ORDER BY
    MIN(
        CASE
            WHEN payment_value < 50 THEN 1
            WHEN payment_value < 100 THEN 2
            WHEN payment_value < 250 THEN 3
            WHEN payment_value < 500 THEN 4
            WHEN payment_value < 1000 THEN 5
            ELSE 6
        END
    );


-- ============================================================
-- 12. PAYMENT TYPE VS AVERAGE ORDER VALUE
-- ============================================================

SELECT
    payment_type,

    COUNT(DISTINCT order_id) AS total_orders,

    ROUND(
        SUM(payment_value) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_payment

FROM warehouse.fact_order_payments

GROUP BY payment_type

ORDER BY average_order_payment DESC;