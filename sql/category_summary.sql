SELECT
    category,
    ROUND(SUM(net_sales), 0)    AS net_revenue,
    ROUND(SUM(cogs), 0)         AS cogs,
    ROUND(SUM(gross_profit), 0) AS gross_profit
FROM dbo.vastra_junction_clean_sales
GROUP BY category
ORDER BY net_revenue DESC;