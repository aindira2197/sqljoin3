WITH product_sales AS (
    SELECT 
        p.id,
        p.name,
        c.name AS category,
        SUM(oi.quantity) AS total_sold,
        SUM(oi.quantity * oi.price) AS revenue,
        AVG(oi.price) AS avg_price
    FROM products p
    JOIN categories c ON p.category_id = c.id
    JOIN order_items oi ON p.id = oi.product_id
    GROUP BY p.id, p.name, c.name
),

monthly_sales AS (
    SELECT 
        oi.product_id,
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity) AS qty,
        RANK() OVER (PARTITION BY oi.product_id ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.id
    GROUP BY oi.product_id, month
),

ranked_products AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
    FROM product_sales
)

SELECT 
    rp.name,
    rp.category,
    rp.total_sold,
    rp.revenue,
    rp.avg_price,
    ms.month AS best_month,
    rp.category_rank
FROM ranked_products rp
LEFT JOIN monthly_sales ms 
    ON rp.id = ms.product_id AND ms.rnk = 1;
