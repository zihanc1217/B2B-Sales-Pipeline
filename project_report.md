# B2B Sales Pipeline & Performance Analysis

## Executive summary

This project analyzed **6,711 closed B2B sales opportunities** from four related CRM datasets using MySQL and Tableau. The observed win rate was **63.15%** (4,238 won deals), with **$10,005,534** in closed-won value, a **$2,360.91** average won deal, and a **47.99-day** average sales cycle. A data-quality check identified **1,147** opportunity records whose product key (`GTXPro`) did not match the product master (`GTX Pro`). Standardizing that name in a cleaned SQL view preserved those records for the analysis.

Performance varied across products, regions, sectors, and reps. The results show why opportunity volume, conversion, and deal size should be considered together: leaders by closed-won value were not consistently leaders by win rate. The project concludes with an interactive Tableau dashboard for exploring those differences. The findings are descriptive and do not establish causal drivers.

## Business question and methodology

The main question was: **Which parts of the pipeline contribute the most closed-won value, and how do conversion, deal size, and sales-cycle length differ across segments?**

The source is Maven Analytics' [CRM Sales Opportunities dataset](https://mavenanalytics.io/data-playground/crm-sales-opportunities), representing a fictitious B2B hardware company. Four CSVs were imported into MySQL: `sales_pipeline` (opportunity-level fact table), `products`, `accounts`, and `sales_teams`. Quality checks covered unique identifiers, missing fields, stage composition, and whether pipeline keys matched the dimension tables.

After the product-name correction, `sales_pipeline_clean` was joined to the other three tables in `sales_analysis_view`. SQL aggregations produced overall and segment metrics. CTEs and `RANK()` window functions supported rankings; `PARTITION BY` supported comparisons within regions. `STR_TO_DATE()` converted imported date text and `DATEDIFF()` calculated days from engagement to close. The analysis view was exported to CSV and used in the [Tableau Public dashboard](https://public.tableau.com/app/profile/zihan.chen5501/viz/B2BSalesPipeline/B2BSalesPipelinePerformanceDashboard) for five KPI cards, three bar charts, a sales-rep scatter plot, and regional-office/sector/product filters.

## Findings

| Area | Observed result | Interpretation |
| --- | --- | --- |
| Overall | 6,711 opportunities; 4,238 won; 63.15% win rate; $10.01M closed-won value | Baseline for comparing segments; all analyzed opportunities had a final Won/Lost stage. |
| Product | `GTX Pro`: ~$3.51M closed-won value, 1,147 opportunities, 63.56% win rate, $4,815.61 average won deal | Highest total value did not require the highest win rate; its observed deal size and volume were substantial. |
| Product volume | `GTX Basic`: 1,436 opportunities and 915 wins, but ~$499K closed-won value | High volume can coexist with low total value when average won deal size is small ($545.64). |
| Region | West: ~$3.57M and 63.94% win rate; Central: 2,604 opportunities and 62.56% win rate | West led value and conversion while Central led opportunity volume. Product and account mix were not adjusted. |
| Sector | Retail: ~$1.87M from 1,267 opportunities; Marketing: 64.85% win rate from 623 opportunities | Retail led value and volume; Marketing led conversion among sectors reported in the project. |
| Sales rep | Darcel Schlecht: ~$1.15M from 553 opportunities, 63.11% win rate; Hayden Neloms: 70.39% win rate | Rep value and conversion rankings tell different stories, so either ranking alone is incomplete. |
| Sales cycle | Overall 47.99 days; Won 51.78 days; Lost 41.48 days | Won opportunities took longer on average in this dataset; the difference is an association. |

## Recommendations

1. **Review the mix behind high-value segments.** Compare won-deal size, opportunity volume, and product/account mix for `GTX Pro` and West before deciding whether their patterns are transferable.
2. **Investigate conversion opportunities where volume is already high.** Central handled the most opportunities but had the lowest reported regional win rate. Examine deal mix, assignment, and stage histories before proposing training or process changes.
3. **Use paired metrics for rep coaching and allocation discussions.** Review win rate alongside opportunity count and average won deal size. High total value can reflect a large pipeline, while a high win rate can reflect a small one.
4. **Maintain the product-key validation.** Re-run unmatched-key checks when new CRM exports arrive so product analyses do not silently drop rows.

These are investigation priorities, not quantified forecasts of incremental value.

## Limitations

- The Maven dataset represents a **fictitious company**; results demonstrate analysis methods rather than a live business outcome.
- The analyzed pipeline contains only `Won` and `Lost` records. It cannot describe open-pipeline health or forecasting accuracy.
- Segment and rep comparisons are unadjusted. Differences in product mix, account mix, territory, tenure, or lead quality may explain part of the observed gaps.
- `close_value` is CRM closed-won value, not audited recognized revenue. The dashboard uses an exported CSV snapshot, so it does not refresh directly from MySQL.
- This report was prepared from the completed project conversation. The original CSVs, SQL files, and workbook were not available in this writing workspace for an independent rerun.

## Appendix: technical notes

**Grain and joins.** `sales_pipeline` has one row per opportunity. The cleaned `product`, `sales_agent`, and `account` fields join respectively to `products`, `sales_teams`, and `accounts`. Before cleaning, 1,147 product joins were unmatched; the account and sales-agent checks found zero unmatched pipeline records. After cleaning, the final analysis view retained 6,711 opportunity rows.

**Metric definitions.** Win rate = Won opportunities ÷ all analyzed opportunities. Closed-won value = sum of `close_value` where `deal_stage = 'Won'`. Average won deal size = mean `close_value` among Won opportunities. Sales cycle = `DATEDIFF(close_date, engage_date)` after `STR_TO_DATE()` conversion, averaged over records with valid dates.

**Implementation.** The project used MySQL `JOIN`, `GROUP BY`, `CASE WHEN`, CTEs, `RANK() OVER`, `PARTITION BY`, `DATEDIFF()`, and `STR_TO_DATE()`. Tableau displays five KPIs, product/region/sector bars, and a sales-rep scatter plot with reference lines and linked filters.

**Source:** [Maven Analytics, CRM Sales Opportunities](https://mavenanalytics.io/data-playground/crm-sales-opportunities).
