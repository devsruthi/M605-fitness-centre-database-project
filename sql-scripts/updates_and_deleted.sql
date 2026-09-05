
-- Update the first customer
UPDATE Customers
SET email = 'newemail1@example.com', phone_number = '1234567890'
WHERE customer_id = 1;

Select * from customers where customer_id = 1;

-- updating the customer id
UPDATE Customers
SET customers.customer_id = 7
WHERE customer_id = 80;

Select * from customers;

delete from customers where customer_id = 87;

INSERT INTO Customers (first_name, last_name, email, phone_number, registration_date, country)
VALUES ('New', 'testuser', 'new1-uszer@example.com', '1234567890', '2024-01-05', 'MALI');


-- Update the first product
UPDATE Products
SET price = 1999, stock = 150
WHERE product_id = 1;


-- Delete the product with product_id = 1
DELETE FROM Products
WHERE product_id = 35;
