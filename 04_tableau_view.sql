CREATE OR REPLACE VIEW sales_analysis_view AS 

SELECT 
	sp.opportunity_id,
    
    -- Sales team
    sp.sales_agent,
    st.manager,
    st.regional_office,
    
    -- Product
    sp.product,
    p.series,
    p.sales_price,
    
    -- Customer / Account
    sp.account,
    a.sector,
    a.year_established,
    a.revenue AS account_revenue,
    a.employees,
    a.office_location,

    -- Deal
    sp.deal_stage,

    STR_TO_DATE(
        sp.engage_date,
        '%Y-%m-%d'
    ) AS engage_date,

    STR_TO_DATE(
        sp.close_date,
        '%Y-%m-%d'
    ) AS close_date,

    DATEDIFF(
        STR_TO_DATE(sp.close_date, '%Y-%m-%d'),
        STR_TO_DATE(sp.engage_date, '%Y-%m-%d')
    ) AS sales_cycle_days,

    sp.close_value,

    CASE
        WHEN sp.deal_stage = 'Won' THEN 1
        ELSE 0
    END AS won_flag
FROM sales_pipeline_clean sp
JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
JOIN products p
    ON sp.product = p.product
JOIN accounts a
    ON sp.account = a.account;
    
SELECT COUNT(*) FROM sales_analysis_view;

SELECT *
FROM sales_analysis_view;

CREATE TABLE sales_analysis_export AS
SELECT *
FROM sales_analysis_view;

DROP TABLE IF EXISTS sales_analysis_export;

CREATE TABLE sales_analysis_view_full AS 
SELECT * 
FROM sales_analysis_view;

SELECT sector 
FROM sales_analysis_view_full;

SELECT * FROM sales_analysis_view_full;