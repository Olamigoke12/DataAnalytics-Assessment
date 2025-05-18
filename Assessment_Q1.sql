use cowrywisedb;

SELECT 
    u.id AS owner_id,  -- Fetch the customer/user ID
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Combine first and last name for readability

    -- Count unique savings accounts where the associated plan is marked as a regular savings plan
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) AS savings_count,

    -- Count unique plans that are investment-type (is_a_fund = 1)
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,

    -- Sum all confirmed inflows for savings plans, divide by 100 to convert kobo to naira, and round to 2 decimal places
    ROUND(SUM(CASE WHEN p.is_regular_savings = 1 THEN s.confirmed_amount ELSE 0 END) / 100, 2) AS total_deposits

FROM 
    users_customuser u  -- Start from the user table

JOIN 
    plans_plan p ON u.id = p.owner_id  -- Join user with their plans

LEFT JOIN 
    savings_savingsaccount s ON p.id = s.plan_id  -- Left join with savings transactions, as not all plans might have savings transactions

GROUP BY 
    u.id, name  -- Group the results by user

HAVING 
    savings_count >= 1 AND investment_count >= 1  -- Filter to only those with at least one savings and one investment plan

ORDER BY 
    total_deposits DESC;  -- Rank users by total deposits in descending order