--select all columns from the products table 
select * from products;

--select only name, price, category from products
select name, price, category from products;

--products with a price greater than $50
select * from products where price >50

--products in the electronic category
select * from products where category = 'Electronics';

--products with a rating of 4.5 or higher
select * from products where rating >=4.5;

--clothing products with a price less than $30
select * from products where category = 'Clothing'and price <30;

--home products or stock quality greater than 100
select * from products where category = 'Home'or stock_quantity > 100;

--available products not in the toys category
select * from products where is_available = TRUE and category <> 'toys';

--products priced between $20 and &$100
select * from products where price between 20 and 100;

--products sorted by price in ascending order
select * from products order by price asc;

--products sorted alphabetically by name
select * from products order by name asc;

--sort by rating descending, then price ascending
select * from products order by rating desc, price asc;

--list the 5 most expensive products
select * from products order by price desc limit 5;

--list the 10 products with the highest stock quantity
select * from products order by stock_quantity desc limit 10;

--products sorted alphabetically, showing results 6-10
select * from products order by name asc limit 5 offset 5;

--products whose name contains "premium"
select * from products where name like '%Premium%';

--products whose name starts with S
select * from products where name like 'S%';

--products whose names end with "er"
select * from products where name like '%er';

--produts whose description contains "with"
select * from products where description like '%with%';

--products whose category contains "o"
select * from products where category ilike '%o%';

--products whose name is exactly 5 characters long
select * from products where length(name) = 5;

--products released in 2023
select * from products where extract (year from release_date) = 2023;

--products with no rating
select * from products where rating is null;

--the 3 most recently released products that are still available
select * from products where is_available = TRUE order by release_date desc limit 3;

--products in books or stationery with price less than $25
select * from products where category in ('Books', 'stationery') and price <25;

--display products and thier lenghths
select name, length(name) as name_length from products;

--display all products names in uppercases
select upper(name) as product_name from products;

--extract the first 10 characters of each product description
select substring(description from 1 for 10) from products;

--replace "premium" with "luxury" in all products names
select replace(name, 'Premium', 'Luxury') as updated_name from products;

--concatenate product name and category with a hyphen
select concat(name, ' - ', category) as product_category from products;

--round all products prices to the nearest integer 
select name, round(price) as rounded_price from products;

--calculate the sale price after a 15% discount
select name, price, price * 0.85 as discounted_price from products;

--display the day of the week when each products where released
select name, TO_CHAR(release_date, 'day') as day_of_week from products;

--products released in the current month, regardless of year
select * from products where extract(month from release_date) = extract(month from current_date);

--calculate how many days each product has been in the inventory since its released date
select name, current_date - release_date as days_in_inventory from products;

--find the average price of all products
select avg(price) as average_price from products;

--find the total stock quantity of all products
select sum(stock_quantity) as total_stock_quantity from products;

--find the highest and lowest products rating
select max(rating) as highest_rating, min(rating) as lowest_rating from products;

--count the total number of products available for sale
select count(*) as available_products from products where is_available = true;

--find the average price, minimum price, maximum price, and total number of products in a single result
select avg(price) as average_price, min(price) as minimum_price, max(price) as maximum_price, count(*) as total_products from products