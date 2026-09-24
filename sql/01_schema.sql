-- ============================================================
-- 01_schema.sql
-- Credit Risk Analysis — Table Schema
-- Defines the base "loans" table that the raw cleaned data
-- (cleaned_credit_risk_data.csv) is loaded into.
-- ============================================================

CREATE TABLE loans (
    person_age INT,
    person_income INT,
    person_home_ownership VARCHAR(20),
    person_emp_length FLOAT,
    loan_intent VARCHAR(30),
    loan_grade VARCHAR(5),
    loan_amnt INT,
    loan_int_rate FLOAT,
    loan_status INT,
    loan_percent_income FLOAT,
    cb_person_default_on_file VARCHAR(5),
    cb_person_cred_hist_length INT,
    age_group VARCHAR(10),
    loan_amount_group VARCHAR(15)
);
