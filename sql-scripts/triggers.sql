DELIMITER //
CREATE TRIGGER log_order_insert
AFTER INSERT ON ORDERS
FOR EACH ROW
BEGIN
    INSERT INTO Order_Lo1g (order_id, customer_id, order_date, total_amount)
    VALUES (NEW.order_id, NEW.customer_id, NEW.order_date, NEW.total_amount);
END //
DELIMITER ;