
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

CREATE TABLE Trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL UNIQUE,
    phone_no VARCHAR(20),
    years_of_experience INT NOT NULL CHECK (years_of_experience >= 0),
    certification VARCHAR(100),
    qualification VARCHAR(100),
    location VARCHAR(100),
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE Subscription_Plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(170) NOT NULL,
    duration_in_months INT NOT NULL CHECK (duration_in_months > 0),
    plan_price DECIMAL(15, 2) NOT NULL CHECK (plan_price >= 0),
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

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(15, 2) NOT NULL CHECK (payment_amount >= 0),
    payment_method ENUM(
        'CREDIT_CARD',
        'DEBIT_CARD',
        'PAYPAL',
        'BANK_TRANSFER'
    ) NOT NULL,
    payment_status ENUM('SUCCESS', 'FAILED', 'PENDING') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (subscription_id) REFERENCES Member_Subscriptions (subscription_id)
);

CREATE TABLE Service_Types (
    service_type_id INT AUTO_INCREMENT PRIMARY KEY,
    service_type_name VARCHAR(100) NOT NULL UNIQUE,
    service_type_description VARCHAR(250) NOT NULL,
    max_participants INT NOT NULL CHECK (
        max_participants > 0
        AND max_participants <= 50
    ),
    service_mode ENUM('GROUP', 'PERSONAL') NOT NULL DEFAULT 'GROUP',
    service_type_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE Sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    service_type_id INT NOT NULL,
    trainer_id INT NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    session_mode ENUM('ONLINE', 'OFFLINE') NOT NULL DEFAULT 'OFFLINE',
    session_location VARCHAR(100),
    session_status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    FOREIGN KEY (service_type_id) REFERENCES Service_Types (service_type_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainers (trainer_id),
    CHECK (start_time < end_time),
    CHECK (
        session_mode = 'OFFLINE'
        AND session_location IS NULL
        OR session_mode = 'ONLINE'
        AND session_location IS NOT NULL
    )
);

CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    session_id INT NOT NULL,
    booking_created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    booking_cancelled_time DATETIME,
    booking_status ENUM ('BOOKED','CANCELLED') NOT NULL DEFAULT 'BOOKED',
    FOREIGN KEY(member_id) REFERENCES Members (member_id),
    FOREIGN KEY (session_id) REFERENCES Sessions (session_id) 
);










