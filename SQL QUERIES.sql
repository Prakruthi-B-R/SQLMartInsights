-- ---------------------------------------Data Wrangling----------------------------------------------------------------

Create Database IF NOT EXISTS Project;
Use project;

Create table if not exists salesdata ( 
invoice_ID varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
VAT float(6,4) not null,
total decimal(12,4) not null,
date datetime not null,
time time not null,
Payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9) not null,
gross_income decimal(12,4) not null,
rating float(2,1)
);

select * from salesdata;

-- ----------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------Feature Engineering--------------------------------------------------------------------
-- -------------------------------------time_of_day----------------------------------------------------------------------------
select time,  
(case
when time between "00:00:00" and "12:00:00" then "Morning"
when time between "12:01:00" and "16:00:00" then "Afternoon"
else "Evening"
end)as time_of_day
from salesdata;

ALTER Table salesdata
add column time__of__day varchar(20);

UPDATE salesdata 
SET time__of__day = ( CASE
                      when time between "00:00:00" and "12:00:00" then "Morning"
                      when time between "12:01:00" and "16:00:00" then "Afternoon"
					   else "Evening"
                       END);
                       
                       
-- -----------------------------------day_name-----------------------------------------------------------------------------
select date, dayname(date) as day from salesdata;
alter table salesdata 
add column day varchar(20);
UPDATE salesdata 
SET day=(dayname(date));

-- ---------------------------------------month_name----------------------------------------------------------------------------
alter table salesdata 
add column month varchar(10);
UPDATE salesdata 
SET month = monthname(date); 

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------generic------------------------------------------------------------------------
# unique cities 

select distinct(city) from salesdata;

# In which city each branch is present

select distinct city, branch from salesdata;

# how many Unique product lines 
-- -------------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------Product Analysis-------------------------------------------------------------

select count(distinct(product_line))as total_product_line from salesdata;

# most common Payment Method 

select payment_method,count(payment_method) from salesdata
group by payment_method
order by count(payment_method) DESC 
LIMIT 1;

# Most Selling Product Line

select product_line, count(product_line) from salesdata 
group by product_line
order by count(product_line) DESC
LIMIT 1;

# Total Revenue by month 
select sum(total) as total_revenue,month from salesdata
group by month
order by total_revenue DESC;

# What month had largest COGs
select month, sum(cogs) as largest_cogs from salesdata
group by month
order by largest_cogs desc
limit 1;

#product line with largest Revenue
select product_line, sum(total) as largest_revenue from salesdata
group by product_line 
order by largest_revenue desc
limit 1;

# What city as the largest Revenue.
select city, sum(total) as largest_revenue from salesdata
group by city
order by largest_revenue desc
limit 1;

# what product_line as the largest VAT
select product_line, avg(VAT) as largest_VAT from salesdata
group by product_line 
order by largest_VAT desc
limit 1;

#Fetch each product line and add column to those product line showing "Good" or "Bad".Good if its greater than average sales.
select product_line,total,
(Case
     when total > avg(total) over (partition by product_line) then "Good"
     else "Bad"
     end) as sales_status
from salesdata;

# Which branch sold more products than average products sold.
select branch, sum(quantity) as total_product from salesdata 
group by branch 
having total_product > (SELECT AVG(quantity) from salesdata);

# what is the most common product line by gender 
select product_line, gender,count(gender) as total_count from salesdata 
group by gender, product_line
order by total_count DESC;

# What is the average rating of each product line.
select product_line, avg(rating) from salesdata 
group by Product_line
order by avg(rating) DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------Sales Analysis--------------------------------------------------------

# Number of sales made in each time of the day per week.
select  time__of__day,COUNT(*)from salesdata
WHERE DAY = "Sunday"
group by time__of__day
order by COUNT(*) desc;

# which of the customer types brings more revenue
select customer_type, sum(total) from salesdata
group by customer_type
order by sum(total) DESC;

# which city has the largest tax percent or vat value 
select city,avg(VAT) from salesdata
group by city 
order by avg(vat) desc;

# which customer pays the most in VAT 
select customer_type, avg(vat) from salesdata
group by customer_type
order by avg(vat) desc;

-- -----------------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------Customer Analysis----------------------------------------------------

# how many Unique customer types does data have.
select distinct(customer_type) from salesdata;

# how many unique payment method doe the data have
select distinct(Payment_method) from salesdata;

# which customer type buys the most
select customer_type,count(*) from salesdata 
group by customer_type
order by count(*) desc;

# What is the gender of most of the customers
select gender, count(*) as count_customer from salesdata 
group by gender
order by count_customer desc;

# what is the gender distribution per branch
select branch, gender, count(*) as gender_distribution from salesdata
group by branch, gender;

# which time of the day do customer gives most ratings 
select time__of__day, count(rating) as most_ratings from salesdata
group by time__of__day
order by most_ratings DESC;

# which time of the day do customer gives most ratings per branch
select branch,time__of__day, count(rating) as most_ratings from salesdata
group by branch,time__of__day
order by most_ratings DESC;

# which day of the week have the best average ratings 
select day, avg(rating) as best_avg_rating from salesdata
group by day
order by best_avg_rating desc;

# which day of the week have the best average ratings 
select branch,day, avg(rating) as best_avg_rating from salesdata
group by branch,day
order by best_avg_rating desc;

