-- Full schema + sample data
CREATE DATABASE IF NOT EXISTS maintenance_rs;
USE maintenance_rs;

CREATE TABLE users (id BIGINT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(150), email VARCHAR(150), password VARCHAR(255), phone VARCHAR(50), role VARCHAR(50), created_at DATETIME, updated_at DATETIME);
CREATE TABLE categories (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100));
CREATE TABLE rooms (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100), floor VARCHAR(20));
CREATE TABLE vendors (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(150), contact_person VARCHAR(100), phone VARCHAR(50), email VARCHAR(100));
CREATE TABLE assets (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_code VARCHAR(50) UNIQUE, name VARCHAR(200), category_id INT, room_id INT, vendor_id INT, serial_number VARCHAR(100), acquisition_date DATE, pm_interval_days INT DEFAULT 90, last_pm_date DATE, calibration_interval_days INT DEFAULT 365, last_calibration_date DATE, qr_code VARCHAR(100), manual_file TEXT, created_at DATETIME, updated_at DATETIME);
CREATE TABLE maintenance_pm (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_id BIGINT, ticket_code VARCHAR(80), scheduled_date DATE, due_date DATE, assigned_technician BIGINT, status VARCHAR(30), checklist JSON, notes TEXT, completed_at DATETIME, created_at DATETIME, updated_at DATETIME);
CREATE TABLE maintenance_cm (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_id BIGINT, ticket_code VARCHAR(80), reported_by BIGINT, reported_at DATETIME, priority VARCHAR(20), assigned_technician BIGINT, status VARCHAR(30), description TEXT, spareparts_used JSON, cost_total DECIMAL(12,2), resolved_at DATETIME, created_at DATETIME, updated_at DATETIME);
CREATE TABLE calibrations (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_id BIGINT, performed_by VARCHAR(200), calibration_date DATE, expiry_date DATE, certificate_file TEXT, notes TEXT, created_at DATETIME, updated_at DATETIME);

INSERT INTO categories (name) VALUES ('Electromedik'),('Mekanik');
INSERT INTO rooms (name,floor) VALUES ('ICU','1'),('IGD','G');
INSERT INTO vendors (name,contact_person,phone,email) VALUES ('PT Medika','Budi','08123456789','medika@example.com');
INSERT INTO assets (asset_code,name,category_id,room_id,vendor_id,serial_number,acquisition_date,pm_interval_days,created_at,updated_at) VALUES ('AS-ECG-001','ECG Machine',1,1,1,'ECG-123','2022-01-01',90,NOW(),NOW()),('AS-OXY-001','Oxygen Manifold',2,2,1,'OXY-001','2023-06-01',30,NOW(),NOW());
