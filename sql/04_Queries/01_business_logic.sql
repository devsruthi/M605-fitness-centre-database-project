
-- MEMBERS & SUBSCRIPTION MANAGEMENT
-- ***********************************

-- 1) To identify all members with ACTIVE subscriptions & their current plan
-- --------------------------------------------------------------------------
SELECT  
m.member_id,CONCAT(m.first_name,' ', m.last_name) AS memeber_name, m.email_id, 
DATE_FORMAT(ms.start_date,'%b %d, %Y') AS Subscription_start_date ,sp.plan_name
FROM Members m 
JOIN Member_Subscriptions ms
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp
ON ms.plan_id = sp.plan_id
WHERE ms.subscription_status = 'ACTIVE'
ORDER BY ms.start_date DESC;
;

-- 2) To identify the popularity rank of subscription plans in the entire history
-- -------------------------------------------------------------------------------
SELECT  sp.plan_name,
COUNT(ms.subscription_id) AS total_subscriptions
FROM Subscription_Plans sp
JOIN Member_Subscriptions ms
ON ms.plan_id = sp.plan_id
GROUP BY ms.plan_id
ORDER BY total_subscriptions DESC
;

-- 3) Display Complete subscription history of members in the wellness centre
-- ---------------------------------------------------------------------
SELECT CONCAT(m.first_name,' ', m.last_name) AS member_name,sp.plan_name, 
sp.duration_in_months AS month_duration,DATE_FORMAT(ms.start_date,'%b %d, %Y') AS start_date,
DATE_FORMAT (DATE_ADD(ms.start_date , INTERVAL sp.duration_in_months MONTH),'%b %d, %Y') AS end_date,
ms.subscription_status
FROM Members m
JOIN Member_Subscriptions ms
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp
ON sp.plan_id = ms.plan_id
ORDER BY m.member_id, ms.start_date;


-- 4) Identify members who are eligible for Personal Training 
-- -------------------------------------------------------------------
SELECT CONCAT(m.first_name,' ', m.last_name) AS member_name,ms.subscription_status,
sp.plan_name,sp.plan_description
FROM Members m
JOIN Member_Subscriptions ms
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp
ON sp.plan_id = ms.plan_id 
WHERE  ms.subscription_status = 'ACTIVE' AND sp.personal_training_acccess = TRUE ;

-- 5) Find all members who have an ACTIVE account but currently don't have any ACTIVE subscription
-- & Check whether they have any previous subscription history/not. 
-- -----------------------------------------------------------------------------------------------

SELECT m.member_id, CONCAT(m.first_name,' ', m.last_name) AS member_name,m.account_status, 
DATE_FORMAT(m.joining_date,'%b %d, %Y') AS join_date,
CASE
WHEN  EXISTS (
SELECT 1
FROM Member_Subscriptions ms
WHERE m.member_id = ms.member_id
) THEN 'Has subscription history' ELSE 'Never subscribed'
END AS subscription_history_status
FROM Members m 
WHERE m.account_status = 'ACTIVE' 
AND NOT EXISTS (
SELECT 1
FROM Member_Subscriptions ms
WHERE m.member_id = ms.member_id AND ms.subscription_status = 'ACTIVE'
);

-- 6) identify members who have an ACTIVE account but never subscribed to any subscription plans yet. 
-- -----------------------------------------------------------------------------------------------------
SELECT
m.member_id,
CONCAT(m.first_name, ' ', m.last_name) AS member_name,m.email_id
FROM Members m
WHERE NOT EXISTS (
SELECT 1
FROM Member_Subscriptions ms
WHERE ms.member_id = m.member_id
);


-- PAYEMENT & HISTORY
-- ***********************************

-- 7) Payment History - Full payment history of every member
-- -----------------------------------------------------------
SELECT m.member_id, CONCAT(m.first_name,' ',last_name) AS member_name, 
p.subscription_id,
DATE_FORMAT(p.payment_date,'%b %d, %Y') AS payment_date,p.payment_amount,
CASE
WHEN p.payment_id IS NULL  THEN 'No Payment yet'
WHEN p.payment_status = 'SUCCESS'  THEN 'Payment Successful'
WHEN p.payment_status = 'FAILED'  THEN 'Failed Payment'
WHEN p.payment_status = 'PENDING'  THEN 'Pending'
END AS payment_status,p.payment_method
FROM Members m
LEFT JOIN Member_Subscriptions ms
ON m.member_id = ms.member_id
LEFT JOIN Payments p
ON ms.subscription_id = p.subscription_id
LEFT JOIN Subscription_Plans sp
ON ms.plan_id = sp.plan_id
ORDER BY m.member_id, p.payment_date
;

-- 8) Identify which payment method fails most often.
-- -----------------------------------------------------------
SELECT p.payment_method, COUNT(p.payment_status) as Total_failure_count
FROM Payments p
WHERE p.payment_status = 'FAILED'
GROUP BY p.payment_method;

-- 9) Comparing the payment methods performance,most success rate payment method.
-- ----------------------------------------------------------------------------------
SELECT
p.payment_method,COUNT(*) as total_attempts,
SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS 'successsful',
SUM(CASE WHEN p.payment_status = 'FAILED' THEN 1 ELSE 0 END) AS 'failed',
SUM(CASE WHEN p.payment_status = 'PENDING' THEN 1 ELSE 0 END) AS 'pending',

CONCAT(ROUND(
SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END)*100 / COUNT(*), 2),' %')
AS 'success_rate',
CONCAT(ROUND(AVG(p.payment_amount), 2),' €') AS average_amount
FROM Payments p
GROUP BY p.payment_method
ORDER BY success_rate DESC;

-- 10)Analysing payment method performance within a selected time period 
-- ---------------------------------------------------------------------
SELECT
p.payment_method,COUNT(*) as total_attempts,
SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS 'successsful',
SUM(CASE WHEN p.payment_status = 'FAILED' THEN 1 ELSE 0 END) AS 'failed',
SUM(CASE WHEN p.payment_status = 'PENDING' THEN 1 ELSE 0 END) AS 'pending',
CONCAT(ROUND(
SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END)*100 / COUNT(*), 2),' %')
AS 'success_rate',
CONCAT(ROUND(AVG(p.payment_amount), 2),' €') AS average_amount
FROM Payments p
WHERE p.payment_date >= '2026-06-01' AND p.payment_date < '2026-07-01'
GROUP BY p.payment_method
ORDER BY success_rate DESC; 

-- 11) Revenue Dashbaord : To find & analyze total and average successful payments & amounts per plan
-- ---------------------------------------------------------------------------------------
SELECT sp.plan_name,sp.plan_price,
COUNT(DISTINCT CASE WHEN ms.subscription_status = 'ACTIVE' THEN 1 END) AS total_active_subscriptions,
SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0  END) AS total_successful_payments,
CONCAT(SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount ELSE 0 END ),' €') AS total_revenue,
CONCAT(ROUND(AVG(p.payment_amount),2),' €') AS average_revenue,
CASE 
WHEN COUNT(p.payment_id) = 0 THEN 'NO SALES'
WHEN SUM(p.payment_amount) > 500 THEN 'HIGH' ELSE 'NORMAL'
END AS revenue_band
FROM Subscription_Plans sp 
LEFT JOIN Member_Subscriptions ms
ON sp.plan_id = ms.plan_id
LEFT JOIN Payments p
ON p.subscription_id = ms.subscription_id
GROUP BY sp.plan_id,sp.plan_name
ORDER BY SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount ELSE 0 END) DESC;

-- 12) Revenue Dashboard for a selected time period
-- ---------------------------------------------------------------------
SELECT
sp.plan_name,
sp.plan_price,
COUNT(DISTINCT CASE WHEN ms.subscription_status = 'ACTIVE' THEN 1 END) AS total_active_subscriptions,
SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS total_successful_payments,
CONCAT(SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount ELSE 0 END),' €') AS total_revenue,
CONCAT(ROUND(AVG(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount END), 2),' €') AS average_revenue,
CASE
WHEN SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN 1 ELSE 0 END) = 0 THEN 'NO SALES'
WHEN SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount ELSE 0 END) > 500 THEN 'HIGH'
ELSE 'NORMAL'
END AS revenue_band
FROM Subscription_Plans sp
LEFT JOIN Member_Subscriptions ms
ON sp.plan_id = ms.plan_id
LEFT JOIN Payments p
ON p.subscription_id = ms.subscription_id
AND p.payment_date >= '2026-01-01' AND p.payment_date < '2026-07-01'
GROUP BY sp.plan_id,sp.plan_name
ORDER BY SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount ELSE 0 END) DESC;

-- 13) Failed or Pending payments for a specific member
-- ---------------------------------------------------------------------

SELECT
DATE_FORMAT(p.payment_date, '%b %d, %Y') AS payment_date,sp.plan_name,
CONCAT(p.payment_amount, ' €') AS amount,
p.payment_method,p.payment_status
FROM Members m
JOIN Member_Subscriptions ms 
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp 
ON sp.plan_id = ms.plan_id
JOIN Payments p 
ON p.subscription_id = ms.subscription_id
WHERE m.member_id = 1 AND p.payment_status IN ('FAILED', 'PENDING')
ORDER BY p.payment_date DESC;


-- 14) Purchase history of a specific member
-- ---------------------------------------------------------------------

SELECT
sp.plan_name,ms.subscription_status,
DATE_FORMAT(ms.start_date, '%b %d, %Y') AS subscription_start,
DATE_FORMAT(p.payment_date, '%b %d, %Y') AS payment_date,
CONCAT(p.payment_amount, ' €') AS amount,
p.payment_method,p.payment_status
FROM Members m
JOIN Member_Subscriptions ms 
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp 
ON sp.plan_id = ms.plan_id
LEFT JOIN Payments p 
ON p.subscription_id = ms.subscription_id
WHERE m.member_id = 1
ORDER BY ms.start_date, p.payment_date;


-- 15) Identify members who have failed payments more than 2 times
-- ---------------------------------------------------------------------
SELECT
m.member_id,
CONCAT(m.first_name, ' ', m.last_name) AS member_name,m.email_id,
COUNT(*) AS failed_payment_count,
CONCAT(SUM(p.payment_amount), ' €') AS failed_amount
FROM Members m
JOIN Member_Subscriptions ms ON m.member_id = ms.member_id
JOIN Payments p ON p.subscription_id = ms.subscription_id
WHERE p.payment_status = 'FAILED'
GROUP BY m.member_id
HAVING COUNT(*) > 2
ORDER BY failed_payment_count DESC;













