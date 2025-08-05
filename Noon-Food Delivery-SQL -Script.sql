SELECT *
FROM orders;



#Q1. FInd top 3 outlets by cuisine type without using limit and top functions
WITH CTE AS (
SELECT Restaurant_id, Cuisine, COUNT(*) AS no_of_orders
FROM orders
GROUP BY Restaurant_id, Cuisine)
SELECT * FROM(
SELECT *
,ROW_NUMBER() OVER (PARTITION BY cuisine ORDER BY no_of_orders DESC) as rn
FROM CTE) A 
WHERE rn=1;


#Q2. Find the daily new customer count from the launch date(everyday how many new cusotmers we are acquiring)

WITH CTE AS (
SELECT Customer_code, DATE(MIN(Placed_at)) as first_order_date
FROM orders
GROUP BY Customer_code)
SELECT first_order_date, COUNT(*) as new_customers
FROM CTE
GROUP BY first_order_date;


#. Q3 Count of all the users who were acquired in Jan 2025  and only placed one order in Jan and 
# did not place any other order
WITH CTE AS(
SELECT  Customer_code as customers, MONTH(Placed_at) as month, COUNT(*) as total_orders_placed
FROM orders
WHERE MONTH(Placed_at)=1 AND customer_code NOT IN (
SELECT DISTINCT customer_code               /*---customers who have placed order in Feb and Mar---*/
FROM orders
WHERE NOT(MONTH(Placed_at)=1)
)
GROUP BY Customer_code, MONTH(Placed_at)
HAVING COUNT(*)=1)
SELECT COUNT(customers) as Jan_customers_with_one_orders
FROM CTE;

#Q4. List all the cutomers with no orders in last 7 days but were acquired 1 month ago with their first order on promo
WITH CTE AS(
SELECT customer_code, MIN(Placed_at) as first_order_date, MAX(Placed_at) as latest_order_date
FROM orders
GROUP BY customer_code)
SELECT CTE.*, orders.Promo_code_Name as first_order_promo
FROM CTE
INNER JOIN orders ON CTE.customer_code=orders.Customer_code and CTE.first_order_date= orders.Placed_at
WHERE first_order_date <  DATE_SUB("2025-03-31", INTERVAL 1 MONTH)
AND latest_order_date < DATE_SUB("2025-03-31", INTERVAL 7 DAY)
AND orders.Promo_code_Name IS NOT NULL;

#Q5. Growth team is planning to create a trigger that will target customers after every 3rd order
# with a personalized communication and they have asked to create a query for this

# ASSUMING THAT THEY ARE CHECKING IT ON DAILY BASIS AND offering Promos to every customers after their 3rd order

WITH CTE AS(
SELECT *
, ROW_NUMBER() OVER(PARTITION BY customer_code ORDER BY Placed_at) as no_of_orders
FROM orders)
SELECT *
FROM CTE
WHERE no_of_orders%3=0 AND DATE(Placed_at) = DATE("2025-03-31");

#Q6. List customers who placed more than 1 order and all their orders on promo only

SELECT Customer_code, COUNT(*) as no_of_orders, COUNT(Promo_code_name) as promo_orders
FROM orders
GROUP BY Customer_code
HAVING COUNT(*)>1 AND COUNT(*)=COUNT(Promo_code_name);

#Q6. What % of customers were organically acquired in Jan 2025(placed 1st order without promos)

WITH CTE AS (
SELECT *
,ROW_NUMBER() OVER(PARTITION BY customer_code order by placed_at) as rn
FROM orders
WHERE MONTH(Placed_at)=1 AND YEAR(Placed_at)=2025
)
SELECT 
ROUND(COUNT(CASE WHEN rn=1 and Promo_code_Name IS NULL THEN Customer_code END)*100.00/COUNT(DISTINCT customer_code),2) as org_perc_cust
FROM CTE






