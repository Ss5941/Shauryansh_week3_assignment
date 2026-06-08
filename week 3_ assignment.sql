create database superstore_db;
use superstore_db;

-- STEP 1: CREATE CUSTOMERS TABLE

create table superstore_raw (
    Row_ID INT,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(10,2),
    Quantity INT,
    Profit DECIMAL(10,2)
);


select * from superstore_raw LIMIT 10;

DESCRIBE superstore_raw;

CREATE TABLE customers AS
SELECT DISTINCT
    `Customer ID`,
    `Customer Name`,
    Segment,
    Country,
    City,
    State
FROM superstore_raw;

DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS orders;



-- STEP 2: CREATE PRODUCTS TABLE
CREATE TABLE products AS
SELECT DISTINCT
   'Product ID',
   ' Product Name',
    Category,
    'Sub Category'
FROM superstore_raw;
    
    
    -- STEP 3: CREATE ORDERS TABLE

CREATE TABLE orders AS
SELECT DISTINCT
    'Order ID',
    'Order Date',
    'Ship Date',
    'Customer ID',
    'Product ID',
    Sales,
    Quantity,
    Profit
FROM superstore_raw;

SELECT * FROM products;

-- QUERY 1: FIND ORDERS WITH SALES GREATER THAN THE AVERAGE SALES VALUE

SELECT *
FROM orders
WHERE Sales >
(
    SELECT AVG(Sales)
    FROM orders
);


-- QUERY 2: FIND THE HIGHEST SALES ORDER FOR EACH CUSTOMER
SELECT o.*
FROM orders o
WHERE Sales =
(
    SELECT MAX(o2.Sales)
    FROM orders o2
    WHERE o.Customer_ID = o2.Customer_ID
);


-- QUERY 3: CALCULATE TOTAL SALES FOR EACH CUSTOMER
WITH customer_sales AS
(
    SELECT
        'Customer ID',
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY  'Customer ID'
)
SELECT *
FROM customer_sales;


-- QUERY 4: FIND CUSTOMERS WHOSE TOTAL SALES ARE ABOVE THE AVERAGE CUSTOMER SALES

WITH customer_sales AS
(
    SELECT
       ' Customer ID',
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY 'Customer ID'
)

SELECT *
FROM customer_sales
WHERE Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM customer_sales
);



-- QUERY 5: RANK CUSTOMERS BASED ON TOTAL SALES

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
)
SELECT
    `Customer ID`,
    Total_Sales,
    RANK() OVER(ORDER BY Total_Sales DESC) AS Sales_Rank
FROM customer_sales;




-- QUERY 6: ASSIGN ROW NUMBERS TO ORDERS WITHIN EACH CUSTOMER
SELECT
    'Customer ID',
    'Order ID',
    Sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY 'Customer ID'
        ORDER BY 'Order Date'
    ) AS Order_Number
FROM orders;

-- QUERY 7: DISPLAY TOP 3 CUSTOMERS  BASED ON TOTAL SALES

WITH customer_sales AS
(
    SELECT
        'Customer ID',
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY 'Customer ID'
),

ranked_customers AS
(
    SELECT
        'Customer ID',
        Total_Sales,
        RANK() OVER(ORDER BY Total_Sales DESC) AS rnk
    FROM customer_sales
)

SELECT *
FROM ranked_customers
WHERE rnk <= 3;


-- FINAL COMBINED QUERY  DISPLAY CUSTOMER NAME, TOTAL SALES AND SALES RANK 

WITH customer_sales AS
(
    SELECT
        'Customer ID',
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY  'Customer ID'
)

SELECT
    'Customer Name',
    cs.Total_Sales,
    RANK() OVER(ORDER BY cs.Total_Sales DESC) AS Sales_Rank
FROM customer_sales cs
JOIN customers c
ON cs.'Customer ID' = c.'Customer ID';


                                      -- MINI PROJECT: CUSTOMER SALES INSIGHTS --
                                      
--  Q 1: WHO ARE THE TOP 5 CUSTOMERS?

WITH customer_sales AS
(
    SELECT
           'Customer ID',
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY 'Customer ID'
)

SELECT
    'Customer Name',
    cs.Total_Sales
FROM customer_sales cs
JOIN customers c
ON 'Customer ID' = 'Customer ID'
ORDER BY cs.Total_Sales DESC
LIMIT 5;



-- Q 2: WHO ARE THE BOTTOM 5 CUSTOMERS?


WITH customer_sales AS
(
    SELECT
        'Customer ID',
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY 'Customer ID'
)

SELECT
    'Customer Name',
    cs.Total_Sales
FROM customer_sales cs
JOIN customers c
ON 'Customer ID'= 'Customer ID'
ORDER BY cs.Total_Sales ASC
LIMIT 5;


-- Q 3: WHICH CUSTOMERS MADE ONLY ONE ORDER?

SELECT
    c.Customer_Name,
    COUNT(o.Order_ID) AS Total_Orders
FROM customers c
JOIN orders o
ON c.Customer_ID = o.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(o.Order_ID) = 1;


-- Q 4: WHICH CUSTOMERS HAVE ABOVE-AVERAGE SALES?

WITH customer_sales AS
(
    SELECT
        `Customer ID`,
        SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY `Customer ID`
)
SELECT
    c.`Customer Name`,
    cs.Total_Sales
FROM customer_sales cs
JOIN customers c
ON cs.`Customer ID` = c.`Customer ID`
WHERE cs.Total_Sales >
(
    SELECT AVG(Total_Sales)
    FROM customer_sales
);


-- Q 5: WHAT IS THE HIGHEST ORDER VALUE PER CUSTOMER?

SELECT
    c.`Customer Name`,
    MAX(o.Sales) AS Highest_Order_Value
FROM customers c
JOIN orders o
ON c.`Customer ID` = o.`Customer ID`
GROUP BY c.`Customer ID`, c.`Customer Name`
ORDER BY Highest_Order_Value DESC;


