-- ============================================================
-- OLIST E-COMMERCE CUSTOMER ANALYTICS
-- CREATE DATABASE SCHEMAS
-- ============================================================

-- Staging layer
CREATE SCHEMA IF NOT EXISTS staging;

-- Analytical warehouse layer
CREATE SCHEMA IF NOT EXISTS warehouse;

-- Business analytics layer
CREATE SCHEMA IF NOT EXISTS analytics;

-- Data quality checks
CREATE SCHEMA IF NOT EXISTS quality_checks;