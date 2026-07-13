# E-commerce Sales & Customer Analytics
A SQL analytics project analyzing sales, customer behavior, and product returns for an online store — from raw data to query-driven business insights.

## Objective
An e-commerce business wants to understand how it's actually performing: who its best customers are, whether revenue is growing, which products are underperforming due to returns, and whether customers come back after their first purchase.

This project answers:
1. Who are the highest-value customers, and how concentrated is revenue among them?
2. Is monthly revenue growing, shrinking, or volatile — and by how much?
3. Which products get returned most often, relative to how often they're bought?
4. Which products drive the most revenue — and is that the same as the best sellers by volume?
5. Do customers come back and buy again within 90 days of their first order?
6. Does average order value differ meaningfully by city?

## Dataset
460 synthetic orders across 110 customers and 18 products (Jan–Dec 2024), spread across 5 relational tables: `customers`, `products`, `orders`, `order_items`, and `returns`. Built to reflect realistic e-commerce patterns — skewed customer spend, variable return rates, and fluctuating monthly order volume.

> Synthetic data was used since this is a practice/portfolio project. Patterns (spend concentration, return variability, order timing) are modeled to behave like real e-commerce data, not purely randomly generated.

> Dataset generated with the help of Claude (Anthropic).

## Project Workflow
1. **Schema Design** — designed 5 relational tables covering customers, products, orders, order items, and returns
2. **Data Generation (SQL)** — used Claude to generate the dataset directly as `CREATE TABLE` + `INSERT` statements (`ecommerce_1500.sql`), run in [sqliteonline.com](https://sqliteonline.com/)
3. **Analysis Queries (SQL)** — wrote and ran 6 queries covering multi-table joins, CTEs, and window functions (`NTILE`, `LAG`, `RANK`)
4. **Result Export** — exported each query's output as CSV (`results_*.csv`)
5. **Visualization (Python)** — used pandas and matplotlib in Google Colab to turn each result into a chart (`generate_charts_simple.py`)
6. **Insights** — translated each result into a plain-English takeaway (`FINDINGS.md`)

## Key Findings
| Metric | Value |
|---|---|
| Top customer by spend | Isha Nair, Jaipur — ₹2.54L |
| Revenue concentration | Top 2 customers outspend the rest of the top 10 combined |
| Highest month-over-month revenue swing | +44.5% (April), -32.3% (June) |
| Highest return-rate product | Coffee Mug Set — 18.5% |
| Top product by revenue | Smartwatch — ₹2.52L (price-driven, not the top seller by units) |
| Best 90-day repeat-purchase cohort | February 2024 — 63.6% repeat rate |
| AOV range across cities | ₹3,213 (Delhi) to ₹3,884 (Pune) — fairly tight, ~20% spread |

Full write-up: `FINDINGS.md`

## Charts

5 charts covering revenue trend, top products, return rates, AOV by city, and cohort repeat rate — all in the `charts/` folder and embedded inline in `FINDINGS.md`.

## Tools Used
- **Claude** — generated the synthetic dataset (SQL `CREATE TABLE`/`INSERT` statements)
- **sqliteonline.com** — building the database (`CREATE TABLE`/`INSERT`) and running all analysis queries
- **Python** (pandas, matplotlib) via **Google Colab** — turning query results into charts
- **SQL** — multi-table joins, CTEs, window functions (`NTILE`, `LAG`, `RANK`), date functions, correlated subqueries

## Repository Structure
```
├── ecommerce_1500.sql          → builds all 5 tables + loads data
├── analysis_queries.sql        → the 6 analysis queries
├── results/                    → query outputs (CSV)
├── generate_charts_simple.py   → turns query results into charts
├── charts/                     → chart images (PNG)
└── FINDINGS.md                 → plain-English insights write-up
```
