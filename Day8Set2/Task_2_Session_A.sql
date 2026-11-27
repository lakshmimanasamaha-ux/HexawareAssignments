USE airline_booking_db;

START TRANSACTION;

SELECT seat_status
FROM flight_seats
WHERE flight_id = 101 AND seat_no = '2A'
FOR UPDATE;

INSERT INTO bookings (flight_id, seat_no, passenger_id, fare)
VALUES (101, '2A', 1, 4999.00);

UPDATE flight_seats
SET seat_status = 'BOOKED'
WHERE flight_id = 101 AND seat_no = '2A';

-- Execute COMMIT only after Session B has started its locking SELECT.
COMMIT;

SELECT flight_id, seat_no, seat_status
FROM flight_seats
WHERE flight_id = 101 AND seat_no = '2A';
