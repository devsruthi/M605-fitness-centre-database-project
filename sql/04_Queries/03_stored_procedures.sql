-- ======================== STORED PROCEDURES ====================================


-- TESTING THE PROCEDURES - Working Flow
-- **********************************************

-- MEMBER WORKING FLOW
-- -------------------------------
-- 1) Member Registration
-- 2) Member Login
-- 3) View Member Details
-- 4) Add Subscription Plan
-- 5) Purchase Subscription Plan
-- 6) Book Session
-- 7) Respond to Session Update

--  ADMIN WORKING FLOW
-- -------------------------------
-- 1) Cancel Session (by admin)
-- 2) Update Session


SET @member_id = NULL;
SET @subscription_id = NULL;

-- Member Registration
CALL MemberRegistration('Member1', 'Member1', 
'member1@example.com', 'password123', '1234567890', '1990-01-01');

-- Member Login
CALL MemberLogin('member1@example.com', 'password123', @member_id);

-- View Member Details
CALL ViewMemberDetails(@member_id);


-- Add Subscription Plan
SELECT * FROM Subscription_Plans;

CALL AddSubscription(@member_id, 1, @subscription_id); -- (member_id, plan_id, subscription_id (output parameter))

SELECT @subscription_id;

-- Purchase Subscription Plan
CALL PurchaseSubscriptionPlan(@subscription_id, 'CREDIT_CARD'); -- (subscription_id, payment_method)

SELECT * FROM Sessions;

-- Book Session
CALL BookSession(@member_id, 1); -- (member_id, session_id)

-- Update Session
CALL SessionUpdate(1,1, NULL, NULL, NULL, 'TRAINER_CHANGED','Current trainer is not available due to personal reasons'); 
-- (session_id, update_trainer, update_date, update_time, update_room, update_mode, update_type, update_reason)

-- Member responds to session update (ids come from the member's pending-notification list)
SET @response_id = NULL;
CALL SessionUpdateResponse(1, 7, 'ACCEPTED', 'Happy to continue with the new trainer.', @response_id);
-- (session_update_id, booking_id, response_status, response_reason, response_id (output parameter))
SELECT @response_id;


-- =====================================================================================================================

 -- PROCEDURES
 -- **********

 -- 1) Member Registration
 -- -----------------------
 
 DELIMITER //
 CREATE PROCEDURE MemberRegistration (
   IN p_first_name VARCHAR(100),IN p_last_name VARCHAR(100),
   IN p_email_id VARCHAR(150),IN p_password VARCHAR(50),
   IN p_phone_no VARCHAR(20),IN p_date_of_birth DATE
 )
  BEGIN
     IF EXISTS (SELECT 1 FROM Members WHERE email_id = p_email_id)
     THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT = 'Email ID already exists!';
     END IF;
    INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth)
    VALUES (p_first_name, p_last_name, p_email_id, p_password, p_phone_no, p_date_of_birth);
    SELECT 'Registration successful' AS message,CONCAT(p_first_name, ' ', p_last_name) AS member_name;
  END //
DELIMITER ;


-- 2) Member Login
-- ---------------

DELIMITER //
CREATE PROCEDURE MemberLogin (
   IN p_email_id VARCHAR(150),IN p_password VARCHAR(50),OUT p_member_id INT
)
 BEGIN
    SET p_member_id = NULL;
    IF EXISTS (SELECT 1 FROM Members WHERE email_id = p_email_id AND password = p_password)
    THEN
    SET p_member_id = (SELECT member_id FROM Members WHERE email_id = p_email_id AND password = p_password);
    SELECT member_id, 'Login successful, Welcome back' AS message, 
    CONCAT (first_name, ' ', last_name) AS member_name;
    ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid email ID or password!';
    END IF;
 END //
DELIMITER ;


-- 3) View Member Details
-- -----------------------

DELIMITER //
CREATE PROCEDURE ViewMemberDetails (
   IN p_member_id INT
)
 BEGIN
    IF EXISTS (SELECT 1 FROM Members WHERE member_id = p_member_id) THEN
    SELECT first_name, last_name, email_id, phone_no, date_of_birth
    FROM Members
    WHERE member_id = p_member_id;
    SELECT member_id, CONCAT (first_name, ' ', last_name) AS member_name, 
    email_id, phone_no, date_of_birth, account_status,'Success' AS message;
    ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Member not found!';
    END IF;
 END //
DELIMITER ;


-- 4) Add a subscription plan
-- ---------------------------------

DELIMITER //
CREATE PROCEDURE AddSubscription (
    IN p_member_id INT,IN p_plan_id INT,OUT p_subscription_id INT
)
  BEGIN
     SET p_subscription_id = NULL;

    IF NOT EXISTS (SELECT 1 FROM Members WHERE member_id = p_member_id AND account_status = 'ACTIVE')
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Member not found or not active!';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Subscription_Plans WHERE plan_id = p_plan_id AND plan_status = 'ACTIVE')
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Subscription plan not found or not active!';
    END IF;
    IF EXISTS (SELECT 1 FROM Member_Subscriptions WHERE member_id = p_member_id 
    AND plan_id = p_plan_id AND subscription_status in ('PENDING', 'ACTIVE'))
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'You have already chosen this subscription plan and it is pending/active!';
    END IF;
    INSERT INTO Member_Subscriptions (member_id, plan_id, start_date, subscription_status)
    VALUES (p_member_id, p_plan_id, null, 'PENDING');

    SET p_subscription_id = LAST_INSERT_ID();

    SELECT p_member_id AS member_id,p_subscription_id AS subscription_id,
        p_plan_id AS plan_id,'PENDING' AS subscription_status,
        (SELECT plan_name FROM Subscription_Plans WHERE plan_id = p_plan_id) AS plan_name,
        'subscription plan added to cart. Complete payment to activate.' AS success_message;
 END //
DELIMITER ;


-- 5) Purchase the selected subscription plan
-- --------------------------------------------
DELIMITER //
CREATE PROCEDURE PurchaseSubscriptionPlan (
    IN p_subscription_id INT,
    IN p_payment_method ENUM('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'BANK_TRANSFER'))

 BEGIN
     DECLARE l_payment_status VARCHAR(10);
     DECLARE l_plan_price DECIMAL(15, 2);
     DECLARE l_payment_id INT;

    IF EXISTS (SELECT 1 FROM Member_Subscriptions WHERE subscription_id = p_subscription_id AND subscription_status = 'ACTIVE')
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Subscription is already active.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Member_Subscriptions WHERE subscription_id = p_subscription_id AND subscription_status = 'PENDING')
    THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'You have not chosen the subscription plan!';
    END IF;

    -- -- getting plan price autmatcially, not taking from user
  SELECT sp.plan_price INTO l_plan_price FROM Member_Subscriptions ms 
  JOIN Subscription_Plans sp ON sp.plan_id = ms.plan_id
  WHERE ms.subscription_id = p_subscription_id;

    START TRANSACTION; -- ------

    -- online transaction happening.....
    -- assuming that --> got payment status from payment gateway (BANK/CARD/PAYPAL etc).....
    SET payment_status_from_gateway = 'SUCCESS';

    INSERT INTO Payments (subscription_id, payment_date, payment_amount, payment_method, payment_status)
    VALUES (p_subscription_id, CURDATE(), l_plan_price, p_payment_method, payment_status_from_gateway);

    SET l_payment_id = LAST_INSERT_ID();

   IF payment_status_from_gateway = 'SUCCESS'
    -- updating subscrition status from PENDING -> ACTIVE
    THEN
    UPDATE Member_Subscriptions
    SET subscription_status = 'ACTIVE', start_date = CURDATE()
    WHERE subscription_id = p_subscription_id;
    COMMIT;
    SELECT  l_payment_id AS payment_id, p_subscription_id,'Congrats,Purchase successful, your subscription is active now.' AS success_message;
    
  ELSE
    COMMIT; --  ----(Need Failed payment records too)
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payment failed,Please try again!';
    END IF;
 END //
DELIMITER ;


-- 5) Session Booking : Member trying to book a specific session
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE BookSession (IN p_member_id INT,IN p_session_id INT)

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
    SELECT p_session_id AS session_id, 'Congrats, you have successfully booked the session' AS success_message;
 END //
DELIMITER ;


-- 6) Cancel a session by admin/trainer
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE CancelSession (IN p_session_id INT)

 BEGIN
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Session cancellation failed!';
   END;

   START TRANSACTION;
    -- cancelling the session
    UPDATE Sessions SET session_status = 'CANCELLED', session_cancelled_time = CURDATE()
    WHERE session_id = p_session_id;

    -- cancelling all the bookings related to that session
    UPDATE Bookings SET booking_status = 'CANCELLED' , booking_cancelled_time = CURDATE()
    WHERE session_id = p_session_id;
    COMMIT;
    SELECT 'Session & All Bookings related to it cancelled successfully' AS success_message;
 END //
DELIMITER ;


-- 7) Update Session
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE SessionUpdate (
  IN p_session_id INT,
  IN p_update_trainer INT,
  IN p_update_date_time DATETIME,
  IN p_update_room VARCHAR(100),
  IN p_update_mode ENUM('ONLINE', 'OFFLINE'),
  IN p_update_type ENUM('TRAINER_CHANGED','TIME_CHANGED','ROOM_CHANGED','MODE_CHANGED','OTHER'),
  IN p_update_reason VARCHAR(250)
)
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM Sessions
        WHERE session_id = p_session_id
          AND session_status = 'SCHEDULED' AND session_date >= CURDATE() AND start_time >= CURTIME()
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Scheduled session not found / Past session cannot be updated!';
    END IF;

    UPDATE Sessions
    SET trainer_id = COALESCE(p_update_trainer, trainer_id),
        start_time = COALESCE(p_update_time, start_time),
        session_room = COALESCE(p_update_room, session_room),
        session_mode = COALESCE(p_update_mode, session_mode)
    WHERE session_id = p_session_id;

    -- inserting the session update history
    INSERT INTO Session_updates_History (session_id,update_trainer,update_date,update_time,
       update_room,update_mode,update_type,update_reason,session_updated_at)
    VALUES (p_session_id, p_update_trainer, p_update_date, p_update_time, p_update_room, p_update_mode, p_update_type, p_update_reason, CURTIME());

    SET p_session_update_id = LAST_INSERT_ID();

    -- one PENDING reply row for each member already booked
    INSERT INTO Session_update_Responses (session_update_id, booking_id, response_status)
    SELECT LAST_INSERT_ID(), b.booking_id, 'PENDING'
    FROM Bookings b
    WHERE b.session_id = p_session_id
      AND b.booking_status = 'BOOKED';

    SELECT
        p_session_update_id AS session_update_id, b.booking_id AS booking_id, 
        'Session updated successfully.Notification sent to booked members.Waiting for member responses.' AS success_message, 
        'Notification sent to booked members.Waiting for member responses.' AS update_status;
END //
DELIMITER ;


-- 8) Member responds to a session update
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE SessionUpdateResponse (
    IN p_session_update_id INT,
    IN p_booking_id INT,
    IN p_response_status ENUM('ACCEPTED', 'DECLINED'),
    IN p_response_reason VARCHAR(250),
    OUT p_response_id INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Session_update_Responses
        WHERE session_update_id = p_session_update_id
          AND booking_id = p_booking_id
          AND response_status = 'PENDING'
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Response already recorded!';
    END IF;

    UPDATE Session_update_Responses
    SET response_status = p_response_status,
        response_reason = p_response_reason,
        response_time = NOW()
    WHERE session_update_id = p_session_update_id
      AND booking_id = p_booking_id;

    SET p_response_id = LAST_INSERT_ID();

    IF p_response_status = 'DECLINED' THEN
        UPDATE Bookings
        SET booking_status = 'CANCELLED', booking_cancelled_time = NOW()
        WHERE booking_id = p_booking_id;
    END IF;

    SELECT p_response_id AS response_id, 'Response recorded successfully' AS success_message;
END //
DELIMITER ;
