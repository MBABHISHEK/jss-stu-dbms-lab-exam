-- Creating and using the "sailors" database
CREATE DATABASE sailors;
USE sailors;

-- Creating the Sailors table
CREATE TABLE Sailors(
    sid INT PRIMARY KEY,
    sname VARCHAR(35) NOT NULL,
    rating FLOAT NOT NULL,
    age INT NOT NULL
);

-- Creating the Boat table
CREATE TABLE Boat(
    bid INT PRIMARY KEY,
    bname VARCHAR(35) NOT NULL,
    color VARCHAR(25) NOT NULL
);

-- Creating the reserves table
CREATE TABLE reserves(
    sid INT NOT NULL,
    bid INT NOT NULL,
    sdate DATE NOT NULL,
    FOREIGN KEY (sid) REFERENCES Sailors(sid) ON DELETE CASCADE,
    FOREIGN KEY (bid) REFERENCES Boat(bid) ON DELETE CASCADE
);

-- Inserting data into the Sailors table
INSERT INTO Sailors VALUES
(1, "Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);

-- Inserting data into the Boat table
INSERT INTO Boat VALUES
(1, "Boat_1", "Green"),
(2, "Boat_2", "Red"),
(103, "Boat_3", "Blue");

-- Inserting data into the reserves table
INSERT INTO reserves VALUES
(1, 103, "2023-01-01"),
(1, 2, "2023-02-01"),
(2, 1, "2023-02-05"),
(3, 2, "2023-03-06"),
(5, 103, "2023-03-06"),
(1, 1, "2023-03-06");

-- Selecting data from Sailors, Boat, and reserves tables
SELECT * FROM Sailors;
SELECT * FROM Boat;
SELECT * FROM reserves;

-- Query 1: Find the colors of boats reserved by Albert
SELECT DISTINCT b.color
FROM Sailors s, Boat b, reserves r
WHERE s.sid = r.sid AND b.bid = r.bid AND s.sname = "Albert";

-- Query 2: Find all sailor IDs of sailors who have a rating of at least 8 or reserved boat 103
SELECT sid
FROM Sailors
WHERE rating >= 8
UNION
SELECT sid
FROM reserves
WHERE bid = 103;

-- Query 3: Find the names of sailors who have not reserved a boat whose name contains the string “storm”. Order the names in ascending order.
SELECT sname
FROM Sailors s
WHERE s.sid NOT IN 
    (SELECT s1.sid FROM Sailors s1, reserves r1 WHERE r1.sid = s1.sid AND s1.sname LIKE "%storm%")
ORDER BY sname ASC;

-- Query 4: Find the names of sailors who have reserved all boats
SELECT sname
FROM Sailors s
WHERE NOT EXISTS
    (SELECT *
     FROM Boat b
     WHERE NOT EXISTS
         (SELECT *
          FROM reserves r
          WHERE r.sid = s.sid AND b.bid = r.bid));

-- Query 5: Find the name and age of the oldest sailor
SELECT sname, age
FROM Sailors
WHERE age = (SELECT MAX(age) FROM Sailors);

-- Query 6: For each boat reserved by at least 5 sailors with age >= 40, find the boat ID and the average age of such sailors
SELECT b.bid, AVG(s.age) AS average_age
FROM Sailors s, Boat b, reserves r
WHERE r.sid = s.sid AND r.bid = b.bid AND s.age >= 40
GROUP BY b.bid
HAVING COUNT(DISTINCT r.sid) >= 5;

-- Creating a third view (Query 7): Boats reserved by sailors with a specific rating
CREATE VIEW ReservedBoatsWithRatedSailor AS
SELECT DISTINCT bname, color
FROM Sailors s, Boat b, reserves r
WHERE s.sid = r.sid AND b.bid = r.bid AND s.rating = 5;

-- Selecting from the third created view
SELECT * FROM ReservedBoatsWithRatedSailor;

-- Changing delimiter for triggers
DELIMITER //

-- Trigger (Query 8): Preventing deletion of boats with active reservations
CREATE TRIGGER PreventDeleteWithReservations
BEFORE DELETE ON Boat
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM reserves WHERE bid = OLD.bid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
    END IF;
END;//

-- Resetting delimiter
DELIMITER ;
