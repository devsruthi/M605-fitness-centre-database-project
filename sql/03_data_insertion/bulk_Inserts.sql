INSERT INTO Members (first_name,last_name,email_id,password,phone_no,date_of_birth,account_status,joining_date)
VALUES
('Arun', 'Kumar', 'arun.kumar@example.com', 'Arun@123', '1512345678', '1999-03-12', 'ACTIVE', '2026-01-10'),

('Emma', 'Miller', 'emma.miller@example.com', 'Emma@123', '1523456789', '1997-07-24', 'ACTIVE', '2026-01-15'),

('Daniel', 'Brown', 'daniel.brown@example.com', 'Daniel@123', '1534567890', '2001-11-08', 'ACTIVE', '2025-02-01'),

('Anna', 'Schmidt', 'anna.schmidt@example.com', 'Anna@123', '1545678901', '1998-05-19', 'ACTIVE', '2026-02-10'),

('Rahul', 'Menon', 'rahul.menon@example.com', 'Rahul@123', '1556789012', '1996-09-03', 'ACTIVE', '2026-03-05'),

('Sofia', 'Weber', 'sofia.weber@example.com', 'Sofia@123', '1567890123', '2000-12-21', 'ACTIVE', '2026-03-18'),

('Michael', 'Wilson', 'michael.wilson@example.com', 'Michael@123', '1578901234', '1995-04-14', 'ACTIVE', '2026-04-02'),

('Nina', 'Fischer', 'nina.fischer@example.com', 'Nina@123', '1589012345', '2002-08-30', 'ACTIVE', '2025-04-20'),

('David', 'Thomas', 'david.thomas@example.com', 'David@123', '1590123456', '1999-10-11', 'ACTIVE', '2026-05-08'),

('Laura', 'Becker', 'laura.becker@example.com', 'Laura@123', '1601234567', '1997-02-27', 'ACTIVE', '2026-09-05');


INSERT INTO Subscription_Plans (
    plan_name,
    duration_in_months,
    plan_price,
    plan_description,
    plan_status,
    group_classes_access,
    personal_training_access,
    exclusive_services
)
VALUES
('Classic', 1, 29.99,
 'Basic membership with unlimited group class access.',
 'ACTIVE', TRUE, FALSE, FALSE),
 
('Premium', 6, 149.99,
 'Premium membership with unlimited group classes and personal training.',
 'ACTIVE', TRUE, TRUE, FALSE),
 
('Gold', 12, 399.99,
 'Gold membership with personal training, group classes and exclusive services.',
 'ACTIVE', TRUE, TRUE, TRUE);
 
INSERT INTO Member_Subscriptions (
    member_id,
    plan_id,
    start_date,
    subscription_status
)
VALUES

-- Member 1: Classic expired → Premium active
(1, 1, '2026-01-10', 'EXPIRED'),
(1, 2, '2026-07-10', 'ACTIVE'),

-- Member 2: Premium expired → Gold active
(2, 2, '2025-01-15', 'EXPIRED'),
(2, 3, '2026-03-15', 'ACTIVE'),

-- Member 3: Classic cancelled → Premium active
(3, 1, '2026-02-01', 'CANCELLED'),
(3, 2, '2026-05-01', 'ACTIVE'),

-- Member 4: Gold expired
(4, 3, '2024-01-10', 'EXPIRED'),

-- Member 5: Classic currently active
(5, 1, '2026-08-20', 'ACTIVE'),

-- Member 6: Premium currently active
(6, 2, '2026-06-15', 'ACTIVE'),

-- Member 7: Gold currently active
(7, 3, '2026-03-10', 'ACTIVE'),

-- Member 8: Classic expired → Gold active
(8, 1, '2026-02-20', 'EXPIRED'),
(8, 3, '2026-03-01', 'ACTIVE'),

-- Member 9: Premium cancelled → Classic active
(9, 2, '2026-01-01', 'CANCELLED'),
(9, 1, '2026-08-01', 'ACTIVE'),

-- Member 10: Classic cancelled
(10, 1, '2026-04-15', 'CANCELLED');


INSERT INTO Payments (
    subscription_id,
    payment_date,
    payment_amount,
    payment_method,
    payment_status
)
VALUES

-- =====================================================
-- MEMBER 1
-- Classic EXPIRED → Premium ACTIVE
-- =====================================================

(1, '2026-01-10', 29.99, 'CREDIT_CARD', 'SUCCESS'),

(2, '2026-07-10', 149.99, 'PAYPAL', 'SUCCESS'),

(2, '2026-07-09', 149.99, 'CREDIT_CARD', 'FAILED'),

-- =====================================================
-- MEMBER 2
-- Premium EXPIRED → Gold ACTIVE
-- =====================================================

(3, '2025-01-15', 149.99, 'DEBIT_CARD', 'SUCCESS'),

(4, '2026-03-15', 399.99, 'BANK_TRANSFER', 'SUCCESS'),

-- =====================================================
-- MEMBER 3
-- Classic CANCELLED → Premium ACTIVE
-- =====================================================

(5, '2026-02-01', 29.99, 'CREDIT_CARD', 'SUCCESS'),

(6, '2026-05-01', 149.99, 'PAYPAL', 'SUCCESS'),

(6, '2026-04-30', 149.99, 'DEBIT_CARD', 'FAILED'),

-- =====================================================
-- MEMBER 4
-- Gold EXPIRED
-- =====================================================

(7, '2024-01-10', 399.99, 'BANK_TRANSFER', 'SUCCESS'),

-- =====================================================
-- MEMBER 5
-- Classic ACTIVE
-- =====================================================

(8, '2026-08-20', 29.99, 'CREDIT_CARD', 'SUCCESS'),

-- =====================================================
-- MEMBER 6
-- Premium ACTIVE
-- =====================================================

(9, '2026-06-15', 149.99, 'PAYPAL', 'SUCCESS'),

(9, '2026-06-14', 149.99, 'CREDIT_CARD', 'FAILED'),

-- =====================================================
-- MEMBER 7
-- Gold ACTIVE
-- =====================================================

(10, '2026-03-10', 399.99, 'BANK_TRANSFER', 'SUCCESS'),

-- =====================================================
-- MEMBER 8
-- Classic EXPIRED → Gold ACTIVE
-- =====================================================

(11, '2026-02-20', 29.99, 'DEBIT_CARD', 'SUCCESS'),

(12, '2026-03-01', 399.99, 'CREDIT_CARD', 'SUCCESS'),

-- =====================================================
-- MEMBER 9
-- Premium CANCELLED → Classic ACTIVE
-- =====================================================

(13, '2026-01-01', 149.99, 'PAYPAL', 'SUCCESS'),

(14, '2026-08-01', 29.99, 'CREDIT_CARD', 'SUCCESS'),

(14, '2026-07-31', 29.99, 'CREDIT_CARD', 'FAILED'),

-- =====================================================
-- MEMBER 10
-- Classic CANCELLED
-- =====================================================

(15, '2026-04-15', 29.99, 'DEBIT_CARD', 'SUCCESS'),

-- =====================================================
-- ADDITIONAL PAYMENT ATTEMPTS
-- =====================================================

(2, '2026-07-10', 149.99, 'BANK_TRANSFER', 'PENDING'),

(4, '2026-03-14', 399.99, 'BANK_TRANSFER', 'PENDING'),

(8, '2026-08-19', 29.99, 'PAYPAL', 'FAILED'),

(10, '2026-03-09', 399.99, 'CREDIT_CARD', 'FAILED'),

(12, '2026-03-01', 399.99, 'BANK_TRANSFER', 'PENDING');

INSERT INTO Service_Types (
    service_type_name,
    service_type_description,
    service_mode,
    max_participants,
    service_type_status
)
VALUES

-- GROUP SERVICES
('Yoga',
 'Group yoga sessions focused on flexibility, balance and relaxation.',
 'GROUP', 20, 'ACTIVE'),

('Power Yoga',
 'Dynamic yoga sessions combining strength, flexibility and movement.',
 'GROUP', 15, 'ACTIVE'),

('Pilates',
 'Group sessions focused on core strength, posture and flexibility.',
 'GROUP', 15, 'ACTIVE'),

('HIIT',
 'High-intensity interval training for improving fitness and endurance.',
 'GROUP', 16, 'ACTIVE'),

('CrossFit',
 'Functional fitness sessions combining strength and conditioning exercises.',
 'GROUP', 12, 'ACTIVE'),

('Zumba',
 'High-energy group dance fitness sessions.',
 'GROUP', 20, 'ACTIVE'),

('Spin Cycling',
 'Indoor cycling sessions designed to improve cardiovascular fitness.',
 'GROUP', 18, 'ACTIVE'),

('Strength Training',
 'Group strength and conditioning sessions using resistance exercises.',
 'GROUP', 12, 'ACTIVE'),

('Mobility & Stretching',
 'Group sessions focused on mobility, flexibility and recovery.',
 'GROUP', 15, 'ACTIVE'),

('Meditation',
 'Guided group meditation sessions for relaxation and mental wellness.',
 'GROUP', 15, 'ACTIVE'),

('Fitness Workshop',
 'Special group workshops focused on fitness techniques and education.',
 'GROUP', 20, 'ACTIVE'),

-- PERSONAL SERVICES
('Personal Training',
 'One-to-one training sessions with a professional trainer.',
 'PERSONAL', 1, 'ACTIVE'),

('Nutrition Consultation',
 'Individual consultation focused on nutrition and wellness goals.',
 'PERSONAL', 1, 'ACTIVE'),

('Fitness Assessment',
 'Individual assessment of fitness level, goals and physical performance.',
 'PERSONAL', 1, 'ACTIVE'),

('Wellness Consultation',
 'Individual consultation focused on lifestyle and overall wellness.',
 'PERSONAL', 1, 'ACTIVE');
 
INSERT INTO Trainers (
    first_name,
    last_name,
    email_id,
    phone_no,
    city,
    total_experience_years,
    hired_date
)
VALUES

('Oliver', 'Hart', 'oliver.hart@wellness.de', '4915112345601', 'Berlin', 8, '2024-02-15'),

('Charlotte', 'Bennett', 'charlotte.bennett@wellness.de', '4915123456702', 'Hamburg', 6, '2024-05-10'),

('Ethan', 'Carter', 'ethan.carter@wellness.de', '4915134567803', 'Munich', 10, '2023-08-21'),

('Amelia', 'Brooks', 'amelia.brooks@wellness.de', '4915145678904', 'Berlin', 5, '2025-01-13'),

('Henry', 'Collins', 'henry.collins@wellness.de', '4915156789005', 'Cologne', 7, '2024-03-18'),

('Grace', 'Mitchell', 'grace.mitchell@wellness.de', '4915167890106', 'Frankfurt', 9, '2023-11-06'),

('Arthur', 'Turner', 'arthur.turner@wellness.de', '4915178901207', 'Berlin', 12, '2022-06-20'),

('Isla', 'Morgan', 'isla.morgan@wellness.de', '4915189012308', 'Stuttgart', 4, '2025-02-03'),

('George', 'Parker', 'george.parker@wellness.de', '4915190123409', 'Dusseldorf', 6, '2024-07-15'),

('Lily', 'Cooper', 'lily.cooper@wellness.de', '4915201234510', 'Leipzig', 8, '2023-09-11'),

('Jack', 'Edwards', 'jack.edwards@wellness.de', '4915212345611', 'Berlin', 11, '2022-10-17'),

('Emily', 'Foster', 'emily.foster@wellness.de', '4915223456712', 'Hamburg', 5, '2025-03-24'),

('William', 'Hughes', 'william.hughes@wellness.de', '4915234567813', 'Munich', 7, '2024-01-29'),

('Ella', 'Ward', 'ella.ward@wellness.de', '4915245678914', 'Cologne', 4, '2025-04-07'),

('James', 'Morris', 'james.morris@wellness.de', '4915256789015', 'Frankfurt', 9, '2023-05-22'),

('Chloe', 'Perry', 'chloe.perry@wellness.de', '4915267890116', 'Berlin', 6, '2024-09-02'),

('Alexander', 'Reed', 'alexander.reed@wellness.de', '4915278901217', 'Stuttgart', 10, '2023-02-13'),

('Lucy', 'Watson', 'lucy.watson@wellness.de', '4915289012318', 'Dusseldorf', 5, '2025-05-19'),

('Thomas', 'Bailey', 'thomas.bailey@wellness.de', '4915290123419', 'Leipzig', 8, '2024-06-10'),

('Hannah', 'Murphy', 'hannah.murphy@wellness.de', '4915301234520', 'Berlin', 13, '2022-04-25');

INSERT INTO Sessions (
    service_type_id,
    trainer_id,
    session_date,
    start_time,
    duration_in_minutes,
    session_mode,
    session_room,
    session_status
)
VALUES

-- =====================================================
-- HISTORICAL SESSIONS - AUGUST 2026
-- =====================================================

(1, 1, '2026-08-05', '08:00:00', 60,
 'OFFLINE', 'Studio A', 'COMPLETED'),

(2, 2, '2026-08-08', '10:00:00', 60,
 'OFFLINE', 'Fitness Hall', 'COMPLETED'),

(12, 13, '2026-08-12', '14:00:00', 60,
 'OFFLINE', 'PT Room 1', 'COMPLETED'),

(3, 3, '2026-08-15', '09:00:00', 60,
 'ONLINE', NULL, 'COMPLETED'),

(5, 5, '2026-08-18', '18:00:00', 60,
 'OFFLINE', 'CrossFit Zone', 'CANCELLED'),

(12, 14, '2026-08-22', '11:00:00', 60,
 'OFFLINE', 'PT Room 2', 'CANCELLED'),

-- =====================================================
-- UPCOMING SESSIONS - OCTOBER 2026
-- =====================================================

(1, 6, '2026-10-02', '08:00:00', 60,
 'OFFLINE', 'Studio A', 'SCHEDULED'),

(2, 6, '2026-10-04', '10:00:00', 60,
 'OFFLINE', 'Fitness Hall', 'SCHEDULED'),

(3, 8, '2026-10-06', '09:00:00', 60,
 'OFFLINE', 'Studio B', 'SCHEDULED'),

(4, 10, '2026-10-08', '18:00:00', 75,
 'OFFLINE', 'Training Room', 'SCHEDULED'),

(5, 12, '2026-10-10', '18:00:00', 60,
 'OFFLINE', 'CrossFit Zone', 'SCHEDULED'),

(6, 14, '2026-10-12', '08:30:00', 60,
 'OFFLINE', 'Dance Studio', 'SCHEDULED'),

(7, 16, '2026-10-15', '17:30:00', 45,
 'OFFLINE', 'Cycling Room', 'SCHEDULED'),

(8, 18, '2026-10-18', '09:00:00', 60,
 'OFFLINE', 'Strength Room', 'SCHEDULED'),

-- =====================================================
-- UPCOMING SESSIONS - NOVEMBER 2026
-- =====================================================

(1, 20, '2026-11-02', '09:00:00', 60,
 'OFFLINE', 'Studio A', 'SCHEDULED'),

(2, 1, '2026-11-05', '17:00:00', 60,
 'OFFLINE', 'Fitness Hall', 'SCHEDULED'),

(5, 3, '2026-11-08', '18:00:00', 60,
 'OFFLINE', 'CrossFit Zone', 'SCHEDULED'),

(12, 5, '2026-11-12', '10:00:00', 60,
 'OFFLINE', 'PT Room 1', 'SCHEDULED'),

(13, 7, '2026-11-15', '13:00:00', 45,
 'ONLINE', NULL, 'SCHEDULED'),

(14, 9, '2026-11-20', '15:00:00', 60,
 'OFFLINE', 'Assessment Room', 'SCHEDULED');
 
 INSERT INTO Bookings (
    member_id,
    session_id,
    booking_created_time,
    booking_cancelled_time,
    booking_status
)
VALUES

-- =====================================================
-- AUGUST 2026 - HISTORICAL BOOKINGS
-- =====================================================

-- Member 1 attended August session
(1, 1, '2026-08-01 10:15:00', NULL, 'BOOKED'),

-- Member 2 attended August session
(2, 2, '2026-08-04 14:20:00', NULL, 'BOOKED'),

-- Member 3 attended online session
(3, 4, '2026-08-10 09:30:00', NULL, 'BOOKED'),

-- Member 4 cancelled before the session
(4, 5, '2026-08-14 11:00:00',
     '2026-08-16 16:30:00', 'CANCELLED'),

-- Member 5 attended session
(5, 3, '2026-08-10 15:45:00', NULL, 'BOOKED'),

-- Member 6 cancelled session
(6, 6, '2026-08-19 09:00:00',
     '2026-08-20 13:15:00', 'CANCELLED'),

-- =====================================================
-- OCTOBER 2026 - UPCOMING BOOKINGS
-- =====================================================

-- Member 1 books multiple sessions
(1, 7, '2026-09-01 10:30:00', NULL, 'BOOKED'),

(1, 9, '2026-09-02 12:10:00', NULL, 'BOOKED'),

-- Member 2
(2, 8, '2026-09-01 14:25:00', NULL, 'BOOKED'),

-- Member 3
(3, 10, '2026-09-02 09:15:00', NULL, 'BOOKED'),

-- Member 4
(4, 11, '2026-09-03 16:40:00', NULL, 'BOOKED'),

-- Member 5
(5, 12, '2026-09-03 18:20:00', NULL, 'BOOKED'),

-- Member 6
(6, 13, '2026-09-04 11:30:00', NULL, 'BOOKED'),

-- Member 7
(7, 14, '2026-09-04 15:00:00', NULL, 'BOOKED'),

-- Member 8 declined the trainer change on session 7
(8, 7, '2026-09-01 08:45:00',
     '2026-09-20 11:00:00', 'CANCELLED'),

-- Member 9
(9, 10, '2026-09-02 13:20:00', NULL, 'BOOKED'),

-- =====================================================
-- CANCELLED UPCOMING BOOKINGS
-- =====================================================

-- Member 10 booked and later cancelled
(10, 14, '2026-09-01 10:00:00',
      '2026-09-04 17:30:00', 'CANCELLED'),

-- Member 3 cancelled an upcoming booking
(3, 15, '2026-09-02 11:15:00',
      '2026-09-04 09:20:00', 'CANCELLED'),

-- =====================================================
-- NOVEMBER 2026 - UPCOMING BOOKINGS
-- =====================================================

(1, 16, '2026-09-03 09:10:00', NULL, 'BOOKED'),

(2, 17, '2026-09-03 10:25:00', NULL, 'BOOKED'),

(5, 18, '2026-09-04 12:40:00', NULL, 'BOOKED'),

(7, 19, '2026-09-04 14:15:00', NULL, 'BOOKED'),

(9, 20, '2026-09-05 08:30:00', NULL, 'BOOKED');


-- =====================================================
-- SESSION CHANGE IMPACT MANAGEMENT
-- Sessions already store the NEW current details.
-- History stores that a change happened; responses store
-- each booked member's accept / decline / no reply.
-- =====================================================
