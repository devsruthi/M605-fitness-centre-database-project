INSERT INTO Members (first_name, last_name, email_id, password, Phone_no, date_of_birth, joining_date)
VALUES ('Sailu', 'Sajeev', 'sailu@example.com','sailu*123 ', '1324567990', '2002-01-15', '2026-08-01');

INSERT INTO Trainers (supplier_name, contact_name, phone, country)
VALUES ('New Supplier', 'New Name', '9876543210', 'Brazil');

INSERT INTO Subscription_Plans (product_name, category, price, stock, supplier_id)
VALUES ('Laptop', 'Electronics', 1200.00, 50, null);  -- Supplier ID links to TechSupply

INSERT INTO Member_Subscriptions (customer_id, order_date, total_amount, o_status)
VALUES (6, '2024-11-01', 1200.00, 'Pending');  -- Customer ID links to John Doe

INSERT INTO Payments (order_id, product_id, quantity, price_each)
VALUES (1, 1, 1, 1200.00);  -- Order ID and Product ID link to relevant rows

INSERT INTO Service_Types (order_id, transaction_date, payment_method, amount)
VALUES (1, '2024-10-01', 'Credit Card', 1200.00);  -- Order ID links to the first order


INSERT INTO Sessions (order_id, transaction_date, payment_method, amount)
VALUES (1, '2024-10-01', 'Credit Card', 1200.00);  -- Order ID links to the first order

INSERT INTO Bookings (order_id, transaction_date, payment_method, amount)
VALUES (1, '2024-10-01', 'Credit Card', 1200.00);  -- Order ID links to the first order