# FlexiMart Data Architecture Project

Student Name: Akriti Sharma  
Student ID: 25071909  
Email: dr.akritis09@gmail.com  
Date: 06/01/2026

--------------------------------------------------

# Project Overview

This project implements an end-to-end data architecture for FlexiMart, an e-commerce platform. 
It includes building an ETL pipeline to clean and load raw CSV data into MySQL, evaluating MongoDB 
for handling flexible product data and designing a star-schema data warehouse to support 
analytical and reporting use cases.

The project focuses on practical data engineering tasks such as handling real-world data quality 
issues, writing analytical SQL queries, and modeling data for business intelligence.

--------------------------------------------------

# Repository Structure
```
customers_raw.csv  
products_raw.csv  
sales_raw.csv  

part1-database-etl/
- etl_pipeline.py
- business_queries.sql
- schema_documentation.md
- data_quality_report.txt
- requirements.txt
- README.md

part2-nosql/
- mongodb_operations.js
- nosql_analysis.md
- products_catalog.json
- README.md

part3-datawarehouse/
- star_schema_design.md
- warehouse_schema.sql
- warehouse_data.sql
- analytics_queries.sql
- README.md

venv/  
.gitignore  
README.md  
```
--------------------------------------------------

# Technologies Used

- Python 3.13.9
- MySQL 8.0.44
- MongoDB 8.2.3
- pandas, mysql-connector-python
- VS Code, MySQL Workbench, MongoDB Compass

--------------------------------------------------

# Setup Instructions

The project was developed and tested on Windows using PowerShell, MySQL CLI and mongosh.

MySQL Setup

Create databases:
```
mysql -u root -p -e "CREATE DATABASE fleximart;"
mysql -u root -p -e "CREATE DATABASE fleximart_dw;"
```
Run ETL pipeline:
```
python part1-database-etl/etl_pipeline.py
```
Run business queries:
```
Get-Content part1-database-etl/business_queries.sql | mysql -u root -p fleximart
```
Run data warehouse scripts:
```
Get-Content part3-datawarehouse/warehouse_schema.sql | mysql -u root -p fleximart_dw
Get-Content part3-datawarehouse/warehouse_data.sql | mysql -u root -p fleximart_dw
Get-Content part3-datawarehouse/analytics_queries.sql | mysql -u root -p fleximart_dw
```
--------------------------------------------------

MongoDB Setup
```
Import products_catalog.json using MongoDB Compass.
```
Run MongoDB operations:
```
mongosh < part2-nosql/mongodb_operations.js
```
--------------------------------------------------

# Key Learnings

- Handling real-world data quality issues in ETL pipelines
- Designing normalized relational schemas and writing analytical SQL
- Understanding when NoSQL databases are more suitable than relational databases
- Building and querying a star-schema data warehouse for business reporting

--------------------------------------------------

# Challenges Faced

1. Handling inconsistent and ambiguous date formats in raw data

    The raw CSV files contained multiple date formats such as YYYY-MM-DD, DD/MM/YYYY and MM-DD-YYYY, sometimes mixed within the same column. This caused parsing warnings and potential misinterpretation of dates during ETL.

    Solution:
    A custom date-cleaning function was implemented in the ETL pipeline that explicitly attempted known date formats before falling back to safe parsing. Invalid or unparseable dates were converted to NULL, ensuring consistent DATE values were loaded into MySQL without silent errors.

2. Managing missing keys and duplicates in transactional data

    The sales dataset included duplicate transactions as well as records with missing customer or product IDs. Loading this data directly would have caused foreign key violations and incorrect analytics.

    Solution:
    Duplicate transactions were removed during transformation, and records with missing foreign keys were excluded before loading. This ensured referential integrity between orders, customers, and products while keeping the dataset analytically reliable.

3. Executing SQL scripts correctly in a Windows PowerShell environment

    Standard SQL redirection syntax (< file.sql) caused errors in PowerShell, which initially prevented scripts from running as expected.

    Solution:
    The execution method was adjusted to use Get-Content file.sql | mysql, which is compatible with PowerShell. This approach allowed all SQL scripts to run reliably on Windows without modifying MySQL or shell configurations.
