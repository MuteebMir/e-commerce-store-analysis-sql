--- Daily / monthly revenue and orders

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.quantity * oi.item_price),2) AS revenue,
    COUNT(o.order_id) AS number_of_orders,
    ROUND(
		 SUM(oi.quantity * oi.item_price)/COUNT(o.order_id),2) AS average_order_value
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY month
ORDER BY month;


-- Month over month change
WITH monthly_revenue AS (
SELECT 
	DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    ROUND(SUM(oi.quantity * oi.item_price),2) AS revenue
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
   WHERE o.order_status = 'Completed'
GROUP BY `month`)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
     ROUND(
        (revenue -  LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
        2
    ) AS mom_growth
FROM monthly_revenue;
    
    WITH Month_revenue AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        ROUND(SUM(oi.quantity * oi.item_price), 2) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY month
)
SELECT
    month,
    revenue,
    prev_month_revenue,
    ROUND(
        (revenue - prev_month_revenue)
        / prev_month_revenue * 100,
        2
    ) AS mom_growth
FROM (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue
    FROM Month_revenue
) t;



-- Status based metrics

SELECT 
	o.order_status,
    ROUND(SUM(oi.quantity * oi.item_price),2) AS revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
WHERE order_status IN ( 'completed', 'cancelled' , 'returned')
GROUP BY order_status;

-- Top products & categories

SELECT p.product_id,p.product_name, p.category,
	ROUND(SUM(oi.quantity * oi.item_price),2) AS revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o 
ON o.order_id = oi.order_id
WHERE order_status = 'Completed'
GROUP BY p.product_name, p.category , p.product_id
ORDER BY revenue DESC
LIMIT 10;

-- Under performing products

SELECT p.product_name
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o 
ON oi.order_id = o.order_id
WHERE order_status = 'cancelled' AND 'returned'
GROUP BY product_name;

-- customer analytics & churn risk list

CREATE VIEW customer_analytics1 AS
SELECT oi.user_id, COUNT(DISTINCT oi.order_id) AS total_orders_lifetime,
	  ROUND(SUM(item_total),2) AS total_spend_lifetime,
	MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
      
DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,

CASE
	WHEN DATEDIFF(CURDATE(),  MAX(o.order_date)) > 90
         AND COUNT(DISTINCT oi.order_id) >=3
    THEN 1
    ELSE 0
END AS is_churn_risk
    
FROM order_items oi
JOIN orders o
	ON oi.order_id = o.order_id
GROUP BY oi.user_id
ORDER BY oi.user_id ASC;

DROP VIEW customer_analytics1;

SELECT *	
FROM customer_analytics1;

SELECT *
FROM customer_analytics1
WHERE is_churn_risk = 1;



