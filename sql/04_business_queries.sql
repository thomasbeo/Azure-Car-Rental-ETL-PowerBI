/*
============================================================
Azure Car Rental ETL Pipeline
File: 04_business_queries.sql

Purpose:
Provide business-oriented analytical queries that validate
the metrics displayed in the Power BI dashboard.
============================================================
*/

------------------------------------------------------------
-- Q1. Executive KPI summary
------------------------------------------------------------

SELECT
    SUM(p.amount) AS total_revenue,
    COUNT(DISTINCT r.rental_id) AS total_rentals,
    COUNT(DISTINCT res.customer_id) AS customers_with_rentals,
    AVG(CAST(rev.rating AS DECIMAL(10,2))) AS average_rating
FROM RENTAL AS r
JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
JOIN RESERVATION AS res
    ON r.reservation_id = res.reservation_id
LEFT JOIN REVIEW AS rev
    ON res.customer_id = rev.customer_id;


------------------------------------------------------------
-- Q2. Total revenue
------------------------------------------------------------

SELECT
    SUM(amount) AS total_revenue
FROM PAYMENT;


------------------------------------------------------------
-- Q3. Average rental value
------------------------------------------------------------

SELECT
    AVG(CAST(amount AS DECIMAL(10,2))) AS average_rental_value
FROM PAYMENT;


------------------------------------------------------------
-- Q4. Average rental duration
------------------------------------------------------------

SELECT
    AVG(
        CAST(
            DATEDIFF(DAY, pickup_date, return_date)
            AS DECIMAL(10,2)
        )
    ) AS average_rental_duration_days
FROM RENTAL;


------------------------------------------------------------
-- Q5. Revenue by branch
------------------------------------------------------------

SELECT
    b.branch_id,
    b.branch_name,
    b.location,
    COUNT(DISTINCT r.rental_id) AS rental_count,
    SUM(p.amount) AS total_revenue
FROM BRANCH AS b
JOIN VEHICLE AS v
    ON b.branch_id = v.branch_id
JOIN RENTAL AS r
    ON v.vehicle_id = r.vehicle_id
JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
GROUP BY
    b.branch_id,
    b.branch_name,
    b.location
ORDER BY total_revenue DESC;


------------------------------------------------------------
-- Q6. Revenue by vehicle category
------------------------------------------------------------

SELECT
    c.category_id,
    c.category_name,
    COUNT(DISTINCT r.rental_id) AS rental_count,
    SUM(p.amount) AS total_revenue,
    AVG(CAST(p.amount AS DECIMAL(10,2)))
        AS average_revenue_per_rental
FROM CATEGORY AS c
JOIN VEHICLE AS v
    ON c.category_id = v.category_id
JOIN RENTAL AS r
    ON v.vehicle_id = r.vehicle_id
JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY total_revenue DESC;


------------------------------------------------------------
-- Q7. Monthly revenue trend
------------------------------------------------------------

SELECT
    YEAR(payment_date) AS revenue_year,
    MONTH(payment_date) AS revenue_month_number,
    DATENAME(MONTH, payment_date) AS revenue_month,
    COUNT(*) AS payment_count,
    SUM(amount) AS monthly_revenue
FROM PAYMENT
GROUP BY
    YEAR(payment_date),
    MONTH(payment_date),
    DATENAME(MONTH, payment_date)
ORDER BY
    revenue_year,
    revenue_month_number;


------------------------------------------------------------
-- Q8. Daily revenue trend
------------------------------------------------------------

SELECT
    payment_date,
    COUNT(*) AS payment_count,
    SUM(amount) AS daily_revenue
FROM PAYMENT
GROUP BY payment_date
ORDER BY payment_date;


------------------------------------------------------------
-- Q9. Top customers by revenue
------------------------------------------------------------

SELECT
    c.customer_id,
    c.customer_name,
    c.country,
    COUNT(DISTINCT r.rental_id) AS rental_count,
    SUM(p.amount) AS total_spending,
    AVG(CAST(p.amount AS DECIMAL(10,2)))
        AS average_rental_spending
FROM CUSTOMER AS c
JOIN RESERVATION AS res
    ON c.customer_id = res.customer_id
JOIN RENTAL AS r
    ON res.reservation_id = r.reservation_id
JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
GROUP BY
    c.customer_id,
    c.customer_name,
    c.country
ORDER BY total_spending DESC;


------------------------------------------------------------
-- Q10. Revenue by customer country
------------------------------------------------------------

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    COUNT(DISTINCT r.rental_id) AS rental_count,
    SUM(p.amount) AS total_revenue
FROM CUSTOMER AS c
JOIN RESERVATION AS res
    ON c.customer_id = res.customer_id
JOIN RENTAL AS r
    ON res.reservation_id = r.reservation_id
JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
GROUP BY c.country
ORDER BY total_revenue DESC;


------------------------------------------------------------
-- Q11. Most frequently rented vehicles
------------------------------------------------------------

SELECT
    v.vehicle_id,
    v.brand,
    v.model,
    c.category_name,
    b.branch_name,
    COUNT(r.rental_id) AS rental_count,
    SUM(p.amount) AS total_revenue
FROM VEHICLE AS v
LEFT JOIN RENTAL AS r
    ON v.vehicle_id = r.vehicle_id
LEFT JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
JOIN CATEGORY AS c
    ON v.category_id = c.category_id
JOIN BRANCH AS b
    ON v.branch_id = b.branch_id
GROUP BY
    v.vehicle_id,
    v.brand,
    v.model,
    c.category_name,
    b.branch_name
ORDER BY
    rental_count DESC,
    total_revenue DESC;


------------------------------------------------------------
-- Q12. Vehicle utilization summary
------------------------------------------------------------

SELECT
    v.vehicle_id,
    CONCAT(v.brand, ' ', v.model) AS vehicle_name,
    COUNT(r.rental_id) AS rental_count,
    COALESCE(
        SUM(DATEDIFF(DAY, r.pickup_date, r.return_date)),
        0
    ) AS total_rental_days
FROM VEHICLE AS v
LEFT JOIN RENTAL AS r
    ON v.vehicle_id = r.vehicle_id
GROUP BY
    v.vehicle_id,
    v.brand,
    v.model
ORDER BY
    total_rental_days DESC,
    rental_count DESC;


------------------------------------------------------------
-- Q13. Maintenance cost by vehicle
------------------------------------------------------------

SELECT
    v.vehicle_id,
    v.brand,
    v.model,
    COUNT(m.maintenance_id) AS maintenance_events,
    COALESCE(SUM(m.cost), 0) AS total_maintenance_cost,
    COALESCE(
        AVG(CAST(m.cost AS DECIMAL(10,2))),
        0
    ) AS average_maintenance_cost
FROM VEHICLE AS v
LEFT JOIN MAINTENANCE AS m
    ON v.vehicle_id = m.vehicle_id
GROUP BY
    v.vehicle_id,
    v.brand,
    v.model
ORDER BY total_maintenance_cost DESC;


------------------------------------------------------------
-- Q14. Revenue versus maintenance cost by vehicle
------------------------------------------------------------

WITH VehicleRevenue AS
(
    SELECT
        v.vehicle_id,
        SUM(p.amount) AS total_revenue
    FROM VEHICLE AS v
    LEFT JOIN RENTAL AS r
        ON v.vehicle_id = r.vehicle_id
    LEFT JOIN PAYMENT AS p
        ON r.rental_id = p.rental_id
    GROUP BY v.vehicle_id
),
VehicleMaintenance AS
(
    SELECT
        vehicle_id,
        SUM(cost) AS total_maintenance_cost
    FROM MAINTENANCE
    GROUP BY vehicle_id
)
SELECT
    v.vehicle_id,
    v.brand,
    v.model,
    COALESCE(vr.total_revenue, 0) AS total_revenue,
    COALESCE(vm.total_maintenance_cost, 0)
        AS total_maintenance_cost,
    COALESCE(vr.total_revenue, 0)
        - COALESCE(vm.total_maintenance_cost, 0)
        AS net_contribution
FROM VEHICLE AS v
LEFT JOIN VehicleRevenue AS vr
    ON v.vehicle_id = vr.vehicle_id
LEFT JOIN VehicleMaintenance AS vm
    ON v.vehicle_id = vm.vehicle_id
ORDER BY net_contribution DESC;


------------------------------------------------------------
-- Q15. Average rating by vehicle
------------------------------------------------------------

SELECT
    v.vehicle_id,
    v.brand,
    v.model,
    COUNT(rev.review_id) AS review_count,
    AVG(CAST(rev.rating AS DECIMAL(10,2)))
        AS average_rating
FROM VEHICLE AS v
LEFT JOIN REVIEW AS rev
    ON v.vehicle_id = rev.vehicle_id
GROUP BY
    v.vehicle_id,
    v.brand,
    v.model
ORDER BY
    average_rating DESC,
    review_count DESC;


------------------------------------------------------------
-- Q16. Average rating by category
------------------------------------------------------------

SELECT
    c.category_id,
    c.category_name,
    COUNT(rev.review_id) AS review_count,
    AVG(CAST(rev.rating AS DECIMAL(10,2)))
        AS average_rating
FROM CATEGORY AS c
JOIN VEHICLE AS v
    ON c.category_id = v.category_id
LEFT JOIN REVIEW AS rev
    ON v.vehicle_id = rev.vehicle_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY average_rating DESC;


------------------------------------------------------------
-- Q17. Revenue handled by employee
------------------------------------------------------------

SELECT
    e.employee_id,
    e.employee_name,
    e.position,
    COUNT(r.rental_id) AS rentals_processed,
    SUM(p.amount) AS total_revenue_processed
FROM EMPLOYEE AS e
LEFT JOIN RENTAL AS r
    ON e.employee_id = r.employee_id
LEFT JOIN PAYMENT AS p
    ON r.rental_id = p.rental_id
GROUP BY
    e.employee_id,
    e.employee_name,
    e.position
ORDER BY total_revenue_processed DESC;


------------------------------------------------------------
-- Q18. Payment method analysis
------------------------------------------------------------

SELECT
    payment_method,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_amount,
    AVG(CAST(amount AS DECIMAL(10,2)))
        AS average_payment
FROM PAYMENT
GROUP BY payment_method
ORDER BY total_amount DESC;


------------------------------------------------------------
-- Q19. Reservation status distribution
------------------------------------------------------------

SELECT
    status,
    COUNT(*) AS reservation_count,
    CAST(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)
    ) AS percentage_of_reservations
FROM RESERVATION
GROUP BY status
ORDER BY reservation_count DESC;


------------------------------------------------------------
-- Q20. Highest-revenue branch using ranking
------------------------------------------------------------

WITH BranchRevenue AS
(
    SELECT
        b.branch_name,
        SUM(p.amount) AS total_revenue
    FROM BRANCH AS b
    JOIN VEHICLE AS v
        ON b.branch_id = v.branch_id
    JOIN RENTAL AS r
        ON v.vehicle_id = r.vehicle_id
    JOIN PAYMENT AS p
        ON r.rental_id = p.rental_id
    GROUP BY b.branch_name
),
RankedBranches AS
(
    SELECT
        branch_name,
        total_revenue,
        DENSE_RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM BranchRevenue
)
SELECT
    branch_name,
    total_revenue,
    revenue_rank
FROM RankedBranches
ORDER BY revenue_rank;


------------------------------------------------------------
-- Q21. Cumulative revenue over time
------------------------------------------------------------

WITH DailyRevenue AS
(
    SELECT
        payment_date,
        SUM(amount) AS daily_revenue
    FROM PAYMENT
    GROUP BY payment_date
)
SELECT
    payment_date,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM DailyRevenue
ORDER BY payment_date;


------------------------------------------------------------
-- Q22. Compare each branch with average branch revenue
------------------------------------------------------------

WITH BranchRevenue AS
(
    SELECT
        b.branch_name,
        SUM(p.amount) AS total_revenue
    FROM BRANCH AS b
    JOIN VEHICLE AS v
        ON b.branch_id = v.branch_id
    JOIN RENTAL AS r
        ON v.vehicle_id = r.vehicle_id
    JOIN PAYMENT AS p
        ON r.rental_id = p.rental_id
    GROUP BY b.branch_name
)
SELECT
    branch_name,
    total_revenue,
    AVG(total_revenue) OVER () AS average_branch_revenue,
    total_revenue - AVG(total_revenue) OVER ()
        AS difference_from_average
FROM BranchRevenue
ORDER BY total_revenue DESC;