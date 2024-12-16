-- HW5: Identifying Adverse Drug Events (ADEs) with Stored Programs
-- Prof. Rachlin
-- CS CS5200: Databases

-- We've already setup the ade database by running ade_setup.sql
-- First, make ade the active database.  Note, this database is actually based on 
-- the emr_sp schema used in the lab, but it included some extra tables.

use ade;


-- A stored procedure to process and validate prescriptions
-- Four things we need to check
-- a) Is patient a child and is medication suitable for children?
-- b) Is patient pregnant and is medication suitable for pregnant women?
-- c) Is dosage reasonable?
-- d) Are there any adverse drug reactions

drop procedure if exists prescribe;

DELIMITER //

CREATE PROCEDURE prescribe
(
    IN patient_name_param VARCHAR(255),
    IN doctor_name_param VARCHAR(255),
    IN medication_name_param VARCHAR(255),
    IN ppd_param INT
)
BEGIN
    -- Variable declarations
    DECLARE patient_id_var INT;
    DECLARE age_var FLOAT;
    DECLARE is_pregnant_var BOOLEAN;
    DECLARE weight_var INT;
    DECLARE doctor_id_var INT;
    DECLARE medication_id_var INT;
    DECLARE take_under_12_var BOOLEAN;
    DECLARE take_if_pregnant_var BOOLEAN;
    DECLARE mg_per_pill_var DOUBLE;
    DECLARE max_mg_per_10kg_var DOUBLE;
    DECLARE calculated_max_dosage INT;
    DECLARE ddi_found BOOLEAN DEFAULT FALSE;
    DECLARE ddi_medication_name VARCHAR(255);

	-- select relevant values into variables
    
    SELECT patient_id, 
           TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age, 
           is_pregnant, 
           weight 
    INTO patient_id_var, 
         age_var, 
         is_pregnant_var, 
         weight_var
    FROM patient 
    WHERE patient_name = patient_name_param;

    SELECT doctor_id INTO doctor_id_var
    FROM doctor WHERE doctor_name = doctor_name_param;

    SELECT medication_id, take_under_12, take_if_pregnant, mg_per_pill, max_mg_per_10kg
    INTO medication_id_var, take_under_12_var, take_if_pregnant_var, mg_per_pill_var, max_mg_per_10kg_var
    FROM medication WHERE medication_name = medication_name_param;

    SET calculated_max_dosage = FLOOR((weight_var / 10) * max_mg_per_10kg_var / mg_per_pill_var);

	-- Check if medication is suitable for children
    IF age_var < 12 AND take_under_12_var = FALSE THEN
        SELECT CONCAT(medication_name_param, ' cannot be prescribed to children under 12.') AS Warning;
    END IF;

	-- Check if medication is suitable for pregnant patients
    IF is_pregnant_var = TRUE AND take_if_pregnant_var = FALSE THEN
        SELECT CONCAT(medication_name_param, ' cannot be prescribed to pregnant women.') AS Warning;
    END IF;

    -- Check dosage
    IF ppd_param > calculated_max_dosage THEN
        SELECT CONCAT('Maximum dosage for ', medication_name_param, ' is ', calculated_max_dosage, ' pills per day for patient ', patient_name_param, '.') AS Warning;
    END IF;

    -- Check for reactions involving medications already prescribed to patient
    SELECT COUNT(*)
    INTO ddi_found
    FROM prescription p
    JOIN interaction i ON p.medication_id = i.medication_1
    WHERE p.patient_id = patient_id_var AND i.medication_2 = medication_id_var;

    IF ddi_found > 0 THEN
        SELECT medication_name INTO ddi_medication_name
        FROM prescription p
        JOIN medication m ON p.medication_id = m.medication_id
        JOIN interaction i ON p.medication_id = i.medication_1
        WHERE p.patient_id = patient_id_var AND i.medication_2 = medication_id_var
        LIMIT 1;

        SELECT CONCAT(medication_name_param, ' interacts with ', ddi_medication_name, ' currently prescribed to ', patient_name_param, '.') AS Warning;
    END IF;

    --  No exceptions thrown, so insert the prescription record
    IF NOT (age_var < 12 AND take_under_12_var = FALSE) AND
       NOT (is_pregnant_var = TRUE AND take_if_pregnant_var = FALSE) AND
       NOT (ppd_param > calculated_max_dosage) AND
       ddi_found = FALSE THEN
        INSERT INTO prescription (medication_id, patient_id, doctor_id, ppd, prescription_dt)
        VALUES (medication_id_var, patient_id_var, doctor_id_var, ppd_param, NOW());
        SELECT CONCAT('Prescription for ', medication_name_param, ' has been added successfully.') AS Message;
    END IF;
END //

DELIMITER ;

-- Trigger for when a patient becomes pregnant

DROP TRIGGER IF EXISTS handle_pregnancy_update;

DELIMITER //

CREATE TRIGGER handle_pregnancy_update
AFTER UPDATE ON patient
FOR EACH ROW
BEGIN
    -- If patient became pregnant
    IF NEW.is_pregnant = TRUE AND OLD.is_pregnant = FALSE THEN
        -- Add prenatal vitamin recommendation
        IF NOT EXISTS (
            SELECT 1 
            FROM recommendation 
            WHERE patient_id = NEW.patient_id 
              AND message = 'Take pre-natal vitamins'
        ) THEN
            INSERT INTO recommendation (patient_id, message)
            VALUES (NEW.patient_id, 'Take pre-natal vitamins');
        END IF;

        -- Delete prescriptions unsafe for pregnancy
        DELETE FROM prescription
        WHERE patient_id = NEW.patient_id
          AND medication_id IN (
              SELECT medication_id
              FROM medication
              WHERE take_if_pregnant = FALSE
          );
    END IF;

    -- If patient is no longer pregnant
    IF NEW.is_pregnant = FALSE AND OLD.is_pregnant = TRUE THEN
        -- Remove prenatal vitamin recommendation
        DELETE FROM recommendation
        WHERE patient_id = NEW.patient_id
          AND message = 'Take pre-natal vitamins';
    END IF;
END //

DELIMITER ;

-- --------------------------          TEST CASES          -----------------------
-- -------------------------- DONT CHANGE BELOW THIS LINE! -----------------------
-- Test cases
truncate prescription;

-- These prescriptions should succeed
call prescribe('Jones', 'Dr.Marcus', 'Happyza', 2);
call prescribe('Johnson', 'Dr.Marcus', 'Forgeta', 1);
call prescribe('Williams', 'Dr.Marcus', 'Happyza', 1);
call prescribe('Phillips', 'Dr.McCoy', 'Forgeta', 1);

-- These prescriptions should fail
-- Pregnancy violation
call prescribe('Jones', 'Dr.Marcus', 'Forgeta', 2);

-- Age restriction
call prescribe('BillyTheKid', 'Dr.Marcus', 'Muscula', 1);

-- Excessive Dosage
call prescribe('Lee', 'Dr.Marcus', 'Foobaral', 3);

-- Drug interaction
call prescribe('Williams', 'Dr.Marcus', 'Sadza', 1);


-- Testing trigger
-- Phillips (patient_id=4) becomes pregnant
-- Verify that a recommendation for pre-natal vitamins is added
-- and that her prescription for 
update patient
set is_pregnant = True
where patient_id = 4;

select * from recommendation;
select * from prescription;


-- Phillips (patient_id=4) is no longer pregnant
-- Verify that the prenatal vitamin recommendation is gone
-- Her old prescription does not need to be added back

update patient
set is_pregnant = False
where patient_id = 4;

select * from recommendation;

