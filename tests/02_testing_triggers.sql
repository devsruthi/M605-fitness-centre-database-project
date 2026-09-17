


--  TRIGGERS TESTING 
-- *********************************************************************


-- 1) Member age validation before member details insertion
--    (member age must be >= 16)
-- *****************************************************************

-- FAIL — too young
INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth, account_status)
VALUES ('Young', 'Tester', 'trigger.young@example.com', 'Test@123', '1700000001', '2016-09-13', 'ACTIVE');


-- SUCCESS — adult
INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth, account_status)
VALUES ('Adult', 'Tester', 'trigger.adult@example.com', 'Test@1234', '1700000002', '2000-01-15', 'ACTIVE');

SELECT member_id, first_name, last_name, email_id, date_of_birth
FROM Members
WHERE email_id = 'trigger.adult@example.com';


-- 2) Log member details after insertion
--    (After a successful member insert, a copy is written to Member_Details_Log)
-- ******************************************************************************

SELECT m.member_id, m.email_id, l.log_id, l.logged_at
FROM Members m
JOIN Member_Details_Log l ON l.member_id = m.member_id
WHERE m.email_id = 'trigger.adult@example.com';


-- 3) Prevent session booking - only memebers with active subscription currently can book sessions
-- ************************************************************************************

-- TEST DATA:
-- memeber id's with no active subscription - (11, 12, 18, 20)
-- memeber id's with active subscription - (1, 2,3,5,19, 21,30 etc)
-- session id's - (34, 14, 3, 1)

SELECT m.member_id, m.first_name, m.last_name, ms.subscription_status
FROM Members m
JOIN Member_Subscriptions ms ON ms.member_id = m.member_id
AND ms.start_date = (
    SELECT MAX(ms2.start_date)
    FROM Member_Subscriptions ms2
    WHERE ms2.member_id = m.member_id
)
AND ms.subscription_status = 'ACTIVE';

-- FAIL 
INSERT INTO Bookings (member_id, session_id)
VALUES (11, 34);

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
-- Expected: already 1 row exist

-- FAIL
INSERT INTO Bookings (member_id, session_id)
VALUES (1, 1);
-- Expected: Member has already booked this session!


-- 5) Prevent session booking - when session reaches maximum capacity, no more bookings are allowed
-- *************************************************************************************************

-- FAIL — member 6 has Premium plan (plan includes PT session access) but the seat is already taken.

SELECT s.session_id,s.session_date,st.service_type_name, count(b.booking_id) as booking_count, st.max_participants
FROM Sessions s
JOIN Bookings b ON b.session_id = s.session_id
JOIN Service_Types st ON st.service_type_id = s.service_type_id
WHERE s.session_id = 42 group by s.session_id;

INSERT INTO Bookings (member_id, session_id)
VALUES (6, 42);


-- 6) check_pt_session_access_before_booking
-- *********************************************

-- member id's with PT access - (5, 2)

SELECT ms.member_id, ms.plan_id, sp.plan_name, sp.personal_training_access, ms.subscription_status
FROM Member_Subscriptions ms
JOIN Subscription_Plans sp ON sp.plan_id = ms.plan_id
WHERE ms.member_id = 5 AND ms.start_date = (
            SELECT MAX(ms2.start_date)
            FROM Member_Subscriptions ms2
            WHERE ms2.member_id = 5
        )  AND ms.subscription_status = 'ACTIVE';

-- FAIL
INSERT INTO Bookings (member_id, session_id)
VALUES (5, 14);

-- SUCCESS 
INSERT INTO Bookings (member_id, session_id)
VALUES (2, 14);

SELECT booking_id, member_id, session_id, booking_status
FROM Bookings
WHERE member_id = 2 AND session_id = 14;
