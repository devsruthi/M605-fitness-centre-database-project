

--  INDEX TESTING 
-- *********************************************************************

-- 1) Upcoming / scheduled sessions

SHOW INDEX FROM Sessions;

-- Step 1 — Run before creating the index
EXPLAIN
SELECT session_id, session_date, start_time, session_status
FROM Sessions
WHERE session_status = 'SCHEDULED' AND session_date >= CURDATE();
  
-- Step 2- create Index
CREATE INDEX idx_sessions_date
ON Sessions (session_date);

-- Step 3 — Run after creating the index
EXPLAIN
SELECT session_id, session_date, start_time, session_status
FROM Sessions
WHERE session_status = 'SCHEDULED' AND session_date >= CURDATE();

SHOW INDEX FROM Sessions;


-- Step 4 — force the index
EXPLAIN
SELECT session_id, session_date, start_time, session_status
FROM Sessions FORCE INDEX (idx_sessions_date)
WHERE session_status = 'SCHEDULED' AND session_date >= CURDATE();


