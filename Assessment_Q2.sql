USE cowrywisedb;  -- Set the database context

-- First CTE: Summarize total transactions and active months per user
WITH user_tx_summary AS (
    SELECT
        s.owner_id,  -- Customer ID
        COUNT(*) AS total_transactions,  -- Total number of transactions made by the user

        -- Calculate number of months between first and last transaction (+1 ensures we count partial months too)
        TIMESTAMPDIFF(MONTH, MIN(s.created_on), MAX(s.created_on)) + 1 AS active_months
    FROM 
        savings_savingsaccount s
    GROUP BY 
        s.owner_id
),

-- Second CTE: Calculate average transactions per month and categorize user
user_with_avg AS (
    SELECT
        owner_id,
        total_transactions,
        active_months,

        -- Compute average monthly transaction frequency
        ROUND(total_transactions / active_months, 2) AS avg_tx_per_month,

        -- Categorize based on frequency rules
        CASE 
            WHEN total_transactions / active_months >= 10 THEN 'High Frequency'
            WHEN total_transactions / active_months BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        user_tx_summary
),

-- Third CTE: Aggregate customer counts and average frequency per category
final_summary AS (
    SELECT 
        frequency_category,
        COUNT(*) AS customer_count,  -- Number of users in this category

        -- Average number of transactions per month across users in the category
        ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
    FROM 
        user_with_avg
    GROUP BY 
        frequency_category
)

-- Final result selection: display frequency tier summary
SELECT * 
FROM final_summary
ORDER BY 
    -- Preserve custom order of frequency category: High → Medium → Low
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');