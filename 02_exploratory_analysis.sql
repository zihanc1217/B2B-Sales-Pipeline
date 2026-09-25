# Baseline KPIs
SELECT COUNT(*) AS total_opportunities,
SUM(
	CASE 
		WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
SUM(
	CASE
		WHEN deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_deals,
ROUND(
	100.0 * SUM(CASE WHEN deal_stage = 'Won' THEN 1 ELSE 0 END) / COUNT(*), 2) 
AS won_rate_pct,
SUM(
	CASE 
		WHEN deal_stage = 'Won' THEN close_value ELSE 0 END) AS total_revenue,
ROUND(
	AVG(
		CASE 
			WHEN deal_stage = 'Won' THEN close_value ELSE NULL END), 2) 
AS avg_won_deal_size
FROM sales_pipeline_clean;

-- Baseline sales performance:
-- 6,711 total opportunities
-- 4,238 won deals and 2,473 lost deals
-- Overall win rate: 63.15%
-- Total closed-won value: $10,005,534
-- Average won deal size: $2,360.91

# Date
SELECT
	engage_date,
    STR_TO_DATE(engage_date, '%Y-%m-%d') AS engage_date_clean,
    close_date,
    STR_TO_DATE(close_date, '%Y-%m-%d') AS close_date_clean
FROM sales_pipeline_clean;

SELECT COUNT(*) AS invalid_sales_cycles
FROM sales_pipeline_clean
WHERE STR_TO_DATE(close_date, '%Y-%m-%d') <
	STR_TO_DATE(engage_date, '%Y-%m-%d');

        