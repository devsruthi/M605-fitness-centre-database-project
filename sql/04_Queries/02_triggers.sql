
-- =============================== TRIGGERS =================================================

-- 1) Member age validation before member details insertion
--  member age must be >= 16
-- ----------------------------------------------------------

DELIMITER //
CREATE TRIGGER check_member_age_before_insertion
BEFORE INSERT ON Members
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.date_of_birth, CURDATE()) < 15 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member must be at least 16 years old!';
    END IF;
END //
DELIMITER ;


-- 2) Log member details after insertion
-- ------------------------------------------------
DELIMITER // 
CREATE TRIGGER log_member_details_insertion 
AFTER INSERT ON Members 
FOR EACH ROW 
BEGIN 
INSERT INTO Member_Details_Log (member_id, first_name, last_name, email_id, phone_no, date_of_birth, account_status, joining_date) 
VALUES (NEW.member_id, NEW.first_name, NEW.last_name, NEW.email_id, NEW.phone_no, NEW.date_of_birth, NEW.account_status, NEW.joining_date); 
END // 
DELIMITER ;


-- 3) Prevent session booking - only memebers with active subscription can book sessions
-- ------------------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER check_member_subscription_before_booking
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Member_Subscriptions ms
        WHERE ms.member_id = NEW.member_id 
        AND ms.subscription_status = 'ACTIVE' 
        AND ms.start_date <= CURDATE()
) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member must have an active subscription plan to book sessions!';
    END IF;   
END //
DELIMITER ;


-- 4) Prevent a member from booking the same session more than once
-- ------------------------------------------------------------------------------------------------

DELIMITER //

CREATE TRIGGER prevent_duplicate_session_booking
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Bookings b
        WHERE b.member_id = NEW.member_id
		AND b.session_id = NEW.session_id
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Member has already booked this session!';
    END IF;
END //

DELIMITER ;


-- 5) Prevent session booking - when session reaches maximum capacity, no more bookings are allowed
-- ------------------------------------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER check_session_capacity_before_booking
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF (
        SELECT COUNT(*)
        FROM Bookings  b
        WHERE b.session_id = NEW.session_id AND b.booking_status = 'BOOKED'
        )
        >= (
            SELECT st.max_participants
            FROM Service_Types st
            JOIN Sessions s
            ON st.service_type_id = s.service_type_id
            WHERE s.session_id = NEW.session_id
            )
     THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Session is at maximum capacity, no more bookings are allowed!';
    END IF;   
END //
DELIMITER ;


-- 6) Prevent PT session booking - when the Member's subscription plan does not include PT service access
-- ------------------------------------------------------------------------------------------------

DELIMITER //
CREATE TRIGGER check_pt_session_access_before_booking
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN

  IF EXISTS (
           SELECT 1 
           FROM Sessions s
           JOIN service_Types st 
           ON s.service_type_id = st.service_type_id
           WHERE s.session_id = NEW.session_id AND st.service_mode = 'PERSONAL')
           
    AND NOT EXISTS (
        SELECT 1
        FROM Member_Subscriptions ms
        JOIN Subscription_Plans sp 
        ON ms.plan_id = sp.plan_id
        WHERE ms.member_id = NEW.member_id 
        AND ms.subscription_status = 'ACTIVE' AND plan_status = 'ACTIVE'
        AND sp.personal_training_access = TRUE)
     THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member subscription does not include Personal Training access!';
    END IF;   
END //
DELIMITER ;

