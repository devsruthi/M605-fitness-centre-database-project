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

--  ADMIN WORKING FLOW
-- -------------------------------
-- 1) Cancel Session (by admin)


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
    -- assuming that --> got payment status from payment gateway (BANK/CARDD etc).....
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
    SELECT 'Session & Bookings cancelled successfully' AS success_message;
 END //
DELIMITER ;
 

