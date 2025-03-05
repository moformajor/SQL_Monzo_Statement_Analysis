# SQL_Monzo_Statement_Analysis (2022 - 2025)


## Project Overview

This project analyzes my personal transaction history from my Monzo bank statements spanning from 2022 to 2025. The goal is to gain insights into my spending habits, income sources, and financial trends using SQL Server.

## Objectives

- Identify the highest spending month in each year.
- Determine the largest payee (money out) and payer (money in).
- Find the most frequently used transaction type.
- Calculate the percentage of total income spent on specific categories.
- Exclude 2023 transactions for specific analyses due rent bills unused for mostly that year.
  
## Data Source

The dataset comes from my Monzo bank statements (2022 - 2025), exported in CSV format and imported into a SQL Server database for analysis. The dataset includes fields such as:

- Transaction ID
- Date
- Transaction Type (Card Payment, Faster Payment, Direct Debit, etc.)
- Transaction Name (e.g., Payee or Payer)
- Money In
- Money Out
- Category (e.g., Bills, Entertainment, Income, etc.)


The key Features of this analysis are:

1. **Data Cleaning:**
   - Remove or replace `NULL` values with default values.
   - Drop unnecessary columns like `Currency` and remove transactions related to "Pot" transfers.

2. **Financial Analysis:**
   - Total income and expenses for each year.
   - Net balance analysis for each year.
   - Track total transactions per category (e.g., Bills, Entertainment, Income, etc.).
   - Identify the highest spending month for each year.

3. **Top Payers and Payees:**
   - Find the top 3 largest sources of income and largest expenses.
   - Identify specific payments made to or received from individuals or services.

4. **Transaction Frequency:**
   - Find the most frequent types of transactions (card payments, faster payments, direct debits).

5. **Spending & Saving Insights:**
   - Analyze months where spending exceeds income, and track overall net savings per month.

6. **Category Spending Percentage:**
   - Analyze what percentage of total income is spent on specific categories.

7. **Largest Transactions:**
   - Find the largest individual transactions for both income and expenses.

8. **Future Spending Predictions:**
   - Predict future spending trends based on past transactions.

## Setup Instructions

1. **Create Database:**
   - Run the following SQL query to create the database and use it:
   
   ```sql
   CREATE DATABASE Monzo_Transaction;
   USE Monzo_Transaction;
   ```
   - Import the CSV file into Monzo_Transaction SQL database naming the table MonzoData
  
2. **Data Cleaning:**
   - The MonzoData table is cleaned by replacing NULL values, removing unnecessary columns, and deleting irrelevant transaction types (like "Pot" transfers).
   
   ```
       UPDATE dbo.MonzoData
       SET Description = 'Unknown'
       WHERE Description IS NULL;
      
    -- Replace NULL values in Money_Out, Money_In, and Category
    UPDATE dbo.MonzoData
    SET 
        Money_Out = CASE WHEN Money_Out IS NULL THEN 0 ELSE Money_Out END,
        Money_In = CASE WHEN Money_In IS NULL THEN 0 ELSE Money_In END,
        Category = CASE WHEN Category IS NULL THEN 'Unknown' ELSE Category END
    WHERE Money_Out IS NULL OR Money_In IS NULL OR Category IS NULL;
    
    -- Drop unnecessary columns
    ALTER TABLE dbo.MonzoData
    DROP COLUMN Currency;
    
    -- Remove 'Pot' transfer transactions
    DELETE FROM dbo.MonzoData
    WHERE Type LIKE 'Pot%';



3. **Key Analysis Queries:**
   - Total Money In and Out by Year:

  ```sql
      SELECT 
        YEAR(Date) as Year,
        CONCAT('£', FORMAT(ABS(SUM(Money_Out)),'N2')) AS Total_Expenses,
        CONCAT('£', FORMAT(SUM(Money_In),'N2')) AS Total_Income
      FROM dbo.MonzoData
      GROUP BY YEAR(Date)
      ORDER BY SUM(Money_In) DESC;

  ```

  - Net Balance by Year:
    ```sql
      SELECT 
        YEAR(Date) as Year,
        CONCAT('£', FORMAT(ABS(SUM(Money_Out)),'N2')) AS Total_Expenses,
        CONCAT('£', FORMAT(SUM(Money_In),'N2')) AS Total_Income,
        CONCAT('£', FORMAT(SUM(Money_In) - ABS(SUM(Money_Out)),'N2')) AS Net_Balance
      FROM dbo.MonzoData
      GROUP BY YEAR(Date)
      ORDER BY SUM(Money_In) - ABS(SUM(Money_Out)) ASC;
    ```
  - Top 3 Payees and Payers:
    ```sql
      SELECT TOP 3 
        Name AS Payer,
        SUM(Money_In) As Total_Income
      FROM dbo.MonzoData
      GROUP BY Name 
      ORDER BY Total_Income DESC;

      SELECT TOP 3
          Name AS Payees,
          Format(ABS(SUM(Money_Out)), 'N2') AS Total_Expenses
      FROM dbo.MonzoData
      WHERE Money_Out < 0
      GROUP BY Name 
      ORDER BY ABS(SUM(Money_Out)) DESC;

    ```

  - Future Spending Estimates:
     - This query estimates future spending based on past patterns:
       ```sql
       -- Average Monthly spending base on Categories
          SELECT 
            Category,
            FORMAT(AVG(ABS(Money_Out)), 'N2') AS Avg_Monthly_Spending
          FROM MonzoData
          WHERE Money_Out < 0 AND YEAR(Date) <> 2023
          GROUP BY Category
          ORDER BY Avg_Monthly_Spending DESC;

       -- Total Average Monthly spending
        SELECT FORMAT(SUM(Avg_Monthly_Spending), 'N2') AS Total_Average_Spending
        FROM (
            SELECT 
                Category,
                AVG(ABS(Money_Out)) AS Avg_Monthly_Spending
            FROM MonzoData
            WHERE Money_Out < 0 AND YEAR(Date) <> 2023
            GROUP BY Category
        ) AS CategoryAveragesPerMonth;

       ```
## Future Improvements

- Create Power BI or Tableau visualizations for better insights.

- Develop a web dashboard for real-time financial tracking.

### Notes:
- The **SQL queries** are designed to help you clean the data, analyze spending, and extract insights from your Monzo transactions.
- This Analysis is based on January 2022 - March 2025 transfer data.
- BASE ON THE IMPORTANT OF THIS CSV FILE, I WOULD NOT BE UPLOADING IT.

Let me know if you need to customize it further!


