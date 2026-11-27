-- ============================================================
-- JAVA TRACK - DAY 8 ASSIGNMENT
-- ============================================================
CREATE DATABASE IF NOT EXISTS airline_booking_db;
USE airline_booking_db;

DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS flight_seats;
DROP TABLE IF EXISTS passengers;
DROP TABLE IF EXISTS flights;

CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_no VARCHAR(10) NOT NULL,
    origin VARCHAR(60) NOT NULL,
    destination VARCHAR(60) NOT NULL,
    flight_date DATE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE passengers (
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE
) ENGINE=InnoDB;

CREATE TABLE flight_seats (
    flight_id INT NOT NULL,
    seat_no VARCHAR(5) NOT NULL,
    seat_status ENUM('AVAILABLE','BOOKED') NOT NULL DEFAULT 'AVAILABLE',
    PRIMARY KEY (flight_id, seat_no),
    CONSTRAINT fk_seat_flight FOREIGN KEY (flight_id)
        REFERENCES flights(flight_id)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    booking_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    seat_no VARCHAR(5) NOT NULL,
    passenger_id INT NOT NULL,
    fare DECIMAL(10,2) NOT NULL,
    booking_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_flight_seat_booking UNIQUE (flight_id, seat_no),
    CONSTRAINT fk_booking_seat FOREIGN KEY (flight_id, seat_no)
        REFERENCES flight_seats(flight_id, seat_no),
    CONSTRAINT fk_booking_passenger FOREIGN KEY (passenger_id)
        REFERENCES passengers(passenger_id),
    CONSTRAINT chk_booking_fare CHECK (fare >= 0)
) ENGINE=InnoDB;

INSERT INTO flights VALUES
(101,'MC101','Chennai','Bengaluru','2026-12-10'),
(102,'MC202','Chennai','Mumbai','2026-12-11');

INSERT INTO passengers VALUES
(1,'Ananya Rao','ananya@example.com'),
(2,'Arjun Kumar','arjun@example.com'),
(3,'Divya S','divya@example.com'),
(4,'Karthik M','karthik@example.com'),
(5,'Meera N','meera@example.com'),
(6,'Rahul P','rahul@example.com');

INSERT INTO flight_seats (flight_id, seat_no) VALUES
(101,'1A'),(101,'1B'),(101,'1C'),(101,'2A'),(101,'2B'),
(102,'1A'),(102,'1B'),(102,'1C'),(102,'2A'),(102,'2B');

INSERT INTO bookings (flight_id, seat_no, passenger_id, fare) VALUES
(101,'1A',1,4500.00),
(101,'1B',2,4500.00),
(101,'1C',3,5200.00),
(101,'2A',4,3800.00),
(102,'1A',5,6100.00),
(102,'1B',6,7200.00);

UPDATE flight_seats fs
JOIN bookings b ON b.flight_id=fs.flight_id AND b.seat_no=fs.seat_no
SET fs.seat_status='BOOKED';

-- Check setup:
SELECT * FROM flights;
SELECT * FROM passengers;
SELECT * FROM flight_seats ORDER BY flight_id, seat_no;
SELECT * FROM bookings ORDER BY flight_id, booking_id;


-- ============================================================
-- TASK 1: BOOKING TRANSACTION
-- ============================================================
DROP PROCEDURE IF EXISTS book_airline_seat;
DELIMITER $$

CREATE PROCEDURE book_airline_seat(
    IN p_flight_id INT,
    IN p_seat_no VARCHAR(5),
    IN p_passenger_id INT,
    IN p_fare DECIMAL(10,2)
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_seat_found INT DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    BEGIN
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_seat_found = 0;
        SELECT seat_status
          INTO v_status
          FROM flight_seats
         WHERE flight_id = p_flight_id
           AND seat_no = p_seat_no
         FOR UPDATE;
    END;

    IF v_seat_found = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Seat does not exist for this flight';
    END IF;

    IF v_status <> 'AVAILABLE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Seat is already booked';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM passengers WHERE passenger_id = p_passenger_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Passenger does not exist';
    END IF;

    IF p_fare < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Fare cannot be negative';
    END IF;

    INSERT INTO bookings (flight_id, seat_no, passenger_id, fare)
    VALUES (p_flight_id, p_seat_no, p_passenger_id, p_fare);

    UPDATE flight_seats
       SET seat_status = 'BOOKED'
     WHERE flight_id = p_flight_id
       AND seat_no = p_seat_no;

    COMMIT;
END$$
DELIMITER ;

-- Execute Task 1 (seat 2B is available in the sample data):
CALL book_airline_seat(101, '2B', 1, 4999.00);

-- Verify Task 1:
SELECT * FROM bookings WHERE flight_id=101 AND seat_no='2B';
SELECT * FROM flight_seats WHERE flight_id=101 AND seat_no='2B';

-- ============================================================
-- TASK 2: TWO-SESSION CONCURRENT BOOKING / LOCKING EXPERIMENT
-- session A and session B are 2 seperate files
-- ============================================================
-- ============================================================
-- TASK 3: FARE RANKING WITH RANK AND DENSE_RANK
-- ============================================================
SELECT
    f.flight_no,
    p.passenger_name,
    b.fare,
    RANK() OVER (
        PARTITION BY b.flight_id ORDER BY b.fare DESC
    ) AS fare_rank,
    DENSE_RANK() OVER (
        PARTITION BY b.flight_id ORDER BY b.fare DESC
    ) AS dense_fare_rank
FROM bookings b
JOIN passengers p ON p.passenger_id = b.passenger_id
JOIN flights f ON f.flight_id = b.flight_id
ORDER BY b.flight_id, b.fare DESC, p.passenger_name;

-- ============================================================
-- TASK 4: CTE AND RUNNING REVENUE PER FLIGHT
-- ============================================================
WITH flight_fares AS (
    SELECT
        b.booking_id,
        b.flight_id,
        f.flight_no,
        p.passenger_name,
        b.fare,
        b.booking_time
    FROM bookings b
    JOIN flights f ON f.flight_id = b.flight_id
    JOIN passengers p ON p.passenger_id = b.passenger_id
)
SELECT
    flight_no,
    passenger_name,
    fare,
    SUM(fare) OVER (
        PARTITION BY flight_id
        ORDER BY booking_time, booking_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM flight_fares
ORDER BY flight_id, booking_time, booking_id;


-- ============================================================
-- TASK 5: CORRELATED SUBQUERY - ABOVE AVERAGE FARE
-- ============================================================
SELECT
    f.flight_no,
    p.passenger_name,
    b.fare
FROM bookings b
JOIN passengers p ON p.passenger_id = b.passenger_id
JOIN flights f ON f.flight_id = b.flight_id
WHERE b.fare > (
    SELECT AVG(b2.fare)
    FROM bookings b2
    WHERE b2.flight_id = b.flight_id
)
ORDER BY b.flight_id, b.fare DESC;


