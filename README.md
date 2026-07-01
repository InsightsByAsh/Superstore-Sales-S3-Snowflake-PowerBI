# 🛒 Superstore Sales Analytics
### End-to-End Cloud Data Pipeline | AWS S3 → Snowflake → Power BI

![Pipeline](https://img.shields.io/badge/Pipeline-AWS%20S3%20→%20Snowflake%20→%20PowerBI-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)
![Dataset](https://img.shields.io/badge/Dataset-9%2C627%20rows-orange?style=for-the-badge)
![Tool](https://img.shields.io/badge/Query-DirectQuery-blueviolet?style=for-the-badge)

---

## 📌 Project Overview

Built a production-style cloud analytics pipeline using **AWS S3** as raw data storage, **Snowflake** as the cloud data warehouse, and **Power BI** as the visualization layer — connected via **DirectQuery** for live data access.

This project simulates how real enterprise data teams move, store, and analyze data at scale — without a single local database.

---

## 🏗️ Architecture

```
Raw Data (CSV)
      │
      ▼
┌─────────────┐
│   AWS S3    │  ← Raw storage bucket: snowflake-superstore-data
│  (Storage)  │
└──────┬──────┘
       │  IAM Role + Storage Integration
       ▼
┌─────────────┐
│  Snowflake  │  ← Cloud warehouse: SUPERSTORE_DB
│ (Warehouse) │     COPY INTO → superstore table (9,627 rows)
└──────┬──────┘
       │  SQL Analysis (6 analytical queries)
       │  DirectQuery Connection
       ▼
┌─────────────┐
│   Power BI  │  ← Executive dashboard: KPIs + 5 visuals
│ (Dashboard) │
└─────────────┘
```

---

## 📊 Dashboard Preview

![Dashboard](dashboard_preview.png)

---

## 🔍 Key Insights

| Metric | Value |
|--------|-------|
| 📦 Total Orders | 4,895 |
| 💰 Total Sales | $2.19M |
| 📈 Total Profit | $269.93K |
| 📉 Profit Margin | 12.33% |

### Sales by Category
| Category | Sales | Profit |
|----------|-------|--------|
| Technology | $751K | $128K ✅ |
| Furniture | $722K | $19K ⚠️ |
| Office Supplies | $714K | $121K ✅ |

### Top 5 States by Sales
| Rank | State | Sales |
|------|-------|-------|
| 1 | California | $426K |
| 2 | New York | $301K |
| 3 | Texas | $162K |
| 4 | Washington | $132K |
| 5 | Pennsylvania | $113K |

### Profitability Analysis
| 🟢 Most Profitable | Profit | 🔴 Loss Making | Loss |
|---|---|---|---|
| Copiers | $55.5K | Tables | -$17.1K |
| Phones | $39.2K | Bookcases | -$3.4K |
| Paper | $33.3K | Supplies | -$1.1K |
| Accessories | $30.8K | Fasteners | +$0.9K |
| Binders | $30.7K | Machines | +$3.1K |

---

## ⚙️ Pipeline Setup — Step by Step

### Step 1 — Upload Raw Data to S3
- Created S3 bucket: `snowflake-superstore-data`
- Uploaded `Sample - Superstore.csv` (2.2 MB)

![S3 Bucket](s3_bucket.png)

### Step 2 — Configure Snowflake Storage Integration
```sql
-- Create storage integration (Snowflake ↔ AWS IAM)
CREATE OR REPLACE STORAGE INTEGRATION s3_superstore_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::880247664720:role/snowflake-s3-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-superstore-data/');

-- Get Snowflake IAM details to configure AWS trust policy
DESC INTEGRATION s3_superstore_integration;
```

### Step 3 — Create External Stage & Load Data
```sql
-- Create stage pointing to S3
CREATE OR REPLACE STAGE superstore_stage
  URL = 's3://snowflake-superstore-data/'
  STORAGE_INTEGRATION = s3_superstore_integration
  FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

-- Load data into Snowflake table
COPY INTO superstore
FROM @superstore_stage/
FILES = ('Sample - Superstore.csv')
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
ON_ERROR = 'CONTINUE';
```

### Step 4 — SQL Analysis in Snowflake

![Snowflake Queries](snowflake_queries..png)

See full queries → [`superstore_analysis.sql`](superstore_analysis.sql)

### Step 5 — Power BI DirectQuery Connection
- Connected Power BI to Snowflake via **DirectQuery** (live connection — not imported)
- Built executive dashboard with KPI cards, bar charts, donut chart
- Created DAX measure for Profit Margin %:
```dax
Profit Margin% = ROUND(SUM(SUPERSTORE[PROFIT]) / SUM(SUPERSTORE[SALES]) * 100, 2)
```

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Storage | AWS S3 | Raw data lake |
| IAM | AWS IAM Role | Secure cross-service auth |
| Warehouse | Snowflake | Cloud SQL + data loading |
| Analysis | Snowflake SQL | 6 analytical queries |
| Visualization | Power BI | Executive dashboard |
| Connection | DirectQuery | Live data — no import |

---

## 📁 Repository Structure

```
Superstore-Sales-S3-Snowflake-PowerBI/
│
├── superstore_analysis.sql       # All SQL queries (setup + analysis)
├── Superstore_Snowflake_Dashboard.pbix  # Power BI dashboard file
├── dashboard_preview.png         # Dashboard screenshot
├── snowflake_queries..png        # Snowflake worksheet screenshot
├── s3_bucket.png                 # S3 bucket screenshot
└── README.md                     # This file
```

---

## 💡 What I Learned

- Setting up **Snowflake ↔ AWS S3 integration** using IAM roles and trust policies
- Creating **external stages** in Snowflake for S3-based data loading
- Using **COPY INTO** for bulk loading with error handling
- Connecting Power BI to Snowflake via **DirectQuery** (live warehouse connection)
- Writing analytical SQL for **profitability analysis** across categories, segments, and geographies

---

## 👤 Author

**Ashutosh Saini**
Data Analyst | SQL · Python · Power BI · AWS · Snowflake

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://linkedin.com/in/ashutosh-flow)
[![GitHub](https://img.shields.io/badge/GitHub-InsightsByAsh-black?style=flat&logo=github)](https://github.com/InsightsByAsh)
