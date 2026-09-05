CALL GetCustomerOrders (1);

Call GetCustomerOrders (5);

Call GetCustomerOrders (6);
 
SELECT *from  products;
 
 
SET @status = '';
CALL CheckStock(1, @status);  -- in stock

SELECT 
    CASE 
        WHEN @status = 'In Stock' THEN 
            (SELECT 'Insert into Order_Details' AS message)
        ELSE 
            (SELECT 'Product is out of stock' AS message)
    END AS Result;

 