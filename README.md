# Zagimore Retail SQL ETL Project

## Overview
This project demonstrates an ETL (Extract, Transform, Load) workflow using the Zagimore retail database. It extracts transactional data, transforms it into analysis-ready tables, and generates summary queries to support business reporting and decision-making.

## Tools
- MySQL
- SQL
- MySQL Workbench / VS Code
- Microsoft Excel (validation/reporting)

## Objectives
- Extract customer, order, and product data from relational tables
- Clean and transform data using joins and aggregations
- Create summary tables to support reporting
- Generate analytical queries for business insights

## Folder Structure
zagimore-sql-etl-project/
│
├── zagimore_etl.sql
├── transform.sql
├── load.sql
├── analysis_queries.sql
└── README.md

## ETL Workflow

### Extract
Pull raw data from tables such as:
- customers
- orders
- order_items
- products

### Transform
- Clean and filter records
- Join tables to create unified datasets
- Aggregate metrics (revenue, order frequency, spend per customer)

### Load
Create derived tables for reporting (examples):
- customer_summary
- sales_summary
- product_performance

## Example Query
```sql
SELECT customer_id,
       COUNT(order_id) AS total_orders,
       SUM(order_total) AS total_spent
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC;

Author

Rumbidzai Mushamba
M.S. Applied Data Science, Clarkson University (Expected May 2026)
