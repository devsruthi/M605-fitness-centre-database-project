

--  SINGLE ROW INSERTs 
-- ***********************************************

-- 1) MEMBERS
INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth, account_status, joining_date)
VALUES ('Rita', 'Shah', 'rita.shah@example.com', 'Rita@123', '1867890123', '1998-06-15', 'ACTIVE', '2026-09-14');


-- 2) TRAINERS
INSERT INTO Trainers (first_name, last_name, email_id, phone_no, city, total_experience_years, account_status, hired_date)
VALUES ('Noah', 'Adler', 'noah.adler@wellness.de', '4915412345631', 'Berlin', 6, 'ACTIVE', '2025-03-01');


-- 3) SUBSCRIPTION PLANS
INSERT INTO Subscription_Plans (plan_name, duration_in_months, plan_price, 
plan_description, plan_status, group_classes_access, personal_training_access, exclusive_services)
VALUES ('Flex Day', 1, 19.99, 'One-month trial with group class access.', 'ACTIVE', TRUE, FALSE, FALSE);


-- 4) MEMBER SUBSCRIPTIONS
INSERT INTO Member_Subscriptions (member_id, plan_id, start_date, subscription_status)
VALUES (1, 1, '2026-09-14', 'ACTIVE');


-- 5) PAYMENTS
INSERT INTO Payments (subscription_id, payment_date, payment_amount, payment_method, payment_status)
VALUES (1, '2026-09-14', 19.99, 'CREDIT_CARD', 'SUCCESS');

-- 6) SERVICE TYPES
INSERT INTO Service_Types (service_type_name, service_type_description, 
service_mode, max_participants, service_type_status)
VALUES ('Morning Stretch', 'Short group session for mobility and warm-up.', 'GROUP', 12, 'ACTIVE');


-- 7) SESSIONS
INSERT INTO Sessions (service_type_id, trainer_id, session_date, start_time, 
duration_in_minutes, session_mode, session_room, session_cancelled_time, session_cancelled_reason, session_status)
VALUES (1, 1, '2028-11-20', '07:30:00', 45, 'OFFLINE', 'Studio C', NULL, NULL, 'SCHEDULED');

-- 8) BOOKINGS
INSERT INTO Bookings (member_id, session_id, booking_created_time, booking_cancelled_time, booking_cancelled_reason,
 booking_cancelled_by, booking_status)
VALUES (1, 1, '2026-09-14 10:00:00', NULL, NULL, 'SYSTEM', 'BOOKED');

-- 9) SESSION UPDATIONS
INSERT INTO Session_updations (session_id, trainer_id, session_date, start_time, session_room, session_mode, 
updation_type, updation_reason, session_updated_at)
VALUES (1, 1, '2026-11-20', '2026-11-20 07:30:00', 'Studio C', 'OFFLINE', 'ROOM_CHANGED', 'Moved to Studio C after a timetable clash.', '2026-09-14 11:00:00');

-- 10) SESSION UPDATION RESPONSES
INSERT INTO Session_updation_Responses (session_update_id, booking_id, response_status, response_reason, response_created_at)
VALUES (1, 1, 'ACCEPTED', 'Happy to continue in the new room.', '2026-09-14 12:00:00');

-- 11) MEMBER DETAILS LOG
-- (the insert trigger also writes a row when a member is created)
INSERT INTO Member_Details_Log (member_id, first_name, last_name, email_id, 
phone_no, date_of_birth, account_status, joining_date)
VALUES (1, 'Rita', 'Shah', 'rita.shah@example.com', '1867890123', '1998-06-15', 'ACTIVE', '2026-09-14');
