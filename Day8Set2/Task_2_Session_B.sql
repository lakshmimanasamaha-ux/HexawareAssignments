USE airline_booking_db;

START TRANSACTION;

SELECT seat_status
FROM flight_seats
WHERE flight_id = 101 AND seat_no = '2A'
FOR UPDATE;

SELECT flight_id, seat_no, seat_status
FROM flight_seats
WHERE flight_id = 101 AND seat_no = '2A';

ROLLBACK;
