INVENTORY MANAGEMENT
--products with fewer than 20 items in stock
select product_name,stock_quantity 
from products
where stock_quantity < 20
order by stock_quantity asc;

--products that are out of stock
select product_name,stock_quantity
from products
where stock_quantity = 0;

--profit margin percentage for each
SELECT
    product_name,
    price,
    cost,
    ROUND(
        ((price - cost) / NULLIF(price, 0) * 100)::numeric,
        2
    ) AS profit_margin_percentage
FROM products
ORDER BY profit_margin_percentage DESC NULLS LAST;

--products without a category or supplier
SELECT
    product_id,
    product_name,
    category_id,
    supplier_id
FROM products
WHERE category_id IS NULL
   OR supplier_id IS NULL;

   --all products with thier category and supplier names
   SELECT
    p.product_name,
    c.category_name,
    s.supplier_name
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN suppliers s
    ON p.supplier_id = s.supplier_id
ORDER BY p.product_name;

SALES ANALYSIS
--total sales amount for each store
SELECT
    st.store_name,
    st.region,
    SUM(sa.total_amount) AS total_sales
FROM stores st
JOIN sales sa
    ON st.store_id = sa.store_id
GROUP BY st.store_id, st.store_name, st.region
ORDER BY total_sales DESC;

--monthly sales and number of transactions in 2023
SELECT
    DATE_TRUNC('month', sale_date)::date AS sales_month,
    SUM(total_amount) AS total_sales,
    COUNT(*) AS transaction_count
FROM sales
WHERE sale_date >= DATE '2023-01-01'
  AND sale_date < DATE '2024-01-01'
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY sales_month;

--categories ranked by revenue
SELECT
    c.category_name,
    SUM(si.quantity * si.price_sold) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(si.quantity * si.price_sold) DESC
    ) AS revenue_rank
FROM categories c
JOIN products p
    ON c.category_id = p.category_id
JOIN sale_items si
    ON p.product_id = si.product_id
GROUP BY c.category_id, c.category_name
ORDER BY revenue_rank;

--top five most frequently purchased products
SELECT
    p.product_name,
    SUM(si.quantity) AS total_quantity_sold
FROM products p
JOIN sale_items si
    ON p.product_id = si.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

--each customer's purchases and most recent purchase date
SELECT
    c.first_name,
    c.last_name,
    c.email,
    COUNT(sa.sale_id) AS number_of_purchases,
    MAX(sa.sale_date) AS most_recent_purchase
FROM customers c
JOIN sales sa
    ON c.customer_id = sa.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
ORDER BY number_of_purchases DESC;

CUSTOMER INSIGHTS
--total amount spent by each customer
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(sa.total_amount) AS total_spent
FROM customers c
JOIN sales sa
    ON c.customer_id = sa.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--average product rating for each loyalty tier
SELECT
    c.loyalty_tier,
    ROUND(AVG(pr.rating)::numeric, 2) AS average_rating,
    COUNT(pr.rating) AS number_of_ratings
FROM customers c
JOIN product_reviews pr
    ON c.customer_id = pr.customer_id
GROUP BY c.loyalty_tier
ORDER BY average_rating DESC;

--customers who purchased but never reviewed a product
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM sales sa
    WHERE sa.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM product_reviews pr
    WHERE pr.customer_id = c.customer_id
);

--customers who spent more in the second quarter than in the first quarter of 2023
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(
        CASE
            WHEN sa.sale_date >= DATE '2023-01-01'
             AND sa.sale_date < DATE '2023-04-01'
            THEN sa.total_amount
            ELSE 0
        END
    ) AS q1_spending,
    SUM(
        CASE
            WHEN sa.sale_date >= DATE '2023-04-01'
             AND sa.sale_date < DATE '2023-07-01'
            THEN sa.total_amount
            ELSE 0
        END
    ) AS q2_spending
FROM customers c
JOIN sales sa
    ON c.customer_id = sa.customer_id
WHERE sa.sale_date >= DATE '2023-01-01'
  AND sa.sale_date < DATE '2023-07-01'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING
    SUM(
        CASE
            WHEN sa.sale_date >= DATE '2023-04-01'
             AND sa.sale_date < DATE '2023-07-01'
            THEN sa.total_amount
            ELSE 0
        END
    )
    >
    SUM(
        CASE
            WHEN sa.sale_date >= DATE '2023-01-01'
             AND sa.sale_date < DATE '2023-04-01'
            THEN sa.total_amount
            ELSE 0
        END
    )
ORDER BY q2_spending DESC;

--favourite product categories among gold tier customers
SELECT
    cat.category_name,
    SUM(si.quantity) AS total_quantity_purchased
FROM customers c
JOIN sales sa
    ON c.customer_id = sa.customer_id
JOIN sale_items si
    ON sa.sale_id = si.sale_id
JOIN products p
    ON si.product_id = p.product_id
JOIN categories cat
    ON p.category_id = cat.category_id
WHERE LOWER(c.loyalty_tier) = 'gold'
GROUP BY cat.category_id, cat.category_name
ORDER BY total_quantity_purchased DESC;

EMPLOYEE PERFORMANCE
--total sales and number of transactions for each employee
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    SUM(s.total_amount) AS total_sales,
    COUNT(s.sale_id) AS number_of_transactions
FROM employees e
LEFT JOIN sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY total_sales DESC NULLS LAST;
--average transactions value for each employee
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ROUND(AVG(s.total_amount), 2) AS average_transaction_value
FROM employees e
JOIN sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY average_transaction_value DESC;

--store name,manager,number of employees and total sales
WITH employee_counts AS (
    SELECT
        store_id,
        COUNT(*) AS number_of_employees
    FROM employees
    GROUP BY store_id
),
store_sales AS (
    SELECT
        store_id,
        SUM(total_amount) AS total_sales
    FROM sales
    GROUP BY store_id
)
SELECT
    st.store_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    COALESCE(ec.number_of_employees, 0) AS number_of_employees,
    COALESCE(ss.total_sales, 0) AS total_sales
FROM stores st
LEFT JOIN employees m
    ON st.store_id = m.store_id
   AND m.position = 'Store Manager'
LEFT JOIN employee_counts ec
    ON st.store_id = ec.store_id
LEFT JOIN store_sales ss
    ON st.store_id = ss.store_id
ORDER BY st.store_id;

--stores with average salaries higher than the company average
SELECT
    st.store_name,
    ROUND(AVG(e.salary), 2) AS average_store_salary
FROM stores st
JOIN employees e
    ON st.store_id = e.store_id
GROUP BY st.store_id, st.store_name
HAVING AVG(e.salary) > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY average_store_salary DESC;

--product performance matrix
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.price,
        p.cost,
        COALESCE(SUM(si.quantity), 0) AS sales_volume
    FROM products p
    LEFT JOIN sale_items si
        ON p.product_id = si.product_id
    GROUP BY p.product_id, p.product_name, p.price, p.cost
),
product_metrics AS (
    SELECT
        *,
        CASE
            WHEN price > 0
            THEN (price - cost) / price * 100
            ELSE NULL
        END AS profit_margin
    FROM product_sales
),
thresholds AS (
    SELECT
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY sales_volume) AS median_sales,
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY profit_margin) AS median_margin
    FROM product_metrics
)
SELECT
    pm.product_name,
    pm.sales_volume,
    ROUND(pm.profit_margin::numeric, 2) AS profit_margin,
    CASE
        WHEN pm.profit_margin IS NULL
            THEN 'Margin unavailable'
        WHEN pm.sales_volume >= t.median_sales
         AND pm.profit_margin >= t.median_margin
            THEN 'Stars'
        WHEN pm.sales_volume >= t.median_sales
         AND pm.profit_margin < t.median_margin
            THEN 'Volume Drivers'
        WHEN pm.sales_volume < t.median_sales
         AND pm.profit_margin >= t.median_margin
            THEN 'Opportunities'
        ELSE 'Problems'
    END AS performance_group
FROM product_metrics pm
CROSS JOIN thresholds t
ORDER BY pm.sales_volume DESC;

ADVANCED ANALYSIS
--management hierachy from store managers to sales associates
WITH RECURSIVE management_hierarchy AS ( SELECT employee_id, store_id, first_name, last_name, position, manager_id, 1 AS hierarchy_level, (first_name  ' '  last_name)::text AS management_path FROM employees WHERE manager_id IS NULL
UNION ALL

SELECT
    e.employee_id,
    e.store_id,
    e.first_name,
    e.last_name,
    e.position,
    e.manager_id
    mh.hierarchy_level + 1,
    mh.management_pathELECT
    e.e        e.first_name  ' '  e.last_name
FROM employees e
JOIN management_hierarchy mh
    ON e.manager_id = mh.employee_id
   AND e.store_id = mh.store_id
) SELECT st.store_name, mh.employee_id, mh.first_name, mh.last_name, mh.position, mh.manager_id, mh.hierarchy_level, mh.management_path FROM management_hierarchy mh JOIN stores st ON mh.store_id = st.store_id ORDER BY st.store_name, mh.hierarchy_level, mh.management_path;

--customer analysis by loyalty tier
WITH transaction_values AS (
    SELECT
        customer_id,
        sale_id,
        total_amount
    FROM sales
),
customer_spending AS (
    SELECT
        customer_id,
        AVG(total_amount) AS average_transaction_value,
        COUNT(sale_id) AS number_of_transactions
    FROM transaction_values
    GROUP BY customer_id
),
category_purchases AS (
    SELECT
        sa.customer_id,
        cat.category_name,
        SUM(si.quantity) AS quantity_purchased,
        ROW_NUMBER() OVER (
            PARTITION BY sa.customer_id
            ORDER BY SUM(si.quantity) DESC, cat.category_name
        ) AS category_rank
    FROM sales sa
    JOIN sale_items si
        ON sa.sale_id = si.sale_id
    JOIN products p
        ON si.product_id = p.product_id
    JOIN categories cat
        ON p.category_id = cat.category_id
    GROUP BY sa.customer_id, cat.category_name
),
customer_reviews AS (
    SELECT
        customer_id,
        COUNT(*) AS number_of_reviews
    FROM product_reviews
    GROUP BY customer_id
)
SELECT
    c.loyalty_tier,
    c.customer_id,
    c.first_name,
    c.last_name,
    COALESCE(cs.number_of_transactions, 0) AS number_of_transactions,
    ROUND(cs.average_transaction_value::numeric, 2)
        AS average_transaction_value,
    cp.category_name AS most_purchased_category,
    COALESCE(cr.number_of_reviews, 0) AS number_of_reviews
FROM customers c
LEFT JOIN customer_spending cs
    ON c.customer_id = cs.customer_id
LEFT JOIN category_purchases cp
    ON c.customer_id = cp.customer_id
   AND cp.category_rank = 1
LEFT JOIN customer_reviews cr
    ON c.customer_id = cr.customer_id
ORDER BY c.loyalty_tier, c.first_name, c.last_name;

