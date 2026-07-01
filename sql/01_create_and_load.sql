/* 01_create_and_load.sql   |   SQL Server (T-SQL)
   Vastra Junction - Revenue & Profitability Analysis
   PURPOSE: create the raw landing table and load the CSV as-is.
   Load it DIRTY - the cleaning in script 02 is part of the story. */


USE [VastraJunction]
GO
/* Object:  Table [dbo].[vastra_junction_raw_sales]    Script Date: 25-06-2026 12:37:15 */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[vastra_junction_raw_sales]
(
	[order_id] [nvarchar](50) NULL,
	[order_date] [date] NULL,
	[order_type] [nvarchar](50) NULL,
	[customer_id] [nvarchar](50) NULL,
	[channel] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[region] [nvarchar](50) NULL,
	[category] [nvarchar](50) NULL,
	[sub_category] [nvarchar](50) NULL,
	[sku_id] [nvarchar](50) NULL,
	[product] [nvarchar](50) NULL,
	[quantity] [int] NULL,
	[unit_price] [int] NULL,
	[discount_pct] [float] NULL,
	[gross_sales] [float] NULL,
	[discount_amount] [float] NULL,
	[net_sales] [float] NULL,
	[gst_rate] [float] NULL,
	[gst_amount] [float] NULL,
	[invoice_total] [float] NULL,
	[unit_cost] [int] NULL,
	[cogs] [int] NULL,
	[gross_profit] [float] NULL,
	[payment_mode] [nvarchar](50) NULL
) ON [PRIMARY]
GO


