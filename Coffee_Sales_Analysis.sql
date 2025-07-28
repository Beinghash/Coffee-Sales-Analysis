# STEP 1: DATA CLEANING 

SELECT * 
FROM coffee_sales LIMIT 10;          -- Check data sample 
DESCRIBE coffee_sales;               -- See data types for each column

# 1.1 Create a duplicate table for changes to be made (leaving the original table untouched)
CREATE TABLE coffee_sales_copy as 
SELECT * FROM coffee_sales;

# Review the table
SELECT * 
FROM coffee_sales_copy LIMIT 10;

# 1.2.1 Convert 'date' column to date format
ALTER TABLE `cofeee_sales_analysis`.`coffee_sales_copy` 
CHANGE COLUMN `sale_date` `sale_date` DATE NULL DEFAULT NULL ;

# 1.2.2 Convert 'datetime' column to 'DATETIME' format 
ALTER TABLE `cofeee_sales_analysis`.`coffee_sales_copy` 
CHANGE COLUMN `datetime` `datetime` DATETIME NULL DEFAULT NULL ;

# 1.3 Handle missing values in 'card' column
UPDATE coffee_sales_copy
SET card = 'CASH_CUSTOMER'
WHERE card IS NULL or card = '';

# 1.4 Removing Duplicates (if any)
WITH ranked_rows AS(                                             # identifying duplicates with row nums
SELECT *,
       ROW_NUMBER() OVER ( PARTITION BY sale_date, `datetime`, cash_type, card, money, coffee_name ORDER BY `datetime`) AS row_num
       FROM coffee_sales_copy
)
# Delete all duplicate rows (keep the first occurance only)
DELETE FROM coffee_sales_copy
WHERE(sale_date, `datetime`,cash_type, card, money, coffee_name) IN (
SELECT sale_date, `datetime`,cash_type, card, money, coffee_name
FROM ranked_rows
WHERE row_num > 1
)
;
# STEP 2: FEATURE ENGINEERING

# 2.1 Adding new columns for further processing
ALTER TABLE coffee_sales_copy ADD COLUMN `Hour` INT;
ALTER TABLE coffee_sales_copy ADD COLUMN day_name VARCHAR(10);
ALTER TABLE coffee_sales_copy ADD COLUMN is_weekend VARCHAR(10);
ALTER TABLE coffee_sales_copy ADD COLUMN month_name VARCHAR(7);
ALTER TABLE coffee_sales_copy ADD COLUMN quantity INT DEFAULT 1;

# Add respective values to the columns (Populate new columns)
UPDATE coffee_sales_copy 
SET 
`Hour` = HOUR(`datetime`),           -- Extract hour
day_name = DAYNAME(sale_date),       -- Get Weekday name 
is_weekend = CASE WHEN DAYOFWEEK(sale_date) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END,
month_name = DATE_FORMAT(sale_date, '%Y-%m');            -- Format to (eg: 2024-03)

# STEP 3: EXPLORATORY DATA ANALYSIS (EDA)

# 3.1 Total Sales 
SELECT SUM(money) AS total_sales                            -- 37508.879999999815 total revenue generated 
FROM coffee_sales_copy;

# 3.2 Total Orders 
SELECT COUNT(*) AS total_orders                            -- 1133 total orders
FROM coffee_sales_copy;

# 3.3 Sales by Weekday & Weekend
SELECT is_weekend, SUM(money)                             -- Weekday: 27242  and Weekend: 10266
FROM coffee_sales_copy
GROUP BY is_weekend;

# 3.4 Daily Sales with Average line
SELECT sale_date, 
	   SUM(money) AS daily_sales,
	   ROUND(AVG(SUM(money)) OVER(), 2) AS avg_sales            -- Rolling average (avg sales =  250.06)
       FROM coffee_sales_copy
       GROUP BY sale_date
       ORDER BY sale_date asc;

# 3.5 Sales by product category (coffee_name)
SELECT coffee_name, SUM(money) AS total_sales
FROM coffee_sales_copy
GROUP BY coffee_name
ORDER BY total_sales DESC
;

# 3.6 Sales by days of week
SELECT day_name, SUM(money) AS total_sales
FROM coffee_sales_copy
GROUP BY day_name
ORDER BY FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') 
;

# 3.7 Sales by hour
SELECT `Hour`, SUM(money) AS total_sales                -- 10AM  - 11AM and 7PM are the peak hours of sales  
FROM coffee_sales_copy
GROUP BY `Hour`
ORDER BY total_sales DESC
;

# STEP 4: ADVANCED TIME SERIES EDA

# 4.1 Monthly sales trend 
SELECT month_name, SUM(money) AS total_sales
FROM coffee_sales_copy
GROUP BY month_name
ORDER BY month_name
;

# 4.2 7-Day Rolling Average
SELECT sale_date, 
       SUM(money) AS total_sales,
       ROUND(AVG(SUM(money)) OVER(ORDER BY sale_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS 7_day_rolling_avg
FROM coffee_sales_copy
GROUP BY sale_date
ORDER BY sale_date
;

# 4.4 Month over month growth  (MoM Growth Calculation)
SELECT month_name,
       SUM(money) AS current_month_sales,
       LAG(SUM(money)) OVER(ORDER BY month_name) AS pevious_month_sales,
       ROUND((SUM(money) - LAG(SUM(money)) OVER(ORDER BY month_name)) / LAG(SUM(money)) OVER(ORDER BY month_name) *100, 2 ) AS mom_growth_pct
FROM coffee_sales_copy
GROUP BY month_name
ORDER BY month_name;

# STEP 5: FORECASTING PREPERATION

# 5.1 Daily sales + next day target column
SELECT sale_date,
       SUM(money) AS current_sales, 
       LEAD(SUM(money)) OVER(ORDER BY sale_date) AS next_day_sales
FROM coffee_sales_copy
GROUP BY sale_date
ORDER BY sale_date
;

# 5.2 Weekly sales + next week target column
WITH daily_sales AS(
           SELECT sale_date, SUM(money) AS daily_sales
           FROM coffee_sales_copy
           GROUP BY sale_date
		 ),
         Weekly_sales AS (
                SELECT DATE_FORMAT(sale_date, '%Y-%u') AS year_week, SUM(daily_sales) AS Weekly_sales
                FROM daily_sales
                GROUP BY DATE_FORMAT(sale_date, '%Y-%u')
                )
                SELECT year_week, Weekly_sales,
                LEAD(Weekly_sales) OVER(ORDER BY year_week) AS next_week_sales
                FROM Weekly_sales 
                ;
                
# STEP 6: CUSTOMER PURCHASE ANALYSIS

# 6.1 Total revenue by customer 
SELECT card,
       SUM(money) AS total_spent         # Total money spent
FROM coffee_sales_copy
WHERE card != 'CASH_CUSTOMER'            # Excluding annonymous buyers (cash_buyers = annonymous buyers)
GROUP BY card 
ORDER BY total_spent DESC
;

# 6.2 No. of orders per customer (card buyers)
SELECT card,
	   COUNT(*) AS total_orders 
FROM coffee_sales_copy
WHERE card != 'CASH_CUSTOMER'
GROUP BY card
ORDER BY total_orders DESC
;

# 6.3 Average spent per order 
SELECT card,
	   ROUND(AVG(money), 2) AS avg_spent                    
FROM coffee_sales_copy
WHERE card != 'CASH_CUSTOMER'
GROUP BY card
ORDER BY avg_spent DESC
;

# 6.4 Most frequently brought product by customer 
SELECT card,
       coffee_name,
       COUNT(*) AS product_count
FROM coffee_sales_copy
WHERE card != 'CASH_CUSTOMER'
GROUP BY card, coffee_name
ORDER BY card, product_count 
;       

# 6.5 First and last purchase date (Checking loyalty)
SELECT card,
       MIN(sale_date) AS first_purchace_date,
       MAX(sale_date) AS last_purchase_date,
       DATEDIFF(MAX(sale_date), MIN(sale_date)) AS loyalty_span_days 
FROM coffee_sales_copy
WHERE card != 'CASH_CUSTOMER'
GROUP BY card
ORDER BY loyalty_span_days DESC
;       

# 6.6 New vs Returning customers by month
WITH first_orders AS (
      SELECT card,
             MIN(sale_date) AS first_order_date
	  FROM coffee_sales_copy
      WHERE card != 'CASH_CUSTOMER'
      GROUP BY card
      )
      SELECT DATE_FORMAT(first_order_date, '%Y-%m') AS `month`,
      COUNT(card) AS new_customers
      FROM first_orders
      GROUP BY `month`
      ORDER BY `month`
      ;

# 6.7 Customer type distribution
SELECT cash_type,
       COUNT(*) AS total_orders,
       ROUND(COUNT(*) * 100.0/ (SELECT COUNT(*) FROM coffee_sales_copy), 2) AS percentage
FROM coffee_sales_copy
GROUP BY cash_type       
;
      







 


