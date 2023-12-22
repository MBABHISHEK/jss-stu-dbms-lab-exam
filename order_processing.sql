-- 1. List the Order# and Ship_date for all orders shipped from Warehouse# "W2"
SELECT order_id, ship_date
FROM Shipments
WHERE warehouse_id = (SELECT warehouse_id FROM Warehouses WHERE city = 'W2');

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
DELETE FROM Orders
WHERE cust_id = (SELECT cust_id FROM Customers WHERE cname = 'Kumar');

-- 5. Find the item with the maximum unit price:
SELECT * FROM Items
WHERE unitprice = (SELECT MAX(unitprice) FROM Items);

-- 6. A trigger that updates order_amount based on quantity and unit price of order_item:
DELIMITER $$
CREATE TRIGGER UpdateOrderAmount
BEFORE INSERT ON OrderItems
FOR EACH ROW
BEGIN
    SET NEW.order_amt = NEW.qty * (SELECT unitprice FROM Items WHERE item_id = NEW.item_id);
END;
$$
DELIMITER ;

-- 7. Create a view to display orderID and shipment date of all orders shipped from warehouse 5:
CREATE VIEW OrdersShippedFromWarehouse5 AS
SELECT order_id, ship_date
FROM Shipments
WHERE warehouse_id = 5;
