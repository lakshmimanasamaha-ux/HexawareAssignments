DROP TABLE IF EXISTS guarantors CASCADE;
DROP TABLE IF EXISTS repayments CASCADE;
DROP TABLE IF EXISTS loan_installments CASCADE;
DROP TABLE IF EXISTS loans CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS branches CASCADE;

CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(100)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    branch_id INT NOT NULL REFERENCES branches(branch_id),
    loan_amount NUMERIC(12,2) NOT NULL,
    loan_date DATE NOT NULL,
    loan_status VARCHAR(20) NOT NULL
);

CREATE TABLE loan_installments (
    installment_id INT PRIMARY KEY,
    loan_id INT NOT NULL REFERENCES loans(loan_id),
    installment_no INT NOT NULL,
    due_date DATE NOT NULL,
    amount_due NUMERIC(10,2) NOT NULL,
    amount_paid NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE repayments (
    repayment_id INT PRIMARY KEY,
    loan_id INT NOT NULL REFERENCES loans(loan_id),
    repayment_date DATE NOT NULL,
    amount_paid NUMERIC(10,2) NOT NULL
);

CREATE TABLE guarantors (
    loan_id INT NOT NULL REFERENCES loans(loan_id),
    guarantor_customer_id INT NOT NULL REFERENCES customers(customer_id),
    PRIMARY KEY (loan_id, guarantor_customer_id)
);

INSERT INTO branches VALUES
(1, 'Chennai Main', 'Chennai'),
(2, 'Anna Nagar', 'Chennai'),
(3, 'Coimbatore', 'Coimbatore'),
(4, 'Madurai', 'Madurai'),
(5, 'Salem', 'Salem');

INSERT INTO customers VALUES
(101, 'Amit', '9000000001'),
(102, 'Priya', '9000000002'),
(103, 'Rahul', '9000000003'),
(104, 'Sneha', '9000000004'),
(105, 'Kavin', '9000000005'),
(106, 'Divya', '9000000006'),
(107, 'Arun', '9000000007'),
(108, 'Meena', '9000000008'),
(109, 'Vijay', '9000000009'),
(110, 'Nila', '9000000010');

INSERT INTO loans VALUES
(1001, 101, 1, 500000, DATE '2025-01-10', 'ACTIVE'),
(1002, 102, 1, 300000, DATE '2025-02-15', 'ACTIVE'),
(1003, 103, 2, 800000, DATE '2025-03-12', 'ACTIVE'),
(1004, 101, 2, 250000, DATE '2025-04-20', 'ACTIVE'),
(1005, 104, 3, 900000, DATE '2025-05-05', 'ACTIVE'),
(1006, 105, 3, 200000, DATE '2025-06-18', 'ACTIVE'),
(1007, 106, 1, 150000, DATE '2025-07-01', 'ACTIVE'),
(1008, 107, 2, 650000, DATE '2025-07-15', 'ACTIVE'),
(1009, 108, 3, 400000, DATE '2025-08-10', 'ACTIVE'),
(1010, 109, 1, 1000000, DATE '2025-09-01', 'ACTIVE'),
(1011, 102, 3, 350000, DATE '2025-09-12', 'ACTIVE');

INSERT INTO loan_installments VALUES
(1, 1001, 1, CURRENT_DATE - 120, 10000, 0),
(2, 1001, 2, CURRENT_DATE - 90, 10000, 0),
(3, 1001, 3, CURRENT_DATE - 60, 10000, 0),
(4, 1001, 4, CURRENT_DATE - 30, 10000, 0),
(5, 1002, 1, CURRENT_DATE - 20, 8000, 8000),
(6, 1003, 1, CURRENT_DATE - 15, 12000, 0),
(7, 1004, 1, CURRENT_DATE - 10, 7000, 7000),
(8, 1005, 1, CURRENT_DATE - 45, 15000, 0),
(9, 1006, 1, CURRENT_DATE - 5, 5000, 5000),
(10, 1007, 1, CURRENT_DATE - 12, 4000, 0),
(11, 1008, 1, CURRENT_DATE - 25, 9000, 0),
(12, 1009, 1, CURRENT_DATE - 18, 6000, 6000),
(13, 1010, 1, CURRENT_DATE - 35, 20000, 0),
(14, 1011, 1, CURRENT_DATE - 8, 7500, 7500);

INSERT INTO repayments VALUES
(1, 1002, CURRENT_DATE - 10, 8000),
(2, 1003, CURRENT_DATE - 20, 12000),
(3, 1004, CURRENT_DATE - 5, 7000),
(4, 1006, CURRENT_DATE - 3, 5000),
(5, 1009, CURRENT_DATE - 15, 6000),
(6, 1011, CURRENT_DATE - 4, 7500);

INSERT INTO guarantors VALUES
(1001, 103),
(1002, 101),
(1003, 104),
(1005, 102),
(1007, 108),
(1008, 105);

-- TASK 1: TEN REPORT QUERIES

-- Q1
SELECT l.loan_id, l.customer_id, l.branch_id, l.loan_amount,
       COUNT(*) AS overdue_installments
FROM loans l
JOIN loan_installments i ON i.loan_id = l.loan_id
WHERE i.due_date < CURRENT_DATE
  AND COALESCE(i.amount_paid, 0) < i.amount_due
GROUP BY l.loan_id, l.customer_id, l.branch_id, l.loan_amount
HAVING COUNT(*) > 3;

-- Q2
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT l.branch_id) AS branch_count
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT l.branch_id) > 1;

-- Q3
SELECT DISTINCT g.guarantor_customer_id,
       c.customer_name AS guarantor_name
FROM guarantors g
JOIN customers c ON c.customer_id = g.guarantor_customer_id
JOIN loans l ON l.customer_id = g.guarantor_customer_id;

-- Q4
SELECT b.branch_id, b.branch_name
FROM branches b
WHERE NOT EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.branch_id = b.branch_id
);

-- Q5
SELECT c.customer_id, c.customer_name,
       SUM(l.loan_amount) AS total_loan_amount
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_loan_amount DESC;

-- Q6
SELECT b.branch_id, b.branch_name,
       COUNT(l.loan_id) AS total_loans,
       COALESCE(SUM(l.loan_amount), 0) AS total_loan_amount
FROM branches b
LEFT JOIN loans l ON l.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY b.branch_id;

-- Q7
SELECT l.loan_id, c.customer_name, l.loan_amount, l.loan_status
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
WHERE l.loan_amount > (
    SELECT AVG(loan_amount)
    FROM loans
);

-- Q8
SELECT c.customer_id, c.customer_name, COUNT(l.loan_id) AS loan_count
FROM customers c
JOIN loans l ON l.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(l.loan_id) > 1;

-- Q9
SELECT b.branch_id, b.branch_name, MAX(l.loan_amount) AS highest_loan
FROM branches b
JOIN loans l ON l.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name;

-- Q10
SELECT l.loan_id, c.customer_name, b.branch_name, l.loan_amount
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
JOIN branches b ON b.branch_id = l.branch_id
WHERE l.loan_status = 'ACTIVE'
ORDER BY l.loan_amount DESC;

-- TASK 2: CORRELATED AND UNCORRELATED SUBQUERIES

-- Q1: CORRELATED SUBQUERY
WITH customer_exposure AS (
    SELECT branch_id, customer_id, SUM(loan_amount) AS total_exposure
    FROM loans
    GROUP BY branch_id, customer_id
)
SELECT ce.branch_id, ce.customer_id, c.customer_name, ce.total_exposure
FROM customer_exposure ce
JOIN customers c ON c.customer_id = ce.customer_id
WHERE ce.total_exposure > (
    SELECT AVG(ce2.total_exposure)
    FROM customer_exposure ce2
    WHERE ce2.branch_id = ce.branch_id
);

-- Q2: UNCORRELATED SUBQUERY
WITH customer_exposure AS (
    SELECT branch_id, customer_id, SUM(loan_amount) AS total_exposure
    FROM loans
    GROUP BY branch_id, customer_id
),
branch_average AS (
    SELECT branch_id, AVG(total_exposure) AS avg_exposure
    FROM customer_exposure
    GROUP BY branch_id
)
SELECT ce.branch_id, ce.customer_id, c.customer_name,
       ce.total_exposure, ba.avg_exposure
FROM customer_exposure ce
JOIN branch_average ba ON ba.branch_id = ce.branch_id
JOIN customers c ON c.customer_id = ce.customer_id
WHERE ce.total_exposure > ba.avg_exposure;

-- TASK 3: EXISTS AND NOT EXISTS

SELECT DISTINCT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM loans l
    WHERE l.customer_id = c.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM loans l
    JOIN repayments r ON r.loan_id = l.loan_id
    WHERE l.customer_id = c.customer_id
      AND r.repayment_date >= CURRENT_DATE - INTERVAL '60 days'
      AND r.repayment_date <= CURRENT_DATE
);

-- TASK 4: NESTED SUBQUERY

SELECT b.branch_id, b.branch_name, MAX(l.loan_amount) AS highest_loan
FROM branches b
JOIN loans l ON l.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name
HAVING MAX(l.loan_amount) > (
    SELECT AVG(branch_max)
    FROM (
        SELECT MAX(loan_amount) AS branch_max
        FROM loans
        GROUP BY branch_id
    ) AS branch_maximums
);
