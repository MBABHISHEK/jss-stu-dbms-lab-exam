-- 1. Create the 'order_processing' database and switch to it
CREATE DATABASE order_processing;
USE order_processing;

-- 2. Create the 'Customers' table
CREATE TABLE Customers (
    cust_id INT PRIMARY KEY,
    cname VARCHAR(35) NOT NULL,
    city VARCHAR(35) NOT NULL
);

-- 3. Create the 'Orders' table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    odate DATE NOT NULL,
    cust_id INT,
    order_amt INT NOT NULL,
    FOREIGN KEY (cust_id) REFERENCES Customers(cust_id) ON DELETE CASCADE
);

-- 4. Create the 'Items' table
CREATE TABLE Items (
    item_id INT PRIMARY KEY,
    unitprice INT NOT NULL
);

-- 5. Create the 'OrderItems' table
CREATE TABLE OrderItems (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    qty INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Items(item_id) ON DELETE CASCADE
);

-- 6. Create the 'Warehouses' table
CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    city VARCHAR(35) NOT NULL
);

-- 7. Create the 'Shipments' table
CREATE TABLE Shipments (
    order_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    ship_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id) ON DELETE CASCADE
);

-- 8. Insert sample data into the 'Customers' table
INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

-- 9. Insert sample data into the 'Orders' table
INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

-- 10. Insert sample data into the 'Items' table
INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

-- 11. Insert sample data into the 'Warehouses' table
INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

-- 12. Insert sample data into the 'OrderItems' table
INSERT INTO OrderItems VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

-- 13. Insert sample data into the 'Shipments' table
INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");

select * from Customers;
select * from Orders;
select * from items;
select * from orderitems;
select * from warehouses;
select * from shipments;

-- 1. List the Order# and Ship_date for all orders shipped from Warehouse# "W2"
SELECT order_id, ship_date
FROM Shipments
WHERE warehouse_id = 2;

-- 2. List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#:
SELECT o.order_id, s.warehouse_id
FROM Orders o
JOIN Shipments s ON o.order_id = s.order_id
JOIN Warehouses w ON s.warehouse_id = w.warehouse_id
JOIN Customers c ON o.cust_id = c.cust_id
WHERE c.cname = 'Kumar';

-- 3. Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and the last column is the average order amount for that customer. (Use aggregate functions):
SELECT c.cname, COUNT(o.order_id) AS NumberOfOrders, AVG(o.order_amt) AS Avg_Order_Amt
FROM Customers c
LEFT JOIN Orders o ON c.cust_id = o.cust_id
GROUP BY c.cname;

-- 4. Delete all orders for the customer named "Kumar":
select * from Orders;
DELETE FROM Orders
WHERE cust_id = (SELECT cust_id FROM Customers WHERE cname = 'Kumar');
select * from Orders;

-- 5. Find the item with the maximum unit price:
SELECT * FROM Items
WHERE unitprice = (SELECT MAX(unitprice) FROM Items);

-- 6. A trigger that updates order_amount based on quantity and unit price of order_item:
DELIMITER $$
CREATE TRIGGER UpdateOrderAmt
    AFTER INSERT ON OrderItems
    FOR EACH ROW
BEGIN
    UPDATE Orders SET order_amt = (new.qty * (SELECT DISTINCT unitprice FROM Items NATURAL JOIN OrderItems WHERE item_id = new.item_id)) WHERE Orders.order_id = new.order_id;
END;
$$
DELIMITER ;
-- to check the trigger
INSERT INTO OrderItems VALUES (001, 0002, 3);
SELECT * FROM Orders WHERE order_id = 001;

-- 7. Create a view to display orderID and shipment date of all orders shipped from warehouse 5:
CREATE VIEW OrdersShippedFromWarehouse5 AS
SELECT order_id, ship_date
FROM Shipments
WHERE warehouse_id = 5;

select * from OrdersShippedFromWarehouse5;
