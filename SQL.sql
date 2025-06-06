/*Sales Optimization Project*/


create database Sales_Opt_Project_db;
use Sales_Opt_Project_db;



/* process to add a new column in table*/
alter  table orders
add column new_order_date date;

/*data cleaning*/
update orders
set order_date = replace(order_date,"/","-");

/* converting string to date format*/
update orders
set	new_order_date = str_to_date(Order_Date,"%m-%d-%Y");

select * from orders;
									
/*A. Identifying Customer Behavior*/----------

/*1. What is the average profit per customer segment across different regions?
- Purpose: Helps determine which customer segments are the most profitable in each region.*/
select o.region,
round(avg(o.profit),2) as average_profit
from  `return` as r right join orders as o  on o.order_id=r.order_id
where r.order_id is null
group by o.region
order by average_profit desc;

/*2.Which shipping modes are preferred by the most profitable customer segments, 
and how does this impact overall sales and profit?
- Purpose: Identify the most profitable customer segments' preferred 
            shipping modes and assess their impact on sales and profit.*/

select o.ship_mode,o.segment,
round(sum(o.sales),0) as total_sales,
round(sum(o.profit),0) as total_profit
from  `return` as r right join orders as o  
       on o.order_id=r.order_id
where r.order_id is null
group by o.ship_mode,o.segment
order by o.segment desc,
         total_sales desc,
         total_profit;
         
/*3. What are the top-performing customer segments by frequency of purchase and average order value?
   - Purpose: Segments customers to target those with high lifetime value.*/

select segment, count(order_id) as frequency,
       round(sum(sales)) as total_order_amount,
       round(sum(sales)/count(order_id)) as average_order_value
from orders
group by segment
order by total_order_amount desc, 
          average_order_value desc;
-------------------------------------------------------------------------------------------------------------------
/*B. Analyzing Product Performance (Sales & Profit)*/

/*1. Which regions contribute the most to total sales but yield low profits?
   - Purpose: Detects geographical areas with high sales but poor margins, 
              signaling the need for cost or pricing review.*/

select o.region , round(sum(o.sales),0) total_sales,
                 round(( (sum(o.profit)/sum(o.sales))*100),2) 
                            as profit_yield_percentage
from orders as o left join `return` as r 
              on o.order_id = r.order_id
where r.order_id is null
group by o.region
order by total_sales desc,profit_yield_percentage asc;

/*2. What is the moving average of profit over the last 3 orders for each region?
- Purpose: Smooths out fluctuations in profits to observe short-term trends region-wise*/

select o.region,round(o.profit) as profit,
       round(avg(profit) over (partition by o.region
                               order by o.profit desc
                               rows between 2 preceding and current row),0)
                               as moving_average_profit
       from orders as o left join `return` as r 
              on o.order_id = r.order_id
where r.order_id is null;

/*3.Rank the sub-categories within each category by profit.
   - Purpose: Assesses sub-category performance in the context of its parent category.*/

select  category,sub_category ,
        round(sum(profit),0) as total_profit,
	   rank() over (partition by category 
                    order by sum(profit) desc) as rnk
       from  orders
       group by sub_category,category
       order by category desc, rnk asc;
       
/*4.Calculate the year-over-year sales growth for each region using LAG().
   - Purpose: Measures regional growth rates for performance benchmarking.*/


with cte as (select year(o.new_order_date) as year,
       sum(sales) as year_wise_total_sales
       
       from orders as o left join `return` as r 
       on o.order_id = r.order_id
       where r.order_id is null
       group by year(o.new_order_date))
       select *,
               ( (year_wise_total_sales - LAG(year_wise_total_sales) OVER (ORDER BY year))
            / NULLIF(LAG(year_wise_total_sales) OVER (ORDER BY year), 0))*100 as pecentage_change
                from cte;
                
/*5.What is the profit-to-sales ratio by product to identify low-margin items despite high sales?
   - Purpose: Highlights products that need margin improvement despite high revenue.*/

with cte 
        as (
           select o.product_name, 
	   round(sum(o.sales)) as total_sales,
       round(sum(o.profit)) as total_profit
       from orders as o left join `return` as r 
       on o.order_id = r.order_id
       where r.order_id is null
       group by o.product_name
                 )
		 select*,
               total_profit/ nullif(total_sales,0)
				as profit_to_sales_ratio
				from cte
				order by total_sales desc
                         ,
						 profit_to_sales_ratio asc;
                         
/*C. Conducting Return Analysis*/
-----------------------------

/*1. Which products or categories have the highest return rates?
- Purpose: Pinpoints which products are most frequently returned — possibly 
           due to quality issues or fulfillment errors.*/

DELIMITER //
create procedure getreturnrate()
begin
with sales_return as ( select o.product_name, 
          sum(o.sales) as total_return_amount
            from orders as o inner join `return` as r 
                 on o.order_id = r.order_id
                 group by o.product_name),
	 sales_amount as
                    (select product_name,
                           sum(sales) as total_sales_amount
            from orders
                 group by product_name)
                 select r.product_name, r.total_return_amount, s.total_sales_amount,
                 round((r.total_return_amount/s.total_sales_amount)*100,2) as return_rate
                 from sales_return as r inner join sales_amount as s
                 on r.product_name = s.product_name
                 order by return_rate desc;
		END //
DELIMITER ;
                 
call getreturnrate();

/*2. What’s the financial impact (lost sales/profit) from returned items?
   - Purpose: Quantifies lost revenue and profit from returns to improve policies and quality.*/

select round(sum(o.sales),0) as total_loss_sales, 
       round(sum(o.profit),0) as total_loss_profit
       from orders as o inner join `return` as r
       on o.order_id = r.order_id
       ;
       
/*3.What is the return rate by product category or sub-category?
   - Purpose: Identifies riskier product lines from a returns perspective.*/
   
   with sales_return as ( select o.category, 
          sum(o.sales) as total_return_amount
            from orders as o inner join `return` as r 
                 on o.order_id = r.order_id
                 group by o.category),
	 sales_amount as
                    (select category,
                           sum(sales) as total_sales_amount
            from orders
                 group by category)
                 select r.category, r.total_return_amount, s.total_sales_amount,
                 round((r.total_return_amount/s.total_sales_amount)*100,2) as return_rate
                 from sales_return as r inner join sales_amount as s
                 on r.category = s.category
                 order by return_rate desc;











                 
          