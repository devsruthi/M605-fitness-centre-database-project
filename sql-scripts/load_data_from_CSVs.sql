
LOAD DATA LOCAL INFILE 'C:/Users/mhameed/OneDrive - GAHL Services Limited/Desktop/GISMA SQL/GISMA_Ecommerce_Data/customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ','  -- CSV delimiter
ENCLOSED BY '"'           -- Enclosing character for text (optional)
LINES TERMINATED BY '\n'  -- New line to mark each record
IGNORE 1 LINES            -- Ignore the first row (header)
(customer_id, first_name, last_name, email, phone_number, registration_date, country);

LOAD DATA LOCAL INFILE 'C:/Users/mhameed/OneDrive - GAHL Services Limited/Desktop/GISMA SQL/GISMA_Ecommerce_Data/orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_id, order_date, total_amount, o_status, customer_id);


LOAD DATA LOCAL INFILE 'C:/Users/mhameed/OneDrive - GAHL Services Limited/Desktop/GISMA SQL/GISMA_Ecommerce_Data/transactions.csv'
INTO TABLE Transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(transaction_id, transaction_date, payment_method, amount,order_id);

LOAD DATA LOCAL INFILE 'C:/Users/mhameed/OneDrive - GAHL Services Limited/Desktop/GISMA SQL/GISMA_Ecommerce_Data/suppliers.csv'
INTO TABLE Suppliers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(supplier_id, supplier_name, contact_name, phone, country);

LOAD DATA LOCAL INFILE 'C:/Users/mhameed/OneDrive - GAHL Services Limited/Desktop/GISMA SQL/GISMA_Ecommerce_Data/products.csv'
INTO TABLE Products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_name, category, price, stock, supplier_id);

LOAD DATA LOCAL INFILE 'C:/Users/mhameed/OneDrive - GAHL Services Limited/Desktop/GISMA SQL/GISMA_Ecommerce_Data/order_details.csv'
INTO TABLE Order_Details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(order_detail_id, order_id, product_id, quantity, price_each);

