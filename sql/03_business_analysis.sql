# Product Analysis
SELECT 
	p.product,
    p.series,
    p.sales_price,
    COUNT(*) AS total_opportunities,
    SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
SUM(
	CASE
		WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_deals,
ROUND(
	100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / COUNT(*), 2) 
AS won_rate_pct,
SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS closed_won_value,
ROUND(
	AVG(
		CASE 
			WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE NULL END), 2) 
AS avg_won_deal_size
FROM sales_pipeline_clean sp
LEFT JOIN products p
	ON sp.product = p.product
GROUP BY 
	p.product,
    p.series,
    p.sales_price
ORDER BY closed_won_value DESC;

# Regional Analysis
SELECT 
    st.regional_office,
    COUNT(*) AS total_opportunities,
    SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
SUM(
	CASE
		WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_deals,
ROUND(
	100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / COUNT(*), 2) 
AS won_rate_pct,
SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS closed_won_value,
ROUND(
	AVG(
		CASE 
			WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE NULL END), 2) 
AS avg_won_deal_size
FROM sales_pipeline_clean sp
LEFT JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
GROUP BY
    st.regional_office
ORDER BY closed_won_value DESC;

WITH regional_performance AS (
	SELECT 
    st.regional_office,
    COUNT(*) AS total_opportunities,
    SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
SUM(
	CASE
		WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_deals,
ROUND(
	100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / COUNT(*), 2) 
AS won_rate_pct,
SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS closed_won_value,
ROUND(
	AVG(
		CASE 
			WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE NULL END), 2) 
AS avg_won_deal_size
FROM sales_pipeline_clean sp
LEFT JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
GROUP BY
    st.regional_office )
SELECT 
	*,
    RANK() OVER(
		ORDER BY closed_won_value DESC)
        AS revenue_rank,
        
	RANK() OVER (
    ORDER BY won_rate_pct DESC
) AS won_rate_rank

FROM regional_performance;

# Sales reps performance
WITH rep_performance AS (
	SELECT 
    st.sales_agent,
    st.manager,
    st.regional_office,
    COUNT(*) AS total_opportunities,
    SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
SUM(
	CASE
		WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_deals,
ROUND(
	100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / COUNT(*), 2) 
AS won_rate_pct,
SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS closed_won_value,
ROUND(
	AVG(
		CASE 
			WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE NULL END), 2) 
AS avg_won_deal_size
FROM sales_pipeline_clean sp
JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
GROUP BY 
	st.sales_agent,
    st.manager,
    st.regional_office
    )
    
SELECT 
	*,
    RANK() OVER(
		ORDER BY closed_won_value DESC)
        AS revenue_rank,
	
    RANK() OVER(
		ORDER BY won_rate_pct DESC)
        AS won_rate_rank

FROM rep_performance

ORDER BY revenue_rank;

SELECT
    st.sales_agent,
    st.manager,
    st.regional_office
FROM sales_teams st
LEFT JOIN sales_pipeline_clean sp
    ON st.sales_agent = sp.sales_agent
WHERE sp.sales_agent IS NULL;

-- 35 registered agents, but only 30 had recorded opportunities in the analyzed pipeline.

# Within region comparison
WITH rep_performance AS (
	SELECT 
    st.sales_agent,
    st.manager,
    st.regional_office,
    COUNT(*) AS total_opportunities,
    SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
SUM(
	CASE
		WHEN sp.deal_stage = 'Lost' THEN 1 ELSE 0 END) AS lost_deals,
ROUND(
	100.0 * SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) / COUNT(*), 2) 
AS won_rate_pct,
SUM(
	CASE 
		WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS closed_won_value,
ROUND(
	AVG(
		CASE 
			WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE NULL END), 2) 
AS avg_won_deal_size
FROM sales_pipeline_clean sp
JOIN sales_teams st
	ON sp.sales_agent = st.sales_agent
GROUP BY 
	st.sales_agent,
    st.manager,
    st.regional_office
    ),

rep_benchmark AS(
SELECT *,
    ROUND(
		AVG(won_rate_pct) OVER(
			PARTITION BY regional_office
            ),
            2
		) AS regional_avg_won_rate,
	ROUND(
		won_rate_pct - AVG(won_rate_pct) OVER(
			PARTITION BY regional_office),
            2) AS won_rate_vs_region,
	
    RANK() OVER(
		PARTITION BY regional_office
        ORDER BY closed_won_value DESC)
        AS revenue_rank_within_region

FROM rep_performance
)

SELECT
	*,
    CASE 
		WHEN won_rate_vs_region >= 3
        THEN "Above Regional Average"
        WHEN won_rate_vs_region <= -3
        THEN "Below Regional Average"
        ELSE "Near Regional Average"
	END AS conversion_performance
FROM rep_benchmark
ORDER BY 
	regional_office,
    revenue_rank_within_region;

# Consumer segment analysis
SELECT 
	a.sector,
    COUNT(*) AS total_opportunities,
    SUM(
        CASE
            WHEN sp.deal_stage = 'Won' THEN 1
            ELSE 0
        END
    ) AS won_deals,

    SUM(
        CASE
            WHEN sp.deal_stage = 'Lost' THEN 1
            ELSE 0
        END
    ) AS lost_deals,

    ROUND(
        100.0 *
        SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS won_rate_pct,

    SUM(
        CASE
            WHEN sp.deal_stage = 'Won' THEN sp.close_value
            ELSE 0
        END
    ) AS closed_won_value,

    ROUND(
        AVG(
            CASE
                WHEN sp.deal_stage = 'Won' THEN sp.close_value
                ELSE NULL
            END
        ),
        2
    ) AS avg_won_deal_size

FROM sales_pipeline_clean sp
JOIN accounts a
	ON sp.account = a.account
GROUP BY a.sector
ORDER BY closed_won_value DESC;
            
# Sales cycle analysis
SELECT 
	ROUND(
		AVG(DATEDIFF(STR_TO_DATE(close_date, '%Y-%m-%d'), 
					STR_TO_DATE(engage_date, '%Y-%m-%d')
                    )), 2) AS average_sales_cycle_days
FROM sales_pipeline_clean sp;

SELECT 
	deal_stage,
    ROUND(
		AVG(DATEDIFF(STR_TO_DATE(close_date, '%Y-%m-%d'), 
					STR_TO_DATE(engage_date, '%Y-%m-%d')
                    )), 2) AS average_sales_cycle_days
FROM sales_pipeline_clean sp
GROUP BY deal_stage;

SELECT 
	product,
    COUNT(*) AS total_opportunities,
    ROUND(
		AVG(DATEDIFF(STR_TO_DATE(close_date, '%Y-%m-%d'), 
					STR_TO_DATE(engage_date, '%Y-%m-%d')
                    )), 2) AS average_sales_cycle_days
FROM sales_pipeline_clean sp
GROUP BY product
ORDER BY average_sales_cycle_days DESC;
                    
