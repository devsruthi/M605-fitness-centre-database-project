

-- ======================== BUSINESS LOGIC QUERIES ==========================================

-- 1) MEMBERS & SUBSCRIPTION MANAGEMENT
-- 2) PAYEMENT & HISTORY
-- 3) SERVICE TYPES MANAGEMENT
-- 4) SESSIONS BOOKING & SCHEDULE MANAGEMENT
-- 5) TRAINERS MANAGEMENT
-- 6) SESSION CHANGE IMPACT (ADMIN)

-- 1) MEMBERS & SUBSCRIPTION MANAGEMENT
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

-- 3) Display member's subscription history in the fitness centre
-- ----------------------------------------------------------------
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
SELECT m.member_id, CONCAT(m.first_name,' ', m.last_name) AS member_name,ms.subscription_status,
sp.plan_name
FROM Members m
JOIN Member_Subscriptions ms
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp
ON sp.plan_id = ms.plan_id 
WHERE  ms.subscription_status = 'ACTIVE' AND sp.personal_training_access = TRUE ;


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

-- 7) Identify members who have an ACTIVE subscription & their subscription ends in the next 7 days
-- -----------------------------------------------------------------------------------------------------
SELECT
m.member_id,
CONCAT(m.first_name, ' ', m.last_name) AS member_name,m.email_id,sp.plan_name,
DATE_FORMAT(ms.start_date, '%b %d, %Y') AS start_date,
DATE_FORMAT(DATE_ADD(ms.start_date, INTERVAL sp.duration_in_months MONTH),'%b %d, %Y') AS end_date
FROM Members m
JOIN Member_Subscriptions ms 
ON m.member_id = ms.member_id
JOIN Subscription_Plans sp 
ON sp.plan_id = ms.plan_id
WHERE ms.subscription_status = 'ACTIVE'
AND DATE_ADD(ms.start_date, INTERVAL sp.duration_in_months MONTH) >= CURDATE()
AND DATE_ADD(ms.start_date, INTERVAL sp.duration_in_months MONTH) < DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY DATE_ADD(ms.start_date, INTERVAL sp.duration_in_months MONTH);



-- 2) PAYEMENT & HISTORY
-- ***********************************

-- 1) Payment History - Full payment history of every member
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

-- 2) Identify which payment method fails most often.
-- -----------------------------------------------------------
SELECT p.payment_method, COUNT(p.payment_status) as Total_failure_count
FROM Payments p
WHERE p.payment_status = 'FAILED'
GROUP BY p.payment_method;


-- 3) Comparing the payment methods performance,most success rate payment method.
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

-- 4)Analysing payment method performance within a selected time period 
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

-- 5)Revenue details : monthly revenue in a specific year (eg: 2026)
-- only listing months with successful payments
-- --------------------------------------------------------------------------------------------------

SELECT
DATE_FORMAT(p.payment_date, '%b, %Y') AS payment_month,
COUNT(*) AS successful_payments,
CONCAT(SUM(p.payment_amount), ' €') AS total_revenue,
CONCAT(ROUND(AVG(p.payment_amount), 2), ' €') AS average_payment
FROM Payments p
WHERE p.payment_status = 'SUCCESS' AND YEAR(p.payment_date) = 2026
GROUP BY YEAR(p.payment_date),MONTH(p.payment_date),
DATE_FORMAT(p.payment_date, '%b, %Y')
ORDER BY YEAR(p.payment_date),MONTH(p.payment_date);


-- 6) Revenue Dashboard for a selected time period 
-- (total and average successful payments & amounts per plan)
-- (selected time period: 2026-01-01 to 2026-07-01)
-- -------------------------------------------------------------------------------

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


-- 6) Failed or Pending payments for a specific member
-- (member_id = 1)
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


-- 7) Purchase history of a specific member
-- (member_id = 1)
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


-- 8) Identify members who have failed payments more than 2 times
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


-- 3) SERVICE TYPES MANAGEMENT
-- *****************************************

-- 1) Identify all service types offered by the fitness centre
-- -------------------------------------------------------------

SELECT
st.service_type_id,st.service_type_name,st.service_mode,st.max_participants,st.service_type_description
FROM Service_Types st
WHERE st.service_type_status = 'ACTIVE'
ORDER BY st.service_mode, st.service_type_name;


-- 2) total count of Group services & personal training services
-- ---------------------------------------------------------------------
SELECT
COUNT(CASE WHEN st.service_mode = 'GROUP' THEN st.service_type_id END) AS total_group_services,
COUNT(CASE WHEN st.service_mode = 'PERSONAL' THEN st.service_type_id END) AS total_personal_training_services
FROM Service_Types st
WHERE st.service_type_status = 'ACTIVE'
ORDER BY st.service_mode, st.service_type_name;


-- 3) Identify most popular service types (in terms of bookings)
-- ---------------------------------------------------------------------
SELECT
st.service_type_id,st.service_type_name,st.service_mode,
COUNT(CASE WHEN b.booking_status = 'BOOKED' THEN b.booking_id END) AS total_bookings
FROM Service_Types st
LEFT JOIN Sessions s 
ON s.service_type_id = st.service_type_id
LEFT JOIN Bookings b 
ON b.session_id = s.session_id
GROUP BY st.service_type_id, st.service_type_name, st.service_mode
ORDER BY total_bookings DESC;


-- 4) Identify service types with no sessions created/scheduled yet
-- ---------------------------------------------------------------------

SELECT
st.service_type_id,st.service_type_name,st.service_mode
FROM Service_Types st 
WHERE NOT EXISTS
(
SELECT 1 
FROM Sessions s 
WHERE s.service_type_id = st.service_type_id
);

-- 5) Identify service types with no bookings yet
-- ---------------------------------------------------------------------
SELECT
st.service_type_id,st.service_type_name,st.service_mode
FROM Service_Types st
WHERE 
NOT EXISTS (
SELECT 1
FROM Sessions s
JOIN Bookings b ON b.session_id = s.session_id
WHERE s.service_type_id = st.service_type_id
);


-- 6) Identify service types with the greatest number of bookings
-- ---------------------------------------------------------------------
SELECT
st.service_type_name,st.service_mode,
COUNT(CASE WHEN b.booking_status = 'BOOKED' THEN b.booking_id END) AS total_bookings
FROM Service_Types st
LEFT JOIN Sessions s 
ON s.service_type_id = st.service_type_id
LEFT JOIN Bookings b 
ON b.session_id = s.session_id
GROUP BY st.service_type_id, st.service_type_name, st.service_mode
ORDER BY total_bookings DESC;


-- 7) Identify the service type with the greatest number of cancelled bookings
-- ---------------------------------------------------------------------

SELECT
st.service_type_name,st.service_mode,
COUNT(CASE WHEN b.booking_status = 'CANCELLED' THEN b.booking_id END) AS total_cancelled_bookings
FROM Service_Types st
JOIN Sessions s 
ON s.service_type_id = st.service_type_id
JOIN Bookings b 
ON b.session_id = s.session_id
GROUP BY st.service_type_id, st.service_type_name, st.service_mode
ORDER BY total_cancelled_bookings DESC;



-- 4) SESSIONS BOOKING & SCHEDULE MANAGEMENT
-- *****************************************

-- 1) booking history of a specific member
-- ---------------------------------------------------------------------
SELECT
st.service_type_name, DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
DATE_FORMAT(b.booking_created_time, '%b %d, %Y') AS booked_on,
b.booking_status,
DATE_FORMAT(b.booking_cancelled_time, '%b %d, %Y') AS cancelled_on,
s.session_status
FROM Members m
JOIN Bookings b ON m.member_id = b.member_id
JOIN Sessions s ON b.session_id = s.session_id
JOIN Service_Types st ON s.service_type_id = st.service_type_id
WHERE m.member_id = 1 ORDER BY s.session_date DESC;


-- 2) Identify all upcoming/future booked sessions of a specific member
-- (eg: member_id = 1)
-- -----------------------------------------------------------------------------

SELECT
b.booking_id,st.service_type_name,
DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date, DATE_FORMAT(s.start_time, '%h:%i %p') AS start_time, session_mode,  b.booking_status
FROM Members m
JOIN Bookings b ON m.member_id = b.member_id
JOIN Sessions s 
ON b.session_id = s.session_id
JOIN Service_Types st 
ON s.service_type_id = st.service_type_id
WHERE m.member_id = 1 AND s.session_date >= CURDATE() 
AND s.session_status ='SCHEDULED' AND b.booking_status = 'BOOKED'
ORDER BY s.session_date DESC;


-- 3) Session dashboard : Display all upcoming/scheduled sessions
-- -------------------------------------------------------------------
SELECT
DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
st.service_type_name,
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
s.session_mode,
s.session_room
FROM Sessions s
JOIN Service_Types st ON s.service_type_id = st.service_type_id
JOIN Trainers t ON s.trainer_id = t.trainer_id
WHERE s.session_status = 'SCHEDULED'
AND s.session_date >= CURDATE()
ORDER BY s.session_date, s.start_time;

-- 4) Identify upcoming sessions in a specific month (eg: November 2026)
-- ---------------------------------------------------------------------
SELECT
DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
st.service_type_name,
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
s.session_mode,
s.session_room
FROM Sessions s
JOIN Service_Types st ON s.service_type_id = st.service_type_id
JOIN Trainers t ON s.trainer_id = t.trainer_id
WHERE s.session_status = 'SCHEDULED'
AND s.session_date >= CURDATE()
AND MONTH(s.session_date) = 11 AND YEAR(s.session_date) = 2026
ORDER BY s.session_date, s.start_time;


-- 5) Identify sessions with no bookings yet
-- ---------------------------------------------------------------------
SELECT
s.session_id,
DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
st.service_type_name,
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
s.session_mode,
s.session_room
FROM Sessions s
JOIN Service_Types st ON s.service_type_id = st.service_type_id
JOIN Trainers t ON s.trainer_id = t.trainer_id
WHERE NOT EXISTS (
SELECT 1
FROM Bookings b
WHERE b.session_id = s.session_id
);

-- 6) Identify All Members booked on a upcoming/scheduled sessions but later cancelled (by admin/trainer)
-- -----------------------------------------------------------------------------------------------------
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name,m.email_id,m.phone_no,
DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
st.service_type_name,
s.session_mode
FROM Members m
JOIN Bookings b 
ON m.member_id = b.member_id
JOIN Sessions s 
ON b.session_id = s.session_id 
AND s.session_status = 'CANCELLED' AND b.booking_status = 'BOOKED' && s.session_date >= CURDATE()
JOIN Service_Types st ON s.service_type_id = st.service_type_id
ORDER BY s.session_date DESC;


-- 7) Future sessions : total bookings and available slots left for each upcoming session
-- --------------------------------------------------------------------------------------
SELECT
st.service_type_name,DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
st.max_participants AS total_slots,
COUNT(CASE WHEN b.booking_status = 'BOOKED' THEN b.booking_id END) 
AS Booked_slots,
st.max_participants - COUNT(CASE WHEN b.booking_status = 'BOOKED' 
THEN b.booking_id END) AS slots_left,
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name
FROM Sessions s
JOIN Service_Types st 
ON s.service_type_id = st.service_type_id
JOIN Trainers t 
ON s.trainer_id = t.trainer_id
LEFT JOIN Bookings b 
ON b.session_id = s.session_id
WHERE s.session_status = 'SCHEDULED'
AND s.session_date >= CURDATE()
GROUP BY s.session_id
ORDER BY s.session_date, s.start_time;

-- 8) Identify sessions with the greatest number of cancellations ( by admin/trainer)
-- ---------------------------------------------------------------------
SELECT
st.service_type_name,DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
COUNT(CASE WHEN s.session_status = 'CANCELLED' THEN s.session_id END) 
AS total_cancellations
FROM Sessions s
JOIN Service_Types st ON s.service_type_id = st.service_type_id
WHERE s.session_status = 'CANCELLED'
GROUP BY s.session_id
ORDER BY total_cancellations DESC;


-- 5) TRAINERS MANAGEMENT
-- *****************************************

-- 1) Display all trainers with their details
-- ---------------------------------------------------------------------
SELECT
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
DATE_FORMAT(t.hired_date, '%b %d, %Y') AS hired_date,
t.phone_no AS phone_number,
t.email_id,
t.city,
t.total_experience_years AS experience_years,
t.account_status AS status
FROM Trainers t
ORDER BY t.hired_date DESC;


-- 2) Identify the number of completed sessions for each trainer
-- ---------------------------------------------------------------------
SELECT
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
COUNT(CASE WHEN s.session_status = 'COMPLETED' THEN s.session_id END) AS completed_sessions
FROM Trainers t
JOIN Sessions s ON s.trainer_id = t.trainer_id
AND s.session_status = 'COMPLETED'
GROUP BY t.trainer_id
ORDER BY completed_sessions DESC;


-- 3) Upcoming session schedule of a specific trainer
-- (eg: trainer_id = 1)
-- ---------------------------------------------------------------------
SELECT
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
st.service_type_name,
DATE_FORMAT(s.session_date, '%b %d, %Y') AS session_date,
TIME_FORMAT(s.start_time, '%h:%i %p') AS start_time,
s.duration_in_minutes,
s.session_mode,
s.session_room
FROM Trainers t
JOIN Sessions s 
ON s.trainer_id = t.trainer_id
JOIN Service_Types st 
ON s.service_type_id = st.service_type_id
WHERE t.trainer_id = 1
AND s.session_status = 'SCHEDULED'
AND s.session_date >= CURDATE()
ORDER BY s.session_date, s.start_time;


-- 4) Identify trainers who have the highest number of upcoming booked sessions
-- -----------------------------------------------------------------------------
SELECT
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,
COUNT(b.booking_id) AS total_bookings
FROM Trainers t
JOIN Sessions s ON s.trainer_id = t.trainer_id
JOIN Bookings b ON b.session_id = s.session_id
AND b.booking_status = 'BOOKED' AND s.session_status = 'SCHEDULED' AND s.session_date >= CURDATE()
GROUP BY t.trainer_id
ORDER BY total_bookings DESC;


-- 5) Identify trainers who have been at the fitness centre for more than 1 year
-- ---------------------------------------------------------------------
SELECT
CONCAT(t.first_name, ' ', t.last_name) AS trainer_name,t.city,
DATE_FORMAT(t.hired_date, '%b %d, %Y') AS hired_date,
CONCAT(
TIMESTAMPDIFF(YEAR, t.hired_date, CURDATE()), ' years ',
TIMESTAMPDIFF(MONTH, t.hired_date, CURDATE()) % 12, ' months') AS years_at_centre
FROM Trainers t
WHERE t.account_status = 'ACTIVE'
AND t.hired_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)ORDER BY t.hired_date DESC;


-- 6) SESSION CHANGE IMPACT (ADMIN)
-- *****************************************

-- 1) How many clients declined / cancelled a booking after a session change
-- ---------------------------------------------------------------------
SELECT
COUNT(CASE WHEN sur.response_status = 'DECLINED' THEN sur.response_id END) AS declined_responses,
COUNT(DISTINCT CASE WHEN sur.response_status = 'DECLINED' THEN b.member_id END) AS clients_who_declined,
COUNT(CASE WHEN sur.response_status = 'DECLINED' AND b.booking_status = 'CANCELLED'
THEN b.booking_id END) AS bookings_cancelled_due_to_change,
COUNT(CASE WHEN sur.response_status = 'ACCEPTED' THEN sur.response_id END) AS accepted_responses,
COUNT(CASE WHEN sur.response_status = 'PENDING' THEN sur.response_id END) AS pending_responses
FROM Session_updation_Responses sur
JOIN Bookings b ON sur.booking_id = b.booking_id;


-- 2) Declines by type of session change (trainer / time / room / mode)
-- ---------------------------------------------------------------------
SELECT
su.updation_type,
COUNT(sur.response_id) AS total_responses,
COUNT(CASE WHEN sur.response_status = 'DECLINED' THEN sur.response_id END) AS declined,
COUNT(CASE WHEN sur.response_status = 'ACCEPTED' THEN sur.response_id END) AS accepted,
COUNT(CASE WHEN sur.response_status = 'PENDING' THEN sur.response_id END) AS pending,
COUNT(CASE WHEN sur.response_status = 'DECLINED' AND b.booking_status = 'CANCELLED'
THEN b.booking_id END) AS bookings_cancelled_due_to_change,
ROUND(
COUNT(CASE WHEN sur.response_status = 'DECLINED' THEN sur.response_id END) * 100
/ NULLIF(COUNT(sur.response_id), 0), 2
) AS decline_rate
FROM Session_updations su
LEFT JOIN Session_updation_Responses sur ON sur.session_update_id = su.session_update_id
LEFT JOIN Bookings b ON sur.booking_id = b.booking_id
GROUP BY su.updation_type
ORDER BY declined DESC;






