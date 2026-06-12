CREATE DATABASE IF NOT EXISTS online_medicine_db;
USE online_medicine_db;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    pharmacy_name VARCHAR(150),
    pharmacy_address TEXT,
    role ENUM('admin','pharmacist','user') NOT NULL DEFAULT 'user',
    approval_status ENUM('pending','approved') NOT NULL DEFAULT 'approved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medicines (
    medicine_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    expiry_date DATE,
    image VARCHAR(255) DEFAULT 'medicine.svg',
    delivery_methods VARCHAR(180) NOT NULL DEFAULT 'Standard Medical Courier,MediCare Delivery Service',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE TABLE cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    medicine_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status ENUM('Pending','Approved','Completed','Cancelled') DEFAULT 'Pending',
    delivery_method VARCHAR(80) NOT NULL DEFAULT 'Standard Medical Courier',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    medicine_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    item_status ENUM('Pending','Approved','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
    expected_delivery_at DATETIME NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id) ON DELETE CASCADE
);

CREATE TABLE order_issues (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    issue_type VARCHAR(80) NOT NULL DEFAULT 'Delivery Problem',
    message TEXT NOT NULL,
    issue_status ENUM('Open','In Review','Resolved','Closed') NOT NULL DEFAULT 'Open',
    admin_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Sample accounts. Password for all: 123456
-- This project uses SHA-256 hashing. Hash below is SHA-256 for 123456.
INSERT INTO users (name,email,password,phone,address,pharmacy_name,pharmacy_address,role,approval_status) VALUES
('Admin User','admin@gmail.com','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','0711111111','Colombo',NULL,NULL,'admin','approved'),
('Pharmacist User','pharmacist@gmail.com','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','0722222222','Galle','MediCare Galle Pharmacy','No 12, Main Street, Galle','pharmacist','approved'),
('Customer User','user@gmail.com','8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92','0733333333','Matara',NULL,NULL,'user','approved');

INSERT INTO medicines (name,category,description,price,quantity,expiry_date,image,delivery_methods,created_by) VALUES
('Paracetamol 500mg','Pain Relief','Used for fever and mild pain relief.',120.00,80,'2027-12-31','medicines/medicine-paracetamol.png','Standard Medical Courier,MediCare Delivery Service',2),
('Vitamin C Tablets','Vitamins','Supports immunity and general wellness.',450.00,35,'2027-10-20','medicines/medicine-vitamin-c.png','Standard Medical Courier,Express Medical Courier,MediCare Delivery Service',2),
('Cough Syrup','Cold & Cough','Relief for cough and throat irritation.',780.00,18,'2026-11-15','medicines/medicine-cough-syrup.png','Standard Medical Courier,MediCare Delivery Service',2),
('Antacid Tablets','Digestive Health','Helps reduce acidity and heartburn.',350.00,10,'2027-05-01','medicines/medicine-antacid.png','Express Medical Courier,MediCare Delivery Service',2),
('ORS Sachet','Hydration','Oral rehydration solution sachet.',90.00,120,'2028-01-01','medicines/medicine-ors.png','Standard Medical Courier,Express Medical Courier,MediCare Delivery Service',2);
