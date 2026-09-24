-- ============================================================
-- 03_view.sql
-- Credit Risk Analysis — Reporting View
-- Creates loans_view, the single source Power BI connects to,
-- plus a few summary queries used for the dashboard KPI cards.
-- Run after 01_schema.sql and 02_analysis.sql.
-- ============================================================

-- Final view for Power BI connection

CREATE VIEW loans_view AS
SELECT
    person_age,
    age_group,
    person_income,
    person_home_ownership,
    person_emp_length,
    loan_intent,
    loan_grade,
    loan_amnt,
    loan_amount_group,
    loan_int_rate,
    loan_status,
    CASE
        WHEN loan_status = 1 THEN 'Default'
        ELSE 'No Default'
    END AS loan_status_label,
    loan_percent_income,
    CASE
        WHEN loan_percent_income <= 0.1 THEN 'Low Risk'
        WHEN loan_percent_income <= 0.3 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_segment,
    cb_person_default_on_file,
    cb_person_cred_hist_length
FROM loans;


-- ------------------------------------------------------------
-- Summary Queries (used for Power BI KPI cards)
-- ------------------------------------------------------------

-- Total Applicants & Overall Default Rate

SELECT
    COUNT(*) AS total_applicants,
    ROUND(AVG(loan_status)::numeric * 100, 2) AS overall_default_rate_pct
FROM loans_view;


-- Key Financial Averages (Loan Amount, Income, Interest Rate)

SELECT
    ROUND(AVG(loan_amnt)::numeric, 2) AS avg_loan_amount,
    ROUND(AVG(person_income)::numeric, 2) AS avg_annual_income,
    ROUND(AVG(loan_int_rate)::numeric, 2) AS avg_interest_rate_pct
FROM loans_view;


-- Applicant Distribution Across Risk Segments

SELECT
    risk_segment,
    COUNT(*) AS total_applicants,
    ROUND(COUNT(*)::numeric * 100 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total_applicants
FROM loans_view
GROUP BY risk_segment
ORDER BY MIN(loan_percent_income);
