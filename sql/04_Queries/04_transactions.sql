
-- ============================= TRANSACTIONS =========================================


-- 1) SUBSCRIPTION PLAN PURCHASE & ACTIVATION 
-- *******************************************************

-- TASKS INCLUDED :
-- -------------------------------
-- 1) Purchasing a subscription
-- 2) Activating the subscription (Updating member_subscriptions status to ACTIVE)


-- =============START TRANSACTION ======================

  START TRANSACTION;

  -- 1) Purchasing a subscription

  INSERT INTO Payments (subscription_id, payment_date, 
  payment_amount, payment_method, payment_status)
  VALUES (@subscription_id, CURDATE(), @payment_amount, 'CREDIT_CARD', @payment_status_from_gateway);


  -- 2) Activating the subscription (Updating member_subscriptions status to ACTIVE)
  -- only if payment from gateway is SUCCESS
  -- if payment is FAILED, this update will not run, then COMMIT keeps the failed payment

  UPDATE Member_Subscriptions
  SET subscription_status = 'ACTIVE', 
  start_date = CURDATE()
  WHERE subscription_id = @subscription_id
  AND @payment_status_from_gateway = 'SUCCESS';

  COMMIT;

 -- =============END TRANSACTION ======================

 -- * TESTING *
 -- ---------------------------------

SELECT * FROM Members;
SELECT * FROM Subscription_Plans;
SELECT * FROM Member_Subscriptions;
 
 -- 1) Initializing the variables

SET @subscription_id = NULL;
SET @member_id = 1;
SET @plan_id = 2;
SET @payment_amount = 149.99;
SET @payment_status_from_gateway = 'SUCCESS';
-- SET @payment_status_from_gateway = 'FAILED';

 -- 2) Adding a subscription plan to the cart
 CALL AddSubscriptionPlan(@member_id, @plan_id, @subscription_id); -- (member_id, plan_id, subscription_id (output parameter))
 
-- 3) Check the subscription status & payment history before the TRANSACTION

SELECT subscription_id, subscription_status 
FROM Member_Subscriptions WHERE member_id = @member_id 
AND subscription_id = @subscription_id;   -- Query 1

SELECT payment_id, payment_date, payment_amount, payment_method, payment_status 
FROM Payments WHERE subscription_id = @subscription_id;   -- Query 2

-- 4) EXECUTE TRANSACTION 
-- 5) Execute Queries 1& 2


-- ==================================================================================================================================


 -- 2) CANCELLING A SESSION  BY ADMIN/TRAINER
-- ***********************************************************

-- TASKS INCLUDED :
-- --------------------------------
-- 1) Cancelling a session
-- 2) Cancelling all the bookings related to the session

 -- =============START TRANSACTION ======================

  START TRANSACTION;

  -- 1) cancelling the session

  Update Sessions 
  SET session_status = 'CANCELLED', cancelled_time = CURDATE()
  WHERE session_id = @session_id;

  -- 2) cancelling the bookings

  Update Bookings 
  SET booking_status = 'CANCELLED', cancelled_time = CURDATE()
  WHERE session_id = @session_id;

  COMMIT;
-- =============END TRANSACTION ======================

  -- * TESTING *
-- -------------------------------
SELECT * FROM Sessions;
SELECT * FROM Bookings;

 -- 1) Initializing the variables
SET @session_id = 1;

 -- 2) Checking the session status & booking status before the TRANSACTION

SELECT * FROM Sessions WHERE session_id = @session_id;  -- Query 1

SELECT * FROM Bookings WHERE session_id = @session_id;   -- Query 2

 -- 3) EXECUTE TRANSACTION 
 -- 4) Execute Queries 1& 2