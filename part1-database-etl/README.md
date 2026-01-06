# Part 1: Database Design and ETL Pipeline

This section focuses on cleaning raw CSV data and loading it into a relational MySQL database using an ETL pipeline.

## Objectives

- Handle missing values, duplicates, and inconsistent formats
- Standardize phone numbers, categories, and dates
- Load clean data into a normalized database schema
- Answer business questions using SQL queries

## What Was Implemented

- Python-based ETL pipeline using pandas
- Data validation and transformation logic
- Auto-generated data quality report
- MySQL schema with proper keys and relationships
- Business queries using joins, aggregation, and filtering

## Files

- `etl_pipeline.py` – Extract, Transform, Load script
- `schema_documentation.md` – Entity descriptions and normalization (3NF)
- `business_queries.sql` – Customer, product, and sales analysis queries
- `data_quality_report.txt` – Summary of data issues handled
- `requirements.txt` – Python dependencies

## Database Used

- MySQL 8.0.44
