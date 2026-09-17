

--  INDEX TESTING 
-- *********************************************************************

-- 1) Upcoming / scheduled sessions

-- Step 1 — Run before creating the index
EXPLAIN
SELECT session_id, session_date, start_time, session_status
FROM Sessions
WHERE session_status = 'SCHEDULED'
  AND session_date >= CURDATE();


-- Step 2 — Run after creating the index
EXPLAIN
SELECT session_id, session_date, start_time, session_status
FROM Sessions
WHERE session_status = 'SCHEDULED'
  AND session_date >= CURDATE();

SHOW INDEX FROM Sessions;


-- Step 3 — force the index
EXPLAIN
SELECT session_id, session_date, start_time, session_status
FROM Sessions FORCE INDEX (idx_sessions_status_date)
WHERE session_status = 'SCHEDULED'
  AND session_date >= CURDATE();


-- 2) Payment report 

EXPLAIN
SELECT payment_id, payment_date, payment_amount, payment_status
FROM Payments FORCE INDEX (idx_payments_status_date)
WHERE payment_status = 'SUCCESS'
  AND payment_date >= '2026-01-01'
  AND payment_date < '2027-01-01';

SHOW INDEX FROM Payments;


-- 3) Simple indexes

EXPLAIN
SELECT session_id, session_date, start_time
FROM Sessions
WHERE session_date >= CURDATE();

EXPLAIN
SELECT booking_id, member_id, session_id
FROM Bookings
WHERE booking_status = 'BOOKED';

SHOW INDEX FROM Bookings;
SHOW INDEX FROM Member_Subscriptions;
SHOW INDEX FROM Session_updation_Responses;
