--1.1
SELECT OrderID, UnitPrice * Quantity * (1-Discount) as Price
FROM [Order Details]
ORDER BY Price DESC

--1.2
SELECT TOP 10 OrderID, UnitPrice * Quantity * (1-Discount) as Price
FROM [Order Details]
ORDER BY Price DESC

--1.3
SELECT TOP 10 WITH TIES OrderID, UnitPrice * Quantity * (1-Discount) as Price
FROM [Order Details]
ORDER BY Price DESC

--2.1
SELECT ProductID, SUM(Quantity) as 'Total Quantity'
FROM [Order Details]
WHERE ProductID < 3
GROUP BY ProductID

--2.2
SELECT ProductID, SUM(Quantity) AS 'Total Quantity'
FROM [Order Details]
GROUP BY ProductID

--2.3
SELECT OrderID, SUM(Quantity*UnitPrice*(1-Discount)) AS 'Total Value'
FROM [Order Details]
GROUP BY OrderID
HAVING SUM(Quantity) > 250

--3.1
SELECT ProductID, OrderID, SUM(Quantity) AS 'Total Quantity'
FROM [Order Details]
GROUP BY ProductID, OrderID
WITH ROLLUP

--3.2

SELECT ProductID, OrderID, SUM(Quantity) AS 'Total Quantity'
FROM [Order Details]
WHERE ProductID = 50
GROUP BY ProductID, OrderID
WITH ROLLUP

--3.3

-- total sum, of Quantity, rollup added two extra rows

--3.4

SELECT ProductID, GROUPING(ProductID) AS 'Product', OrderID, GROUPING(OrderID) AS 'Order', SUM(Quantity) AS 'Total Quantity'
FROM [Order Details]
GROUP BY ProductID, OrderID
WITH CUBE

--3.5

-- rows with Order as 1 -> Total Quantity of each Product
-- rows with Product as 1 -> Total Quantity of elements in each Order
-- double NULL -> total summary of Products Quantity