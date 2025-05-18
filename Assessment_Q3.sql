USE cowrywisedb;  -- Select the target database

-- First CTE: Get the most recent inflow (confirmed deposit) per plan
WITH last_inflow AS (
    SELECT
        s.plan_id,
        MAX(s.created_on) AS last_transaction_date  -- Find the latest inflow date per plan
    FROM 
        savings_savingsaccount s
    WHERE 
        s.confirmed_amount > 0  -- Only consider inflows (ignore withdrawals or zero-value transactions)
    GROUP BY 
        s.plan_id
)

-- Main query: Identify plans that have been inactive for more than a year
SELECT 
    p.id AS plan_id,
    p.owner_id AS owner_id,

    -- Categorize plan type based on flag fields
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'  -- Fallback for uncategorized plans
    END AS type,

    li.last_transaction_date,  -- Last inflow date
    DATEDIFF(CURDATE(), li.last_transaction_date) AS inactivity_days  -- Days since last transaction

FROM 
    plans_plan p

-- Join plan data with latest inflow data
LEFT JOIN 
    last_inflow li ON p.id = li.plan_id

WHERE 
    li.last_transaction_date IS NOT NULL  -- Ensure the plan had at least one inflow in the past

    -- Filter for accounts with no inflow in the last 365 days
    AND DATEDIFF(CURDATE(), li.last_transaction_date) > 365

ORDER BY 
    inactivity_days DESC;  -- Rank by longest inactivity first