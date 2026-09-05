SHOW INDEX FROM customers;
SHOW INDEX FROM orders;

CREATE INDEX idx_customer_name ON customers(first_name); 

-- use DROP command to delete an index
DROP INDEX idx_customer_name ON customers;

SELECT * FROM customers;

SELECT COUNT(*) FROM customers;
CALL InsertCustomers();

EXPLAIN SELECT * FROM Customers WHERE first_name = 'First1000000';



