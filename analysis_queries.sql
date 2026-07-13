/* ============================================================
   E-COMMERCE SALES & CUSTOMER ANALYTICS
   Database: ecommerce.db (SQLite)
   Tables: customers, products, orders, order_items, returns
   ============================================================ */


/* ------------------------------------------------------------
   1. TOP 10% OF CUSTOMERS BY TOTAL SPEND
   Skills: JOIN, aggregation, window function (NTILE), CTE
   ------------------------------------------------------------ */
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        SUM(oi.quantity * oi.unit_price) AS total_spend
    FROM customers c
    JOIN orders o        ON o.customer_id = c.customer_id
    JOIN order_items oi  ON oi.order_id  = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY c.customer_id, c.customer_name, c.city
),
ranked AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY total_spend DESC) AS spend_decile
    FROM customer_spend
)
SELECT customer_id, customer_name, city, total_spend
FROM ranked
WHERE spend_decile = 1
ORDER BY total_spend DESC;


/* ------------------------------------------------------------
   2. MONTH-OVER-MONTH REVENUE TREND
   Skills: date grouping, window function (LAG), % growth calc
   ------------------------------------------------------------ */
WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)               AS prev_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1
    )                                                  AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;


/* ------------------------------------------------------------
   3. WHICH PRODUCTS GET RETURNED MOST, AND DOES IT CORRELATE
      WITH PRICE? (using price as a proxy since we don't store
      a separate "rating" field in this dataset)
   Skills: multi-table JOIN, LEFT JOIN, aggregation, ratios
   ------------------------------------------------------------ */
SELECT
    p.product_name,
    p.category,
    p.unit_price,
    COUNT(DISTINCT oi.order_item_id)  AS times_ordered,
    COUNT(DISTINCT r.return_id)       AS times_returned,
    ROUND(
        100.0 * COUNT(DISTINCT r.return_id) / COUNT(DISTINCT oi.order_item_id), 1
    )                                  AS return_rate_pct
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
LEFT JOIN returns r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_id, p.product_name, p.category, p.unit_price
ORDER BY return_rate_pct DESC
LIMIT 10;


/* ------------------------------------------------------------
   4. TOP 10 PRODUCTS BY REVENUE
   Skills: JOIN, RANK() window function
   ------------------------------------------------------------ */
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        SUM(oi.quantity)                  AS units_sold
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o        ON o.order_id   = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    product_name,
    category,
    units_sold,
    revenue
FROM product_revenue
ORDER BY revenue_rank
LIMIT 10;


/* ------------------------------------------------------------
   5. COHORT-STYLE REPEAT PURCHASE ANALYSIS
   For each signup month (cohort), what % of customers placed
   a 2nd order within 90 days of their first order?
   Skills: CTE chaining, self-referencing logic, window function
   ------------------------------------------------------------ */
WITH first_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
),
cohorts AS (
    SELECT
        customer_id,
        strftime('%Y-%m', first_order_date) AS cohort_month,
        first_order_date
    FROM first_orders
),
repeat_flags AS (
    SELECT
        c.customer_id,
        c.cohort_month,
        CASE WHEN EXISTS (
            SELECT 1 FROM orders o2
            WHERE o2.customer_id = c.customer_id
              AND o2.status = 'Delivered'
              AND o2.order_date > c.first_order_date
              AND julianday(o2.order_date) - julianday(c.first_order_date) <= 90
        ) THEN 1 ELSE 0 END AS repeated_within_90d
    FROM cohorts c
)
SELECT
    cohort_month,
    COUNT(*)                          AS cohort_size,
    SUM(repeated_within_90d)          AS repeat_customers,
    ROUND(100.0 * SUM(repeated_within_90d) / COUNT(*), 1) AS repeat_rate_pct
FROM repeat_flags
GROUP BY cohort_month
ORDER BY cohort_month;


/* ------------------------------------------------------------
   6. AVERAGE ORDER VALUE (AOV) BY CITY
   Skills: JOIN, aggregation, simple ranking
   ------------------------------------------------------------ */
SELECT
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(o.order_total), 2) AS avg_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'Delivered'
GROUP BY c.city
ORDER BY avg_order_value DESC;
