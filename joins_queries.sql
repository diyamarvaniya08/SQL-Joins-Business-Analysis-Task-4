SELECT * FROM superstore_joins_db.superstore_sales;

create table customers (
  customer_id varchar(50),
  customer_name varchar(100),
  segment varchar(50),
  region varchar(50)
); 

CREATE TABLE orders (
    order_id VARCHAR(50),
    order_date DATE,
    customer_id VARCHAR(50),
    sales DECIMAL(10,2),
    profit DECIMAL(10,2)
); 
CREATE TABLE products (
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE order_products (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10,2)
);
describe order_products;

insert into customers 
select distinct `customer id`, `customer name`, segment, region
from superstore_sales;

insert into products
select distinct `product id`, `product name`, category, `sub-category`
from superstore_sales;

insert into orders(order_id, order_date, customer_id, sales, profit)
select distinct
 `order id`,  str_to_date(`order date`, '%d-%m-%Y'), `customer id`, CAST(
        REPLACE(
            REPLACE(sales, ',', ''),
        '₹', '')
    AS DECIMAL(10,2)), CAST(
        REPLACE(
            REPLACE(profit, ',', ''),
        '₹', '')
    AS DECIMAL(10,2))
from superstore_sales WHERE sales IS NOT NULL AND profit IS NOT NULL;

SELECT sales
FROM superstore_sales
WHERE sales NOT REGEXP '^[0-9]+(\\.[0-9]{1,2})?$'
LIMIT 10;
TRUNCATE TABLE order_products;

INSERT INTO order_products (order_id, product_id, sales)
SELECT DISTINCT
    `order id`, `product id`,
    CAST(
        REPLACE(
            REPLACE(sales, ',', ''),
        '₹', '')
    AS DECIMAL(10,2))
FROM superstore_sales
WHERE sales IS NOT NULL;


-- 1. INNER join

select o.order_id, 
       o.order_date,
	   c.customer_name,
       c.region,
	   o.sales
from orders o 
inner join customers c
on o.customer_id = c.customer_id; 

-- 2. Left Join (Customer with no orders)

select c.customer_id,
       c.customer_name
from customers c
left join orders o
on c.customer_id = o.customer_id
where o.order_id is null;

-- 3. revenue per product

select p.product_name, sum(op.sales)total_revenue
from products p
inner join order_products op
on p.product_id = op.product_id
group by product_name 
order by total_revenue desc;

-- 4. revenue category-wise

select p.category, sum(op.sales)total_revenue
from products p
inner join order_products op
on p.product_id = op.product_id
group by category  
order by total_revenue desc;

-- 5. sales in east region between dates

select o.order_id,
       c.region,
       o.sales
from orders o 
inner join customers c
on o.customer_id = o.customer_id
where c.region = 'East'
and o.order_date between '2019-01-01' and '2019-06-30';

-- 6. Top customers by profit

select c.customer_name,
       p.product_name,
       sum(o.profit) total_profit,
       count(distinct o.order_id)total_orders
from customers c 
join orders o
   on c.customer_id = o.customer_id
join order_products op 
   on o.order_id = op.order_id
join products p 
   on op.product_id = p.product_id
group by c.customer_name, p.product_name
order by total_orders, total_profit desc 
limit 10;

-- 7. highest profitable product by category
SELECT c.region,
       p.category,
       SUM(o.profit) total_profit
from orders o
join ustomers c
    on o.customer_id = c.customer_id
join order_products op
    on o.order_id = op.order_id
join products p
    on op.product_id = p.product_id
group by c.region, p.category
order by c.region, total_profit desc;


-- 8. output csv 

SELECT 
    p.product_name,
    SUM(op.sales) AS total_revenue
FROM order_products op
INNER JOIN products p
ON op.product_id = p.product_id
GROUP BY p.product_name;


