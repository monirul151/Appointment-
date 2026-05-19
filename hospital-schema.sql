CREATE DATABASE IF NOT EXISTS hospital_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hospital_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS doctor_reviews;
DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS consultation_notes;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS leave_dates;
DROP TABLE IF EXISTS doctor_availability;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS specializations;
DROP TABLE IF EXISTS dependents;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(30),
    role ENUM('patient','doctor','receptionist','admin') NOT NULL,
    profile_pic VARCHAR(255),
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    date_of_birth DATE NULL,
    blood_group VARCHAR(10),
    gender VARCHAR(20),
    address TEXT,
    emergency_contact_name VARCHAR(120),
    emergency_contact_phone VARCHAR(30),
    medical_history_notes TEXT,
    CONSTRAINT fk_patients_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE specializations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    specialization_id INT,
    bio TEXT,
    consultation_fee DECIMAL(10,2) NOT NULL DEFAULT 0,
    photo_path VARCHAR(255),
    license_number VARCHAR(80),
    experience_years INT NOT NULL DEFAULT 0,
    is_approved TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_doctors_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_doctors_specialization FOREIGN KEY (specialization_id) REFERENCES specializations(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE doctor_availability (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration_minutes INT NOT NULL DEFAULT 30,
    is_available TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uq_doctor_day (doctor_id, day_of_week),
    CONSTRAINT fk_availability_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE leave_dates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    leave_date DATE NOT NULL,
    reason VARCHAR(255),
    UNIQUE KEY uq_doctor_leave (doctor_id, leave_date),
    CONSTRAINT fk_leave_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason TEXT,
    status ENUM('pending','confirmed','checked_in','completed','cancelled','no_show','rejected') NOT NULL DEFAULT 'pending',
    booked_by ENUM('patient','receptionist') NOT NULL DEFAULT 'patient',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_doctor_datetime (doctor_id, appointment_date, appointment_time),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE consultation_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    doctor_id INT NOT NULL,
    patient_id INT NOT NULL,
    symptoms TEXT,
    diagnosis TEXT,
    prescription TEXT,
    follow_up_date DATE NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_consultation_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    CONSTRAINT fk_consultation_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    CONSTRAINT fk_consultation_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE billing (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    payment_method VARCHAR(40) NOT NULL DEFAULT 'cash',
    payment_status ENUM('pending','paid') NOT NULL DEFAULT 'pending',
    paid_at DATETIME NULL,
    CONSTRAINT fk_billing_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    CONSTRAINT fk_billing_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE doctor_reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    rating INT NOT NULL,
    review_text TEXT,
    doctor_reply TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    CONSTRAINT fk_review_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

CREATE TABLE dependents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    primary_patient_id INT NOT NULL,
    name VARCHAR(120) NOT NULL,
    date_of_birth DATE NULL,
    relationship VARCHAR(50),
    blood_group VARCHAR(10),
    CONSTRAINT fk_dependents_patient FOREIGN KEY (primary_patient_id) REFERENCES patients(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_id INT NOT NULL,
    title VARCHAR(180) NOT NULL,
    body TEXT NOT NULL,
    target_role ENUM('all','patient','doctor') NOT NULL DEFAULT 'all',
    published_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_announcements_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE settings (
    setting_key VARCHAR(80) PRIMARY KEY,
    setting_value VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

INSERT INTO specializations (name, description) VALUES
('Cardiology', 'Heart and cardiovascular care'),
('Dermatology', 'Skin, hair, and nail conditions'),
('Medicine', 'General internal medicine'),
('Orthopedics', 'Bone, joint, and muscle care');

INSERT INTO users (id, name, email, password_hash, phone, role, profile_pic, is_active, created_at) VALUES
(1, 'Admin User', 'admin@example.com', '$2y$12$ceLp.grklDRPv1T86vYAi.CxfvO/h/2xIB0jqP7jfOUSR.hXUDpGO', '01700000001', 'admin', NULL, 1, NOW()),
(2, 'Dr. Ahmed Rahman', 'doctor@example.com', '$2y$12$9FxLurc2GE5cnCBGeCqyuuQUt7ISoBSIIjZtJA5jjarUBr2TOVORa', '01700000002', 'doctor', NULL, 1, NOW()),
(3, 'Patient One', 'patient@example.com', '$2y$12$RAKveON4mSTbIpmtSAdma.LoPSCQlttPK8kZMEY5soNto2T3GGXZ2', '01700000003', 'patient', NULL, 1, NOW()),
(4, 'Front Desk Officer', 'receptionist@example.com', '$2y$12$EmYN3IfdSvrUOtQyG8CKruAwSwUX03Do42ycEv076.R37WKtvblGG', '01700000004', 'receptionist', NULL, 1, NOW());

UPDATE users SET role = LOWER(TRIM(role));

INSERT INTO doctors (id, user_id, specialization_id, bio, consultation_fee, photo_path, license_number, experience_years, is_approved) VALUES
(1, 2, 1, 'Experienced cardiologist focused on preventive heart care and patient-centred consultation.', 800.00, '', 'BMDC-1001', 8, 1);

INSERT INTO patients (id, user_id, date_of_birth, blood_group, gender, address, emergency_contact_name, emergency_contact_phone, medical_history_notes) VALUES
(1, 3, '1998-05-10', 'B+', 'Male', 'Dhaka, Bangladesh', 'Guardian One', '01700000009', 'No major chronic condition reported.');

INSERT INTO doctor_availability (doctor_id, day_of_week, start_time, end_time, slot_duration_minutes, is_available) VALUES
(1, 'Monday', '09:00:00', '13:00:00', 30, 1),
(1, 'Tuesday', '09:00:00', '13:00:00', 30, 1),
(1, 'Wednesday', '09:00:00', '13:00:00', 30, 1),
(1, 'Thursday', '09:00:00', '13:00:00', 30, 1),
(1, 'Friday', '09:00:00', '12:00:00', 30, 1),
(1, 'Saturday', '10:00:00', '14:00:00', 30, 1),
(1, 'Sunday', '10:00:00', '12:00:00', 30, 0);

INSERT INTO appointments (id, patient_id, doctor_id, appointment_date, appointment_time, reason, status, booked_by, created_at) VALUES
(1, 1, 1, CURDATE(), '09:00:00', 'Chest discomfort follow-up', 'confirmed', 'patient', NOW()),
(2, 1, 1, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00:00', 'Routine checkup', 'pending', 'patient', NOW()),
(3, 1, 1, DATE_SUB(CURDATE(), INTERVAL 7 DAY), '11:00:00', 'Previous consultation', 'completed', 'receptionist', NOW());

INSERT INTO consultation_notes (appointment_id, doctor_id, patient_id, symptoms, diagnosis, prescription, follow_up_date, created_at) VALUES
(3, 1, 1, 'Mild chest pain and fatigue', 'Observation required; no emergency signs at consultation', 'Rest, hydration, and prescribed medicine as advised', DATE_ADD(CURDATE(), INTERVAL 14 DAY), NOW());

INSERT INTO billing (appointment_id, patient_id, amount, payment_method, payment_status, paid_at) VALUES
(3, 1, 800.00, 'cash', 'paid', NOW());

INSERT INTO doctor_reviews (appointment_id, patient_id, doctor_id, rating, review_text, doctor_reply, created_at) VALUES
(3, 1, 1, 5, 'Doctor explained everything clearly.', 'Thank you for your feedback.', NOW());

INSERT INTO settings (setting_key, setting_value) VALUES
('minimum_cancellation_hours', '24'),
('maximum_advance_booking_days', '30'),
('default_consultation_fee', '600');
