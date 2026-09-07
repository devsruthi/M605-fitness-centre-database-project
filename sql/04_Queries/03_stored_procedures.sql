

-- TESTING THE PROCEDURES
-- *****************************


CALL MemberRegistration('Member1', 'Member1', 
'member1@example.com', 'password123', '1234567890', '1990-01-01');

CALL MemberLogin('member1@example.com', 'password123');

CALL ViewMemberDetails('member1@example.com');

CALL BookSession(1, 1);


 -- 1) Member Registration
 -- -----------------------
 
 DELIMITER //
 CREATE PROCEDURE MemberRegistration (
   IN p_first_name VARCHAR(100),
   IN p_last_name VARCHAR(100),
   IN p_email_id VARCHAR(150),
   IN p_password VARCHAR(50),
   IN p_phone_no VARCHAR(20),
   IN p_date_of_birth DATE
 )
 BEGIN
     IF EXISTS (SELECT 1 FROM Members WHERE email_id = p_email_id)
     THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT = 'Email ID already exists!';
     END IF;
    INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth)
    VALUES (p_first_name, p_last_name, p_email_id, p_password, p_phone_no, p_date_of_birth);
    SELECT CONCAT(p_first_name, ' ', p_last_name) AS member_name, 'Registration successful' AS message;
 END //
DELIMITER ;


-- 2) Member Login
-- ---------------

DELIMITER //
CREATE PROCEDURE MemberLogin (
   IN p_email_id VARCHAR(150),
   IN p_password VARCHAR(50)
)
BEGIN
    IF EXISTS (SELECT 1 FROM Members WHERE email_id = p_email_id AND password = p_password)
    THEN
    SELECT 'Login successful' AS message, 'Welcome back, ' AS welcome_message, 
    (SELECT first_name FROM Members WHERE email_id = p_email_id) AS member_name;
    ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid email ID or password!';
    END IF;
END //
DELIMITER ;


--3) View Member Details
-- -----------------------

DELIMITER //
CREATE PROCEDURE ViewMemberDetails (
   IN p_email_id VARCHAR(150)
)
BEGIN
    SELECT first_name, last_name, email_id, phone_no, date_of_birth 
    FROM Members 
    WHERE email_id = p_email_id;
    SELECT 'Member details retrieved successfully' AS message;
    ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Member not found!';
    END IF;
END //
DELIMITER ;


--4) Session Booking : Member trying to book a specific session
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE BookSession (
    IN p_member_id INT,
    IN p_session_id INT
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Member_Subscriptions WHERE member_id = p_member_id AND subscription_status = 'ACTIVE')
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'You do not have an active subscription!';
    END IF;
    IF EXISTS (SELECT 1 FROM Bookings WHERE member_id = p_member_id 
    AND session_id = p_session_id AND booking_status = 'BOOKED')
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'You have already booked this session!';
    END IF;
    IF EXISTS (SELECT 1 FROM Sessions WHERE session_id = p_session_id AND session_status IN ('COMPLETED', 'CANCELLED'))
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Session is already completed or cancelled!';
    END IF;
    INSERT INTO Bookings (member_id, session_id)
    VALUES (p_member_id, p_session_id);
    SELECT 'Congrats, you have successfully booked the session' AS success_message;
END //
DELIMITER ;

 

