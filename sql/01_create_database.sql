CREATE TABLE CUSTOMER (
	customer_id INT IDENTITY(1,1) PRIMARY KEY,
	customer_name VARCHAR(100) NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE,
	reg_date DATE NOT NULL,
	country VARCHAR(50) NOT NULL
);

CREATE TABLE CATEGORY
(
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    daily_price DECIMAL(10,2) NOT NULL,
    CHECK (daily_price > 0)
);

CREATE TABLE BRANCH
(
    branch_id INT IDENTITY(1,1) PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL
);

CREATE TABLE VEHICLE
(
    vehicle_id INT IDENTITY(1,1) PRIMARY KEY,
    category_id INT NOT NULL,
    branch_id INT NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    manufacture_year INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY(category_id)
        REFERENCES CATEGORY(category_id),
    FOREIGN KEY(branch_id)
        REFERENCES BRANCH(branch_id),
    CHECK
    (
        status IN
        (
            'Available',
            'Rented',
            'Maintenance'
        )
    )
);

CREATE TABLE EMPLOYEE
(
    employee_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL
);

CREATE TABLE RESERVATION
(
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    category_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY(customer_id)
        REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY(category_id)
        REFERENCES CATEGORY(category_id),
    CHECK (end_date > start_date),
    CHECK
    (
        status IN
        (
            'Pending',
            'Confirmed',
            'Cancelled'
        )
    )
);

CREATE TABLE RENTAL
(
    rental_id INT IDENTITY(1,1) PRIMARY KEY,
    reservation_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    employee_id INT NOT NULL,
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    total_cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY(reservation_id)
        REFERENCES RESERVATION(reservation_id),
    FOREIGN KEY(vehicle_id)
        REFERENCES VEHICLE(vehicle_id),
    FOREIGN KEY(employee_id)
        REFERENCES EMPLOYEE(employee_id),
    CHECK(return_date >= pickup_date),
    CHECK(total_cost >= 0)
);

CREATE TABLE PAYMENT
(
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    rental_id INT NOT NULL UNIQUE,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    FOREIGN KEY(rental_id)
        REFERENCES RENTAL(rental_id),
    CHECK(amount >= 0),
    CHECK
    (
        payment_method IN
        (
            'Cash',
            'Credit Card',
            'Debit Card'
        )
    )
);

CREATE TABLE MAINTENANCE
(
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    description VARCHAR(200) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    FOREIGN KEY(vehicle_id)
        REFERENCES VEHICLE(vehicle_id),
    CHECK(cost >= 0)
);

CREATE TABLE REVIEW
(
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    rating INT NOT NULL,
    review_text VARCHAR(300),
    review_date DATE NOT NULL,
    FOREIGN KEY(customer_id)
        REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY(vehicle_id)
        REFERENCES VEHICLE(vehicle_id),
    CHECK(rating BETWEEN 1 AND 5)
);