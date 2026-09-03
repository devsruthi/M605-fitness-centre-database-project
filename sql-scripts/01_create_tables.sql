
-- CREATE TABLE Roles (
--     role_id INT AUTO_INCREMENT PRIMARY KEY,
--     role_name VARCHAR(50) NOT NULL UNIQUE,
--     role_description VARCHAR(250) NOT NULL
-- );

-- CREATE TABLE Users (
--     user_id INT AUTO_INCREMENT PRIMARY KEY,
--     first_name VARCHAR(100) NOT NULL,
--     last_name VARCHAR(100) NOT NULL,
--     email_id VARCHAR(150) NOT NULL UNIQUE,
--     Phone_no VARCHAR(20),
--     account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
--     role_id INT NOT NULL,
--     FOREIGN KEY (role_id) REFERENCES Roles (role_id)
-- );


CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL UNIQUE,
    Phone_no VARCHAR(20),
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    date_of_birth DATE,
    joining_date DATE NOT NULL
);


CREATE TABLE Subscription_Plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(170) NOT NULL,
    duration_in_months INT NOT NULL CHECK (duration_in_months > 0),
    plan_price DECIMAL(15 , 2 ) NOT NULL CHECK (plan_price >= 0 ),
    plan_description VARCHAR(250),
    plan_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    
);

CREATE TABLE Member_Subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    subscription_status ENUM('ACTIVE', 'EXPIRED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (member_id) REFERENCES Members (member_id),
    CHECK (start_date <= end_date)
);







