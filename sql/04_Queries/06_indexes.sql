

--  CREATE INDEXES 
-- *********************************************************************

CREATE INDEX idx_sessions_date
ON Sessions (session_date);

CREATE INDEX idx_bookings_status
ON Bookings (booking_status);

CREATE INDEX idx_member_subs_status
ON Member_Subscriptions (subscription_status);

CREATE INDEX idx_sur_status
ON Session_updation_Responses (response_status);

CREATE INDEX idx_sessions_status_date
ON Sessions (session_status, session_date);

CREATE INDEX idx_payments_status_date
ON Payments (payment_status, payment_date);

-- ********************** DROP INDEXES **********************

DROP INDEX idx_sessions_date ON Sessions;

DROP INDEX idx_sessions_status_date ON Sessions;

DROP INDEX idx_payments_status_date ON Payments;

DROP INDEX idx_bookings_status ON Bookings;

DROP INDEX idx_member_subs_status ON Member_Subscriptions;

DROP INDEX idx_sur_status ON Session_updation_Responses;

