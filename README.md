# DataAnalytics-Assessment


## 1.  High-Value Customers with Multiple Products
## Task: Find customers with at least one funded Savings plan and one funded Investment plan

### Thought Process Summary  :

**Objective** : *Identify Customers that are have both Savings `and` Investment products for cross selling Opportunity*

**Join logic** : *I started with getting the **Users** then `Join` them to their respective **Plans** and `Join` the **Savings** transactions( Some plans might not have savings transactions)*

**Filtering using Having Clause** : *I used `Having` clause because Saving_count and investment_count are aggregates and cant be filtered using `Where` clause.*

**Efficiency** : *This structure allows combining  counts, filtering, and monetary aggregation in a single pass - good ballance of accuracy and performance*

#### Step-by-Step Methodology

**Step 1**: Understand the Business Rules
- Savings plan: Identified by `plans_plan.is_regular_savings = 1`

- Investment plan: `Identified by plans_plan.is_a_fund = 1`

- Transaction values: Found in `savings_savingsaccount.confirmed_amount`

- Deposit values are in kobo, so divide by 100 to convert to Naira

**Step 2**: Identify Required Data
- `owner_id`, `name` from `users_customuser`

- Count of savings plans and investment plans

- Sum of `confirmed_amount` for savings (linked via `plan_id`)

- Only include users with both plan types

**Step 3**: Join Relevant Tables
- `plans_plan` to `user_customuser` (via `owner_id`)

- `savings_savingsaccount` to `plans_plan` (via `plan_id`)

**Step 4**: Aggregate and Filter
- Count `savings_count`: where `is_regular_savings = 1`

- Count `investment_count`: where `is_a_fund = 1`

- Sum only confirmed savings deposits

- Use `HAVING savings_count >= 1 AND investment_count >= 1` to filter

**Step 5**: Sort Output
- Use `ORDER BY total_deposits DESC` to show high-value customers at the top
 

## 2. Transaction Frequency Analysis

## Task: Calculate the Average number of transactions per customer per month.

### Thought Process Summary : 

**Objective** : *To understand Customers behaviours(Customer segmentation) by Classifying customers by average monthly transaction frequency into 3 groups:*

- High (≥10/month)

- Medium (3–9/month)

- Low (≤2/month)

#### Step-by-Step Methodology
**Step 1**: Understand Key Logic

- Transactions occur in `savings_savingsaccount`

- Each transaction has `owner_id` and `created_on`

- Time range is from first to last transaction

- Grouping logic:

  - High: ≥10/month

  - Medium: 3–9/month

  - Low: ≤2/month

**Step 2**: Aggregate per User

CTE: `user_tx_summary`

- Count total transactions per user

- Use `TIMESTAMPDIFF(MONTH, MIN(created_on), MAX(created_on)) + 1` for active months
(adding 1 to avoid divide-by-zero or zero-month gaps)

**Step 3**: Calculate Average Frequency
CTE: `user_with_avg`

- Compute `avg_tx_per_month` = `total_tx / active_months`

- Assign frequency label via `CASE` expression

**Step 4**: Final Summary
CTE: `final_summary`

- Group by frequency category

- Count number of customers per group

- Compute average transactions per month for each category

**Step 5**: Ordered Output
Use:
`ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency')`
to ensure the logical order in output.
#### Summary:  
 *I Calculated each `User's total transactions` and `account activities duration` in months. Then Calculated `monthly frequency` and Categorize each User, grouped Users by category and calculated total count and average frequency*
             
  *To ensure users with transactions in the same monthare still counted as active over 1 month, hence the use of #+1# in `TIMESTAMPDIFF`*
             
  *To smartly custom-sort the non-alphabetical categories, hence the usage of `FIELD`*

## 3. Account Inactivity Alert.
## Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).

### Thought Process Summary:

**Objective** : *To flag accounts with inflow inactiveity for over a year, useful for operational alert or re-engagement.*

#### Step-by-Step Methodology

**Step 1**: Define "Inactivity"
- A plan is inactive if last deposit `(confirmed_amount > 0)` is older than 1 year

- Must check for savings and investment plans

- Use `DATEDIFF(CURDATE(), last_transaction_date) > 365`

**Step 2**: Find Last Transaction Date
CTE: `last_inflow`

- For each `plan_id`, get the latest `created_on` date where `confirmed_amount > 0`

**Step 3**: Join Plan Metadata
Join `plans_plan` with `last_inflow` to:

- Retrieve `owner_id`

- Determine plan type via:

  - `is_regular_savings = 1 to 'Savings'`

  - `is_a_fund = 1 to 'Investment'`

**Step 4**: Filter on Inactivity
- Exclude plans with no deposit ever (`last_transaction_date IS NULL`)

- Only include those inactive > 365 days using `DATEDIFF(...) > 365`

**Step 5**: Output Fields

Return:

- `plan_id`, `owner_id`, `type`, `last_transaction_date`, `inactivity_days`

- Sorted by most inactive plans (`ORDER BY inactivity_days DESC`)


**Why CTE?**  : *Isolating logic to get last inflow per plan, while keeping the main query cleaner.*

**Left Join Usage** :  To ensure i still get the plan infomation even if there are no matching transactions( incase i later remove `IS NOT NULL`)

**`DATEDIFF`** : *A simple but powerful way to calculate duration from the last inflow date.*


## 4. Customer Lifetime Value (CLV) Estimation.
## Task :  For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:

- Account tenure (months since signup)

- Total transactions

- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)

- Order by estimated CLV from highest to lowest

## Thought Process Summary:

### Unerstand the Business Logic 
**Objective**: *Estimate how valuable each customer is over time using a simplified CLV model.(Estimate long-term customer profitability (CLV) using simplified assumptions).*

Formula given:

`CLV = (Total Transactions ÷ Tenure in Months) × 12 × Avg Profit per Transaction`

- **Total Transactions:** *Number of deposits (savings transactions)*

- **Tenure:** *Time since customer joined (in months)*

- **Avg Profit per Transaction:** *0.1% of the average transaction value*

- **Data Unit Conversion:** *Since values are in kobo, convert to Naira by dividing by 100*

### 2. Identify Required Data Elements

- User ID and name

- Date joined (for tenure calculation)

- Number of savings transactions

- Total value of those transactions

- Derived metrics: average transaction value, tenure, CLV

### 3. Design the Query in Logical layers 

  *Use Common Table Expression(CTEs) to break the logic into clear, modular steps. 

 **Formula Dissection:**

*(t.total_transactions / tenure) * 12: estimates yearly transaction volume.*

*(total_transaction_value / total_transactions) * 0.001: average transaction value × 0.1% profit margin.*

*/100: Converts kobo to naira.*

NULLIF safeguard: *Prevents division by zero if tenure_months = 0.*









