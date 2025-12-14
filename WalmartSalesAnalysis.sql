-- create database
create database if not exists DataWalmartSales;

-- create table called sales within salesDataWalmart 
create table if not exists sales (
				invoice_id VARCHAR (30) NOT NULL PRIMARY KEY,
				branch VARCHAR (5) NOT NULL,
				city VARCHAR (30) NOT NULL,
				customer_type VARCHAR (30) NOT NULL,
				gender VARCHAR (10) NOT NULL,
				product_line VARCHAR (100) NOT NULL,
				unit_price DECIMAL (10, 2) NOT NULL,
				quantity INT NOT NULL,
				VAT FLOAT(6, 4) NOT NULL,
				total DECIMAL(12, 4) NOT NULL,
				date DATETIME NOT NULL,
				time TIME NOT NULL,
				payment_method VARCHAR(15) NOT NULL,
				cogs DECIMAL(10,2) NOT NULL,
				gross_margin_perct FLOAT(11, 9),
				gross_income DECIMAL(12, 4) NOT NULL,
				rating FLOAT(2, 1)
);

-- -------- Feture Engineering : adding new columns for analysis --------------

-- 1. time_of_day column
-- testing if case logic works
Select time,
case
	when `time` between "00:00:00" and "12:00:00" then "Morning"
    when `time` between "12:10:00" and "16:00:00" then "Afternoon"
    Else "Evening"
end as time_of_day
from sales;

-- add column time_of_day into sales (no data yet)
alter table sales add column time_of_day VARCHAR(20);

-- add data into new column
Update sales
set time_of_day = (
	case
		when `time` between "00:00:00" and "12:00:00" then "Morning"
		when `time` between "12:10:00" and "16:00:00" then "Afternoon"
		Else "Evening"
	end 
);

-- 2. day_name column
-- test logic
select date, dayname(date)
from sales;

-- create column day_name and add into sales (no data yet)
alter table sales add column day_name VARCHAR(10);

-- add data into new column
Update sales
set day_name = dayname(date);


-- 3. month_name column
-- test logic
select date, monthname(date)
from sales;

-- add column month_name into sales (no data yet)
alter table sales add column month_name VARCHAR(10);

-- add data into new column
Update sales
set month_name = monthname(date);

-- -------- Exploratory Data Analysis (EDA): answering business questions --------------

-- ------------------------------- Sales KPIs ------------------------------------------
-- -------------------------------------------------------------------------------------

-- total sales, total transactions and total quantity
select
	count(*) as total_transactions,
    round(sum(total), 2) as total_revenue,
    sum(quantity) as total_units_sold
from sales;

-- average transaction value
select 
	avg(total) as avg_transaction_value
from sales;

-- average basket size - avarage number of items customer buys in a single transaction
select
	round(avg(quantity), 0) as avg_basket_size
from sales;

-- -------------------------- Revenue and Sales trend analysis -------------------------
-- -------------------------------------------------------------------------------------

-- daily sales trend
select
	date,
    round(sum(total), 2) as daily_sales
from sales
group by date
order by date;

-- total revenue by month
select 
	month_name as month,
    round(sum(total), 2) as monthly_sales
from sales
group by month
order by min(DATE);

-- sales by time of day 
select 
	time_of_day,
    round(sum(total), 2) as sales
from sales
group by time_of_day
order by sales desc;

-- ------------------------------- Product Performance ---------------------------------
-- -------------------------------------------------------------------------------------

-- Overall Revenue and Quantity sold by product line segment
select 
	product_line,
    round(sum(total), 2) as revenue,
    sum(quantity) as units_sold
from sales
group by product_line
order by revenue desc;

-- Highest selling product line by branch in each city
select 
	city,
	branch,
	product_line,
    round(sum(total), 2) as revenue,
    sum(quantity) as units_sold
from sales
group by city, branch, product_line
order by branch, revenue  desc;

-- -------------------------- Branch and Location Analysis -----------------------------
-- -------------------------------------------------------------------------------------

-- revenue by branch
select 
	branch, 
    round(sum(total), 2) as revenue 
from sales
group by branch
order by revenue desc;

-- revenue by city
select 
    city, 
    round(sum(total), 2) as revenue 
from sales
group by city
order by revenue desc;

-- branch performance summary
select 
	branch,
	count(*) as total_transactions,
    round(sum(total), 2) as total_revenue,
    round(avg(rating), 2) as avg_rating
from sales
group by branch;

-- -------------------------------- Customer Insights ----------------------------------
-- -------------------------------------------------------------------------------------

-- product line sales by gender
select
	gender,
    product_line,
    count(*) as transactions,
    round(sum(total), 2) as revenue
from sales
group by gender, product_line
order by gender, revenue desc;


-- sales by customer type
select 
	customer_type,
    count(*) as transactions,
    round(sum(total), 2) as revenue
from sales
group by customer_type
order by revenue desc;

-- -------------------------------- Profitability --------------------------------------
-- -------------------------------------------------------------------------------------

-- Total COGS and total Gross Income
select
	sum(cogs) as total_cogs,
    round(sum(gross_income), 2) as total_gross_income
from sales;

-- gross income by branch
select
	branch,
    round(sum(gross_income), 2) as branch_gross_income
from sales
group by branch;

-- gross margin % by product line
select
	product_line,
    avg(gross_margin_perct) as avg_margin
from sales
group by product_line
order by avg_margin desc;


-- -------------------------- Rating and Customer Satisfaction -------------------------
-- -------------------------------------------------------------------------------------

-- Average rating by product line
select
	product_line,
    round(avg(rating), 2) as avg_rating
from sales
group by product_line
order by avg_rating desc;

	