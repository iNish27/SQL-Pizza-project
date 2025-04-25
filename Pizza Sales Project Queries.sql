Create Database Pizzas;
Create table orders
(Order_Id int not null,
Order_Date date not null,
Order_Time time not null
);
Select * from orders;

Create table orders_Details
(Order_Details_Id int not null,
Order_Id int not null,
Pizza_Id text not null,
Quantity int not null,
primary key (Order_Details_Id)
);
Select * from orders_Details;

select * from pizzas;
select * from pizza_types;
select * from orders;
select * from orders_details;

######################################### Project Start #########################################
# 1. Retrieve the total number of orders placed.
Select count(Order_Id) as Total_Orders from orders;

# 2. Calculate the total revenue generated from pizza sales.
Select round(sum(pizzas.price * orders_details.Quantity), 2) as Total_Revenue from
pizzas join orders_details on
pizzas.pizza_Id = orders_details.Pizza_Id;

# 3. Identify the highest-priced pizza.
Select pizza_types.name, max(pizzas.price) as highest_priced_pizza from 
pizzas join pizza_types on 
pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name order by highest_priced_pizza DESC
LIMIT 1;

# 4. Identify the most common pizza size ordered.
Select pizzas.size as most_common_pizza_size_ordered, count(*) as Order_Count from
orders_details join pizzas on 
orders_details.Pizza_Id = pizzas.pizza_id
Group by pizzas.size order by Order_Count DESC
Limit 1;

# 5. List the top 5 most ordered pizza types along with their quantities.
Select pizzas.pizza_type_id as Pizza_types, count(orders_details.Quantity) as Quantities 
from orders_details join pizzas on 
orders_details.Pizza_Id = pizzas.pizza_id
group by pizzas.pizza_type_id order by Quantities DESC
Limit 5;

# 6. Join the necessary tables to find the total quantity of each pizza category ordered
select sum(orders_details.Quantity) as Total_Quantity, pizza_types.category from 
pizzas join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on 
orders_details.Pizza_Id = pizzas.pizza_id
group by pizza_types.category order by Total_Quantity DESC;

# 7. Determine the distribution of orders by hour of the day.
Select hour(Order_Time) as Hours, count(Order_Id) as Orders from orders
group by hour(Order_Time) order by  Hours;

# 8. Join relevant tables to find the category-wise distribution of pizzas.
Select category, count(Name) from pizza_types
group by category;

# 9. Group the orders by date and calculate the average number of pizzas ordered per day.
Select date(orders.Order_Date) as Date, round(sum(orders_details.Quantity) / count(distinct orders.Order_Id), 0) as Total_pizzas_ordered
from orders join orders_details on orders.Order_Id = orders_details.Order_Id 
group by date(orders.Order_Date);

# 10. Determine the top 3 most ordered pizza types based on revenue.
Select pizzas.pizza_type_id as Pizza_types, round(sum(pizzas.price * orders_details.Quantity), 0) as Total_Revenue 
from orders_details join pizzas on 
orders_details.Pizza_Id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizzas.pizza_type_id order by Total_Revenue DESC
Limit 3;

SELECT pizza_types.name AS Pizza_Type, 
       ROUND(SUM(pizzas.price * orders_details.quantity), 0) AS Total_Revenue
FROM orders_details
JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Total_Revenue DESC
LIMIT 3;

# 11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
  pizza_types.name AS Pizza_Type,
  ROUND(SUM(pizzas.price * orders_details.quantity), 2) AS Type_Revenue,
  ROUND(
    SUM(pizzas.price * orders_details.quantity) * 100.0 / 
    (SELECT SUM(pizzas.price * orders_details.quantity)
     FROM orders_details
     JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id),
    2
  ) AS Revenue_Percentage
FROM orders_details
JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY Revenue_Percentage DESC;

# 12. Analyze the cumulative revenue generated over time.
Select DATE(orders.Order_Date) as Order_Date, 
round(sum(pizzas.price * orders_details.Quantity), 2) as Daily_Revenue,
round(sum(sum(pizzas.price * orders_details.Quantity))
Over(order by DATE(orders.Order_Date)), 2) as cumulative_revenue
FROM orders
JOIN orders_details ON orders.Order_Id = orders_details.Order_Id
JOIN pizzas ON pizzas.pizza_id = orders_details.Pizza_Id
group by DATE(orders.Order_Date) 
order by Order_Date;

# 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
With RankedPizzas as (
SELECT 
pizza_types.name AS Pizza_Type, pizza_types.category,
       ROUND(SUM(pizzas.price * orders_details.quantity), 0) 
       AS Total_Revenue,
       RANK() OVER(partition by pizza_types.category 
       order by sum(pizzas.price * orders_details.quantity) DESC) 
       as rank_in_category
FROM orders_details
JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name, pizza_types.category
)
Select pizza_type, Category, Total_Revenue
from RankedPizzas
where rank_in_category <=3
order by category, Total_Revenue DESC
Limit 3;

SELECT pizza_types.name AS Pizza_Type, pizza_types.category,
       ROUND(SUM(pizzas.price * orders_details.quantity), 0) AS Total_Revenue
FROM orders_details
JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name, pizza_types.category
ORDER BY Total_Revenue DESC
LIMIT 3;