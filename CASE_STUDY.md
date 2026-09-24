# Case Study: Understanding Loan Default Risk

## Overview

Lenders earn money by giving loans, but every defaulted loan is a direct loss of trust and capital. This project analyses **32,406 loan applicants** to answer a practical question: **which borrower and loan characteristics are associated with default, and where should a lender look first?**

The work covers the full analytics chain: cleaning raw data in Python, querying it in PostgreSQL, and turning the results into a 3-page Power BI dashboard for non-technical readers.

## Business Problem

A consumer lending team sees that about **1 in 5 loans (21.87%)** ends in default, but does not know which applicants drive that number. Reviewing every application in detail is slow and costly. The team needs to know:

1. Which factors separate high-risk from low-risk applicants?
2. Which commonly used signals (age, credit history, prior default) actually add information, and which do not?
3. Where should extra checks be added first for the biggest effect?

> The lending team is a business framing for this portfolio project. The data is a public Kaggle dataset, not from a real lender.

---

## Approach

| Layer | Tool | Role |
|-------|------|------|
| Cleaning and exploration | Python (Pandas, Matplotlib, Seaborn) | Quality checks, cleaning, feature grouping, 10 visual analyses |
| Analysis | PostgreSQL | Schema, 14 analytical queries, reporting view, KPI queries |
| Reporting | Power BI | 3-page interactive dashboard with slicers |

### Step 1: Cleaning (Python)

| Step | What was done | Result |
|------|---------------|--------|
| Load and check | 32,581 rows, 12 columns. Found 4,011 missing cells and 165 duplicate rows | Issues identified |
| Remove duplicates | Dropped exact duplicate rows | 32,416 rows |
| Fill missing values | `person_emp_length` (895 missing) and `loan_int_rate` (3,116 missing) filled with the median, chosen because it is not pulled by extreme values | 0 missing |
| Remove impossible values | Removed ages above 80 (7 rows, max 144) and employment length above 40 years (3 rows, max 123) | **32,406 rows** |
| Create groups | Added `age_group` (5 bands) and `loan_amount_group` (Low, Medium, High, Very High). Replaced Y/N with Yes/No | 14 columns |
| Validate | Assertions for no nulls and no duplicates before export | Cleaned CSV saved |

The notebook then plots the data: target balance, distributions, default rate by home ownership, grade, age and loan-to-income, plus a correlation heatmap.

### Step 2: Analysis (SQL)

The 14 queries in `02_analysis.sql` are organised by difficulty:

- **Basic aggregations:** applicant counts by home ownership, purpose, grade and default status.
- **Group-wise analysis:** default rate by age group, grade (with average interest rate), loan amount group and home ownership (with average income).
- **Window functions:** rank loan purposes by default rate with `RANK()`, and list the top 5 loan amounts per age group with `ROW_NUMBER()`.
- **CTEs:** profile applicants with a prior default, and measure default rate for loan-to-income above 30%.
- **Business insight:** default rate by credit history bucket, and a Low / Medium / High risk segmentation using loan-to-income.

`03_view.sql` creates `loans_view`, which adds a readable default label and the risk segment, and is the single source for Power BI. It also holds the KPI queries used on the dashboard cards.

The SQL results were re-run against the cleaned CSV and match the Python and Power BI numbers.

### Step 3: Reporting (Power BI)

| Page | Focus |
|------|-------|
| Risk Overview | KPIs (32K loans, 21.9% default rate, ₹310.86M total loan amount, 11.01% average interest rate), default rate by grade, purpose and risk segment |
| Demographic Insights | Default rate by age and home ownership, applicant mix, average loan amount by grade, interest rate by age |
| Advanced Analysis | Default rate by employment length, credit history length, prior default and loan amount group |

Each page has slicers and a short Key Insights box.

---

## Key Findings

| Finding | Numbers |
|---------|---------|
| Portfolio default rate | **21.87%** (7,088 of 32,406) |
| Loan grade | **9.96%** (A) to **59.05%** (D) to **98.44%** (G, only 64 loans: strong signal, not proof) |
| Loan-to-income above 30% | **70.43%** vs **15.39%** (about 4.6x); 11.8% of applicants, 37.9% of defaults |
| Home ownership | Renters **31.61%** vs homeowners **11.80%** (about 2.7x), also within loan grades A to F |
| Loan purpose | Debt consolidation **28.68%** vs venture **14.86%** |
| Employment length | **24.20%** for 0 to 5 years vs about **16%** for 11+ years |
| Age, credit history, prior default | Little independent pattern; prior default overlaps with grade |

Full detail, sample sizes and tables are in [INSIGHTS.md](INSIGHTS.md).

## Business Impact

There is no cost, revenue or loss-recovery data in this dataset, so this project **does not estimate money saved**. What it does show is where risk is concentrated:

- **Grades D to G plus loan-to-income above 30%** together cover **24.4% of applicants (7,906) but 70.7% of defaults**. Inside that group the default rate is 63.4%, vs 21.87% overall.
- The loan-to-income above 30% group holds **19.4% of the total loan amount but about 52.3% of the amount tied to defaulted loans**.
- A review process aimed at these groups would let a lender focus detailed checks on roughly a quarter of applications instead of all of them.
- The trade-off is real: about 37% of the flagged applicants (2,897 of 7,906) did not default. The rule is a way to prioritise reviews, not to reject people automatically.

These figures were measured on the same data used to find the patterns, so they show where risk sits today, not how well a rule would perform on new applicants.

## Recommendations

1. **Add a loan-to-income check at 30%.** Route these applications to manual review rather than automatic rejection.
2. **Treat Grades D to G as a separate high-risk tier** with stricter approval rules and closer monitoring.
3. **Use housing status as a review flag** alongside grade and loan-to-income, and test whether it still adds value in a model before using it in policy.
4. **Apply extra affordability checks to debt consolidation, medical and home improvement loans**, but do not use purpose alone to decline.
5. **Do not rely on age, credit history length or prior default as standalone filters** in this data. They add little beyond grade.
6. **Improve data collection**: record employment length reliably (895 values were missing and applicants with missing values looked riskier in the raw data).
7. **Next step: build and test a predictive model** (for example logistic regression) on a train/test split to confirm which factors still matter when considered together.

## Limitations

- Single snapshot of a public dataset with no documented collection method or time period. The source does not state a currency; ₹ is assumed in the dashboard.
- Associations only. Nothing here proves that a factor causes default.
- No predictive model or holdout test has been built yet.
- Missing employment length and interest rate were filled with the median. Rows missing employment length had a higher default rate in the raw data (31.5%), so this fill may blur the employment pattern.
- Income outliers were not removed (maximum income is 2,039,784). Only impossible age and employment values were removed.
- Some groups are small: Grade G (64 loans), Grade F (241), home ownership `OTHER` (106) and ages 61+ (62).
- Loan grade is set by the lender, so it is a summary of risk rather than an independent driver.

---

## Tools and Skills Demonstrated

- **Data cleaning (Pandas):** duplicates, missing values, outlier rules, feature grouping, export validation
- **Exploratory analysis:** distributions, correlation, target-based comparisons (Matplotlib, Seaborn)
- **SQL (PostgreSQL):** aggregations, `CASE` bucketing, window functions (`RANK`, `ROW_NUMBER`), CTEs, views
- **Power BI:** DAX measures, derived grouping fields, slicers, KPI cards, dashboard design
- **Analytical thinking:** separating association from causation, checking for overlap between variables (grade vs prior default), flagging small samples
- **Communication:** README, insight write-ups with sample sizes, and business recommendations
- **Git / GitHub:** version control and project publishing

## Project Files

| File | Link |
|------|------|
| Overview and setup | [README.md](README.md) |
| Detailed insights | [INSIGHTS.md](INSIGHTS.md) |
| Raw dataset | [dataset/raw/credit_risk_dataset.csv](dataset/raw/credit_risk_dataset.csv) |
| Cleaned dataset | [dataset/clean/cleaned_credit_risk_data.csv](dataset/clean/cleaned_credit_risk_data.csv) |
| Python notebook | [notebook/credit_risk_analysis.ipynb](notebook/credit_risk_analysis.ipynb) |
| SQL: schema | [sql/01_schema.sql](sql/01_schema.sql) |
| SQL: analysis | [sql/02_analysis.sql](sql/02_analysis.sql) |
| SQL: reporting view | [sql/03_view.sql](sql/03_view.sql) |
| Power BI dashboard | [powerbi/credit_risk_dashboard.pbix](powerbi/credit_risk_dashboard.pbix) |
| Dashboard screenshots | [images/](images/) |
