
-- Q1: High-Value Customers with Savings and Investment Plans
-- Description: Identify customers who have at least one funded savings plan (regular savings) 
-- and one funded investment plan (fund type), and sort them by total deposits in descending order.

USE adashi_staging;

SELECT 
    u.id AS owner_id,
    u.name,
    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,
    ROUND(SUM(s.confirmed_amount + p.amount) / 100.0, 2) AS total_deposits
FROM users_customuser u

-- Join savings transactions that have confirmed amounts
JOIN savings_savingsaccount s 
    ON s.owner_id = u.id 
    AND s.confirmed_amount > 0

-- Join savings plan to ensure it's a regular savings plan
JOIN plans_plan sp
    ON s.plan_id = sp.id 
    AND sp.is_regular_savings = 1

-- Join investment plans with positive amount and marked as fund
JOIN plans_plan p 
    ON p.owner_id = u.id 
    AND p.amount > 0 
    AND p.is_a_fund = 1

GROUP BY u.id, u.name
ORDER BY total_deposits DESC;

-- Q2: Transaction Frequency Analysis
-- Description: Categorize customers based on their average monthly transaction frequency.

-- Q2: Transaction Frequency Analysis
-- Description: Categorize customers based on their average monthly transaction frequency.

USE adashi_staging;

WITH user_transactions AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS active_months
    FROM savings_savingsaccount s
    WHERE s.transaction_date IS NOT NULL
    GROUP BY s.owner_id
),
categorized_users AS (
    SELECT
        ut.owner_id,
        ROUND(ut.total_transactions / ut.active_months, 2) AS avg_transactions_per_month,
        CASE
            WHEN ut.total_transactions / ut.active_months >= 10 THEN 'High Frequency'
            WHEN ut.total_transactions / ut.active_months BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_transactions ut
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');

-- Q3: Account Inactivity Alert
-- Description: Find active savings or investment plans with no inflow transactions in the last 365 days.

USE adashi_staging;

WITH last_savings_txn AS (
    SELECT
        s.plan_id,
        MAX(s.transaction_date) AS last_transaction_date
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0
    GROUP BY s.plan_id
), 
active_plans AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        p.is_deleted,
        p.is_archived
    FROM plans_plan p
    WHERE p.is_deleted = 0
      AND p.is_archived = 0
      AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
)
SELECT
    ap.plan_id,
    ap.owner_id,
    ap.type,
    COALESCE(lst.last_transaction_date, 'No Transactions') AS last_transaction_date,
    CASE 
        WHEN lst.last_transaction_date IS NULL THEN NULL
        ELSE DATEDIFF(CURRENT_DATE, lst.last_transaction_date)
    END AS inactivity_days
FROM active_plans ap
LEFT JOIN last_savings_txn lst ON lst.plan_id = ap.plan_id
WHERE (lst.last_transaction_date IS NULL OR lst.last_transaction_date <= DATE_SUB(CURRENT_DATE, INTERVAL 365 DAY))
ORDER BY 
  CASE WHEN inactivity_days IS NULL THEN 1 ELSE 0 END,
  inactivity_days DESC;
  
  /*
Question 4: Customer Lifetime Value (CLV) Estimation

Scenario:
Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).

Task:
For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
- Account tenure (months since signup)
- Total transactions
- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)

Order results by estimated CLV from highest to lowest.

Tables:
- users_customuser (id, name, created_on)
- savings_savingsaccount (owner_id, confirmed_amount, transaction_date)

Note:
- confirmed_amount is in kobo, so divide by 100 to convert to currency units.
- profit_per_transaction = 0.001 * transaction value
*/

USE adashi_staging;

WITH customer_transactions AS (
    SELECT
        u.id AS customer_id,
        u.name,
        TIMESTAMPDIFF(MONTH, u.created_on, CURRENT_DATE) AS tenure_months,
        COUNT(t.id) AS total_transactions,
        AVG(t.confirmed_amount) AS avg_transaction_value
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount t
        ON t.owner_id = u.id
        AND t.confirmed_amount > 0
    GROUP BY u.id, u.name, u.created_on
)
SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(
        (total_transactions / NULLIF(tenure_months, 0)) * 12 * 
        (COALESCE(avg_transaction_value, 0) / 100) * 0.001
    , 2) AS estimated_clv
FROM customer_transactions
ORDER BY estimated_clv DESC;

