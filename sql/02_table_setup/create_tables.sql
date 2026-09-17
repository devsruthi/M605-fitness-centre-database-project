--  CREATE TABLES 
-- *********************************************************************

CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,
    phone_no VARCHAR(20),
    date_of_birth DATE NOT NULL,
    account_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    joining_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE Trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL UNIQUE,
    phone_no VARCHAR(20),
    city VARCHAR(100),
    total_experience_years INT NOT NULL CHECK (total_experience_years > 0),
    account_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    hired_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

CREATE TABLE Subscription_Plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(170) NOT NULL UNIQUE,
    duration_in_months INT NOT NULL CHECK (duration_in_months > 0),
    plan_price DECIMAL(15, 2) NOT NULL CHECK (plan_price >= 0),
    plan_description VARCHAR(250),
    plan_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    group_classes_access BOOLEAN NOT NULL DEFAULT TRUE,
    personal_training_access BOOLEAN NOT NULL DEFAULT FALSE,
    exclusive_services BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE Member_Subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE,
    subscription_status ENUM('PENDING', 'ACTIVE', 'EXPIRED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (member_id) REFERENCES Members (member_id),
    FOREIGN KEY (plan_id) REFERENCES Subscription_Plans (plan_id)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(15, 2) NOT NULL CHECK (payment_amount >= 0),
    payment_method ENUM(
        'CREDIT_CARD','DEBIT_CARD','PAYPAL','BANK_TRANSFER'
    ) NOT NULL,
    payment_status ENUM('SUCCESS', 'FAILED', 'PENDING') NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (subscription_id) REFERENCES Member_Subscriptions (subscription_id)
);

CREATE TABLE Service_Types (
    service_type_id INT AUTO_INCREMENT PRIMARY KEY,
    service_type_name VARCHAR(100) NOT NULL UNIQUE,
    service_type_description VARCHAR(250) NOT NULL,
    service_mode ENUM('GROUP', 'PERSONAL') NOT NULL DEFAULT 'GROUP',
    max_participants INT NOT NULL,
    service_type_status ENUM('ACTIVE', 'INACTIVE') NOT NULL DEFAULT 'ACTIVE',
    CHECK (
        (
            service_mode = 'PERSONAL'
            AND max_participants = 1
        )
        OR (
            service_mode = 'GROUP'
            AND max_participants > 1 AND max_participants <= 20
        )
    )
);

CREATE TABLE Sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    service_type_id INT NOT NULL,
    trainer_id INT NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    duration_in_minutes INT NOT NULL DEFAULT 30 CHECK (duration_in_minutes >= 30),
    session_mode ENUM('ONLINE', 'OFFLINE') NOT NULL DEFAULT 'OFFLINE',
    session_room VARCHAR(100),
    session_cancelled_time DATETIME,
    session_cancelled_reason VARCHAR(250),
    session_status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    FOREIGN KEY (service_type_id) REFERENCES Service_Types (service_type_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainers (trainer_id),
    CHECK (
        (
            session_mode = 'OFFLINE' AND session_room IS NOT NULL
        )
        OR (
            session_mode = 'ONLINE' AND session_room IS NULL
        )
    )
);

CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    session_id INT NOT NULL,
    booking_created_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    booking_cancelled_time DATETIME,
    booking_cancelled_reason VARCHAR(250),
    booking_cancelled_by ENUM('MEMBER','SYSTEM'),
    booking_status ENUM ('BOOKED','CANCELLED') NOT NULL DEFAULT 'BOOKED',
    FOREIGN KEY(member_id) REFERENCES Members (member_id),
    FOREIGN KEY (session_id) REFERENCES Sessions (session_id),
    UNIQUE (member_id, session_id)  -- A member cannot have multiple bookings for the same session 
);

-- Session Change Impact Management

CREATE TABLE Session_updations(
    session_update_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    trainer_id INT NOT NULL,
    session_date DATE NOT NULL,
    start_time DATETIME NOT NULL,
    session_room VARCHAR(100) NOT NULL,
    session_mode ENUM('ONLINE', 'OFFLINE') NOT NULL DEFAULT 'OFFLINE',
    updation_type ENUM('TRAINER_CHANGED','TIME_CHANGED','ROOM_CHANGED','MODE_CHANGED','OTHER') NOT NULL,
    updation_reason VARCHAR(250) NOT NULL,
    session_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES Sessions (session_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainers (trainer_id)
);

CREATE TABLE Session_updation_Responses (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    session_update_id INT NOT NULL,
    booking_id INT NOT NULL,
    response_status ENUM('PENDING', 'ACCEPTED', 'DECLINED') NOT NULL DEFAULT 'PENDING',
    response_reason VARCHAR(250),
    response_created_at DATETIME,
    FOREIGN KEY (session_update_id) REFERENCES Session_updations (session_update_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings (booking_id),
    CHECK (
        (
            response_status = 'PENDING' AND response_created_at IS NULL
        )
        OR (
            response_status IN ('ACCEPTED', 'DECLINED') AND response_created_at IS NOT NULL
        )
    )
);


-- Maintaining Log (during trigger)
CREATE TABLE Member_Details_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email_id VARCHAR(150) NOT NULL,
    phone_no VARCHAR(20),
    date_of_birth DATE NOT NULL,
    account_status ENUM('ACTIVE', 'INACTIVE') NOT NULL,
    joining_date DATE NOT NULL,
    logged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES Members (member_id)
);


