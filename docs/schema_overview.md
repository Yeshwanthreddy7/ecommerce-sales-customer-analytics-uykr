# Olist E-Commerce Data Model

## Overview

The Olist e-commerce dataset contains customer, order, product, seller,
payment, review, and geolocation information.

The dataset consists of multiple relational CSV files connected through
primary and foreign key relationships.

---

## Core Tables

### 1. Customers

File:

`olist_customers_dataset.csv`

Purpose:

Contains customer-level information and customer location identifiers.

Important columns:

- customer_id
- customer_unique_id
- customer_zip_code_prefix
- customer_city
- customer_state

---

### 2. Orders

File:

`olist_orders_dataset.csv`

Purpose:

Contains order-level information and timestamps related to the order lifecycle.

Important columns:

- order_id
- customer_id
- order_status
- order_purchase_timestamp
- order_approved_at
- order_delivered_carrier_date
- order_delivered_customer_date
- order_estimated_delivery_date

Relationship:

`customers.customer_id → orders.customer_id`

---

### 3. Order Items

File:

`olist_order_items_dataset.csv`

Purpose:

Contains individual products purchased within each order.

Important columns:

- order_id
- order_item_id
- product_id
- seller_id
- shipping_limit_date
- price
- freight_value

Relationships:

`orders.order_id → order_items.order_id`

`products.product_id → order_items.product_id`

`sellers.seller_id → order_items.seller_id`

---

### 4. Products

File:

`olist_products_dataset.csv`

Purpose:

Contains product-level attributes.

Important columns:

- product_id
- product_category_name
- product_name_lenght
- product_description_lenght
- product_photos_qty
- product_weight_g
- product_length_cm
- product_height_cm
- product_width_cm

Relationship:

`products.product_id → order_items.product_id`

---

### 5. Sellers

File:

`olist_sellers_dataset.csv`

Purpose:

Contains seller information and seller location identifiers.

Important columns:

- seller_id
- seller_zip_code_prefix
- seller_city
- seller_state

Relationship:

`sellers.seller_id → order_items.seller_id`

---

### 6. Order Payments

File:

`olist_order_payments_dataset.csv`

Purpose:

Contains payment information associated with orders.

Important columns:

- order_id
- payment_sequential
- payment_type
- payment_installments
- payment_value

Relationship:

`orders.order_id → order_payments.order_id`

---

### 7. Order Reviews

File:

`olist_order_reviews_dataset.csv`

Purpose:

Contains customer review information associated with orders.

Important columns:

- review_id
- order_id
- review_score
- review_comment_title
- review_comment_message
- review_creation_date
- review_answer_timestamp

Relationship:

`orders.order_id → order_reviews.order_id`

---

### 8. Geolocation

File:

`olist_geolocation_dataset.csv`

Purpose:

Contains geographical information associated with Brazilian ZIP-code prefixes.

Important columns:

- geolocation_zip_code_prefix
- geolocation_lat
- geolocation_lng
- geolocation_city
- geolocation_state

Used by:

- customers
- sellers

---

### 9. Product Category Translation

File:

`product_category_name_translation.csv`

Purpose:

Maps Portuguese product category names to English names.

Important columns:

- product_category_name
- product_category_name_english

Relationship:

`products.product_category_name → product_category_name_translation.product_category_name`

---

# Relationship Overview

```text
                    ┌─────────────────┐
                    │    CUSTOMERS    │
                    │                 │
                    │ customer_id PK  │
                    └────────┬────────┘
                             │
                             │
                             ▼
                    ┌─────────────────┐
                    │     ORDERS      │
                    │                 │
                    │ order_id PK     │
                    │ customer_id FK  │
                    └───────┬─────────┘
                            │
            ┌───────────────┼────────────────┐
            │               │                │
            ▼               ▼                ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ ORDER ITEMS  │ │   PAYMENTS   │ │   REVIEWS    │
    │              │ │              │ │              │
    │ order_id FK  │ │ order_id FK  │ │ order_id FK  │
    │ product_id   │ │ payment_type │ │ review_score │
    │ seller_id    │ │ payment_value│ │              │
    └──────┬───────┘ └──────────────┘ └──────────────┘
           │
       ┌───┴────────────┐
       │                │
       ▼                ▼
┌──────────────┐ ┌──────────────┐
│   PRODUCTS   │ │   SELLERS    │
│              │ │              │
│ product_id   │ │ seller_id    │
└──────┬───────┘ └──────────────┘
       │
       ▼
┌────────────────────────────┐
│ CATEGORY TRANSLATION       │
│                            │
│ Portuguese → English       │
└────────────────────────────┘