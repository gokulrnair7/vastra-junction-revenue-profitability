/* 03_analysis.sql  |  Vastra Junction - Revenue & Profitability
   Seven analyses in narrative order: scene -> headline insights ->
   drill-down -> trends. */

/* ---- 1) Revenue & gross margin by category and sub-category ----------
   Q: Where does revenue and profit come from?
   Finding: Womenswear leads revenue; Footwear is high-revenue but the
   lowest margin of the big categories. */
    SELECT
        category,
        sub_category,
        ROUND(SUM(net_sales), 0)    AS net_revenue,
        ROUND(SUM(gross_profit), 0) AS gross_profit,
        ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2))
              / NULLIF(SUM(net_sales),0) * 100, 2) AS gross_margin_percent
    FROM dbo.vastra_junction_clean_sales
    GROUP BY category, sub_category
    ORDER BY net_revenue DESC;
    GO

/* ---- 2) Discount-impact analysis ------------------
 Q: What does discounting do to margin?
   Finding: margin falls from ~45% at full price to under 9% once
   discounts exceed 30% -> deep clearance destroys profit. */
   SELECT
    CASE
        WHEN discount_pct = 0     THEN '0 - None'
        WHEN discount_pct <= 0.10 THEN '1 - 1-10%'
        WHEN discount_pct <= 0.20 THEN '2 - 11-20%'
        WHEN discount_pct <= 0.30 THEN '3 - 21-30%'
        ELSE '4 - 30%+'
    END AS discount_band,
    COUNT(*)                 AS line_count,
    ROUND(SUM(net_sales), 0) AS net_revenue,
    ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2))
          / NULLIF(SUM(net_sales),0) * 100, 2) AS gross_margin_percent
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
GO

/* ---- 3) Channel split: Store vs Online --------------------------
   Q: Is the Online channel as profitable as physical Stores?
   Finding: Online margin (~33%) trails Store (~36%) -> deeper
   discounts and more returns online; needs a margin floor. */
SELECT
    channel,
    ROUND(SUM(net_sales), 0)    AS net_revenue,
    ROUND(SUM(gross_profit), 0) AS gross_profit,
    ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2))
          / NULLIF(SUM(net_sales),0) * 100, 2) AS gross_margin_percent
FROM dbo.vastra_junction_clean_sales
GROUP BY channel
ORDER BY net_revenue DESC;
GO

/* ---- 4) Regional profitability ranking -------------------
   Q: Which regions generate the most gross profit?
   RANK() numbers regions 1 to 4 by gross profit, highest first.
   Finding: South ranks 1 by a wide margin, then North, West, East. */
SELECT
    region,
    ROUND(SUM(net_sales), 0)    AS net_revenue,
    ROUND(SUM(gross_profit), 0) AS gross_profit,
    RANK() OVER (ORDER BY SUM(gross_profit) DESC) AS profit_rank
FROM dbo.vastra_junction_clean_sales
GROUP BY region
ORDER BY profit_rank;
GO

/* ---- 5) Top 10 & bottom 10 products by gross-margin % -----------
   Q: Which products are the margin winners and losers? */

   -- top 10 (the margin winners):
    SELECT TOP 10
        product,
        ROUND(SUM(net_sales), 0)    AS net_revenue,
        ROUND(SUM(gross_profit), 0) AS gross_profit,
        ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2))
              / NULLIF(SUM(net_sales),0) * 100, 2) AS gross_margin_percent
    FROM dbo.vastra_junction_clean_sales
    GROUP BY product
    HAVING SUM(net_sales) > 0
    ORDER BY gross_margin_percent DESC;
    GO
-- bottom 10 (the margin losers):
    SELECT TOP 10
        product,
        ROUND(SUM(net_sales), 0)    AS net_revenue,
        ROUND(SUM(gross_profit), 0) AS gross_profit,
        ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2))
              / NULLIF(SUM(net_sales),0) * 100, 2) AS gross_margin_percent
    FROM dbo.vastra_junction_clean_sales
    GROUP BY product
    HAVING SUM(net_sales) > 0
    ORDER BY gross_margin_percent ASC;
    GO
/* ---- 6) Month-over-month revenue growth -------------------
   Q: How is revenue trending month to month?
   LAG() pulls the prior month's revenue onto the current row.
   Note: the first row's mom_change is NULL (no prior month). */
WITH monthly AS (
    SELECT FORMAT(order_date,'yyyy-MM') AS ym,
           SUM(net_sales)               AS net_rev
    FROM dbo.vastra_junction_clean_sales
    GROUP BY FORMAT(order_date,'yyyy-MM')
)
SELECT
    ym,
    ROUND(net_rev, 0)                                   AS net_rev,
    ROUND(net_rev - LAG(net_rev) OVER (ORDER BY ym), 0) AS mom_change,
    ROUND(CAST(net_rev AS DECIMAL(18,2))
          / NULLIF(LAG(net_rev) OVER (ORDER BY ym), 0) * 100 - 100, 2) AS mom_percent
FROM monthly
ORDER BY ym;
GO

/* ---- 7) Year-over-year by month (LAG 12) ------------------------
   Q: Is each month growing vs the same month last year?
   LAG(...,12) compares to 12 months earlier in the ordered series.
   Note: the first 12 rows have NULL (no same-month-last-year yet). */
WITH monthly AS (
    SELECT FORMAT(order_date,'yyyy-MM') AS ym,
           SUM(net_sales)               AS net_rev
    FROM dbo.vastra_junction_clean_sales
    GROUP BY FORMAT(order_date,'yyyy-MM')
    )
    SELECT
        ym,
        ROUND(net_rev, 0)                          AS net_rev,
        ROUND(LAG(net_rev,12) OVER (ORDER BY ym), 0) AS net_rev_ly,
        ROUND(CAST(net_rev AS DECIMAL(18,2))
              / NULLIF(LAG(net_rev,12) OVER (ORDER BY ym), 0) * 100 - 100, 2) AS yoy_percent
    FROM monthly
    ORDER BY ym;
    GO