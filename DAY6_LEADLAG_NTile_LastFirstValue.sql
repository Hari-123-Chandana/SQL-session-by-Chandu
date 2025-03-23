CREATE TABLE SALES (
sales_id int primary key,
customer_id int,
sales_date date,
sales_amount decimal(16, 2)
);
INSERT INTO SALES VALUES
(1, 1, '20200201', 500),
(2, 1, '20200301', 7200),
(3, 1, '20200401', 3440),
(4, 2, '20200315', 29990),
(5, 2, '20200921', 6700),
(6, 3, '20201026', 4500),
(7, 3, '20200611', 30000),
(8, 4, '20201229', 8560);

SELECT customer_id, sales_date, sales_amount, LEAD (sales_amount) OVER (
PARTITION BY customer_id
ORDER BY sales_date ) next_sale
FROM SALES;

-------------LEAD------------------
SELECT customer_id, sales_date, sales_amount, LEAD (sales_amount,2) OVER
(
PARTITION BY customer_id
ORDER BY sales_date ) next_to_next_sale
FROM SALES;

SELECT t.SalesTerritoryKey, t.Region, t.Country, t.Continent,
LEAD(t.Region) OVER (ORDER BY t.SalesTerritoryKey) AS
NextRegion
FROM territories t;


SELECT
	DATE_FORMAT(s.orderdate, '%Y-%m') AS year_and_month,
		Round(SUM(s.orderquantity * p.productprice), 2) AS
			total_sales_amount,
	LEAD(round(SUM(s.orderquantity * p.productprice), 2)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) AS next_month_total_sales_amount
	FROM sales_2016 s
JOIN products p ON s.productkey = p.productkey
GROUP BY DATE_FORMAT(s.orderdate, '%Y-%m')
ORDER BY year_and_month;


-------------------LAG--------------------------
SELECT customer_id, sales_date, sales_amount, LAG (sales_amount) OVER (
PARTITION BY customer_id
ORDER BY sales_date) last_sale
FROM SALES;


------------------: Comparing Monthly Sales Amount with the Previous Month----------------------------
SELECT
	DATE_FORMAT(s.orderdate, '%Y-%m') AS month,
	Round(SUM(s.orderquantity * p.productprice), 2) AS total_sales_amount,
	LAG(round(SUM(s.orderquantity * p.productprice),2)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) AS previous_month_total_sales_amount
	FROM sales_2016 s
JOIN products p ON s.productkey = p.productkey
GROUP BY DATE_FORMAT(s.orderdate, '%Y-%m')
ORDER BY month;


-------------: Calculating the Sales Amount Change from the Previous Month--------------------
SELECT
	DATE_FORMAT(s.orderdate, '%Y-%m') AS month,
	SUM(s.orderquantity * p.productprice) AS total_sales_amount,
	LAG(SUM(s.orderquantity * p.productprice)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) AS previous_month_total_sales_amount,
	SUM(s.orderquantity * p.productprice) - LAG(SUM(s.orderquantity * p.productprice)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) AS sales_amount_change
FROM sales_2016 s
JOIN products p ON s.productkey = p.productkey
GROUP BY
	DATE_FORMAT(s.orderdate, '%Y-%m')
ORDER BY month;


SELECT
	DATE_FORMAT(s.orderdate, '%Y-%m') AS month,
	round(SUM(s.orderquantity * p.productprice), 2) AS total_sales_amount,
	LAG(round(SUM(s.orderquantity * p.productprice), 2)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) AS previous_month_total_sales_amount,
CASE
	WHEN SUM(s.orderquantity * p.productprice) < LAG(SUM(s.orderquantity * p.productprice)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) THEN 'Decreased'
	WHEN SUM(s.orderquantity * p.productprice) > LAG(SUM(s.orderquantity * p.productprice)) OVER (ORDER BY DATE_FORMAT(s.orderdate, '%Y-%m')) THEN 'Increased'
	ELSE 'No Change'
END AS sales_trend
FROM sales_2016 s
JOIN products p ON s.productkey = p.productkey
GROUP BY
	DATE_FORMAT(s.orderdate, '%Y-%m')
ORDER BY month;
-----------------------------------------------------------------------

--------analyze the company's yearly sales trend-----------------
SELECT year,
	SUM(sales_amount) AS total_sales_amount,
	LAG(SUM(sales_amount)) OVER (ORDER BY year) AS previous_year_total_sales_amount,
	CASE
		WHEN SUM(sales_amount) < LAG(SUM(sales_amount)) OVER (ORDER BY year) THEN 'Decreased'
		WHEN SUM(sales_amount) > LAG(SUM(sales_amount)) OVER (ORDER BY year) THEN 'Increased'
		ELSE 'No Change'
	END AS sales_trend
FROM combined_sales
GROUP BY year
ORDER BY year;



---------------NTILE----------------------

SELECT ProductKey, ProductName, ProductPrice,
NTILE(4) OVER (ORDER BY ProductPrice) AS price_quartile
FROM Products;	


WITH monthly_sales AS (
	SELECT DATE_FORMAT(orderdate, '%Y-%m') AS month, Round(SUM(orderquantity * p.productprice), 2) AS total_sales_amount
FROM sales_2017 s
JOIN products p ON s.productkey = p.productkey
GROUP BY DATE_FORMAT(orderdate, '%Y-%m')
)
SELECT
month,
total_sales_amount,
NTILE(3) OVER (ORDER BY total_sales_amount) AS sales_tercile
FROM
monthly_sales;



-----Analyze Sales Performance by Price Range-----------------

WITH product_sales AS (
SELECT p.ProductKey, p.ProductName, p.ProductPrice,
SUM(s.OrderQuantity) AS total_quantity,
NTILE(5) OVER (ORDER BY p.ProductPrice) AS price_range
FROM Products p
JOIN Sales_2015 s ON p.ProductKey = s.ProductKey
GROUP BY p.ProductKey, p.ProductName, p.ProductPrice
)
SELECT price_range,
	COUNT(*) AS num_products, SUM(total_quantity) AS total_quantity_sold, MIN(ProductPrice) AS min_price, MAX(ProductPrice) AS max_price
FROM product_sales
GROUP BY price_range;



WITH product_stats AS (
	SELECT ProductPrice, 	
		NTILE(4) OVER (ORDER BY ProductPrice) AS price_quartile
	FROM Products
),
quartiles AS (
	SELECT MAX(CASE WHEN price_quartile = 1 THEN ProductPrice END) AS
Q1,
	MAX(CASE WHEN price_quartile = 3 THEN ProductPrice END) AS
Q3
	FROM product_stats
),
iqr_bounds AS (
	SELECT Q1, Q3,
		Q3 - Q1 AS IQR,
		Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
		Q3 + 1.5 * (Q3 - Q1) AS upper_bound
	FROM quartiles
)
SELECT p.ProductKey, p.ProductName, p.ProductPrice
FROM Products p
JOIN iqr_bounds ib
ON p.ProductPrice >= ib.lower_bound AND p.ProductPrice <=
ib.upper_bound;


----------FIRST_VALUE---------------------
SELECT
	s.productkey,
	c.firstname,
	c.lastname,
	FIRST_VALUE(c.firstname) OVER (PARTITION BY s.productkey ORDER BY
s.OrderDate) AS first_customer_firstname,
	FIRST_VALUE(c.lastname) OVER (PARTITION BY s.productkey ORDER BY
s.OrderDate) AS first_customer_lastname
FROM
	sales_2015 s
JOIN
	Customers c ON s.customerkey = c.customerkey
ORDER BY
	s.productkey;


-----------------LAST_VALUE------------------------
SELECT
	s.productkey,
	t.region,
	LAST_VALUE(t.region) OVER (PARTITION BY s.productkey ORDER BY
	s.orderDate RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
AS last_region_sold
FROM
	sales_2017 s
JOIN
	territories t ON s.territorykey = t.salesterritorykey
ORDER BY
	s.productkey;



----------------------NTH VALUE------------------------
SELECT
	p.productkey,
	NTH_VALUE(productprice, 3) OVER (PARTITION BY p.productkey ORDER BY
	p.productprice) AS third_sale_price
FROM
	products p
JOIN
	sales_2017 s7 ON p.ProductKey = s7.productkey
ORDER BY
	p.productkey;


-----------Identify the customers who have ordered products from the same subcategory and calculate the average number of days between orders-------------------------

WITH subcategory_orders AS (
	SELECT s.customerkey, p.ProductSubcategoryKey, s.orderdate,
		LAG(s.orderdate) OVER (PARTITION BY s.customerkey,
p.ProductSubcategoryKey ORDER BY s.orderdate) AS prev_orderdate
	FROM sales_2017 s
	JOIN products p ON s.productkey = p.productkey
)
SELECT customerkey, ProductSubcategoryKey,
	round(AVG(DATEDIFF(orderdate, prev_orderdate)), 0) AS avg_days_between_orders
FROM subcategory_orders
WHERE prev_orderdate IS NOT NULL
GROUP BY customerkey, ProductSubcategoryKey
HAVING COUNT(*) > 1;



-----------------Find the product that has been out of stock the longest and calculate the number of days it has been unavailable.--------------------------------

WITH stock_changes AS (
	SELECT productkey, stockdate,
		LEAD(stockdate) OVER (PARTITION BY productkey ORDER BY stockdate) AS next_stockdate
FROM sales_2017
)
SELECT productkey,
	MAX(DATEDIFF(next_stockdate, stockdate)) AS days_out_of_stock
FROM stock_changes
WHERE next_stockdate IS NOT NULL
GROUP BY productkey;




------------------------3. Write a query to calculate the yearly sales trend, showing the total sales amount and the percentage change from the previous year.------------------------

WITH yearly_sales AS (
	SELECT YEAR(orderdate) AS year,
		round(SUM(orderquantity * ProductPrice), 2) AS total_sales
FROM
	(SELECT * FROM sales_2015 UNION ALL SELECT * FROM sales_2016
UNION ALL SELECT * FROM sales_2017) s
	JOIN products p ON s.productkey = p.productkey
	GROUP BY YEAR(orderdate)
),
sales_trend AS (
	SELECT year, total_sales,
		LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales
	FROM yearly_sales
)
SELECT year, total_sales,
	(total_sales - prev_year_sales) / prev_year_sales * 100.00 AS sales_change_percentage
FROM sales_trend
WHERE prev_year_sales IS NOT NULL;
