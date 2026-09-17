
-- ======================== TEST DATA ========================


-- PLANS
-- ids: 1, 2, 3
-- plan_id 1 = Classic  (group classes only, no PT)
-- plan_id 2 = Premium  (group classes + PT)
-- plan_id 3 = Gold     (group classes + PT + exclusive)


-- MEMBERS WITH ACTIVE SUBSCRIPTION  (can book group sessions)
--ids: 
-- Classic : 5, 9, 15, 19, 22, 25, 29
-- Premium : 1, 3, 6, 14, 17, 21, 24, 27, 30
-- Gold    : 2, 7, 8, 16, 23, 26, 28
-- All ACTIVE ids: 1, 2, 3, 5, 6, 7, 8, 9, 14, 15, 16, 17, 19, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30
-- PT access (Premium + Gold): 1, 2, 3, 6, 7, 8, 14, 16, 17, 21, 23, 24, 26, 27, 28, 30


-- MEMBERS WITH NO ACTIVE SUBSCRIPTION  (booking should fail)
-- ids: 
-- Never subscribed     : 11, 12, 13, 35
-- Expired / cancelled  : 4, 10, 20
-- PENDING (not paid)   : 18, 31, 32, 33, 34
-- INACTIVE user accounts    : 13, 20, 35


-- SESSIONS
-- ids :
-- COMPLETED : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 43, 44
-- CANCELLED : 13, 14, 31, 52, 53, 56, 58, 59
-- SCHEDULED : 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
--             32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
--             45, 46, 47, 48, 49, 50, 51, 54, 55, 57, 60, 61
--


-- USEFUL TEST CASES

-- BookSession SUCCESS          : member 1, session 34
-- BookSession FAIL no plan     : member 11, session 34
-- BookSession FAIL PENDING     : member 18, session 34
-- BookSession FAIL Classic+PT  : member 5, session 23
-- BookSession SUCCESS Gold+PT  : member 2, session 28
-- Duplicate booking FAIL       : member 1, session 15  (already booked)
-- CancelSession                : session 61
-- SessionUpdate                : session 60

