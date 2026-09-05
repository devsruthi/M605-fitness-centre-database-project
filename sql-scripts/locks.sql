-- TRANSACTION ONE

START TRANSACTION;
SELECT * FROM orders WHERE order_id = 1 FOR UPDATE; -- Locks the row
UPDATE orders SET o_status = 'shipped' WHERE order_id = 1;
COMMIT; -- Lock released

-- -- TRANSACTION TWO
UPDATE orders SET o_status = 'delivered' WHERE order_id = 1; -- BLOCKED until Transaction 1 commits

--  LOCKING THE ENTIRE TABLE 
LOCK TABLES orders WRITE;
-- Now no other transaction can read or write to 'orders'
INSERT INTO orders VALUES (30, 101, '2024-11-01', 1200.00, 'Pending');
UNLOCK TABLES; -- Releases lock



