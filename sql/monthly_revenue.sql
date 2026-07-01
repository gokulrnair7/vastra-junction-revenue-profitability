
SELECT
    FORMAT(order_date,'yyyy-MM') AS month,
    ROUND(SUM(net_sales), 0)     AS net_revenue,
    ROUND(SUM(gross_profit), 0)  AS gross_profit
FROM dbo.vastra_junction_clean_sales
GROUP BY FORMAT(order_date,'yyyy-MM')
ORDER BY month;