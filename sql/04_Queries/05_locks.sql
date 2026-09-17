
SELECT * FROM Sessions;

--  LOCKS 
-- *********************************************************************

-- 1) Booking a Session by a Member
-- *********************************

START TRANSACTION;

SET @session_id = 7;
SET @member_id = 1;

-- Locking the session row until booking is confirmed
SELECT s.session_id, st.max_participants
FROM Sessions s
JOIN Service_Types st ON st.service_type_id = s.service_type_id
WHERE s.session_id = @session_id FOR UPDATE;

-- count current bookings 
SELECT COUNT(*) AS booked
FROM Bookings
WHERE session_id = @session_id
  AND booking_status = 'BOOKED';

INSERT INTO BookSession (member_id, session_id)
VALUES (@member_id, @session_id);

COMMIT; 

