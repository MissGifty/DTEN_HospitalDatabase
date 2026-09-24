-- ================================
-- DTEN Internship - Task 2: SQL Query Practice Project
-- Hospital Records Management System
-- Submitted by: Gifty Lumor Adzo (2526400193), GCTU
-- ================================

-- ================================
-- STEP 1: Create and select the database
-- ================================
CREATE DATABASE HospitalDB;
USE HospitalDB;

-- ================================
-- STEP 2: Create all 6 tables
-- ================================
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(50),
    Location VARCHAR(50)
);

CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Specialty VARCHAR(50),
    PhoneNumber VARCHAR(20),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    PhoneNumber VARCHAR(20)
);

CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATE,
    AppointmentTime TIME,
    Reason VARCHAR(100),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

CREATE TABLE Diagnosis (
    DiagnosisID INT PRIMARY KEY AUTO_INCREMENT,
    AppointmentID INT,
    Condition_Name VARCHAR(100),
    DiagnosisDate DATE,
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

CREATE TABLE Medication (
    MedicationID INT PRIMARY KEY AUTO_INCREMENT,
    DiagnosisID INT,
    DrugName VARCHAR(50),
    Dosage VARCHAR(50),
    DurationDays INT,
    FOREIGN KEY (DiagnosisID) REFERENCES Diagnosis(DiagnosisID)
);

-- ================================
-- STEP 3: Insert sample data
-- ================================
INSERT INTO Department (DepartmentName, Location) VALUES
('Cardiology', 'Block A, 1st Floor'),
('Pediatrics', 'Block B, Ground Floor'),
('General Medicine', 'Block A, Ground Floor');

INSERT INTO Doctor (FirstName, LastName, Specialty, PhoneNumber, DepartmentID) VALUES
('Kwame', 'Nkrumah', 'Cardiologist', '0244123456', 1),
('Cletus', 'Mensah', 'Pediatrician', '0201234567', 2),
('Ama', 'Boateng', 'General Practitioner', '0551122334', 3);

INSERT INTO Patient (FirstName, LastName, PhoneNumber) VALUES
('Kojo', 'Asante', '0244556677'),
('Efua', 'Owusu', '0208889900'),
('Yaw', 'Darko', '0559998877'),
('Abena', 'Sarpong', '0271234567');

INSERT INTO Appointment (PatientID, DoctorID, AppointmentDate, AppointmentTime, Reason) VALUES
(1, 1, '2026-09-01', '09:00:00', 'Chest pain'),
(2, 2, '2026-09-02', '10:30:00', 'Fever'),
(3, 3, '2026-09-03', '11:00:00', 'Routine checkup'),
(4, 1, '2026-09-04', '14:00:00', 'High blood pressure'),
(1, 3, '2026-09-10', '09:30:00', 'Follow-up');

INSERT INTO Diagnosis (AppointmentID, Condition_Name, DiagnosisDate) VALUES
(1, 'Hypertension', '2026-09-01'),
(2, 'Malaria', '2026-09-02'),
(3, 'Healthy - no issues', '2026-09-03'),
(4, 'Hypertension', '2026-09-04');

INSERT INTO Medication (DiagnosisID, DrugName, Dosage, DurationDays) VALUES
(1, 'Amlodipine', '5mg once daily', 30),
(2, 'Artemether', '80mg twice daily', 3),
(4, 'Amlodipine', '5mg once daily', 30);

-- ================================
-- STEP 4: 8 Business Questions (SQL Queries)
-- ================================

-- 1. List all patients and their phone numbers
SELECT FirstName, LastName, PhoneNumber FROM Patient;

-- 2. List all doctors with their department name (JOIN)
SELECT d.FirstName, d.LastName, d.Specialty, dept.DepartmentName
FROM Doctor d
JOIN Department dept ON d.DepartmentID = dept.DepartmentID;

-- 3. Show all appointments with patient and doctor names (JOIN across 3 tables)
SELECT a.AppointmentDate, p.FirstName AS PatientFirstName, p.LastName AS PatientLastName,
       doc.FirstName AS DoctorFirstName, doc.LastName AS DoctorLastName, a.Reason
FROM Appointment a
JOIN Patient p ON a.PatientID = p.PatientID
JOIN Doctor doc ON a.DoctorID = doc.DoctorID;

-- 4. Count how many appointments each doctor has (AGGREGATION)
SELECT doc.FirstName, doc.LastName, COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctor doc
LEFT JOIN Appointment a ON doc.DoctorID = a.DoctorID
GROUP BY doc.DoctorID;

-- 5. Find all patients diagnosed with Hypertension (JOIN + WHERE)
SELECT DISTINCT p.FirstName, p.LastName, diag.Condition_Name
FROM Patient p
JOIN Appointment a ON p.PatientID = a.PatientID
JOIN Diagnosis diag ON a.AppointmentID = diag.AppointmentID
WHERE diag.Condition_Name = 'Hypertension';

-- 6. List all medications prescribed, with the patient who received them
SELECT p.FirstName, p.LastName, m.DrugName, m.Dosage, m.DurationDays
FROM Medication m
JOIN Diagnosis diag ON m.DiagnosisID = diag.DiagnosisID
JOIN Appointment a ON diag.AppointmentID = a.AppointmentID
JOIN Patient p ON a.PatientID = p.PatientID;

-- 7. Find doctors who have more than 1 appointment (SUBQUERY)
SELECT FirstName, LastName FROM Doctor
WHERE DoctorID IN (
    SELECT DoctorID FROM Appointment
    GROUP BY DoctorID
    HAVING COUNT(*) > 1
);

-- 8. Show departments that have no doctors assigned yet (SUBQUERY)
SELECT DepartmentName FROM Department
WHERE DepartmentID NOT IN (
    SELECT DISTINCT DepartmentID FROM Doctor WHERE DepartmentID IS NOT NULL
);
