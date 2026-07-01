SELECT
    CASE
        WHEN discount_pct = 0     THEN '0 - None'
        WHEN discount_pct <= 0.10 THEN '1 - 1-10%'
        WHEN discount_pct <= 0.20 THEN '2 - 11-20%'
        WHEN discount_pct <= 0.30 THEN '3 - 21-30%'
        ELSE '4 - 30%+'
    END AS discount_band,
    COUNT(*)                          AS line_count,
    ROUND(SUM(net_sales), 2)          AS net_revenue,
    ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2)) / NULLIF(SUM(net_sales),0) * 100, 2) AS gross_margin_percent
FROM dbo.vastra_junction_clean_sales
GROUP BY
    CASE
        WHEN discount_pct = 0     THEN '0 - None'
        WHEN discount_pct <= 0.10 THEN '1 - 1-10%'
        WHEN discount_pct <= 0.20 THEN '2 - 11-20%'
        WHEN discount_pct <= 0.30 THEN '3 - 21-30%'
        ELSE '4 - 30%+'
    END
ORDER BY discount_band;