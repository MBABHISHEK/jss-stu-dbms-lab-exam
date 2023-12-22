CREATE DATABASE sailors;
USE sailors;

CREATE TABLE Sailors(
    sid INT PRIMARY KEY,
    sname VARCHAR(35) NOT NULL,
    rating FLOAT NOT NULL,
    age INT NOT NULL
);

CREATE TABLE Boat(
    bid INT PRIMARY KEY,
    bname VARCHAR(35) NOT NULL,
    color VARCHAR(25) NOT NULL
);

CREATE TABLE reserves(
    sid INT NOT NULL,
    bid INT NOT NULL,
    sdate DATE NOT NULL,
    FOREIGN KEY (sid) REFERENCES Sailors(sid) ON DELETE CASCADE,
    FOREIGN KEY (bid) REFERENCES Boat(bid) ON DELETE CASCADE
);

INSERT INTO Sailors VALUES
(1, "Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);

INSERT INTO Boat VALUES
(1, "Boat_1", "Green"),
(2, "Boat_2", "Red"),
(103, "Boat_3", "Blue");

INSERT INTO reserves VALUES
(1, 103, "2023-01-01"),
(1, 2, "2023-02-01"),
(2, 1, "2023-02-05"),
(3, 2, "2023-03-06"),
(5, 103, "2023-03-06"),
(1, 1, "2023-03-06");

SELECT * FROM Sailors;
SELECT * FROM Boat;
SELECT * FROM reserves;

SELECT color 
FROM Sailors s, Boat b, reserves r 
WHERE s.sid = r.sid AND b.bid = r.bid AND s.sname = "Albert";

SELECT sid
FROM Sailors
WHERE Sailors.rating >= 8
UNION
SELECT sid
FROM reserves
WHERE reserves.bid = 103;

SELECT s.sname
FROM Sailors s
WHERE s.sid NOT IN 
(SELECT s1.sid FROM Sailors s1, reserves r1 WHERE r1.sid = s1.sid AND s1.sname LIKE "%storm%")
AND s.sname LIKE "%storm%"
ORDER BY s.sname ASC;

SELECT sname
FROM Sailors s
WHERE NOT EXISTS
    (SELECT *
     FROM Boat b
     WHERE NOT EXISTS
         (SELECT *
          FROM reserves r
          WHERE r.sid = s.sid AND b.bid = r.bid));

SELECT sname, age
FROM Sailors WHERE age IN (SELECT MAX(age) FROM Sailors);

SELECT b.bid, AVG(s.age) AS average_age
FROM Sailors s, Boat b, reserves r
WHERE r.sid = s.sid AND r.bid = b.bid AND s.age >= 40
GROUP BY bid
HAVING 2 <= COUNT(DISTINCT r.sid);

CREATE VIEW NamesAndRating AS
SELECT sname, rating
FROM Sailors
ORDER BY rating DESC;

SELECT * FROM NamesAndRating;

CREATE VIEW SailorsWithReservation AS
SELECT sname
FROM Sailors s, reserves r
WHERE r.sid = s.sid AND r.sdate = "2023-03-06";

SELECT * FROM SailorsWithReservation;

CREATE VIEW ReservedBoatsWithRatedSailor AS
SELECT DISTINCT bname, color
FROM Sailors s, Boat b, reserves r
WHERE s.sid = r.sid AND b.bid = r.bid AND s.rating = 5;

SELECT * FROM ReservedBoatsWithRatedSailor;

DELIMITER //
CREATE OR REPLACE TRIGGER CheckAndDelete
BEFORE DELETE ON Boat
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM reserves WHERE reserves.bid = old.bid) THEN
        SIGNAL SQLSTATE '45000' SET message_text = 'Boat is reserved and hence cannot be deleted';
    END IF;
END;//
DELIMITER ;

DELETE FROM Boat WHERE bid = 103;

DELIMITER //
CREATE TRIGGER BlockReservation
BEFORE INSERT ON reserves
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT * FROM Sailors WHERE sid = new.sid AND rating < 3) THEN
        SIGNAL SQLSTATE '45000' SET message_text = 'Sailor rating less than 3';
    END IF;
END;//
DELIMITER ;

INSERT INTO reserves VALUES
(4, 2, "2023-10-01");

CREATE TABLE TempTable (
    last_deleted_date DATE PRIMARY KEY
);

DELIMITER //
CREATE TRIGGER DeleteExpiredReservations
BEFORE INSERT ON TempTable
FOR EACH ROW
BEGIN
    DELETE FROM reserves WHERE sdate < CURDATE();
END;//
DELIMITER ;

SELECT * FROM reserves;

INSERT INTO TempTable VALUES
(CURDATE());

SELECT * FROM reserves;
