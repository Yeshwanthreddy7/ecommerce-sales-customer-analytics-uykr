SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM staging.customers

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM staging.orders

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM staging.order_items

UNION ALL

SELECT
    'order_payments',
    COUNT(*)
FROM staging.order_payments

UNION ALL

SELECT
    'order_reviews',
    COUNT(*)
FROM staging.order_reviews

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM staging.products

UNION ALL

SELECT
    'sellers',
    COUNT(*)
FROM staging.sellers

UNION ALL

SELECT
    'geolocation',
    COUNT(*)
FROM staging.geolocation

UNION ALL

SELECT
    'product_category_translation',
    COUNT(*)
FROM staging.product_category_translation;