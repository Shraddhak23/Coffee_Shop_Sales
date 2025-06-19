USE coffee_shop_sales_db;

SELECT * FROM coffee_shop_sales;

SET SQL_SAFE_UPDATES = 0;

DESCRIBE coffee_shop_sales;

# Convert date column into dd-mm-yyyy format
UPDATE coffee_shop_sales
SET transaction_date = str_to_date(transaction_date, '%d-%m-%y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

# Convert time column into h-i-s format
UPDATE coffee_shop_sales
SET transaction_time = str_to_date(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

# Change field name ï»¿transaction_id
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

# TOTAL SALES For each respective month
SELECT ROUND(SUM(unit_price*transaction_qty),1) AS Total_Sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;   #(For CM May)

# Determine MoM increase or decrease in sales
# TOTAL SALES KPI - MoM Diff and MoM Growth
SELECT
MONTH(transaction_date) AS month,
ROUND(SUM(unit_price*transaction_qty),1) AS total_sales,
(SUM(unit_price*transaction_qty) - LAG(SUM(unit_price*transaction_qty),1) OVER(ORDER BY MONTH(transaction_date))) /
LAG(SUM(unit_price*transaction_qty),1) OVER(ORDER BY MONTH(transaction_date))*100 AS MoM_increase_percentage
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

# TOTAL ORDERS
SELECT COUNT(transaction_id) AS Total_Order
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;     #(For CM MAY)

# Determine MoM increase or decrease in orders
# TOTAL ORDERS KPI - MoM Diff and MoM Growth
SELECT
MONTH(transaction_date) AS month,
ROUND(COUNT(transaction_id)) AS total_orders,
(COUNT(transaction_id) - LAG(COUNT(transaction_id),1) OVER(ORDER BY MONTH(transaction_date))) /
LAG(COUNT(transaction_id),1) OVER(ORDER BY MONTH(transaction_date))*100 AS MoM_increase_percentage
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

# TOTAL QUANTITY SOLD
SELECT SUM(transaction_qty) AS Total_Qty
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5;

# Determine MoM increase or decrease in orders
# TOTAL QUNATITY SOLD KPI - MoM Diff and MoM Growth
SELECT 
MONTH(transaction_date) AS month,
ROUND(SUM(transaction_qty),1) AS Total_qty_sold,
(SUM(transaction_qty) - LAG(SUM(transaction_qty),1) OVER(ORDER BY MONTH(transaction_date)))/
LAG(SUM(transaction_qty),1) OVER(ORDER BY MONTH(transaction_date)) * 100 AS MoM_increase_growth
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

# CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
SUM(unit_price*transaction_qty) AS Total_Sales,
SUM(transaction_qty) AS Total_qty_sold,
COUNT(transaction_id) AS Total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18';


# If you want to get exact Rounded off values then use below query to get the result:
SELECT
CONCAT(ROUND(SUM(unit_price*transaction_qty)/1000,1),'K') AS Total_Sales,
CONCAT(ROUND(SUM(transaction_qty)/1000,1),'K') AS Total_qty_sold,
CONCAT(ROUND(COUNT(transaction_id)/1000,1),'K') AS Total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18';

# SALES TREND OVER PERIOD
SELECT AVG(Total_Sales) AS AVG_Sales
FROM
(
SELECT SUM(unit_price*transaction_qty) AS toal_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY transaction_date
) AS internal_query;

#DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);
    
# Comparing daily sales with avg sales-- IF > 'above avg' and < 'below avg'

# SALES BY WEEKDAY / WEEKEND:
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty),2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;
    
# SALES BY STORE LOCATION
SELECT
  store_location,
  SUM(unit_price * transaction_qty) AS total_qty
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty);


# SALES BY PRODUCT CATEGORY
SELECT
  product_category,
  SUM(unit_price * transaction_qty) AS total_qty
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

# SALES BY PRODUCTS (TOP 10)
SELECT
  product_type,
  SUM(unit_price * transaction_qty) AS total_qty
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

# SALES BY DAY | HOUR
SELECT 
   ROUND(SUM(unit_price * transaction_qty),1) AS Total_Sales,
   SUM(transaction_qty) AS Total_qty,
   COUNT(*) AS Total_orders
FROM coffee_shop_sales
WHERE DAYOFWEEK(transaction_date) = 3
      AND HOUR(transaction_time) = 8
      AND MONTH(transaction_date) = 5;
      
# TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday';


#TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);
