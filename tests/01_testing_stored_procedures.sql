
--  STORED PROCEDURES  TESTING 
-- *********************************************************************

-- SECTIONS
-- ***********

-- 1) ANALYSIS & REPORTS  
-- 2) MEMBER FLOW
-- 3) ADMIN FLOW
-- 4) Session Impact Module


-- 1) ANALYSIS & REPORTS
-- *********************************************
 CALL SubscriptionPlanPopularity();
 CALL ViewPaymentMethodPerformance();
 CALL ViewYearlyRevenue(2026);
 CALL ViewRevenueDashboard('2026-01-01', '2026-07-01');
 CALL MembersWithFailedPayments(2); -- (frequency of failed payments)
 CALL MostPopularServices();
 CALL IdentifyMostCancelledSessions();
 CALL ViewUpcomingSessions(11, 2026); -- (month, year)
 CALL MembersWithoutBookings();
 CALL FutureSessionsWithAvailablitity();


-- 2) MEMBER FLOW
-- *********************************************
-- 1) Member Registration
-- 2) Member Login
-- 3) View Member Details
-- 4) Add Subscription Plan
-- 5) Purchase Subscription Plan
-- 6) Book Session
-- 7) Respond to Session Update



-- 1. Member Registration

SET @member_id = NULL;
SET @subscription_id = NULL;

CALL MemberRegistration('Test', 'Member', 
'test@example.com', 'password@123', '1234567890', '1990-01-01', @member_id);

-- 2. Member Login
CALL MemberLogin('test@example.com', 'password@123');

-- 3. View Member Details
CALL ViewMemberDetails(@member_id);

-- 4. Add Subscription Plan

SELECT * FROM Subscription_Plans;

CALL AddSubscription(@member_id, 2, @subscription_id); -- (member_id, plan_id, subscription_id )

SELECT @subscription_id;

-- 5. Purchase Subscription Plan
CALL PurchaseSubscriptionPlan(@subscription_id, 'CREDIT_CARD'); -- (subscription_id, payment_method)

SELECT * FROM Sessions;

-- 6. Book a Session
CALL BookSession(@member_id, 17); -- (member_id, session_id)

 -- 3) ADMIN FLOW
 -- ***********************************************

 -- 1. Cancel scheduled Session
 CALL CancelSession(1); -- (session_id)

 -- 2. Cancellesd Bookings Analysis
  CALL CanceledBookingsAnalysis();


-- 4) SESSION IMPACT MODULE
-- ***********************************************

SET @session_id = 49;

-- session update  (eg:changing trainer )
 CALL SessionUpdate(@session_id,2, NULL, NULL, NULL,NULL, 'TRAINER_CHANGED','Current trainer is not available',@session_update_id); 
 -- (session_id, update_trainer, update_date, update_time, update_room, update_mode, update_type, update_reason)

 -- Member responds to session updates

 SELECT * FROM Bookings WHERE session_id = @session_id AND booking_status = 'BOOKED';

CALL SessionUpdateResponse(@session_update_id, 59, 'ACCEPTED', 'Happy to continue with the new trainer changes.');
-- (session_update_id, booking_id, response_status, response_reason)

SELECT * FROM Session_updation_Responses;


CALL MostAffectedSessionsAnalysis();
CALL SessionChangeDeclinesByUpdationType();
CALL SessionChangeDeclinesByService();
CALL SessionChangeResponseDashboard();
CALL MembersWhoDeclinedSessionChanges();
CALL MostAffectedClientsAnalysis();
CALL BookingsCancelledDueToSessionChange(9, 2026); -- (month, year)
CALL BookingsCancelledDueToSessionChange(NULL, 2026); -- (year)
CALL PendingSessionChangeResponses();
