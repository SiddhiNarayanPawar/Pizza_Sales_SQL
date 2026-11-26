CREATE DATABASE PizzaHut;

SELECT * FROM PizzaHut.pizza;
USE PizzaHut;
-- Basic:
-- Retrieve the total number of orders placed.
SELECT	
		Count(DISTINCT order_id) as Total_Orders
FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
		round(sum(p.price * od.quantity),2) as Total_Revenue
FROM pizza p 
JOIN order_details od 
ON p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.
SELECT 	
		pt.name as Pizza_Name
FROM pizza p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;



-- Identify the most common pizza size ordered.
SELECT 
		p.size,
		COUNT(od.order_details_id) as Total_Orders
FROM pizza p
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY Total_Orders DESC
LIMIT 1;
-- List the top 5 most ordered pizza types along with their quantities.
SELECT pt.name as Pizza_Name,
		COUNT(od.quantity) as Ordered_Pizza
FROM order_details od 
JOIN pizza p 
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1
ORDER BY Ordered_Pizza DESC
LIMIT 5 ;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
		pt.category as Category,
        COUNT(od.quantity) as Total_Quantity
FROM order_details od 
JOIN pizza p 
ON od.pizza_id = p.pizza_id 
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category;

-- Determine the distribution of orders by hour of the day.
SELECT 	
		HOUR(time),
        COUNT(order_id) as Total_Hours
FROM orders
GROUP BY 1
ORDER BY Total_Hours DESC; 

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 	
		category,
        COUNT(name) as Total_Pizza
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
WITH MAIN AS 
(SELECT 
		o.date,
		SUM(od.quantity) as total_order 
FROM orders o 
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.date)
SELECT 
        ROUND(AVG(total_order),0) as Average_Orders_Per_Day
FROM MAIN;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
		pt.name as Pizza_Name,
        SUM(od.quantity * p.price)  as Revenue
FROM pizza p
JOIN order_details od 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id 
GROUP BY pt.name
ORDER BY Revenue DESC
LIMIT 3;

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
	pt.category,
   ROUND(
   SUM(od.quantity * p.price)  / (SELECT ROUND(SUM(od.quantity * p.price),2) AS total_Revenu  FROM order_details od join pizza p 
   ON od.pizza_id = p.pizza_id ) *100,2) as Revenue
FROM pizza p
JOIN order_details od 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id 
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.
SELECT
		DISTINCT o.date,
        ROUND(
		SUM(od.quantity * p.price)OVER(order by date ASC),2) as Cumulative_Revenue
FROM orders o
JOIN order_details od 
ON o.order_id = od.order_id 
JOIN pizza p 
ON od.pizza_id = p.pizza_id;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH MAIN AS(
SELECT pt.name,
		pt.category,
        SUM(od.quantity * p.price) as Revenue
FROM pizza p
JOIN order_details od 
ON p.pizza_id = od.pizza_id
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1,2
ORDER BY category ASC),
RANKER as (
SELECT *,
		DENSE_RANK( )OVER(PARTITION BY category ORDER BY Revenue DESC ) AS Ranking
FROM MAIN)
SELECT name, category, revenue
FROM RANKER
WHERE Ranking <= 3;


