SELECT 
	account,
    COUNT(*) AS record_count
FROM accounts
GROUP BY account
HAVING COUNT(*) > 1;
    
SELECT
	product,
    COUNT(*) AS record_count
FROM products
GROUP BY product
HAVING COUNT(*) > 1;

SELECT 
	sales_agent,
    COUNT(*) AS record_count
FROM sales_teams
GROUP BY sales_agent
HAVING COUNT(*) > 1;

SELECT 
	opportunity_id,
    COUNT(*) AS record_count
FROM sales_pipeline
GROUP BY opportunity_id
HAVING COUNT(*) > 1;

# Check distinct counts
SELECT 
	COUNT(*) As total_rows,
    COUNT(DISTINCT opportunity_id) AS unique_opportunities
FROM sales_pipeline;

# Check missing_values
SELECT
	SUM(CASE WHEN opportunity_id IS NULL OR TRIM(opportunity_id) = '' THEN 1 ELSE 0 END) AS 
Missing_opportunity_id,
	SUM(CASE WHEN sales_agent IS NULL OR TRIM(sales_agent) = '' THEN 1 ELSE 0 END) AS 
Missing_sales_agent,
	SUM(CASE WHEN product IS NULL OR TRIM(product) = '' THEN 1 ELSE 0 END) AS 
Missing_product,
	SUM(CASE WHEN account IS NULL OR TRIM(account) = '' THEN 1 ELSE 0 END) AS 
Missing_account,
	SUM(CASE WHEN deal_stage IS NULL OR TRIM(deal_stage) = '' THEN 1 ELSE 0 END) AS 
Missing_deal_stage,
	SUM(CASE WHEN engage_date IS NULL OR TRIM(engage_date) = '' THEN 1 ELSE 0 END) AS 
Missing_engage_date,
	SUM(CASE WHEN close_date IS NULL OR TRIM(close_date) = '' THEN 1 ELSE 0 END) AS 
Missing_close_date,
	SUM(CASE WHEN close_value IS NULL OR TRIm(close_value) = '' THEN 1 ELSE 0 END) AS 
Missing_close_value
FROM sales_pipeline;

SELECT 
	deal_stage,
    COUNT(*) AS deal_count
FROM sales_pipeline
GROUP BY deal_stage
ORDER BY deal_count DESC;

SELECT 
	opportunity_id,
    deal_stage,
    close_date,
    close_value
FROM sales_pipeline
ORDER BY deal_stage
LIMIT 50;

SELECT
	deal_stage,
    MIN(close_value) AS min_close_value,
    MAX(close_value) AS max_close_value,
    AVG(close_value) AS avg_close_value
FROM sales_pipeline
GROUP BY deal_stage;

-- All opportunities are closed: deal_stage contains only "Won" and "Lost".
-- Lost deals all have close_value = 0, while Won deals have positive close values.

# Relational integrity check
SELECT 
	COUNT(*) AS unmatched_sales_agent
FROM sales_pipeline sp
LEFT JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
WHERE st.sales_agent IS NULL;

SELECT COUNT(*) AS unmatched_products
FROM sales_pipeline sp
LEFT JOIN products p
	ON sp.product = p.product
WHERE p.product IS NULL;

SELECT COUNT(*) AS unmatched_accounts
FROM sales_pipeline sp
LEFT JOIN accounts a
    ON sp.account = a.account
WHERE a.account IS NULL;

SELECT 
	sp.product,
    COUNT(*) AS unmatched_product
FROM sales_pipeline sp
LEFT JOIN products p
	ON sp.product = p.product
WHERE p.product IS NULL
GROUP BY sp.product
ORDER BY unmatched_product DESC;

SELECT DISTINCT product
FROM products
ORDER BY product;

SELECT DISTINCT product
FROM sales_pipeline
ORDER BY product;

SELECT COUNT(*) AS unmatched_products_after_clean
FROM sales_pipeline sp
LEFT JOIN products p
	ON REPLACE(sp.product, ' ', '') = REPLACE(p.product, ' ', '')
WHERE p.product IS NULL;

SELECT DISTINCT 
	sp.product AS pipeline_product,
    p.product AS product_master
FROM sales_pipeline sp
LEFT JOIN products p
	ON REPLACE(sp.product, ' ', '') = REPLACE(p.product, ' ', '')
WHERE sp.product <> p.product;

CREATE VIEW sales_pipeline_clean AS 
SELECT 
	opportunity_id,
    sales_agent,
    CASE 
		WHEN product = 'GTXPro' THEN 'GTX Pro'
        ELSE product
	END AS product,
    account,
	deal_stage,
    engage_date,
    close_date,
    close_value
FROM sales_pipeline;

SELECT DISTINCT product
FROM sales_pipeline_clean
ORDER BY product;
    
SELECT COUNT(*) AS unmatched_product_count
FROM sales_pipeline_clean sp
LEFT JOIN products p
	ON sp.product = p.product
WHERE p.product IS NULL;

SELECT COUNT(*) AS joined_rows
FROM sales_pipeline_clean sp
JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
JOIN products p
	ON sp.product = p.product
JOIN accounts a
	ON sp.account = a.account;

-- Data quality issue identified:
-- 1,147 records used 'GTXPro' while the product master used 'GTX Pro'.
-- Created a cleaned view to standardize the product name without modifying raw data.

    