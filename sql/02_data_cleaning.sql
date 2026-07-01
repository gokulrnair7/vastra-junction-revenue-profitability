/* 02_data_cleaning |  Vastra Junction - Revenue & Profitability
   PURPOSE: turn dirty vastra_junction_raw_sales into a trusted layer (vastra_junction_clean_sales).
   Handles, explicitly: messy category labels, NULL city/payment,
   exact duplicate rows. Returns are KEPT (they are real data) */

/* STEP 1: profiling the messy data first */

-- messy category labels:
SELECT category, COUNT(*) AS messy_category FROM dbo.vastra_junction_raw_sales GROUP BY category ORDER BY category;
-- missing values:
SELECT
      SUM(CASE WHEN city IS NULL OR city = '' THEN 1 ELSE 0 END) AS missing_city,
      SUM(CASE WHEN payment_mode IS NULL OR payment_mode = '' THEN 1 ELSE 0 END) AS missing_pay
FROM dbo.vastra_junction_raw_sales;
-- sales vs returns:
        SELECT order_type, COUNT(*) AS transaction_count FROM dbo.vastra_junction_raw_sales GROUP BY order_type;
GO

/* STEP 2: building the trusted view */

IF OBJECT_ID('dbo.vastra_junction_clean_sales', 'V') IS NOT NULL
    DROP VIEW dbo.vastra_junction_clean_sales;
GO

CREATE VIEW dbo.vastra_junction_clean_sales AS
WITH deduped AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id, order_date, order_type, customer_id, channel,
                            city, region, category, sub_category, sku_id, product,
                            quantity, unit_price, discount_pct, net_sales,
                            gst_amount, cogs, gross_profit, payment_mode
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM dbo.vastra_junction_raw_sales
)
SELECT
    order_id, order_date, order_type, customer_id, channel,
    CASE
        WHEN LOWER(REPLACE(category,' ','')) LIKE 'mens%'  THEN 'Menswear'
        WHEN LOWER(REPLACE(category,' ','')) LIKE 'women%' THEN 'Womenswear'
        WHEN LOWER(REPLACE(category,' ','')) LIKE 'kids%'  THEN 'Kidswear'
        WHEN LOWER(REPLACE(category,' ','')) LIKE 'foot%'  THEN 'Footwear'
        ELSE 'Accessories'
    END AS category,
        sub_category, sku_id, product,
        ISNULL(NULLIF(city, ''), 'Unknown') AS city,
        region,
        ISNULL(NULLIF(payment_mode, ''), 'Unknown') AS payment_mode,
        quantity, unit_price, discount_pct,
        net_sales, gst_amount, cogs, gross_profit
FROM deduped
WHERE rn = 1;
GO

/* STEP 3: confirming the clean layer */

SELECT COUNT(*) AS clean_rows,
       COUNT(DISTINCT category) AS categories,
       ROUND(SUM(net_sales), 0)    AS net_revenue,
       ROUND(SUM(gross_profit), 0) AS gross_profit,
       ROUND(CAST(SUM(gross_profit) AS DECIMAL(18,2)) / NULLIF(SUM(net_sales),0) * 100, 2) AS blended_margin
FROM dbo.vastra_junction_clean_sales;
GO 