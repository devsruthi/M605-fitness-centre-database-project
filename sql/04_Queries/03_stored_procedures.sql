

-- ==================================STORED PROCEDURES =============================================

-- ***************** ANALYSIS & REPORTS ***************************

-- 1) Popularity rank of subscription plans in the entire history
-- --------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE SubscriptionPlanPopularity ()
BEGIN
    SELECT sp.plan_name,COUNT(ms.subscription_id) AS total_subscriptions
    FROM Subscription_Plans sp
    JOIN Member_Subscriptions ms ON sp.plan_id = ms.plan_id 
    GROUP BY sp.plan_id ORDER BY total_subscriptions DESC;
END //
DELIMITER ;

-- 1) Payment method performance (Comparing the payment methods performance,most success rate giving first)
-- -------------------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ViewPaymentMethodPerformance ()
BEGIN
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
   END //
    DELIMITER ;

-- 2) Revenue details : monthly revenue in a specific year (eg: 2026)
-- only listing months with successful payments
-- --------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ViewYearlyRevenue (IN p_year INT)
BEGIN
    SELECT
    DATE_FORMAT(p.payment_date, '%b, %Y') AS payment_month,
    COUNT(*) AS successful_payments,
    CONCAT(SUM(p.payment_amount), ' €') AS total_revenue,
    CONCAT(ROUND(AVG(p.payment_amount), 2), ' €') AS average_payment
    FROM Payments p
    WHERE p.payment_status = 'SUCCESS' AND YEAR(p.payment_date) = p_year
    GROUP BY YEAR(p.payment_date),MONTH(p.payment_date),
    DATE_FORMAT(p.payment_date, '%b, %Y')
    ORDER BY YEAR(p.payment_date),MONTH(p.payment_date);
END //
DELIMITER ;

--3) Revenue Dashboard for a selected time period 
-- (total and average successful payments & amounts per plan)
-- (selected time period: 2026-01-01 to 2026-07-01)
-- --------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ViewRevenueDashboard (IN p_start_date DATE, IN p_end_date DATE)
BEGIN
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
    LEFT JOIN Member_Subscriptions ms ON sp.plan_id = ms.plan_id
    LEFT JOIN Payments p ON p.subscription_id = ms.subscription_id
    AND p.payment_date >= p_start_date AND p.payment_date < p_end_date
    GROUP BY sp.plan_id,sp.plan_name
    ORDER BY SUM(CASE WHEN p.payment_status = 'SUCCESS' THEN p.payment_amount ELSE 0 END) DESC;
END //
DELIMITER ;

-- 4) Most popular services (in terms of bookings)
-- --------------------------------------------------------
DELIMITER //
CREATE PROCEDURE MostPopularServices ()
BEGIN
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
END //
DELIMITER ;

-- 5) Identify upcoming sessions in a specific month (eg: November 2026)
-- --------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE ViewUpcomingSessions (IN p_month INT, IN p_year INT)
BEGIN
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
    WHERE s.session_status = 'SCHEDULED' AND MONTH(s.session_date) = p_month AND YEAR(s.session_date) = p_year
    ORDER BY s.session_date, s.start_time;
END //
DELIMITER ;

-- 5) Sessions with the greatest number of cancellations ( by admin/trainer)
-- --------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE IdentifyMostCancelledSessions ()
BEGIN
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
END //
DELIMITER ;


-- 4) Members who have failed payments more than 2 times
-- --------------------------------------------------------
DELIMITER //
CREATE PROCEDURE MembersWithFailedPayments (IN p_frequency INT)
BEGIN
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
    HAVING COUNT(*) > p_frequency
    ORDER BY failed_payment_count DESC;
END //
DELIMITER ;

-- 6) Members who have not made any bookings in the last 30 days
-- ----------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE MembersWithoutBookings ()
BEGIN
    SELECT
    m.member_id,
    CONCAT(m.first_name, ' ', m.last_name) AS member_name,m.email_id,
    COUNT(b.booking_id) AS total_bookings
    FROM Members m
    LEFT JOIN Bookings b ON m.member_id = b.member_id
    AND b.booking_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY m.member_id
    HAVING COUNT(b.booking_id) = 0
    ORDER BY total_bookings DESC;
END //
DELIMITER ;

-- 7) Future sessions : total bookings and available slots left for each upcoming session
-- --------------------------------------------------------
DELIMITER //
CREATE PROCEDURE FutureSessionsWithAvailablitity ()
BEGIN
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
END //
DELIMITER ;



-- *********************************** MEMBER FLOW ************************************

 -- 1) Member Registration
 -- ------------------------------
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
     DECLARE l_payment_status_from_gateway VARCHAR(10);

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
    SET l_payment_status_from_gateway = 'SUCCESS';

    INSERT INTO Payments (subscription_id, payment_date, payment_amount, payment_method, payment_status)
    VALUES (p_subscription_id, CURDATE(), l_plan_price, p_payment_method, l_payment_status_from_gateway);

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


-- 6) Session Booking : Member trying to book a specific session
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE BookSession (IN p_member_id INT,IN p_session_id INT)

 BEGIN
  DECLARE l_booking_id INT;

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
    SET l_booking_id = LAST_INSERT_ID();
    SELECT l_booking_id AS booking_id, member_id, p_session_id AS session_id, 'Congrats, you have successfully booked the session' AS success_message;
 END //
DELIMITER ;

-- 7) Member responds to a session update
-- --------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE SessionUpdateResponse (
    IN p_session_update_id INT,
    IN p_booking_id INT,
    IN p_response_status ENUM('ACCEPTED', 'DECLINED'),
    IN p_response_reason VARCHAR(250),
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Session_update_Responses
        WHERE session_update_id = p_session_update_id
          AND booking_id = p_booking_id
          AND response_status != 'PENDING'
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Your response has already been recorded!';
    END IF;

    INSERT INTO Session_update_Responses (session_update_id, booking_id, response_status, response_reason)
    VALUES (p_session_update_id, p_booking_id, p_response_status, p_response_reason);

    IF p_response_status = 'DECLINED' THEN
        UPDATE Bookings SET booking_status = 'CANCELLED', booking_cancelled_time = NOW()
        WHERE booking_id = p_booking_id;
    END IF;

    SELECT p_booking_id AS booking_id , p_response_status AS response_status,'Your response has been recorded' AS message;
END //
DELIMITER ;


-- 3) ADMIN FLOW
-- -------------------------------

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
  IN p_update_date DATE,
  IN p_update_time TIME,
  IN p_update_room VARCHAR(100),
  IN p_update_mode ENUM('ONLINE', 'OFFLINE'),
  IN p_update_type ENUM('TRAINER_CHANGED','TIME_CHANGED','ROOM_CHANGED','MODE_CHANGED','OTHER'),
  IN p_update_reason VARCHAR(250)
)
BEGIN
    DECLARE v_session_update_id INT;

    IF NOT EXISTS (
        SELECT 1 FROM Sessions
        WHERE session_id = p_session_id
          AND session_status = 'SCHEDULED' AND session_date >= CURDATE() AND start_time >= CURTIME()
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Scheduled session not found / Past session cannot be updated!';
    END IF;

    START TRANSACTION;

    UPDATE Sessions
    SET trainer_id = COALESCE(p_update_trainer, trainer_id),
        start_time = COALESCE(p_update_time, start_time),
        session_date = COALESCE(p_update_date, session_date),
        session_room = COALESCE(p_update_room, session_room),
        session_mode = COALESCE(p_update_mode, session_mode)
    WHERE session_id = p_session_id;

    -- Inserting into session update history tbale
    INSERT INTO Session_updates_History (
        session_id, update_trainer, update_date, update_time,
        update_room, update_mode, update_type, update_reason
    )
    SELECT
        s.session_id,
        s.trainer_id,
        s.session_date,
        TIMESTAMP(s.session_date, s.start_time),
        COALESCE(s.session_room, 'ONLINE'),
        s.session_mode,
        p_update_type,
        p_update_reason
    FROM Sessions s
    WHERE s.session_id = p_session_id;

    SET v_session_update_id = LAST_INSERT_ID();
    COMMIT;

    SELECT v_session_update_id AS session_update_id, p_session_id AS session_id, 
    (SELECT COUNT(*) FROM Bookings WHERE session_id = p_session_id AND booking_status = 'BOOKED') AS affected_bookings_count,
    p_update_type AS update_type, p_update_reason AS update_reason,
           'Session updated successfully. Notification sent to booked members.' AS success_message;
END //
DELIMITER ;



