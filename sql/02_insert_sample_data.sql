/*
============================================================
Azure Car Rental ETL Pipeline
File: 02_insert_sample_data.sql

Purpose:
Populate the Azure SQL Database with synthetic car-rental
records used by the Power BI analytical dashboard.

Note:
The dataset is synthetic and contains no real customer data.
============================================================
*/

INSERT INTO CUSTOMER
(customer_name,email,reg_date,country)

VALUES

('Thomas Beopoulos','thomas@gmail.com','2025-01-10','Greece'),
('George Papadopoulos','george@gmail.com','2025-01-15','Greece'),
('Anna Schmidt','anna@gmail.com','2025-01-20','Germany'),
('Michael Johnson','michael@gmail.com','2025-02-01','USA'),
('Maria Rossi','maria@gmail.com','2025-02-05','Italy'),
('Carlos Garcia','carlos@gmail.com','2025-02-10','Spain'),
('Sophie Martin','sophie@gmail.com','2025-02-15','France'),
('Daniel Wilson','daniel@gmail.com','2025-02-20','UK'),
('Emma Brown','emma@gmail.com','2025-03-01','USA'),
('Lucas Muller','lucas@gmail.com','2025-03-05','Germany'),
('Olivia Smith','olivia@gmail.com','2025-03-10','Canada'),
('Marco Ferrari','marco@gmail.com','2025-03-15','Italy'),
('Nikos Konstantinou','nikos@gmail.com','2025-03-20','Greece'),
('Laura White','laura@gmail.com','2025-04-01','UK'),
('Robert Taylor','robert@gmail.com','2025-04-05','USA');

INSERT INTO VEHICLE
(category_id,branch_id,brand,model,manufacture_year,status)

VALUES

(1,1,'Toyota','Yaris',2023,'Available'),
(1,2,'Hyundai','i20',2022,'Available'),
(1,3,'Renault','Clio',2023,'Available'),

(2,1,'Toyota','RAV4',2024,'Available'),
(2,2,'Nissan','Qashqai',2023,'Available'),
(2,3,'Kia','Sportage',2024,'Available'),

(3,1,'BMW','X5',2024,'Available'),
(3,2,'Audi','A6',2023,'Available'),
(3,3,'Mercedes','C-Class',2024,'Available'),

(4,1,'Tesla','Model 3',2025,'Available'),
(4,2,'Tesla','Model Y',2025,'Available'),

(5,1,'Ford','Transit',2022,'Available'),
(5,3,'Volkswagen','Transporter',2023,'Available');

INSERT INTO CATEGORY
(category_name,daily_price)

VALUES
('Economy',40),
('SUV',80),
('Luxury',150),
('Electric',100),
('Van',120);

INSERT INTO BRANCH
(branch_name,location)

VALUES

('Athens Center','Athens'),
('Patras Branch','Patras'),
('Thessaloniki Branch','Thessaloniki'),
('Heraklion Branch','Crete'),
('Larissa Branch','Larissa');

INSERT INTO EMPLOYEE
(employee_name,position)

VALUES

('John Smith','Manager'),
('Maria Jones','Rental Agent'),
('Nick Brown','Rental Agent'),
('George Adams','Rental Agent'),
('Emily Wilson','Manager'),
('David Miller','Rental Agent'),
('Sophia Brown','Rental Agent'),
('Alex Johnson','Rental Agent');



INSERT INTO RESERVATION
(customer_id, category_id, start_date, end_date, status)
VALUES
(1,1,'2025-04-01','2025-04-05','Confirmed'),
(2,2,'2025-04-03','2025-04-08','Confirmed'),
(3,3,'2025-04-05','2025-04-10','Confirmed'),
(4,4,'2025-04-07','2025-04-12','Confirmed'),
(5,5,'2025-04-10','2025-04-15','Confirmed'),
(6,1,'2025-04-12','2025-04-16','Confirmed'),
(7,2,'2025-04-15','2025-04-20','Confirmed'),
(8,3,'2025-04-18','2025-04-23','Confirmed'),
(9,4,'2025-04-20','2025-04-25','Confirmed'),
(10,5,'2025-04-22','2025-04-28','Confirmed'),
(11,1,'2025-05-01','2025-05-06','Confirmed'),
(12,2,'2025-05-03','2025-05-08','Confirmed'),
(13,3,'2025-05-05','2025-05-10','Confirmed'),
(14,4,'2025-05-08','2025-05-13','Confirmed'),
(15,5,'2025-05-10','2025-05-15','Confirmed');

INSERT INTO RENTAL
(reservation_id, vehicle_id, employee_id, pickup_date, return_date, total_cost)
VALUES
(1,1,2,'2025-04-01','2025-04-05',160),
(2,4,3,'2025-04-03','2025-04-08',400),
(3,7,4,'2025-04-05','2025-04-10',750),
(4,10,6,'2025-04-07','2025-04-12',500),
(5,12,7,'2025-04-10','2025-04-15',600),
(6,2,2,'2025-04-12','2025-04-16',160),
(7,5,3,'2025-04-15','2025-04-20',400),
(8,8,4,'2025-04-18','2025-04-23',750),
(9,11,6,'2025-04-20','2025-04-25',500),
(10,13,7,'2025-04-22','2025-04-28',600),
(11,3,2,'2025-05-01','2025-05-06',160),
(12,6,3,'2025-05-03','2025-05-08',400),
(13,9,4,'2025-05-05','2025-05-10',750),
(14,10,6,'2025-05-08','2025-05-13',500),
(15,12,7,'2025-05-10','2025-05-15',600);

INSERT INTO PAYMENT
(rental_id, amount, payment_date, payment_method)
VALUES
(1,160,'2025-04-05','Credit Card'),
(2,400,'2025-04-08','Debit Card'),
(3,750,'2025-04-10','Cash'),
(4,500,'2025-04-12','Credit Card'),
(5,600,'2025-04-15','Debit Card'),
(6,160,'2025-04-16','Cash'),
(7,400,'2025-04-20','Credit Card'),
(8,750,'2025-04-23','Debit Card'),
(9,500,'2025-04-25','Cash'),
(10,600,'2025-04-28','Credit Card'),
(11,160,'2025-05-06','Credit Card'),
(12,400,'2025-05-08','Cash'),
(13,750,'2025-05-10','Debit Card'),
(14,500,'2025-05-13','Credit Card'),
(15,600,'2025-05-15','Cash');

INSERT INTO REVIEW
(customer_id, vehicle_id, rating, review_text, review_date)
VALUES
(1,1,5,'Excellent service','2025-04-06'),
(2,4,4,'Very comfortable SUV','2025-04-09'),
(3,7,5,'Amazing luxury car','2025-04-11'),
(4,10,5,'Loved the electric vehicle','2025-04-13'),
(5,12,4,'Very practical van','2025-04-16'),
(6,2,3,'Good economy option','2025-04-17'),
(7,5,4,'Nice SUV','2025-04-21'),
(8,8,5,'Luxury experience','2025-04-24'),
(9,11,5,'Tesla was fantastic','2025-04-26'),
(10,13,4,'Perfect for family trip','2025-04-29');

INSERT INTO MAINTENANCE
(vehicle_id, maintenance_date, description, cost)
VALUES
(1,'2025-03-01','Oil Change',50),
(2,'2025-03-05','Brake Inspection',120),
(3,'2025-03-10','Annual Service',250),
(4,'2025-03-12','Battery Check',80),
(5,'2025-03-15','Tire Replacement',300),
(6,'2025-03-18','Oil Change',60),
(7,'2025-03-20','Engine Inspection',180),
(8,'2025-03-22','Brake Service',140),
(9,'2025-03-25','Annual Service',280),
(10,'2025-03-28','Software Update',40);