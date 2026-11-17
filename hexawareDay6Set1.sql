-- PART A: CREATE DATABASE AND TABLES

CREATE DATABASE IF NOT EXISTS insurance_reporting;
USE insurance_reporting;

DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS policies;
DROP TABLE IF EXISTS agents;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL
);

CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100) NOT NULL
);

CREATE TABLE policies (
    policy_id INT PRIMARY KEY,
    policy_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    agent_id INT NOT NULL,
    premium DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id)
);

CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    policy_id INT NOT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (policy_id) REFERENCES policies(policy_id)
);

-- PART B: INSERT SAMPLE DATA

INSERT INTO products VALUES
(1, 'Motor'),
(2, 'Health'),
(3, 'Life');

INSERT INTO customers VALUES
(1, 'Arun',   '1990-05-10'),
(2, 'Banu',   '1985-02-20'),
(3, 'Charan', '2002-08-15'),
(4, 'Divya',  '1970-12-01'),
(5, 'Ezhil',  '1998-03-30'),
(6, 'Farah',  '1960-01-05');

INSERT INTO agents VALUES
(1, 'Meena'),
(2, 'Ravi'),
(3, 'Karthik'),
(4, 'Priya'),
(5, 'Suresh');

INSERT INTO policies VALUES
(1,  'POL10001', 1, 1, 1, 12000.00, DATE_SUB(CURDATE(), INTERVAL 2 MONTH), DATE_ADD(CURDATE(), INTERVAL 5 DAY),   'ACTIVE'),
(2,  'POL10002', 1, 2, 2, 18000.00, DATE_SUB(CURDATE(), INTERVAL 2 MONTH), DATE_ADD(CURDATE(), INTERVAL 20 DAY),  'ACTIVE'),
(3,  'POL10003', 2, 1, 1, 15000.00, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_ADD(CURDATE(), INTERVAL 35 DAY),  'ACTIVE'),
(4,  'POL10004', 3, 2, 3, 10000.00, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_ADD(CURDATE(), INTERVAL 10 DAY),  'ACTIVE'),
(5,  'POL10005', 4, 3, 2, 25000.00, DATE_SUB(CURDATE(), INTERVAL 1 MONTH), DATE_ADD(CURDATE(), INTERVAL 60 DAY),  'ACTIVE'),
(6,  'POL10006', 5, 3, 1, 30000.00, DATE_SUB(CURDATE(), INTERVAL 10 DAY),  DATE_ADD(CURDATE(), INTERVAL 15 DAY),  'ACTIVE'),
(7,  'POL10007', 6, 1, 3,  8000.00, DATE_SUB(CURDATE(), INTERVAL 9 DAY),   DATE_ADD(CURDATE(), INTERVAL 90 DAY),  'ACTIVE'),
(8,  'POL10008', 2, 2, 2, 16000.00, DATE_SUB(CURDATE(), INTERVAL 8 DAY),   DATE_ADD(CURDATE(), INTERVAL 120 DAY), 'ACTIVE'),
(9,  'POL10009', 4, 1, 1, 14000.00, DATE_SUB(CURDATE(), INTERVAL 5 DAY),   DATE_ADD(CURDATE(), INTERVAL 200 DAY), 'ACTIVE'),
(10, 'POL10010', 5, 2, 3, 11000.00, DATE_SUB(CURDATE(), INTERVAL 2 DAY),   DATE_ADD(CURDATE(), INTERVAL 250 DAY), 'ACTIVE'),
(11, 'POL10011', 3, 1, 4,  9000.00, DATE_SUB(CURDATE(), INTERVAL 1 DAY),   DATE_ADD(CURDATE(), INTERVAL 40 DAY),  'ACTIVE'),
(12, 'POL10012', 6, 2, 5, 20000.00, CURDATE(),                              DATE_ADD(CURDATE(), INTERVAL 300 DAY), 'ACTIVE');

INSERT INTO claims VALUES
(1,  1, DATE_SUB(CURDATE(), INTERVAL 20 DAY),  4000.00),
(2,  2, DATE_SUB(CURDATE(), INTERVAL 18 DAY),  6000.00),
(3,  3, DATE_SUB(CURDATE(), INTERVAL 15 DAY),  3000.00),
(4,  5, DATE_SUB(CURDATE(), INTERVAL 12 DAY),  9000.00),
(5,  6, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 12000.00),
(6,  6, DATE_SUB(CURDATE(), INTERVAL  5 DAY),  2000.00),
(7,  9, DATE_SUB(CURDATE(), INTERVAL  3 DAY),  5000.00),
(8, 11, DATE_SUB(CURDATE(), INTERVAL  2 DAY),  2500.00);



SELECT
    CONCAT(SUBSTRING(p.policy_number, 1, 3), '****',
           SUBSTRING(p.policy_number, -4)) AS masked_policy_number,
    c.customer_name,
    p.expiry_date,
    DATEDIFF(p.expiry_date, CURDATE()) AS days_remaining
FROM policies p
INNER JOIN customers c ON p.customer_id = c.customer_id
WHERE p.expiry_date BETWEEN CURDATE()
                        AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY p.expiry_date;

-- QUERY 2: PREMIUM DETAILS PER PRODUCT

SELECT
    pr.product_name,
    COUNT(p.policy_id) AS total_policies,
    SUM(p.premium) AS total_premium,
    ROUND(AVG(p.premium), 2) AS average_premium
FROM products pr
INNER JOIN policies p ON pr.product_id = p.product_id
GROUP BY pr.product_id, pr.product_name
ORDER BY pr.product_name;

-- QUERY 3: CUSTOMERS WITH MORE THAN ONE ACTIVE POLICY

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(p.policy_id) AS active_policy_count
FROM customers c
INNER JOIN policies p ON c.customer_id = p.customer_id
WHERE p.status = 'ACTIVE'
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(p.policy_id) > 1
ORDER BY active_policy_count DESC, c.customer_name;

-- QUERY 4: PRODUCTS WITH CLAIM RATIO ABOVE 60 PERCENT

SELECT
    pr.product_name,
    COUNT(DISTINCT p.policy_id) AS total_policies,
    COUNT(DISTINCT cl.policy_id) AS policies_with_claims,
    ROUND(
        COUNT(DISTINCT cl.policy_id) * 100.0 /
        NULLIF(COUNT(DISTINCT p.policy_id), 0),
        2
    ) AS claim_ratio_percent
FROM products pr
LEFT JOIN policies p ON pr.product_id = p.product_id
LEFT JOIN claims cl ON p.policy_id = cl.policy_id
GROUP BY pr.product_id, pr.product_name
HAVING claim_ratio_percent > 60
ORDER BY claim_ratio_percent DESC;

-- QUERY 5: POLICIES WITHOUT CLAIMS

SELECT
    p.policy_number,
    c.customer_name,
    pr.product_name,
    p.premium,
    p.status
FROM policies p
INNER JOIN customers c ON p.customer_id = c.customer_id
INNER JOIN products pr ON p.product_id = pr.product_id
LEFT JOIN claims cl ON p.policy_id = cl.policy_id
WHERE cl.claim_id IS NULL
ORDER BY p.policy_id;

-- QUERY 6: AVERAGE PREMIUM BY CUSTOMER AGE BAND

SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, report_date.today) BETWEEN 18 AND 30
            THEN '18-30'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, report_date.today) BETWEEN 31 AND 45
            THEN '31-45'
        WHEN TIMESTAMPDIFF(YEAR, c.date_of_birth, report_date.today) BETWEEN 46 AND 60
            THEN '46-60'
        ELSE '61+'
    END AS age_band,
    COUNT(p.policy_id) AS total_policies,
    ROUND(AVG(p.premium), 2) AS average_premium
FROM customers c
CROSS JOIN (SELECT CURDATE() AS today) AS report_date
INNER JOIN policies p ON c.customer_id = p.customer_id
GROUP BY age_band
ORDER BY
    CASE age_band
        WHEN '18-30' THEN 1
        WHEN '31-45' THEN 2
        WHEN '46-60' THEN 3
        ELSE 4
    END;

-- QUERY 7: MONTHLY NEW POLICIES

SELECT
    DATE_FORMAT(start_date, '%Y-%m') AS policy_month,
    COUNT(*) AS new_policy_count
FROM policies
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY policy_month;

-- QUERY 8: TOP 5 AGENTS BY TOTAL PREMIUM

SELECT
    a.agent_id,
    a.agent_name,
    COUNT(p.policy_id) AS policies_sold,
    SUM(p.premium) AS total_premium
FROM agents a
INNER JOIN policies p ON a.agent_id = p.agent_id
GROUP BY a.agent_id, a.agent_name
ORDER BY total_premium DESC
LIMIT 5;
