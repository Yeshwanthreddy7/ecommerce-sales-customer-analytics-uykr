import pandas as pd
from pathlib import Path


# Location of the raw Olist CSV files
RAW_DATA_PATH = Path("data/raw")


def profile_table(file_path):
    """
    Read one CSV file and return basic profiling information.
    """

    df = pd.read_csv(file_path)

    print("\n" + "=" * 70)
    print(f"TABLE: {file_path.name}")
    print("=" * 70)

    print(f"Rows              : {df.shape[0]:,}")
    print(f"Columns           : {df.shape[1]}")
    print(f"Duplicate Rows    : {df.duplicated().sum():,}")

    print("\nColumns:")
    for column in df.columns:
        print(f"  - {column}")

    print("\nData Types:")
    print(df.dtypes)

    print("\nMissing Values:")
    null_values = df.isnull().sum()

    for column, count in null_values.items():
        if count > 0:
            percentage = (count / len(df)) * 100
            print(f"  {column}: {count:,} ({percentage:.2f}%)")

    if null_values.sum() == 0:
        print("  No missing values")

    print("\nUnique Values:")
    for column in df.columns:
        print(f"  {column}: {df[column].nunique(dropna=False):,}")


def main():

    # Find all CSV files in the raw data folder
    csv_files = sorted(RAW_DATA_PATH.glob("*.csv"))

    if not csv_files:
        print("ERROR: No CSV files found in data/raw/")
        return

    print("=" * 70)
    print("OLIST E-COMMERCE DATA PROFILING")
    print("=" * 70)

    print(f"\nRaw data directory : {RAW_DATA_PATH}")
    print(f"CSV files found    : {len(csv_files)}")

    print("\nFiles:")
    for file in csv_files:
        print(f"  - {file.name}")

    # Profile every CSV file
    for file_path in csv_files:
        profile_table(file_path)

    print("\n" + "=" * 70)
    print("PROFILING COMPLETED")
    print("=" * 70)


if __name__ == "__main__":
    main()