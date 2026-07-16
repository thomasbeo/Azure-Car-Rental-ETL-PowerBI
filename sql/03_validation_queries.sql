/*
============================================================
Azure Car Rental ETL Pipeline
File: 03_validation_queries.sql

Purpose:
Validate that the Azure SQL Database schema and data were
loaded correctly after the Azure Data Factory ingestion process.
============================================================
*/

------------------------------------------------------------
-- Q1. List all user tables
------------------------------------------------------------

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


------------------------------------------------------------
-- Q2. Count rows in every project table
------------------------------------------------------------

SELECT 'BRANCH' AS table_name, COUNT(*) AS row_count
FROM BRANCH

UNION ALL

SELECT 'CATEGORY', COUNT(*)
FROM CATEGORY

UNION ALL

SELECT 'CUSTOMER', COUNT(*)
FROM CUSTOMER

UNION ALL

SELECT 'EMPLOYEE', COUNT(*)
FROM EMPLOYEE

UNION ALL

SELECT 'VEHICLE', COUNT(*)
FROM VEHICLE

UNION ALL

SELECT 'RESERVATION', COUNT(*)
FROM RESERVATION

UNION ALL

SELECT 'RENTAL', COUNT(*)
FROM RENTAL

UNION ALL

SELECT 'PAYMENT', COUNT(*)
FROM PAYMENT

UNION ALL

SELECT 'REVIEW', COUNT(*)
FROM REVIEW

UNION ALL

SELECT 'MAINTENANCE', COUNT(*)
FROM MAINTENANCE;


------------------------------------------------------------
-- Q3. Verify primary-key ranges
------------------------------------------------------------

SELECT
    MIN(customer_id) AS minimum_customer_id,
    MAX(customer_id) AS maximum_customer_id,
    COUNT(*) AS customer_count
FROM CUSTOMER;

SELECT
    MIN(vehicle_id) AS minimum_vehicle_id,
    MAX(vehicle_id) AS maximum_vehicle_id,
    COUNT(*) AS vehicle_count
FROM VEHICLE;

SELECT
    MIN(rental_id) AS minimum_rental_id,
    MAX(rental_id) AS maximum_rental_id,
    COUNT(*) AS rental_count
FROM RENTAL;


------------------------------------------------------------
-- Q4. Check for duplicate customer emails
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    email,
    COUNT(*) AS duplicate_count
FROM CUSTOMER
GROUP BY email
HAVING COUNT(*) > 1;


------------------------------------------------------------
-- Q5. Check for duplicate payment records per rental
-- PAYMENT.rental_id should be unique
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    rental_id,
    COUNT(*) AS payment_count
FROM PAYMENT
GROUP BY rental_id
HAVING COUNT(*) > 1;


------------------------------------------------------------
-- Q6. Rentals without a valid reservation
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    r.*
FROM RENTAL AS r
LEFT JOIN RESERVATION AS res
    ON r.reservation_id = res.reservation_id
WHERE res.reservation_id IS NULL;


------------------------------------------------------------
-- Q7. Rentals without a valid vehicle
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    r.*
FROM RENTAL AS r
LEFT JOIN VEHICLE AS v
    ON r.vehicle_id = v.vehicle_id
WHERE v.vehicle_id IS NULL;


------------------------------------------------------------
-- Q8. Rentals without a valid employee
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    r.*
FROM RENTAL AS r
LEFT JOIN EMPLOYEE AS e
    ON r.employee_id = e.employee_id
WHERE e.employee_id IS NULL;


------------------------------------------------------------
-- Q9. Reservations without a valid customer
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    res.*
FROM RESERVATION AS res
LEFT JOIN CUSTOMER AS c
    ON res.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


------------------------------------------------------------
-- Q10. Reservations without a valid category
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    res.*
FROM RESERVATION AS res
LEFT JOIN CATEGORY AS c
    ON res.category_id = c.category_id
WHERE c.category_id IS NULL;


------------------------------------------------------------
-- Q11. Payments without a valid rental
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    p.*
FROM PAYMENT AS p
LEFT JOIN RENTAL AS r
    ON p.rental_id = r.rental_id
WHERE r.rental_id IS NULL;


------------------------------------------------------------
-- Q12. Vehicles without a valid category or branch
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    v.*
FROM VEHICLE AS v
LEFT JOIN CATEGORY AS c
    ON v.category_id = c.category_id
LEFT JOIN BRANCH AS b
    ON v.branch_id = b.branch_id
WHERE c.category_id IS NULL
   OR b.branch_id IS NULL;


------------------------------------------------------------
-- Q13. Reviews without a valid customer or vehicle
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    rev.*
FROM REVIEW AS rev
LEFT JOIN CUSTOMER AS c
    ON rev.customer_id = c.customer_id
LEFT JOIN VEHICLE AS v
    ON rev.vehicle_id = v.vehicle_id
WHERE c.customer_id IS NULL
   OR v.vehicle_id IS NULL;


------------------------------------------------------------
-- Q14. Maintenance records without a valid vehicle
-- Expected result: zero rows
------------------------------------------------------------

SELECT
    m.*
FROM MAINTENANCE AS m
LEFT JOIN VEHICLE AS v
    ON m.vehicle_id = v.vehicle_id
WHERE v.vehicle_id IS NULL;


------------------------------------------------------------
-- Q15. Invalid reservation date ranges
-- Expected result: zero rows
------------------------------------------------------------

SELECT *
FROM RESERVATION
WHERE end_date <= start_date;


------------------------------------------------------------
-- Q16. Invalid rental date ranges
-- Expected result: zero rows
------------------------------------------------------------

SELECT *
FROM RENTAL
WHERE return_date < pickup_date;


------------------------------------------------------------
-- Q17. Invalid monetary values
-- Expected result: zero rows
------------------------------------------------------------

SELECT *
FROM RENTAL
WHERE total_cost < 0;

SELECT *
FROM PAYMENT
WHERE amount < 0;

SELECT *
FROM MAINTENANCE
WHERE cost < 0;


------------------------------------------------------------
-- Q18. Invalid review ratings
-- Expected result: zero rows
------------------------------------------------------------

SELECT *
FROM REVIEW
WHERE rating < 1
   OR rating > 5;


------------------------------------------------------------
-- Q19. Compare rental costs with payment amounts
-- Expected result: zero rows when each rental is fully paid
------------------------------------------------------------

SELECT
    r.rental_id,
    r.total_cost,
    p.amount,
    r.total_cost - p.amount AS difference
FROM RENTAL AS r
JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
WHERE r.total_cost <> p.amount;


------------------------------------------------------------
-- Q20. Final validation summary
------------------------------------------------------------

SELECT
    (SELECT COUNT(*) FROM CUSTOMER) AS total_customers,
    (SELECT COUNT(*) FROM VEHICLE) AS total_vehicles,
    (SELECT COUNT(*) FROM RESERVATION) AS total_reservations,
    (SELECT COUNT(*) FROM RENTAL) AS total_rentals,
    (SELECT COUNT(*) FROM PAYMENT) AS total_payments,
    (SELECT SUM(amount) FROM PAYMENT) AS total_revenue,
    (SELECT AVG(CAST(rating AS DECIMAL(10,2))) FROM REVIEW)
        AS average_rating,
    (SELECT SUM(cost) FROM MAINTENANCE)
        AS total_maintenance_cost;