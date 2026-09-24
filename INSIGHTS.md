# Insights: Credit Risk Analysis

**Dataset:** 32,406 loan applicants after cleaning (raw file: 32,581 rows)
**Main metric:** Default rate = share of loans with `loan_status = 1` (**21.87% overall**, 7,088 defaults)
**Currency / units:** The source dataset does not state a currency. The dashboard shows amounts in ₹ (assumed); amounts below are plain numbers in the same units. Rates are percentages of loans in each group.
**Method:** All numbers were recomputed from `cleaned_credit_risk_data.csv` and match the SQL queries and the Power BI dashboard.

**How to read this document**
- `n` is the number of loans in a group. Where `n` is under 100, the result is marked **strong signal, not proof**.
- Every finding is an **association** in one dataset snapshot. None of them shows that a factor *causes* default.
- "Homeowners" means `OWN` + `MORTGAGE` combined (n = 15,928).
- "Loan-to-income" is `loan_percent_income` (loan amount divided by annual income). It does not include the applicant's other debts.

---

## 1. About 1 in 5 loans defaults

**7,088 of 32,406 loans (21.87%)** are in default. The remaining 25,318 (78.13%) are not. Total loan amount in the file is **310.86M**, with an average loan of **9,592.77**, an average income of **65,895.23** (median 55,000), and an average interest rate of **11.01%**.

The data is imbalanced (about 3.6 non-defaults for every default), so any future prediction model would need to account for that.

**Recommendation:** Use 21.87% as the baseline. Any segment worth acting on should be judged against this number, not against zero.

---

## 2. Loan grade ranks risk sharply, with a big jump at Grade D

Default rate rises from **9.96% at Grade A** to **59.05% at Grade D**, about **5.9x higher**. Interest rates rise with grade too.

| Grade | n | Default rate | Avg interest rate |
|-------|--------|--------------|-------------------|
| A | 10,700 | **9.96%** | 7.67% |
| B | 10,384 | **16.32%** | 11.00% |
| C | 6,435 | **20.76%** | 13.22% |
| D | 3,619 | **59.05%** | 14.98% |
| E | 963 | **64.49%** | 16.49% |
| F | 241 | **70.54%** | 17.76% |
| G | 64 | **98.44%** (63 of 64) | 19.53% |

Grades D to G together are **15.1% of loans (4,887)** but **42.2% of all defaults (2,991)**.

**Caution:** Grade is assigned by the lender, so it already reflects the lender's own risk view. It is a summary of risk, not an independent cause. Grade G has only 64 loans: **strong signal, not proof**.

**Recommendation:** Treat Grade D and above as a distinct high-risk tier with stricter approval rules or manual review.

---

## 3. Loan-to-income above 30% is the strongest affordability signal

Applicants borrowing more than 30% of their income default at **70.43%** (n = 3,818) vs **15.39%** for everyone else (n = 28,588), about **4.6x higher**.

| Risk segment (loan-to-income) | n | Share of applicants | Default rate |
|-------------------------------|--------|---------------------|--------------|
| Low (10% or less) | 10,425 | 32.17% | **11.76%** |
| Medium (over 10% to 30%) | 18,163 | 56.05% | **17.47%** |
| High (over 30%) | 3,818 | 11.78% | **70.43%** |

The High segment is **11.8% of applicants but 37.9% of all defaults (2,689 of 7,088)**.

The pattern holds **inside every loan grade**, so it is not just a grade effect:

| Grade | Default rate, 30% or less (n) | Default rate, over 30% (n) |
|-------|-------------------------------|----------------------------|
| A | 5.1% (9,776) | **60.9%** (924) |
| B | 8.8% (9,027) | **66.2%** (1,357) |
| C | 13.7% (5,697) | **75.5%** (738) |
| D | 54.9% (3,073) | **82.6%** (546) |
| E | 59.3% (778) | **86.5%** (185) |
| F | 67.2% (192) | **83.7%** (49, small sample) |

**Recommendation:** Add a loan-to-income check at 30%. Note the trade-off: 1,129 of the 3,818 flagged applicants did not default, so this rule should trigger a review, not an automatic rejection.

---

## 4. Renters default at about 2.7x the rate of homeowners

| Home ownership | n | Default rate | Avg income |
|----------------|--------|--------------|------------|
| OWN | 2,563 | **7.49%** | 57,858.83 |
| MORTGAGE | 13,365 | **12.62%** | 80,689.91 |
| RENT | 16,372 | **31.61%** | 55,006.87 |
| OTHER | 106 | **31.13%** (small sample) | 76,561.27 |

Renters (31.61%) vs homeowners (11.80%) is a gap of about **2.7x**. Renters are **50.5% of applicants but 73.0% of defaults**.

Renters stay riskier within each grade (homeowners = OWN + MORTGAGE):

| Grade | Renters (n) | Homeowners (n) |
|-------|-------------|----------------|
| A | **17.5%** (4,341) | 4.8% (6,333) |
| B | **24.1%** (5,529) | 7.4% (4,822) |
| C | **26.6%** (3,678) | 12.8% (2,740) |
| D | **73.8%** (2,109) | 38.3% (1,490) |

Average income of renters (55,007) and `OWN` applicants (57,859) is similar, yet their default rates are 31.61% vs 7.49%. So income alone does not explain this gap. Housing status may be standing in for something not in the data, such as savings, stability or family support.

**Recommendation:** Use housing status as a review flag alongside grade and loan-to-income, and test whether it still adds value in a proper model before using it in policy.

---

## 5. Debt consolidation, medical and home improvement loans are riskiest

| Loan purpose | n | Default rate |
|--------------|-------|--------------|
| Debt consolidation | 5,189 | **28.68%** |
| Medical | 6,040 | **26.77%** |
| Home improvement | 3,594 | **26.15%** |
| Personal | 5,495 | **19.89%** |
| Education | 6,409 | **17.26%** |
| Venture | 5,679 | **14.86%** |

The gap between the highest and lowest purpose is about **14 percentage points** (28.68% vs 14.86%), roughly 1.9x. It is moderate compared with grade or loan-to-income.

It is tempting to say debt consolidation signals existing financial stress, but the dataset has no debt information to test that. Treat it as a hypothesis.

**Recommendation:** Apply extra affordability checks to the top three purposes. Do not use purpose on its own to decline loans.

---

## 6. Very large loans default more, but the pattern is not a straight line

| Loan amount group | Range | n | Default rate | Avg loan-to-income |
|-------------------|-------|--------|--------------|--------------------|
| Low | up to 5,000 | 9,427 | **20.47%** | 9.2% |
| Medium | 5,001 to 10,000 | 11,980 | **18.05%** | 16.4% |
| High | 10,001 to 20,000 | 8,872 | **25.41%** | 23.6% |
| Very High | over 20,000 | 2,127 | **34.88%** | 28.1% |

Very High loans default at **34.88%**, about **1.9x** the Medium group. The risk rises together with loan-to-income (9.2% to 28.1%), so the size of the loan relative to income may matter more than the size alone.

**Recommendation:** Review large loans against the borrower's income rather than setting a flat amount cap.

---

## 7. Default risk is concentrated in the first 5 years of employment

| Employment length | n | Default rate |
|-------------------|--------|--------------|
| 0 to 5 years | 20,928 | **24.20%** |
| 6 to 10 years | 8,564 | **18.10%** |
| 11 to 15 years | 2,303 | **16.24%** |
| 15+ years | 611 | **16.20%** |

Default drops by about **6 points** after year 5 and then flattens.

**Data caution:** 895 rows in the raw file had no employment length. They were filled with the median (about 4 years), so they sit in the 0 to 5 year group. In the raw file those rows had a **31.5% default rate**, higher than average, so the fill may blur the true pattern.

**Recommendation:** Treat applicants with under 5 years of employment as a watch group and collect employment length reliably at application.

---

## 8. Prior default flag mostly overlaps with loan grade

Applicants with a prior default on file default at **37.86%** (n = 5,729) vs **18.44%** without (n = 26,677), about **2.1x** higher on the surface.

But the two are tangled together. **No applicant in Grade A or B has a prior default.** Among prior-default applicants, 56.6% are Grade C and 32.7% are Grade D. Once grade is held fixed, the difference mostly disappears:

| Grade | No prior default (n) | Prior default (n) |
|-------|----------------------|-------------------|
| C | 21.8% (3,190) | 19.7% (3,245) |
| D | 57.9% (1,747) | 60.1% (1,872) |
| E | 66.1% (499) | 62.7% (464) |
| F | 71.3% (129) | 69.6% (112) |

The extra risk of a prior default appears to be already captured by the loan grade. That the flag has no Grade A or B applicants is unusually clean and may reflect how this dataset was built.

**Recommendation:** Do not add a separate penalty for prior default on top of grade without first testing whether it adds anything.

---

## 9. Age and credit history length show little pattern

| Age group | n | Default rate |
|-----------|--------|--------------|
| 20-25 | 15,243 | **23.13%** |
| 26-35 | 13,711 | **20.69%** |
| 36-45 | 2,809 | **20.68%** |
| 46-60 | 581 | **21.86%** |
| 61+ | 62 | **27.42%** (small sample) |

| Credit history length | n | Default rate |
|-----------------------|--------|--------------|
| 0 to 5 years | 19,580 | **22.61%** |
| 6 to 10 years | 9,374 | **20.65%** |
| 11 to 15 years | 2,317 | **20.63%** |
| 15+ years | 1,135 | **21.76%** |

Rates stay within about **21% to 23%** for all groups with a reasonable sample. The 61+ group (17 defaults among 62 loans) is too small to read anything into. Average interest rate is also almost flat across age groups (10.98% to 11.27%).

Age and credit history length are strongly linked to each other (correlation 0.88), so they carry mostly the same information. Also, **89.3% of applicants are aged 35 or under**, so this dataset says little about older borrowers.

**Recommendation:** Do not use age or credit history length as standalone risk filters in this data.

---

## 10. Defaulters borrow more relative to income and pay higher rates

| Measure | No default | Default |
|---------|------------|---------|
| Median income | 60,000 | **41,655** |
| Average loan-to-income | 15% | **25%** |
| Average interest rate | 10.49% | **12.88%** |
| Median loan amount | 8,000 | 9,600 |

Correlation of each numeric column with default: loan-to-income **0.38**, interest rate **0.32**, income **-0.17**, loan amount 0.11, age -0.02, credit history length -0.02. These are simple linear correlations and only rank how strongly each variable moves with default.

The differences between defaulters and non-defaulters are larger for income and loan-to-income than for the loan amount itself.

**Recommendation:** Build any future scorecard around affordability (loan-to-income, income) and grade first.

---

## Summary

Four themes come out of the data:

1. **Affordability and lender grade are the strongest signals.** Loan-to-income above 30% and grades D to G each isolate a small group that produces a large share of defaults. Together they cover **24.4% of applicants and 70.7% of defaults** (63.4% default rate within that group). This is measured on the same data used to find the rule, so it is not yet a tested result.
2. **Housing status carries extra information.** Renters default much more than homeowners, even within the same grade, and income does not fully explain it.
3. **Purpose and loan size are secondary.** They move risk moderately, and much of the loan size effect looks tied to loan-to-income.
4. **Age, credit history length and prior default add little on their own.** They flatten out or overlap with grade.

**Limitations:** single snapshot of one public dataset with no documented collection method or time period, no predictive model or holdout test, no cost or recovery data, and currency not stated. Findings show what is associated with default here, not what causes it.
