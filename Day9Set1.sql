USE retail_order_db;

-- TASK 1: CREATE TWO VIEWS

CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    c.customer_id,
    c.customer_name,
    o.order_date,
    o.status,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.unit_price) AS total_amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    c.customer_id,
    c.customer_name,
    o.order_date,
    o.status;

SELECT * FROM vw_order_summary;

CREATE OR REPLACE VIEW vw_low_stock AS
SELECT
    product_id,
    product_name,
    category,
    stock_qty,
    reorder_level
FROM products
WHERE stock_qty <= reorder_level
WITH CHECK OPTION;

SELECT * FROM vw_low_stock;

UPDATE vw_low_stock
SET stock_qty = 9
WHERE product_id = 1;

SELECT * FROM products;


-- TASK 2: STORED PROCEDURE sp_place_order

DROP PROCEDURE IF EXISTS sp_place_order;

DELIMITER //

CREATE PROCEDURE sp_place_order(
    IN p_customer_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_order_number INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET p_order_number = NULL;

    START TRANSACTION;

    IF NOT EXISTS (
        SELECT 1
        FROM customers
        WHERE customer_id = p_customer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;

    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid quantity';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM products
        WHERE product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product does not exist';
    END IF;

    SELECT stock_qty, selling_price
    INTO v_stock, v_price
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    INSERT INTO orders (customer_id, status)
    VALUES (p_customer_id, 'PENDING');

    SET p_order_number = LAST_INSERT_ID();

    INSERT INTO order_items (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES (
        p_order_number,
        p_product_id,
        p_quantity,
        v_price
    );

    UPDATE products
    SET stock_qty = stock_qty - p_quantity
    WHERE product_id = p_product_id;

    COMMIT;
END //

DELIMITER ;

SET @order_no = NULL;

CALL sp_place_order(101, 2, 3, @order_no);

SELECT @order_no AS generated_order_number;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;


-- TASK 3: STORED FUNCTION fn_order_total_with_tax

DROP FUNCTION IF EXISTS fn_order_total_with_tax;

DELIMITER //

CREATE FUNCTION fn_order_total_with_tax(
    p_order_id INT
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT COALESCE(SUM(quantity * unit_price), 0)
    INTO v_total
    FROM order_items
    WHERE order_id = p_order_id;

    RETURN v_total * 1.18;
END //

DELIMITER ;

SELECT
    order_id,
    fn_order_total_with_tax(order_id) AS total_with_tax
FROM orders;


-- TASK 4: CURSOR-BASED PENDING ORDER FOLLOW-UP

DROP PROCEDURE IF EXISTS sp_pending_order_followup;

DELIMITER //

CREATE PROCEDURE sp_pending_order_followup()
BEGIN
    DECLARE v_order_id INT;
    DECLARE v_order_date DATE;
    DECLARE v_finished INT DEFAULT 0;

    DECLARE order_cursor CURSOR FOR
        SELECT order_id, order_date
        FROM orders
        WHERE status = 'PENDING'
          AND order_date < CURDATE() - INTERVAL 3 DAY;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_finished = 1;

    OPEN order_cursor;

    order_loop: LOOP
        FETCH order_cursor INTO v_order_id, v_order_date;

        IF v_finished = 1 THEN
            LEAVE order_loop;
        END IF;

        IF NOT EXISTS (
            SELECT 1
            FROM follow_ups
            WHERE order_id = v_order_id
              AND follow_up_status = 'OPEN'
        ) THEN
            INSERT INTO follow_ups
                (order_id, follow_up_date, note, follow_up_status)
            VALUES
                (v_order_id, CURDATE(),
                 'Follow-up required for pending order', 'OPEN');
        END IF;
    END LOOP;

    CLOSE order_cursor;
END //

DELIMITER ;

CALL sp_pending_order_followup();

SELECT * FROM follow_ups;


-- TASK 5: STORED PROCEDURE FOR QUANTITY VALIDATION

DROP PROCEDURE IF EXISTS sp_validate_quantity;

DELIMITER //

CREATE PROCEDURE sp_validate_quantity(IN p_quantity INT)
BEGIN
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid quantity: quantity must be greater than zero';
    ELSE
        SELECT 'Valid quantity' AS message;
    END IF;
END //

DELIMITER ;

-- Test with a valid quantity
CALL sp_validate_quantity(5);

-- Test with an invalid quantity (this call intentionally returns an error)
CALL sp_validate_quantity(0);

-- Test with a negative quantity (this call intentionally returns an error)
CALL sp_validate_quantity(-3);
