CREATE DATABASE crm_sales_analysis;

USE crm_sales_analysis;

SHOW DATABASES;

SELECT DATABASE();

SHOW TABLES;

SELECT * FROM accounts
LIMIT 10;

DESCRIBE accounts;

SELECT COUNT(*) AS total_rows
FROM accounts;

SELECT * FROM products
LIMIT 10;

DESCRIBE products;

SELECT COUNT(*) AS total_rows
FROM products;

SELECT * FROM sales_teams
LIMIT 10;

DESCRIBE sales_teams;

SELECT COUNT(*) AS total_rows
FROM sales_teams;

SELECT *
FROM sales_pipeline
LIMIT 10;

DESCRIBE sales_pipeline;

SELECT COUNT(*) AS total_rows
FROM sales_pipeline;