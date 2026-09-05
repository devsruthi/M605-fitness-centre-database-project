SELECT *FROM Customers;
SELECT * from Orders;

-- ============================= INNER JOIN (JOIN) =======================

-- Query 1: List All Orders with Customer Information
SELECT 
    Customers.customer_id, 
    Customers.first_name, 
    Customers.last_name, 
    Orders.order_id, 
    Orders.order_date, 
    Orders.total_amount
FROM 
    Customers
INNER JOIN 
    Orders ON Customers.customer_id = Orders.customer_id;
    
-- DROP and ALTER
-- ===============================================================
-- Query 2: Find Each Product's Supplier

SELECT 
    Products.product_id, 
    Products.product_name, 
    Suppliers.supplier_name, 
    Suppliers.country
FROM 
    Products
INNER JOIN 
    Suppliers ON Products.supplier_id = Suppliers.supplier_id;

-- ===============================================================
 -- Query 3: List All Orders with Product Details

 SELECT 
    Orders.order_id, 
    Orders.order_date, 
    Products.product_name, 
    Order_Details.quantity, 
    Order_Details.price_each
FROM 
    Orders
INNER JOIN 
    Order_Details ON Orders.order_id = Order_Details.order_id
INNER JOIN 
    Products ON Order_Details.product_id = Products.product_id;

-- ==============================================================
-- Query 4: Calculate Total Amount Spent by Each Customer

SELECT 
    Customers.customer_id, 
    Customers.first_name, 
    Customers.last_name, 
    SUM(Order_Details.quantity * Order_Details.price_each) AS total_spent
FROM 
    Customers
INNER JOIN 
    Orders ON Customers.customer_id = Orders.customer_id
INNER JOIN 
    Order_Details ON Orders.order_id = Order_Details.order_id
GROUP BY 
    Customers.customer_id, Customers.first_name, Customers.last_name;

-- ================================= LEFT OUTER JOIN (LEFT JOIN) ==================================

-- Query 1: List All Customers and Their Orders (Including Customers without Orders)

SELECT 
    Customers.customer_id, 
    Customers.first_name, 
    Customers.last_name, 
    Orders.order_id, 
    Orders.order_date, 
    Orders.total_amount
FROM 
    Customers
LEFT JOIN 
    Orders ON Customers.customer_id = Orders.customer_id;

-- ============================================================
-- Query 2: Identify inactive customers (those without orders).
SELECT 
    Customers.customer_id, 
    Customers.first_name, 
    Customers.last_name
FROM 
    Customers
LEFT JOIN 
    Orders ON Customers.customer_id = Orders.customer_id
WHERE 
    Orders.order_id IS NULL;

-- ================================= RIGHT OUTER JOIN (RIGHT JOIN) ==================================

-- Query 1 : List All Suppliers with Products (Including Products with No Supplier Information)
SELECT 
    Products.product_id, 
    Products.product_name, 
    Suppliers.supplier_name, 
    Suppliers.contact_name
FROM 
    Products
RIGHT JOIN 
    Suppliers ON Products.supplier_id = Suppliers.supplier_id;

 -- ================================= FULL OUTER JOIN (Full JOIN) ==================================
 

 SELECT 
    Products.product_id, 
    Products.product_name, 
    Suppliers.supplier_id, 
    Suppliers.supplier_name
FROM 
    Products
LEFT JOIN   -- The first table Products is the left table, and all its rows are included. 
    Suppliers ON Products.supplier_id = Suppliers.supplier_id

UNION

SELECT 
    Products.product_id, 
    Products.product_name, 
    Suppliers.supplier_id, 
    Suppliers.supplier_name
FROM 
    Products
RIGHT JOIN -- The second table Suppliers is the right table, and all its rows are included.
    Suppliers ON Products.supplier_id = Suppliers.supplier_id;


