SELECT UnitPrice*Quantity*(1-Discount)
FROM [Order Details]
WHERE OrderID = 10250

SELECT ' , ' + ISNULL(PHONE,'') + ',' + ISNULL(FAX,'')
FROM Customers

SELECT COUNT(*)
FROM Products
WHERE UnitPrice NOT BETWEEN 10 AND 20

SELECT MAX(UnitPrice)
FROM Products
WHERE UnitPrice < 20

SELECT MAX(UnitPrice), MIN(UnitPrice), AVG(UnitPrice)
FROM Products p
	WHERE QuantityPerUnit like '%bottle%'

SELECT *
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products)

SELECT QuantityPerUnit*(UnitPrice*(1-Discontinued))
FROM Products
WHERE ProductID = 10250

-- GROUP BY

SELECT OrderID, MAX(Quantity*UnitPrice*(1-Discount)) as 'MAX PRICE'
FROM [Order Details]
GROUP BY OrderID

SELECT OrderID, MAX(Quantity*UnitPrice*(1-Discount)) as 'MAX PRICE'
FROM [Order Details]
GROUP BY OrderID

SELECT OrderID, MIN(UnitPrice) as 'min', MAX(UnitPrice) as 'max'
FROM [Order Details]
GROUP BY OrderID

SELECT TOP 1 ShipVia, Count(OrderID) AS 'number'
FROM Orders
GROUP BY ShipVia
ORDER BY number DESC

SELECT TOP 1 ShipVia, Count(OrderID) AS 'total'
FROM Orders
WHERE YEAR(ShippedDate) = 1997
GROUP BY ShipVia
ORDER BY total DESC