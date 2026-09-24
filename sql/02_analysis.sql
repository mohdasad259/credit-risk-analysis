-- ============================================================
-- 02_analysis.sql
-- Credit Risk Analysis — Analytical Queries
-- Run after 01_schema.sql and after loading data into "loans".
-- Organized into 5 categories, increasing in complexity.
-- ============================================================


-- ------------------------------------------------------------
-- Category 1 — Basic Aggregations (4)
-- ------------------------------------------------------------

-- Home ownership type wise applicant count

SELECT
	person_home_ownership,
	COUNT(*) AS total_applicant
FROM loans
GROUP BY person_home_ownership;


-- Loan intent (purpose) wise total loans count

SELECT
	loan_intent,
	COUNT(*) AS total_loan
FROM loans
GROUP BY loan_intent;


-- Loan grade wise applicant count

SELECT
	loan_grade,
	COUNT(*) AS total_applicant
FROM loans
GROUP BY loan_grade
ORDER BY loan_grade;


-- Default status wise count

SELECT
	loan_status,
	COUNT(*) AS total_loans
FROM loans
GROUP BY loan_status
ORDER BY loan_status;


-- ------------------------------------------------------------
-- Category 2 — Group-wise Analysis (4)
-- ------------------------------------------------------------

-- Age group wise default rate (%)

SELECT
	age_group,
	COUNT(*) AS total_applicant,
	ROUND(AVG(loan_status) * 100, 2) AS default_rate_percent
FROM loans
GROUP BY age_group
ORDER BY age_group;


-- Loan grade wise average interest rate + default rate

SELECT
	loan_grade,
	COUNT(*) AS total_applicant,
	ROUND(AVG(loan_int_rate) ::numeric, 2) AS avg_int_rate,
	ROUND(AVG(loan_status) ::numeric * 100, 2) AS default_rate_percent
FROM loans
GROUP BY loan_grade
ORDER BY loan_grade;


-- Loan amount group wise default count

SELECT
	loan_amount_group,
	COUNT(*) AS total_applicant,
	SUM(loan_status) AS total_defaults,
	ROUND(AVG(loan_status) ::numeric * 100, 2) AS default_rate_percent
FROM loans
GROUP BY loan_amount_group
ORDER BY MIN(loan_amnt);


-- Home ownership type wise average income + default rate

SELECT
	person_home_ownership,
	COUNT(*) AS total_applicant,
	ROUND(AVG(person_income) ::numeric, 2) AS avg_income,
	ROUND(AVG(loan_status) ::numeric * 100, 2) AS default_rate_percent
FROM loans
GROUP BY person_home_ownership;


-- ------------------------------------------------------------
-- Category 3 — Window Functions (2)
-- ------------------------------------------------------------

-- Rank loan intents by their default rate

SELECT
	loan_intent,
	COUNT(*) AS total_applicant,
	ROUND(AVG(loan_status) ::numeric * 100, 2) AS default_rate_percent,
	RANK() OVER(ORDER BY AVG(loan_status) DESC) AS rank
FROM loans
GROUP BY loan_intent;


-- Top 5 highest loan amount applicants within each age group

SELECT *
FROM(
	SELECT
		age_group,
		person_age,
		loan_amnt,
		ROW_NUMBER() OVER(PARTITION BY age_group ORDER BY loan_amnt DESC) AS row_num
	FROM loans
) AS ranked_applicants
WHERE row_num <= 5
ORDER BY age_group, row_num;


-- ------------------------------------------------------------
-- Category 4 — CTEs (2)
-- ------------------------------------------------------------

-- High-Risk Applicants' Average Income and Loan Amount using CTE

WITH high_risk_applicant AS(
	SELECT *
	FROM loans
	WHERE cb_person_default_on_file = 'Yes'
)
SELECT
	COUNT(*) AS total_applicant,
	ROUND(AVG(person_income), 2) AS person_avg_income,
	ROUND(AVG(loan_amnt), 2) AS avg_loan_amount
FROM high_risk_applicant;


-- Default Rate of Applicants with High Loan-to-Income Ratio

WITH high_ratio_applicant AS(
	SELECT *
	FROM loans
	WHERE loan_percent_income > 0.3
)
SELECT
	COUNT(*) AS total_applicant,
	ROUND(AVG(loan_status) * 100, 2) AS default_rate_percent
FROM high_ratio_applicant;


-- ------------------------------------------------------------
-- Category 5 — Advanced / Business Insight (2)
-- ------------------------------------------------------------

-- Credit history length buckets vs default rate

SELECT
	CASE
		WHEN cb_person_cred_hist_length <= 5 THEN '0-5 years'
		WHEN cb_person_cred_hist_length <= 10 THEN '6-10 years'
		WHEN cb_person_cred_hist_length <= 15 THEN '11-15 years'
		ELSE '15+ years'
	END AS credit_history_bucket,
	COUNT(*) AS total_applicant,
	ROUND(AVG(loan_status) * 100, 2) AS default_rate_percent
FROM loans
GROUP BY credit_history_bucket
ORDER BY MIN(cb_person_cred_hist_length);


-- Create risk segments (Low/Medium/High) based on loan_percent_income (debt-to-income ratio) and check default rate

SELECT
	CASE
		WHEN loan_percent_income <= 0.1 THEN 'Low Risk'
		WHEN loan_percent_income <= 0.3 THEN 'Medium Risk'
		ELSE 'High Risk'
	END AS risk_segment,
	COUNT(*) AS total_applicant,
	ROUND(AVG(loan_status) * 100, 2) AS default_rate_percent
FROM loans
GROUP BY risk_segment
ORDER BY MIN(loan_percent_income);
