# Part 3: Data Warehouse and Analytics

This section implements a star-schema data warehouse to analyze historical sales data.

## Objectives

- Design a dimensional model for analytical workloads
- Load realistic dimension and fact data
- Write OLAP-style analytical queries

## What Was Implemented

- Star schema with fact and dimension tables
- Time, product, and customer dimensions
- Fact table at transaction line-item grain
- Analytical queries for:
  - Time-based drill-down
  - Top product performance
  - Customer value segmentation

## Files

- `star_schema_design.md` – Schema design and rationale
- `warehouse_schema.sql` – Data warehouse table creation
- `warehouse_data.sql` – Dimension and fact data inserts
- `analytics_queries.sql` – OLAP queries

## Database Used

- MySQL 8.0.44 (Data Warehouse)
