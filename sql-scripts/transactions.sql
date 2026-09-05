SELECT * FROM products;
SELECT * FROM orders;


-- ================================================ Example # 01 =============================
START TRANSACTION;

-- Deduct stock
UPDATE Products
SET stock = stock - 5
WHERE product_id = 1;

-- Insert into Order_Details
INSERT INTO Order_Details (order_id, product_id, quantity, price_each)
VALUES (19, 136, 5, 50.00);

-- Update Orders total amount
UPDATE Orders
SET total_amount = total_amount + 250.00
WHERE order_id = 18;

COMMIT;  -- Commit the transaction

-- =============================================================== Testing Transactions ================================

CALL ProcessOrderTransaction(1, 'Credit Card', 150.00);
SELECT * FROM orders;
SELECT * FROM transactions;


SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_details;

UPDATE Products
SET stock = 50
WHERE product_id = 136;
    
DELETE FROM order_details WHERE order_detail_id > 5;

CALL HandleOrder(26, 136, 29, 50.00);  -- order_id, product_id, quantity, price (place holder value)


