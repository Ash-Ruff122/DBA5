use ap; 


--  Create a stored procedure to get all invoices for a specific vendor
DELIMITER // 
CREATE PROCEDURE get_vendor_invoices(IN v_vendor_id INT)
BEGIN 
    SELECT invoice_id, invoice_number, invoice_date, invoice_total, payment_total
    FROM invoices 
    WHERE vendor_id = v_vendor_id;
END //
DELIMITER ;


-- Accepts a invoice id and a payment total.
-- It checks if the payment total is less than or equal to the invoice total.
-- If it is, it updates the payment total for that invoice.If the payment total is greater than the invoice total, it returns an error message.
DELIMITER //
CREATE PROCEDURE apply_payment(IN i_invoice_id INT, IN i_payment_total DECIMAL(10,2))
BEGIN 
    DECLARE v_invoice_total DECIMAL(10,2);
    DECLARE v_payment_total DECIMAL(10,2);
    DECLARE v_new_payment_total DECIMAL(10,2);

    SELECT invoice_total, payment_total 
    INTO v_invoice_total, v_payment_total 
    FROM invoices 
    WHERE invoice_id = i_invoice_id;

    SET v_new_payment_total = v_payment_total + i_payment_total;

    IF v_new_payment_total > v_invoice_total 
    THEN 
        SELECT 'ERROR: Payment total exceeds invoice total'; 
    ELSE
        UPDATE invoices    
        SET payment_total = v_new_payment_total 
        WHERE invoice_id = i_invoice_id;
        SELECT 'Payment applied successfully'; 
    END IF;
END //




-- Inserts a new invoice into the invoices table.
-- Sets the payment total to 0. And returns the new invoice id.
DELIMITER // 
CREATE PROCEDURE insert_new_invoice(IN v_vendor_id INT, IN i_invoice_number VARCHAR(50), IN i_invoice_date DATE, IN i_invoice_total DECIMAL(10,2),IN t_terms_id INT)
BEGIN 
    DECLARE new_invoice_id INT;

    INSERT INTO invoices (vendor_id, invoice_number, invoice_date, invoice_total, payment_total, terms_id)
    VALUES (v_vendor_id, i_invoice_number, i_invoice_date, i_invoice_total, 0, t_terms_id);
    SET new_invoice_id = LAST_INSERT_ID();
    SELECT new_invoice_id AS invoice_id;
END //
DELIMITER ;
