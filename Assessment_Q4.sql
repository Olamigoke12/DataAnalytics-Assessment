USE cowrywisedb;  -- Set the database context

-- Step 1: Summarize total transactions and total transaction value per user
WITH transaction_summary AS (
    SELECT
        s.owner_id,  -- Link to user
        COUNT(*) AS total_transactions,  -- Number of savings transactions
        SUM(s.confirmed_amount) AS total_transaction_value  -- Total transaction value (in kobo)
    FROM 
        savings_savingsaccount s
    GROUP BY 
        s.owner_id
),

-- Step 2: Calculate account tenure in months from signup to today
user_tenure AS (
    SELECT
        u.id AS customer_id,  -- Unique ID of the user
        CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Combine names for readability

        -- Calculate tenure in months
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months
    FROM 
        users_customuser u
),

-- Step 3: Combine tenure and transactions, and compute CLV
clv_calc AS (
    SELECT 
        u.customer_id,
        u.name,
        u.tenure_months,
        t.total_transactions,

        -- Estimated CLV Formula:
        -- ((transactions per month) * 12) * (avg transaction * 0.1%) → Convert kobo to Naira (/100)
        ROUND(
            ((t.total_transactions / NULLIF(u.tenure_months, 0)) * 12) *
            ((t.total_transaction_value / t.total_transactions) * 0.001) / 100,
            2
        ) AS estimated_clv
    FROM 
        user_tenure u
    JOIN 
        transaction_summary t ON u.customer_id = t.owner_id
)

-- Final output: All customers ranked by CLV
SELECT * 
FROM clv_calc
ORDER BY estimated_clv DESC;