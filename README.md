E-Commerce Sales & Customer Analytics


1. Project Title + One-line Description

E-Commerce Sales & Customer Analytics

An end-to-end analytics project using PostgreSQL, SQL, Python, and Power BI to analyze e-commerce sales, customers, products, sellers, payments, delivery performance, and customer experience.

2. Dashboard Screenshot

Power BI Dashboard: powerbi/Analysis_Dashboard.pbix

3. Key Highlights

Built an end-to-end E-Commerce Analytics pipeline from raw CSV data to an executive Power BI dashboard.
Loaded 9 Olist datasets into PostgreSQL staging tables.
Designed a structured data warehouse using fact and dimension tables.
Performed SQL-based data transformation, quality checks, and business analysis.
Created analytical views specifically for Power BI reporting.
Analyzed:
Sales and revenue
Customers and customer behavior
Products and categories
Sellers
Orders and order status
Payments
Delivery performance
Customer reviews
Developed an executive Power BI dashboard with 6 KPIs and 4 analytical visuals.

4. Business Objectives

The project focuses on answering key business questions such as:

How much revenue is the business generating?
How are sales changing over time?
Which product categories generate the most revenue?
Which states contribute the most sales?
How many customers and orders does the business have?
What is the Average Order Value?
Which sellers and products perform best?
What are the major order statuses?
How do delivery performance and customer reviews relate to customer experience?
Which payment methods are most commonly used?
Who are the highest-value customers?

5. Architecture / Pipeline
             RAW OLIST CSV DATA
                     │
                     ▼
          Python Ingestion / Profiling
                     │
                     ▼
             PostgreSQL STAGING
                     │
                     ▼
          Data Transformation / ETL
                     │
                     ▼
            PostgreSQL WAREHOUSE
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
   Quality Checks          Analytical SQL
                                │
                                ▼
                         Analytics Views
                                │
                                ▼
                           Power BI
                                │
                                ▼
                    Executive Dashboard

Flow:

Collect raw Olist CSV datasets.
Inspect and profile the raw data using Python.
Load the datasets into PostgreSQL staging tables.
Transform staging data into warehouse fact and dimension tables.
Run data-quality checks.
Perform business analysis using SQL.
Create reporting views for Power BI.
Build the final executive dashboard in Power BI.


6. Repository Structure

ecommerce-sales-customer-analytics/
│
├── docs/
│   └── schema_overview.md
│
├── powerbi/
│   └── Analysis_Dashboard.pbix
│
├── python/
│   └── ingestion/
│       ├── inspect_raw_data.py
│       ├── load_to_postgres.py
│       └── profile_all_tables.py
│
├── screenshots/
│   └── dashboard.png
│
├── sql/
│   ├── ddl/
│   │   ├── 01_create_schemas.sql
│   │   ├── 02_create_staging_tables.sql
│   │   ├── 03_create_warehouse_tables.sql
│   │   └── query1.sql
│   │
│   ├── transformations/
│   │   └── 01_load_warehouse.sql
│   │
│   ├── quality_checks/
│   │   └── 01_warehouse_quality_checks.sql
│   │
│   ├── views/
│   │   └── 01_powerbi_views.sql
│   │
│   └── analysis/
│       ├── 01_business_analysis.sql
│       ├── 02_customer_analysis.sql
│       ├── 03_sales_analysis.sql
│       ├── 04_product_category_analysis.sql
│       ├── 05_seller_analysis.sql
│       ├── 06_delivery_customer_experience.sql
│       ├── 07_payment_analysis.sql
│       └── 08_executive_kpis.sql
│
├── .gitignore
├── README.md
└── requirements.txt

7. What Each Folder Contains

docs/

Contains project documentation.

schema_overview.md — Documents the database schemas and warehouse structure.
python/ingestion/

Contains Python scripts used during the data-ingestion and profiling stage.

inspect_raw_data.py — Inspects raw CSV data.
load_to_postgres.py — Loads the Olist CSV datasets into PostgreSQL staging tables.
profile_all_tables.py — Profiles the datasets and helps understand their structure and quality.
sql/ddl/

Contains database-definition scripts.

Creates PostgreSQL schemas.
Creates staging tables.
Creates warehouse tables.
sql/transformations/

Contains SQL used to transform and load data from staging into the warehouse.

sql/quality_checks/

Contains SQL validation and data-quality checks, including:

Row counts
Duplicate checks
NULL checks
Orphan-record checks
Value validation
sql/views/

Contains analytical/reporting views designed to provide Power BI with structured datasets.

sql/analysis/

Contains business-focused SQL analysis covering:

Business KPIs
Customers
Sales
Product categories
Sellers
Delivery and customer experience
Payments
Executive metrics
powerbi/

Contains the Power BI dashboard file.

Analysis_Dashboard.pbix — Interactive executive sales and customer analytics dashboard.
screenshots/

Contains screenshots of the final dashboard for repository presentation.

8. Data Warehouse

The PostgreSQL warehouse follows a fact-and-dimension structure.

Dimension Tables
dim_customers
dim_product_category
dim_products
dim_sellers
Fact Tables
fact_orders
fact_order_items
fact_order_payments
fact_order_reviews
Database Schemas
staging
   ↓
warehouse
   ↓
analytics
   ↓
Power BI

A separate quality_checks schema is used for validation.

This structure separates raw/staging data, transformed warehouse data, analytical views, and quality checks, making the project easier to maintain and extend.

9. Power BI Dashboard

Dashboard: E-Commerce Sales Dashboard

The dashboard provides an executive-level overview of business performance.

KPI Cards
KPI	Value
Total Revenue	13.59M
Total Customers	95K
Total Orders	99K
Total Products	33K
Total Sellers	3K
Average Order Value	160.58
Visualizations

Monthly Revenue Trend
Shows how revenue changes over time.

Top Product Categories by Sales
Identifies the highest-performing product categories.

Sales by Order Status
Shows the distribution of orders across different statuses.

Top 10 States by Sales
Highlights the states generating the highest sales.

The dashboard follows a clean executive reporting style, with KPI cards at the top and supporting trend and performance visuals below.

10. Key Metrics / Insights

The project calculates and analyzes metrics including:

Total Revenue
Total Orders
Total Customers
Total Products
Total Sellers
Average Order Value
Monthly Revenue
Monthly Orders
Revenue Growth
Revenue by State
Revenue by Product Category
Product Performance
Seller Performance
Customer Revenue
Repeat vs One-time Customers
Orders by Status
Payment Performance
Delivery Performance
Customer Review Scores
Important Dashboard Metrics
Revenue: 13.59M
Customers: approximately 95K
Orders: approximately 99K
Products: approximately 33K
Sellers: approximately 3K
AOV: 160.58

AOV definition: Product revenue divided by distinct orders. Freight is not included in this AOV calculation.


11. Technology Stack

Technology	Purpose
Python	Data inspection, profiling, and ingestion
Pandas	Data manipulation and profiling
PostgreSQL	Database and data warehouse
SQL	Transformation, validation, analysis, and reporting
Power BI	Interactive dashboard and visualization
DAX	Power BI measures and calculations
Git & GitHub	Version control and project management
CSV	Source data format


12. How to Run

1. Clone the Repository
git clone https://github.com/Yeshwanthreddy7/ecommerce-sales-customer-analytics-uykr.git
cd ecommerce-sales-customer-analytics-uykr

2. Install Python Dependencies
pip install -r requirements.txt

3. Add the Olist Dataset

Place the raw CSV files inside:

data/raw/

The project expects the 9 Olist source files, including:

olist_customers_dataset.csv
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_order_reviews_dataset.csv
olist_products_dataset.csv
olist_sellers_dataset.csv
olist_geolocation_dataset.csv
product_category_name_translation.csv

4. Configure PostgreSQL

Create the required database and configure the PostgreSQL connection securely using environment variables.

5. Run Python Ingestion
python python/ingestion/inspect_raw_data.py
python python/ingestion/profile_all_tables.py
python python/ingestion/load_to_postgres.py

6. Execute SQL Pipeline

Run the SQL scripts in this general order:

sql/ddl/
      ↓
sql/transformations/
      ↓
sql/quality_checks/
      ↓
sql/views/
      ↓
sql/analysis/

7. Open Power BI

Open : 

powerbi/Analysis_Dashboard.pbix

Refresh the data connection and explore the dashboard.

Security note: Database credentials should never be hard-coded or committed to GitHub. Use environment variables or a local .env file that is excluded through .gitignore.

13. Project Status

✅ Completed
 Raw dataset inspection
 Python data profiling
 PostgreSQL staging setup
 Data warehouse design
 Warehouse transformation
 Data-quality validation
 SQL business analysis
 Customer analysis
 Sales analysis
 Product/category analysis
 Seller analysis
 Delivery/customer-experience analysis
 Payment analysis
 Executive KPI analysis
 Power BI reporting views
 Executive Power BI dashboard
 Project documentation
 Git/GitHub version control


Status: Completed


---

## Author

**Yeshwanth Reddy**

Data Analytics | SQL | Python | PostgreSQL | Power BI

This project was designed, developed, and documented as an end-to-end
E-Commerce Sales & Customer Analytics portfolio project.

**GitHub:** [Yeshwanthreddy7](https://github.com/Yeshwanthreddy7)

---