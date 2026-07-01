-- Database Setup
CREATE DATABASE IF NOT EXISTS superstore_db;
USE DATABASE superstore_db;
CREATE SCHEMA IF NOT EXISTS superstore_schema;
USE SCHEMA superstore_schema;

-- Storage Integration
CREATE OR REPLACE STORAGE INTEGRATION s3_superstore_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::880247664720:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-superstore-data/');

-- Stage Creation
CREATE OR REPLACE STAGE superstore_stage
  URL = 's3://snowflake-superstore-data/'
  STORAGE_INTEGRATION = s3_superstore_integration
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

-- Table Creation
CREATE OR REPLACE TABLE superstore (
    Row_ID INT, Order_ID STRING, Order_Date DATE, Ship_Date DATE,
    Ship_Mode STRING, Customer_ID STRING, Customer_Name STRING,
    Segment STRING, Country STRING, City STRING, State STRING,
    Postal_Code STRING, Region STRING, Product_ID STRING,
    Category STRING, Sub_Category STRING, Product_Name STRING,
    Sales FLOAT, Quantity INT, Discount FLOAT, Profit FLOAT
);

-- Load Data
COPY INTO superstore
FROM @superstore_stage/
FILES = ('Sample - Superstore.csv')
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';

-- Analysis Queries
-- 1. Total Sales, Profit, Orders
SELECT 
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS Profit_Margin_Pct
FROM superstore;

-- 2. Sales by Category
SELECT Category, ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore GROUP BY Category ORDER BY Total_Sales DESC;

-- 3. Top 5 States by Sales
SELECT State, ROUND(SUM(Sales), 2) AS Total_Sales
FROM superstore GROUP BY State ORDER BY Total_Sales DESC LIMIT 5;

-- 4. Sales by Segment
SELECT Segment, ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore GROUP BY Segment ORDER BY Total_Sales DESC;

-- 5. Most Profitable Sub-Categories
SELECT Sub_Category, ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore GROUP BY Sub_Category ORDER BY Total_Profit DESC LIMIT 5;

-- 6. Loss Making Sub-Categories
SELECT Sub_Category, ROUND(SUM(Profit), 2) AS Total_Profit
FROM superstore GROUP BY Sub_Category ORDER BY Total_Profit ASC LIMIT 5;