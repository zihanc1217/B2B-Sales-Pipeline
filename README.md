# B2B Sales Pipeline & Performance Analysis

**MySQL · Tableau · 6,711 B2B opportunities**

This project combines four CRM datasets to evaluate sales outcomes across products, regional offices, customer sectors, and sales representatives. I checked the relationships between tables, corrected a product-key mismatch, analyzed conversion and closed-won value in MySQL, and built an interactive Tableau dashboard.

**[Explore the interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/zihan.chen5501/viz/B2BSalesPipeline/B2BSalesPipelinePerformanceDashboard)**

![B2B Sales Pipeline Performance Dashboard with five KPIs and product, regional, sector, and sales-rep charts](images/dashboard.png)

## Business problem

Which parts of a B2B sales pipeline contribute the most closed-won value? A value ranking alone cannot show whether a result is associated with more opportunities, a higher win rate, or larger won deals. This analysis compares all three measures and examines sales-cycle length to give sales leaders a clearer basis for follow-up questions.

## Data and relationships

The source is Maven Analytics' [CRM Sales Opportunities dataset](https://mavenanalytics.io/data-playground/crm-sales-opportunities), describing a fictitious computer-hardware company. The four source files are available in [`dataset/`](dataset/), alongside a [data dictionary](dataset/data_dictionary.csv) and the [Tableau-ready export](dataset/sales_analysis_view.csv).

| Table | Grain | Relationship to `sales_pipeline` |
| --- | --- | --- |
| [`sales_pipeline.csv`](dataset/sales_pipeline.csv) | One opportunity | Fact table with deal stage, value, dates, product, account, and sales agent |
| [`products.csv`](dataset/products.csv) | One product | Join on `product` for series and sales price |
| [`accounts.csv`](dataset/accounts.csv) | One account | Join on `account` for sector and account attributes |
| [`sales_teams.csv`](dataset/sales_teams.csv) | One sales agent | Join on `sales_agent` for manager and regional office |

All **6,711** analyzed opportunities have a final `Won` or `Lost` stage. This is a closed-deal analysis, not a forecast of an open pipeline.

## Workflow and data cleaning

1. Imported the four CSVs into MySQL and inspected their fields and row counts.
2. Checked key uniqueness, missing values, deal stages, and whether pipeline records matched the product, account, and sales-team tables.
3. Found **1,147** pipeline records with `product = 'GTXPro'` that did not match `GTX Pro` in the product master. A `CASE WHEN` rule in `sales_pipeline_clean` standardized the name while preserving the raw table. The corrected product join matched, and the final analysis view retained **6,711 rows**.
4. Calculated baseline and segment metrics; used CTEs, `RANK()` and `PARTITION BY` for ranking and within-region rep comparisons. Converted text dates with `STR_TO_DATE()` and measured elapsed days with `DATEDIFF()`.
5. Joined the cleaned opportunity data to the other three tables in `sales_analysis_view`, exported it to CSV, and built the Tableau dashboard.

The key correction matters because an inner join on the original product names would have excluded the 1,147 affected opportunities from downstream analysis.

## Core metrics

| Metric | Definition | Result |
| --- | --- | ---: |
| Total opportunities | Count of analyzed opportunities | 6,711 |
| Won deals | Opportunities with `deal_stage = 'Won'` | 4,238 |
| Win rate | Won deals ÷ total opportunities | 63.15% |
| Closed-won value | Sum of `close_value` for won deals | $10,005,534 |
| Average won deal size | Average `close_value` among won deals | $2,360.91 |
| Average sales cycle | Average days from engagement to close | 47.99 days |

“Closed-won value” is the CRM deal-value measure; it should not be read as audited revenue.

## Findings

- **Product:** `GTX Pro` led closed-won value at about **$3.51M** across **1,147** opportunities, with a **63.56%** win rate. Its average won deal was **$4,815.61**. `GTX Basic` generated more opportunities (**1,436**) and wins (**915**) but about **$499K** in closed-won value, with a much smaller **$545.64** average won deal.
- **Region:** West led both closed-won value (about **$3.57M**) and win rate (**63.94%**). Central handled the most opportunities (**2,604**) but had a lower **62.56%** win rate. These are descriptive differences; the analysis does not adjust for territory, product, or account mix.
- **Sector:** Retail generated the highest closed-won value (about **$1.87M**) and had **1,267** opportunities. Marketing had the highest reported sector win rate (**64.85%**) across **623** opportunities but less total value (about **$922K**).
- **Sales reps:** Darcel Schlecht generated about **$1.15M** in closed-won value from **553** opportunities, while his **63.11%** win rate was not the highest. Rep value and conversion rankings therefore answer different questions.
- **Sales cycle:** Deals averaged **47.99 days** from engagement to close. Won deals averaged **51.78 days** and lost deals **41.48 days**. This association does not show that longer cycles improve the chance of winning.

## Tableau dashboard

The [interactive dashboard](https://public.tableau.com/app/profile/zihan.chen5501/viz/B2BSalesPipeline/B2BSalesPipelinePerformanceDashboard) contains five KPI cards; product, regional-office, and sector bar charts; and a sales-rep scatter plot of win rate versus closed-won value with average reference lines. Regional-office, sector, and product filters support segment exploration. The workbook uses the exported [analysis view CSV](dataset/sales_analysis_view.csv) produced from MySQL.

## SQL files

The scripts in [`sql/`](sql/) document the actual analysis. They are query files, not a one-click automated ETL pipeline. Import the source CSVs before running queries that refer to their tables.

| File | What it covers |
| --- | --- |
| [`Database.sql`](sql/Database.sql) | Creates/selects the database and inspects the imported tables |
| [`01_data_quality.sql`](sql/01_data_quality.sql) | Uniqueness, missing-value and join checks; creates `sales_pipeline_clean` |
| [`02_exploratory_analysis.sql`](sql/02_exploratory_analysis.sql) | Baseline KPIs and date validation |
| [`03_business_analysis.sql`](sql/03_business_analysis.sql) | Product, region, sector, rep, within-region, and sales-cycle analysis |
| [`04_tableau_view.sql`](sql/04_tableau_view.sql) | Defines `sales_analysis_view` and includes export-related checks |

The work demonstrates MySQL `JOIN`, `GROUP BY`, `CASE WHEN`, CTEs, `RANK() OVER`, `PARTITION BY`, `STR_TO_DATE()`, `DATEDIFF()`, and referential-integrity checks, alongside Tableau dashboard design and business interpretation.

## Repository contents

```text
B2B-Sales-Pipeline-/
├── README.md
├── dataset/
│   ├── accounts.csv
│   ├── data_dictionary.csv
│   ├── products.csv
│   ├── sales_analysis_view.csv
│   ├── sales_pipeline.csv
│   └── sales_teams.csv
├── images/
│   └── dashboard.png
└── sql/
    ├── Database.sql
    ├── 01_data_quality.sql
    ├── 02_exploratory_analysis.sql
    ├── 03_business_analysis.sql
    └── 04_tableau_view.sql
```

**Source:** [Maven Analytics, CRM Sales Opportunities](https://mavenanalytics.io/data-playground/crm-sales-opportunities). This is a portfolio analysis of a fictitious business. The segment comparisons are descriptive; they do not establish causal effects.
