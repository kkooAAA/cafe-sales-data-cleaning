# Cafe Sales Data Cleaning (MySQL)

A SQL project that cleans a messy cafe sales dataset (`dirty_cafe_sales.csv`) so it is ready for analysis. All cleaning is done in MySQL on a staging table, so the original raw data is never modified.

## Dataset

Source: [Cafe Sales - Dirty Data for Cleaning Training (Kaggle)](https://www.kaggle.com/datasets/ahmedmohamed2003/cafe-sales-dirty-data-for-cleaning-training)

The raw table `dirty_cafe_sales` has 10,000 transactions with the following columns:

| Column | Description |
|---|---|
| `Transaction ID` | Unique ID of each transaction (e.g. `TXN_1961373`) |
| `Item` | Item sold (e.g. Coffee, Cake, Cookie, Salad) |
| `Quantity` | Number of items purchased |
| `Price Per Unit` | Price of one item |
| `Total Spent` | Total amount of the transaction |
| `Payment Method` | How the customer paid (e.g. Credit Card, Cash) |
| `Location` | Where the purchase was made (e.g. In-store, Takeaway) |
| `Transaction Date` | Date of the transaction |

The raw data contains placeholder values such as `ERROR`, `UNKNOWN` and blank strings in several columns.

## Cleaning Workflow

1. **Create a staging table**
2. **Remove duplicates**
3. **Standardize the data**
4. **Handle error / unknown / blank values**
5. **Fix data types**
6. **Add new columns (feature engineering)**

### 1. Staging table

`cafe_staging` is created as a copy of `dirty_cafe_sales` (`CREATE TABLE ... LIKE` and `INSERT ... SELECT`). `DROP TABLE IF EXISTS` is used first so the script can be re-run safely.

### 2. Remove duplicates

Duplicates are checked with `ROW_NUMBER() OVER (PARTITION BY ...)` across all columns. Any row with `Row Num > 1` is a duplicate.

### 3. Standardize and clean each column

- **Item:** rows where `Item` is `ERROR`, `UNKNOWN` or blank are deleted, since a transaction without an item cannot be analyzed.
- **Total Spent:**
  - `ERROR`, `UNKNOWN` and blank values are converted to `NULL`.
  - The column type is changed from text to `DOUBLE`.
  - Missing values are recalculated as `Quantity * Price Per Unit`.
  - Values are rounded to 2 decimal places.
- **Price Per Unit:** rounded to 2 decimal places.
- **Payment Method:** `ERROR`, `UNKNOWN` and blank values are converted to `NULL`.
- **Location:** `ERROR`, `UNKNOWN` and blank values are converted to `NULL`.
- **Transaction Date:**
  - Values not matching the `YYYY-MM-DD` pattern are inspected.
  - `ERROR`, `UNKNOWN` and blank values are converted to `NULL`.
  - The column type is changed from text to `DATE`.

### 4. Feature engineering

A new column `Day of the Week` is added and filled with `DAYNAME(Transaction Date)` to support day-of-week analysis (for example, which days have the most sales).

## Result

The final table, `cafe_staging`, has:

- No duplicate rows
- No `ERROR` / `UNKNOWN` / blank placeholder values (replaced with proper `NULL`s)
- Correct data types (`DOUBLE` for `Total Spent`, `DATE` for `Transaction Date`)
- A new `Day of the Week` column

## Skills Demonstrated

- Staging-table workflow for safe data cleaning
- Window functions (`ROW_NUMBER`, `PARTITION BY`)
- Handling `NULL`, blank and placeholder values
- Recalculating missing values from related columns
- `ALTER TABLE ... MODIFY COLUMN` for type conversion
- Date functions (`DAYNAME`)
- `ALTER TABLE ... ADD COLUMN` for feature engineering

## How to Run

1. Import `dirty_cafe_sales.csv` into a MySQL database as a table named `dirty_cafe_sales`.
2. Run `Cafe_Data_Cleaning.sql` from top to bottom in MySQL Workbench (or any MySQL client).
3. Query `cafe_staging` for the cleaned data.

## Requirements

- MySQL 8.0 or later (window functions are required)

## Notes

- The original `dirty_cafe_sales` table is left untouched.
- The duplicate check in the script only selects the duplicate rows; it does not delete them.
- `NULL` values remain in `Payment Method`, `Location` and `Transaction Date` where the true value is unknown. Filter them out or handle them depending on the analysis.
