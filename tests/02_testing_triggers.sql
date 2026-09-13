


-- ======================== TRIGGERS TESTING ====================================


-- 1) check_member_age_before_insertion
--    (Member must be at least 16)
-- *****************************************************************

-- 1a) FAIL — too young
INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth, account_status)
VALUES ('Young', 'Tester', 'trigger.young@example.com', 'Test@123', '1700000001', '2016-09-13', 'ACTIVE');


-- 1b) SUCCESS — adult
INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth, account_status)
VALUES ('Adult', 'Tester', 'trigger.adult@example.com', 'Test@1234', '1700000002', '2000-01-15', 'ACTIVE');

SELECT member_id, first_name, last_name, email_id, date_of_birth
FROM Members
WHERE email_id = 'trigger.adult@example.com';


-- 2) log_member_details_insertion
--    (After a successful member insert, a copy is written to Member_Details_Log)
-- ******************************************************************************

SELECT m.member_id, m.email_id, l.log_id, l.logged_at
FROM Members m
JOIN Member_Details_Log l ON l.member_id = m.member_id
WHERE m.email_id = 'trigger.adult@example.com';


-- 3) Prevent session booking - only memebers with active subscription can book sessions
-- ************************************************************************************

-- TEST DATA:
-- memeber id's with no active subscription - (11, 12, 18)
-- memeber id's with active subscription - (19, 20, 21)
-- session id's - (34, 14, 3, 1)

SELECT m.member_id, m.first_name, m.last_name, ms.subscription_status
FROM Members m
JOIN Member_Subscriptions ms ON ms.member_id = m.member_id
WHERE ms.subscription_status != 'ACTIVE';

-- FAIL 
INSERT INTO Bookings (member_id, session_id)
VALUES (11, 34);
-- Expected: Member must have an active subscription plan to book sessions!

-- SUCCESS 
INSERT INTO Bookings (member_id, session_id)
VALUES (19, 34);

SELECT booking_id, member_id, session_id, booking_status
FROM Bookings
WHERE member_id = 19 AND session_id = 34;


-- 4) prevent_duplicate_session_booking
-- *********************************************

SELECT booking_id, member_id, session_id, booking_status
FROM Bookings
WHERE member_id = 1 AND session_id = 1;
-- Expected: already 1 row from seed

-- FAIL
INSERT INTO Bookings (member_id, session_id)
VALUES (1, 1);
-- Expected: Member has already booked this session!


-- 5) Prevent session booking - when session reaches maximum capacity, no more bookings are allowed
-- *************************************************************************************************

-- FAIL — member 6 has Premium (can take PT) but the seat is already taken
INSERT INTO Bookings (member_id, session_id)
VALUES (6, 3);

-- Expected: Session is at maximum capacity, no more bookings are allowed!


-- 6) check_pt_session_access_before_booking
-- *********************************************

SELECT member_id, plan_id, subscription_status
FROM Member_Subscriptions
WHERE member_id = 5 AND subscription_status = 'ACTIVE';
-- Expected: plan_id = 1 (Classic)

-- FAIL
INSERT INTO Bookings (member_id, session_id)
VALUES (5, 14);
-- Expected: Member subscription does not include Personal Training access!

-- SUCCESS 
INSERT INTO Bookings (member_id, session_id)
VALUES (2, 14);

SELECT booking_id, member_id, session_id, booking_status
FROM Bookings
WHERE member_id = 2 AND session_id = 14;
