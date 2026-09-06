
-- MEMBERS & SUBSCRIPTION MANAGEMENT
-- ***********************************

-- 1) To identify all members with ACTIVE subscriptions & their current plan
-- --------------------------------------------------------------------------
SELECT  
m.member_id,CONCAT(m.first_name,' ', m.last_name) AS memeber_name, m.email_id, DATE_FORMAT(ms.start_date,'%b %d, %Y') AS Subscription_start_date ,sp.plan_name
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
SELECT CONCAT(m.first_name,' ', m.last_name) AS member_name,sp.plan_name, sp.duration_in_months AS month_duration,DATE_FORMAT(ms.start_date,'%b %d, %Y') AS start_date,
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
SELECT CONCAT(m.first_name,' ', m.last_name) AS member_name,ms.subscription_status,sp.plan_name,sp.plan_description
FROM Members m
JOIN Member_Subscriptions ms
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp
ON sp.plan_id = ms.plan_id 
WHERE  ms.subscription_status = 'ACTIVE' AND sp.personal_training_acccess = TRUE ;


-- 5) Find all members who have an ACTIVE account but currently don't have any ACTIVE subscription. 
-- -----------------------------------------------------------------------------------------------

SELECT m.member_id, CONCAT(m.first_name,' ', m.last_name) AS member_name,m.account_status, DATE_FORMAT(m.joining_date,'%b %d, %Y') AS join_date
FROM Members m 
WHERE m.account_status = TRUE 
AND NOT EXISTS (
SELECT 1
FROM Member_Subscriptions ms
WHERE m.member_id = ms.member_id AND ms.subscription_status = 'ACTIVE'
);


-- PAYEMENT & HISTORY
-- ***********************************