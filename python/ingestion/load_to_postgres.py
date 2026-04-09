import pandas as pd
import psycopg2
from pathlib import Path
from io import StringIO


# ============================================================
# CONFIGURATION
# ============================================================

RAW_DATA_PATH = Path("data/raw")

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "database": "olist_analytics",
    "user": "postgres",
    "password": "Deepika@2385"
}


# ============================================================
# CSV → POSTGRES TABLE MAPPING
# ============================================================

TABLE_MAPPING = {
    "olist_customers_dataset.csv": "customers",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv":
        "product_category_translation"
}


# ============================================================
# LOAD ONE CSV INTO POSTGRES
# ============================================================

def load_table(connection, csv_path, table_name):

    print("\n" + "=" * 70)
    print(f"Loading: {csv_path.name}")
    print(f"Target : staging.{table_name}")
    print("=" * 70)

    # Load CSV
    df = pd.read_csv(csv_path)

    # --------------------------------------------------------
    # Clean numeric columns that should be integers
    # --------------------------------------------------------

    integer_columns = [
        "product_name_lenght",
        "product_description_lenght",
        "product_photos_qty",
        "product_weight_g",
        "product_length_cm",
        "product_height_cm",
        "product_width_cm"
    ]

    for column in integer_columns:
        if column in df.columns:
            df[column] = pd.to_numeric(
                df[column],
                errors="coerce"
            ).round().astype("Int64")

    print(f"CSV rows: {len(df):,}")

    # Replace NaN with PostgreSQL NULL
    df = df.where(pd.notnull(df), None)

    # Convert DataFrame to CSV buffer
    buffer = StringIO()

    df.to_csv(
        buffer,
        index=False,
        header=False,
        na_rep="\\N"
    )

    buffer.seek(0)

    cursor = connection.cursor()

    # Empty existing staging table
    cursor.execute(
        f"TRUNCATE TABLE staging.{table_name};"
    )

    # Column list
    columns = ", ".join(df.columns)

    # PostgreSQL COPY command
    copy_sql = f"""
        COPY staging.{table_name} ({columns})
        FROM STDIN
        WITH (
            FORMAT CSV,
            NULL '\\N',
            HEADER FALSE
        )
    """

    cursor.copy_expert(copy_sql, buffer)

    connection.commit()

    cursor.close()

    print(f"Loaded rows: {len(df):,}")
    print("Status: SUCCESS")


# ============================================================
# MAIN
# ============================================================

def main():

    print("=" * 70)
    print("OLIST → POSTGRESQL DATA INGESTION")
    print("=" * 70)

    print(f"\nRaw data directory: {RAW_DATA_PATH}")
    print(f"Database: {DB_CONFIG['database']}")

    try:

        connection = psycopg2.connect(**DB_CONFIG)

        print("\nPostgreSQL connection: SUCCESS")

    except Exception as error:

        print("\nERROR: Could not connect to PostgreSQL.")
        print(error)
        return

    try:

        for csv_file, table_name in TABLE_MAPPING.items():

            csv_path = RAW_DATA_PATH / csv_file

            if not csv_path.exists():

                print(
                    f"\nWARNING: File not found: {csv_path}"
                )

                continue

            load_table(
                connection,
                csv_path,
                table_name
            )

    except Exception as error:

        connection.rollback()

        print("\nERROR during ingestion:")
        print(error)

    finally:

        connection.close()

        print("\n" + "=" * 70)
        print("INGESTION PROCESS COMPLETED")
        print("=" * 70)


if __name__ == "__main__":
    main()