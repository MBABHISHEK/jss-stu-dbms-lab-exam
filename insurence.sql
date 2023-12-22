-- Drop and create the 'insurance' database
DROP DATABASE IF EXISTS insurance;
CREATE DATABASE insurance;
USE insurance;

-- Create the 'person' table to store information about individuals
CREATE TABLE person (
    driver_id VARCHAR(255) NOT NULL,
    driver_name TEXT NOT NULL,
    address TEXT NOT NULL,
    PRIMARY KEY (driver_id)
);

-- Create the 'car' table to store information about vehicles
CREATE TABLE car (
    reg_no VARCHAR(255) NOT NULL,
    model TEXT NOT NULL,
    c_year INTEGER,
    PRIMARY KEY (reg_no)
);

-- Create the 'accident' table to store information about accidents
CREATE TABLE accident (
    report_no INTEGER NOT NULL,
    accident_date DATE,
    location TEXT,
    PRIMARY KEY (report_no)
);

-- Create the 'owns' table to represent the ownership relationship between persons and cars
CREATE TABLE owns (
    driver_id VARCHAR(255) NOT NULL,
    reg_no VARCHAR(255) NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

-- Create the 'participated' table to represent the participation of drivers and cars in accidents
CREATE TABLE participated (
    driver_id VARCHAR(255) NOT NULL,
    reg_no VARCHAR(255) NOT NULL,
    report_no INTEGER NOT NULL,
    damage_amount FLOAT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
    FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

-- Insert sample data into the 'person' table
INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

-- Insert sample data into the 'car' table
INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

-- Insert sample data into the 'accident' table
INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

-- Insert sample data into the 'owns' table
INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

-- Insert sample data into the 'participated' table
INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);


-- 1. Total number of people who owned cars involved in accidents in 2021
SELECT COUNT(DISTINCT P.driver_id) AS total_owners
FROM person P
JOIN owns O ON P.driver_id = O.driver_id
JOIN participated PA ON O.driver_id = PA.driver_id AND O.reg_no = PA.reg_no
JOIN accident A ON PA.report_no = A.report_no
WHERE YEAR(A.accident_date) = 2021;

-- 2. Number of accidents involving cars belonging to "Smith"
SELECT COUNT(DISTINCT A.report_no) AS accidents_involving_smith
FROM accident A
JOIN participated PA ON A.report_no = PA.report_no
JOIN owns O ON PA.driver_id = O.driver_id AND PA.reg_no = O.reg_no
JOIN person P ON O.driver_id = P.driver_id
WHERE P.driver_name = 'Smith';

-- 3. Add a new accident to the database
INSERT INTO accident VALUES
(67890, '2023-06-15', 'NewLocation');

-- 4. Delete the Mazda belonging to "Smith"
DELETE FROM car
WHERE model = 'Mazda'
AND reg_no IN (SELECT O.reg_no FROM owns O JOIN person P ON O.driver_id = P.driver_id WHERE P.driver_name = 'Smith');

-- 5. Update the damage amount for the car with license number "KA-09-MA-1234" in the accident
UPDATE participated
SET damage_amount = 15000
WHERE report_no = 65738 AND reg_no = 'KA-09-MA-1234';

-- 6. View showing models and years of cars involved in accidents
CREATE VIEW CarsInAccident AS
SELECT DISTINCT model, c_year
FROM car C
JOIN participated P ON C.reg_no = P.reg_no;

-- 7. Trigger preventing a driver from participating in more than 3 accidents in a given year
DELIMITER //
CREATE TRIGGER PreventExcessiveParticipation
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM participated WHERE driver_id = NEW.driver_id AND YEAR(accident_date) = YEAR(NOW())) >= 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver has participated in 3 or more accidents this year';
    END IF;
END;
//
DELIMITER ;



