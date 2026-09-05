
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
    personal_training_acccess BOOLEAN NOT NULL DEFAULT FALSE,
    exclusive_services BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE Member_Subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    subscription_status ENUM('ACTIVE', 'EXPIRED', 'CANCELLED') NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (member_id) REFERENCES Members (member_id),
    FOREIGN KEY (plan_id) REFERENCES Subscription_Plans (plan_id)
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
            AND max_participants > 1
            AND max_participants <= 20
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
    session_status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    FOREIGN KEY (service_type_id) REFERENCES Service_Types (service_type_id),
    FOREIGN KEY (trainer_id) REFERENCES Trainers (trainer_id),
    CHECK (
        (
            session_mode = 'OFFLINE'
            AND session_room IS NOT NULL
        )
        OR (
            session_mode = 'ONLINE'
            AND session_room IS NULL
        )
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
    FOREIGN KEY (session_id) REFERENCES Sessions (session_id),
    UNIQUE (member_id, session_id)  -- A member cannot have multiple bookings for the same session 
);










