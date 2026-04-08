import pandas as pd
from pathlib import Path


# Path to the raw Olist customer data
DATA_PATH = Path("data/raw/olist_customers_dataset.csv")


def main():
    # Load the CSV file
    df = pd.read_csv(DATA_PATH)

    print("\n========== DATASET SHAPE ==========")
    print(f"Rows    : {df.shape[0]}")
    print(f"Columns : {df.shape[1]}")

    print("\n========== COLUMN NAMES ==========")
    for column in df.columns:
        print(column)

    print("\n========== DATA TYPES ==========")
    print(df.dtypes)

    print("\n========== FIRST 5 ROWS ==========")
    print(df.head())

    print("\n========== NULL VALUES ==========")
    print(df.isnull().sum())

    print("\n========== DUPLICATE ROWS ==========")
    print(df.duplicated().sum())


if __name__ == "__main__":
    main()