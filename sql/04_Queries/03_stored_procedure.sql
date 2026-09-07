CALL RegisterMember('Member1', 'Member1', 'member1@example.com', 'password123', '1234567890', '1990-01-01');


 -- Member Registration
 -- **********************
 
 DELIMITER //
 CREATE PROCEDURE RegisterMember (
   IN p_first_name VARCHAR(100),
   IN p_last_name VARCHAR(100),
   IN p_email_id VARCHAR(150),
   IN p_password VARCHAR(50),
   IN p_phone_no VARCHAR(20),
   IN p_date_of_birth DATE,
 )
 BEGIN
     IF EXISTS (SELECT 1 FROM Members WHERE email_id = p.email_id)
     THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT = 'Email already exists!';
     END IF;
    INSERT INTO Members (first_name, last_name, email_id, password, phone_no, date_of_birth)
    VALUES (p_first_name, p_last_name, p_email_id, p_password, p_phone_no, p_date_of_birth);
 
 END //
DELIMITER ;
 

