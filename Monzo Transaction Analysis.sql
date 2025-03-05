CREATE DATABASE Monzo_Transaction;

USE Monzo_Transaction;

-- View Complete table
	SELECT * FROM dbo.MonzoData;

-- Cleaning the data
-- Removing what is not needed

-- 1) Remove NULL or Replace with Defaults

		UPDATE dbo.MonzoData
		SET Description = 'Unknown'
		WHERE Description IS NULL;

/*	UPDATE dbo.MonzoData
	SET Money_Out = 0, Money_In = 0
	WHERE Money_Out IS NULL OR Money_In IS NULL;*/


		UPDATE dbo.MonzoData
		SET 
			Money_Out = CASE WHEN Money_Out IS NULL THEN 0 ELSE Money_Out END,
			Money_In = CASE WHEN Money_In IS NULL THEN 0 ELSE Money_In END,
			Category = CASE WHEN Category IS NULL THEN 'Unknown' ELSE Category END

	WHERE Money_Out IS NULL OR Money_In IS NULL OR Category IS NULL;



-- 2) Remove unwanted column
		-- Currency
		ALTER TABLE dbo.MonzoData
		DROP COLUMN Currency

		-- Remove all the pot transfer
		DELETE FROM dbo.MonzoData
		WHERE Type LIKE 'Pot%'


--		General Financial Analysis

-- 1} What is the total money in and money out for each year?
-- → Helps determine your most expensive year in terms of income and expenses.

		SELECT 
			YEAR(Date) as Year,
			CONCAT('£', FORMAT(ABS(SUM(Money_Out)),'N2')) AS Total_Expenses,
			CONCAT('£', FORMAT(SUM(Money_In),'N2')) AS Total_Income
		FROM dbo.MonzoData
		GROUP BY YEAR(Date)
		ORDER BY SUM(Money_IN) DESC;

/* NB
ABS() removes the negative value, 
FORMAT(,N2) - Formats numbers with comma separators and 2 decimal places.
CONCAT('£', ...) → Adds the pound (£) symbol in front of the numbers.
*/

	-- 1B What is my Net Balance for each year
			SELECT 
				YEAR(Date) as Year,
				CONCAT('£', FORMAT(ABS(SUM(Money_Out)),'N2')) AS Total_Expenses,
				CONCAT('£', FORMAT(SUM(Money_In),'N2')) AS Total_Income,
				CONCAT('£', FORMAT(SUM(Money_In) - ABS(SUM(Money_Out)),'N2')) AS Net_Balance

			FROM dbo.MonzoData
			GROUP BY YEAR(Date)
			ORDER BY SUM(Money_In) - ABS(SUM(Money_Out)) ASC;




-- 2) What are my total transactions per category (e.g., Bills, Entertainment, Income, etc.)?
	-- → Helps track where most of your money is going.

		SELECT 
			Category,
			CONCAT('£', FORMAT(ABS(SUM(Money_Out)),'N2')) AS Total_Expenses,
			CONCAT('£', FORMAT(SUM(Money_In),'N2')) AS Total_Income,
			CONCAT('£', FORMAT(SUM(Money_In) - ABS(SUM(Money_Out)),'N2')) AS Net_Balance
		FROM dbo.MonzoData
		GROUP BY Category
		ORDER BY ABS(SUM(Money_Out)) DESC;





-- 3) What is my highest spending month in each year?
-- → Identifies months with high expenses for better budget planning.

-- A Procedure with each year inserted

		CREATE PROCEDURE GetHighestSpendingMonth
			@Year INT
		AS
		BEGIN
			-- Declare a table to store the result
			DECLARE @Result TABLE
			(
				Year INT,
				Month INT,
				TotalSpending DECIMAL(18, 2)
			);
    
			-- Insert the total spending for each month of the given year into the table
			INSERT INTO @Result
			SELECT
				YEAR(Date) AS Year,
				MONTH(Date) AS Month,
				SUM([Money_Out]) AS TotalSpending
			FROM MonzoData
			WHERE YEAR(Date) = @Year AND [Money_Out] < 0 -- Expenses (negative amounts)
			GROUP BY YEAR(Date), MONTH(Date);
    
			-- Select the highest spending month for the given year
			SELECT TOP 1
				Year,
				Month,
				TotalSpending
			FROM @Result
			ORDER BY TotalSpending DESC; -- Order by highest spending
		END;

		-- To execute the Procedure
		EXEC GetHighestSpendingMonth @Year = 2022;
		EXEC GetHighestSpendingMonth @Year = 2023;
		EXEC GetHighestSpendingMonth @Year = 2024;
		EXEC GetHighestSpendingMonth @Year = 2025;





-- 4) Who are my Top 3 highest payers (money_in) and payees (money out)?
	-- → Finds the largest recipient and source of income.

		SELECT TOP 3
			Name AS Payer,
			SUM(Money_In) As Total_Income
		FROM dbo.MonzoData
		--WHERE Money_In > 0
		GROUP BY Name 
		ORDER BY Total_Income DESC;

		SELECT TOP 3
			Name AS Payees,
			Format(ABS(SUM(Money_Out)), 'N2') AS Total_Expenses
		FROM dbo.MonzoData
		WHERE Money_Out < 0
		GROUP BY Name 
		ORDER BY ABS(SUM(Money_Out)) DESC;

		-- Top Payer
		SELECT Sum(Amount) AS IK_Investment
		FROM dbo.MonzoData
		WHERE Name LIKE 'I Umejiofor' OR Name LIKE 'Ikechukwu Umejiofor';



-- 5) Which type of transactions occur most frequently?
	-- → Determines whether you use card payments, faster payments, or direct debits more.

		SELECT Type, COUNT(*) AS [Number of Payment]
		FROM MonzoData
		GROUP BY Type
		ORDER BY [Number of Payment] DESC;

-- 6) Spending & Saving Insights
	--→ Helps analyze spending patterns
	--→	Find months where you spent more than you earned.
		SELECT 
		   FORMAT(Date, 'yyyy-MM') AS Month,
		   FORMAT(SUM(Money_In) - SUM(ABS(Money_Out)), 'N2') AS Net_Savings
		FROM MonzoData
		GROUP BY FORMAT(Date, 'yyyy-MM')
		ORDER BY SUM(Money_In) - SUM(ABS(Money_Out));



-- 7) How much money have I sent/received from specific people?
-- → Helps track payments from/to specific individuals.

		-- Top Payers
		SELECT CONCAT ('£', FORMAT(Sum(Amount), 'N2')) AS IK_Investment
		FROM dbo.MonzoData
		WHERE Name LIKE 'I Umejiofor' OR Name LIKE 'Ikechukwu Umejiofor';
				

		SELECT CONCAT ('£', FORMAT(Sum(Amount), 'N2')) AS SYFT_Payment
		FROM MonzoData
		WHERE Name LIKE 'SYFT ONLIN LTDSW FMQ';

		-- Top expenses
		SELECT CONCAT ('£', FORMAT(Sum(Amount), 'N2')) AS Aliexpress
		FROM MonzoData
		WHERE Name LIKE 'Aliexpress';

		SELECT CONCAT ('£', FORMAT(Sum(Money_out), 'N2')) AS Footy
		FROM MonzoData
		WHERE Name LIKE 'footy';

		-- Expenses on train and Road Transport
		SELECT CONCAT ('£', FORMAT(Sum(Money_out), 'N2')) AS Train_Expenses
		FROM MonzoData
		WHERE Name LIKE 'Train%';

		-- Road Transport
		SELECT CONCAT ('£', FORMAT(Sum(Money_out), 'N2')) AS Road_Transport
		FROM MonzoData
		WHERE Name LIKE 'Uber'
		OR 
		Name LIKE 'First%'
		OR 
		NAME LIKE 'Arriva%'
		OR
		NAME LIKE 'NX West%'
		OR
		NAME LIKE 'Stage%';


		-- sim contract
		SELECT CONCAT ('£', FORMAT(Sum(Money_out), 'N2')) AS Train_Expenses
		FROM MonzoData
		WHERE Name LIKE 'giffgaff' 
		OR 
		Name LIKE 'Lebara'
		OR 
		NAME LIKE 'Three';

--8) What percentage of my total income is spent on specific categories?
	--	→ Finds what percentage of income goes to bills, entertainment, etc..

			SELECT 
				Category,
				SUM(ABS(Money_Out)) AS Total_Spent,
				CONCAT(FORMAT((SUM(ABS(Money_Out)) * 100.0) / (SELECT SUM(Money_In) FROM MonzoData WHERE Money_In > 0), 'N2' ), '%') AS Percentage_Of_Income
			FROM MonzoData
			WHERE Money_Out < 0
			GROUP BY Category
			ORDER BY Total_Spent DESC;


-- 9) What are my largest individual transactions for money in and money out?
	-- → Identifies the biggest transactions in your records. */

		SELECT TOP 1
			Name,
			ABS(Money_In) AS INCOME
		FROM MonzoData
		ORDER BY INCOME DESC

		SELECT TOP 3
			Name,
			Money_Out AS Expenses
		FROM MonzoData
		ORDER BY Expenses ASC

 -- 10) What are my possible Future Spending
		--→  Use past spending patterns to predict future expenses.
		--→ Remove 2023 because rarely paid rent that period

		SELECT 
			Category,
			FORMAT(AVG(ABS(Money_Out)), 'N2') AS Avg_Monthly_Spending
		FROM MonzoData
		WHERE Money_Out < 0 AND YEAR(Date) <> 2023
		GROUP BY Category
		ORDER BY Avg_Monthly_Spending DESC;

		
		SELECT FORMAT(SUM(Avg_Monthly_Spending), 'N2') AS Total_Average_Spending
		FROM(
		SELECT 
			Category,
			AVG(ABS(Money_Out)) AS Avg_Monthly_Spending
		FROM MonzoData
		WHERE Money_Out < 0 AND YEAR(Date) <> 2023
		GROUP BY Category
		) AS CategoryAveragesPerMonth;
