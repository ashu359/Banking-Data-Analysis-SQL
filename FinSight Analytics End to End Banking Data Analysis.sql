-- FinSight Analytics: End-to-End Banking Data Analysis
/* FinSight Analytics */ -- project name -- 

/* create database */
create database banking_project;

/* use database */
use banking_project;

/* Problem Statement

Banks generate huge amounts of data from customers, accounts, loans, and transactions.
However, this data is often scattered and not properly analyzed, making it difficult to:

Understand customer behavior
Track financial performance
Identify risky loans or defaults
Monitor transaction patterns and fraud risks

 The challenge is to convert this raw data into meaningful insights that help banks make better decisions
------------------------------------------------------------------------------------------------------
 Project Objective

The goal of this project is to build a complete analytics system that:

Cleans and processes raw banking data
Analyzes customer, account, loan, and transaction data
Identifies trends, risks, and opportunities
Creates interactive dashboards for decision-making */

select * from accounts;

SELECT closed_date 
FROM accounts
WHERE closed_date = '';

UPDATE banking_project.accounts
SET closed_date = '2022-01-01'
WHERE closed_date = '';

set sql_safe_updates=0;

/* select all dataset */

select * from customers;
select * from accounts;
select * from branches;
select * from loan_repayments;
select * from loans;
select * from transactions;

-- Customer Insights--

 -- 1. We want to identify our top customers to offer premium banking services.--
 SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(a.balance) AS total_balance
FROM customers c JOIN
accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id , c.first_name , c.last_name
ORDER BY total_balance DESC
LIMIT 10;
-- Insight: Helps bank identify high-value customers → offer credit cards, loans, VIP services --

-- Which location should we expand our branches? --
SELECT city, state, COUNT(*) AS total_customers
FROM customers
GROUP BY city, state
ORDER BY total_customers DESC;
-- insight: High customer count = business opportunity for expansion-- 

-- How to segment customers based on usage? -- 
SELECT 
    c.customer_id,
    COUNT(t.transaction_id) AS txn_count,
    CASE 
        WHEN COUNT(t.transaction_id) > 50 THEN 'High'
        WHEN COUNT(t.transaction_id) > 20 THEN 'Medium'
        ELSE 'Low'
    END AS segment
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id;
-- Insight: Used for target marketing & retention strategies --

-- Account Analysis -- 
-- How many accounts are inactive?
SELECT account_status, COUNT(*) 
FROM accounts
GROUP BY account_status;
-- Insight: Helps bank identify inactive users → reactivation campaigns

-- Which account type holds maximum money? 
SELECT account_type, AVG(balance) AS avg_balance
FROM accounts
GROUP BY account_type;
-- Insight: Helps bank improve product strategy (Savings vs Current)

-- Which branch is performing best?”
SELECT 
    b.branch_name,
    SUM(a.balance) AS total_balance
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_name
ORDER BY total_balance DESC;
-- Insight: Used for branch ranking & performance evaluation

-- Transaction Analysis
-- How are transactions trending over time?
SELECT 
    DATE(transaction_date) AS txn_date,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY txn_date
ORDER BY txn_date;
-- insight: Helps track business growth or decline

-- What is the ratio of money coming vs going?
SELECT 
    transaction_type,
    SUM(amount) AS total
FROM transactions
GROUP BY transaction_type;
-- Insight: Shows cash inflow vs outflow

-- Which channel is most used by customers?
SELECT channel, COUNT(*) AS total_txn
FROM transactions
GROUP BY channel
ORDER BY total_txn DESC;
-- Insight: Helps bank invest in UPI / digital banking

-- Loan Risk Analysis
-- Which loan type is most issued?
SELECT loan_type, COUNT(*) AS total_loans
FROM loans
GROUP BY loan_type;
-- Insight: Helps bank focus on high-demand loan products

-- Who are risky customers?
SELECT 
    c.customer_id,
    c.first_name,
    COUNT(*) AS default_count
FROM customers c
JOIN loans l ON c.customer_id = l.customer_id
WHERE l.status = 'Default'
GROUP BY c.customer_id, c.first_name;
-- Insight: Used for risk control & loan approval decisions

-- How well are customers repaying loans?
SELECT status, COUNT(*) 
FROM loan_repayments
GROUP BY status;
-- Insight: Tracks loan repayment health (Paid vs Late)

-- Business Insights
-- Which branches are underperforming?
SELECT 
    b.branch_name,
    SUM(a.balance) AS total_balance
FROM branches b
JOIN accounts a ON b.branch_id = a.branch_id
GROUP BY b.branch_name
ORDER BY total_balance ASC
LIMIT 5;
-- Insight: Helps bank improve low-performing branches

-- Detect suspicious transactions (fraud)
SELECT *
FROM transactions
WHERE amount > 10000;
-- Insight: Used for fraud detection systems

-- find Customers with No Transactions
SELECT c.customer_id, c.first_name, c.last_name
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN transactions t ON a.account_id = t.account_id
WHERE t.transaction_id IS NULL;
 -- Insight: Finds inactive customers → target for engagement. -- 

-- Top 5 Customers by Loan + Balance Combined -- 
SELECT 
    c.customer_id,
    c.first_name,
    SUM(a.balance) + IFNULL(SUM(l.principal),0) AS total_value
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN loans l ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.first_name
ORDER BY total_value DESC
LIMIT 5;
 -- Insight: Identifies overall high-value customers. -- 
 
 -- ADVANCED ANALYSIS 
-- Find transactions higher than average transaction amount - Subquery
SELECT *
FROM transactions
WHERE amount > (
    SELECT AVG(amount) FROM transactions
);
-- Insight: Used to detect unusual high-value transactions → fraud monitoring

-- Find top 5 customers by total balance -CTE (Common Table Expression)
WITH customer_balance AS (
    SELECT 
        c.customer_id,
        c.first_name,
        SUM(a.balance) AS total_balance
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    GROUP BY c.customer_id, c.first_name
)
SELECT *
FROM customer_balance
ORDER BY total_balance DESC
LIMIT 5;
-- Insight: CTE makes query clean + reusable → used in reporting systems

-- Rank customers based on total balance -Window Function (RANK)
SELECT 
    c.customer_id,
    c.first_name,
    SUM(a.balance) AS total_balance,
    RANK() OVER (ORDER BY SUM(a.balance) DESC) AS rank_no
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name;
-- Insight: Used for: Customer ranking , Loyalty programs

 -- Categorize customers based on balance -CASE Statement
 SELECT 
    customer_id,
    balance,
    CASE 
        WHEN balance > 500000 THEN 'High Value'
        WHEN balance > 100000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS category
FROM accounts;
-- Insight: Helps in customer segmentation & marketing

-- Speed up transaction search by account_id - Indexing
CREATE INDEX idx_account_id 
ON transactions(account_id);
-- Insight: Used in real systems to: Improve query performance, Handle large datasets efficiently

-- Create reusable view for active accounts” - View
CREATE VIEW active_accounts AS
SELECT *
FROM accounts
WHERE account_status = 'Active';

SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

SELECT * FROM active_accounts;
-- Insight: Used for: Simplifying complex queries , Security (hide sensitive columns)

-- Get customer transaction history - Stored Procedure
DELIMITER $$

CREATE PROCEDURE get_customer_transactions(IN cust_id INT)
BEGIN
    SELECT t.*
    FROM transactions t
    JOIN accounts a ON t.account_id = a.account_id
    WHERE a.customer_id = cust_id;
END$$

DELIMITER ;

CALL get_customer_transactions(101);
CALL get_customer_transactions(5);
-- Insight : Used in real apps: Backend APIs , Reusable business logic

-- Update account balance after transaction - Trigger
CREATE TRIGGER update_balance
AFTER INSERT ON transactions
FOR EACH ROW
UPDATE accounts
SET balance = NEW.balance_after
WHERE account_id = NEW.account_id;

-- Fix table structure
ALTER TABLE transactions
MODIFY transaction_id BIGINT AUTO_INCREMENT;

-- Change column to DATETIME
ALTER TABLE transactions
MODIFY transaction_date DATETIME;

-- Now insert a transaction
INSERT INTO transactions (
    account_id, transaction_type, amount, balance_after, transaction_date, channel
)
VALUES (
    1, 'Debit', 500, 5500, NOW(), 'ATM'
);

-- You will see updated balance
SELECT account_id, balance 
FROM accounts 
WHERE account_id = 1;
-- Insight: Used for: Automation Real-time updates

-- TRIAL 
DELIMITER $$

CREATE TRIGGER update_balance
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN

    DECLARE current_balance DECIMAL(12,2);

    -- Get current balance
    SELECT balance INTO current_balance
    FROM accounts
    WHERE account_id = NEW.account_id;

    -- Debit logic (money goes out)
    IF NEW.transaction_type = 'Debit' THEN
        SET NEW.balance_after = current_balance - NEW.amount;

    -- Credit logic (money comes in)
    ELSEIF NEW.transaction_type = 'Credit' THEN
        SET NEW.balance_after = current_balance + NEW.amount;
    END IF;

END$$

DELIMITER ;

-- 
INSERT INTO transactions (
    account_id, transaction_type, amount, transaction_date, channel
)
VALUES (
    2, 'Debit', 3000, NOW(), 'ATM'
);

SELECT account_id, balance
FROM accounts
WHERE account_id = 2;


SELECT *
FROM transactions
WHERE account_id = 2
ORDER BY transaction_id DESC
LIMIT 1;

-- Show transaction amount by channel - Pivot Table
SELECT 
    SUM(CASE WHEN channel = 'UPI' THEN amount ELSE 0 END) AS UPI,
    SUM(CASE WHEN channel = 'ATM' THEN amount ELSE 0 END) AS ATM,
    SUM(CASE WHEN channel = 'Online' THEN amount ELSE 0 END) AS Online,
    SUM(CASE WHEN channel = 'Branch' THEN amount ELSE 0 END) AS Branch
FROM transactions; 

-- Insight: Used in dashboards: Compare channels ,Decision making

-- END -- 