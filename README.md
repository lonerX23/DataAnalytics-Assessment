# DataAnalytics-Assessment
SQL-based Data Analytics assessment involving customer segmentation, transaction behavior analysis, account inactivity tracking, and lifetime value computation. Contains well-structured queries and insights using real-world-like financial data models.

DataAnalytics-Assessment/
├── Assessment_Q1.sql
├── Assessment_Q2.sql
├── Assessment_Q3.sql
├── Assessment_Q4.sql
└── README.md

# DataAnalytics-Assessment

This repository contains SQL solutions for a Data Analytics assessment involving customer and transaction data analysis. The queries address key business scenarios such as customer segmentation, transaction frequency, account inactivity, and customer lifetime value estimation.

---

## Repository Structure


---

## Assessment Questions

### 1. High-Value Customers with Multiple Products
Identify customers who have both funded savings plans and funded investment plans (cross-selling opportunities).  
Output includes customer ID, name, count of savings and investment plans, and total deposits.

### 2. Transaction Frequency Analysis
Analyze transaction frequency per customer per month and categorize customers as High, Medium, or Low frequency users.

### 3. Account Inactivity Alert
Flag active accounts (savings or investment) with no inflow transactions in the last 365 days.

### 4. Customer Lifetime Value (CLV) Estimation
Estimate CLV per customer based on account tenure and transaction volume. Profit per transaction is assumed at 0.1% of transaction value.

---

## Usage

- Each SQL file contains a single query solving the corresponding assessment question.
- Queries are formatted and commented for readability.
- To execute, run the SQL scripts against the `adashi_staging` database or your equivalent environment.

---

## Notes

- Amount fields are stored in kobo and converted to standard currency units in calculations.
- The schema includes the tables: `users_customuser`, `savings_savingsaccount`, and `plans_plan`.
- Join conditions and filtering ensure accuracy and efficiency.


---

*Prepared by Olabanji Okunade*  
*Data Analyst*  
