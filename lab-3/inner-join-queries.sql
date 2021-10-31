--1.1
SELECT  o.OrderID, c.CompanyName, SUM(od.Quantity) as 'Number'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID  = od.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP  BY o.OrderID, c.CompanyName

--1.2
SELECT  o.OrderID, c.CompanyName, SUM(od.Quantity) as 'Number'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID  = od.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP  BY o.OrderID, c.CompanyName
HAVING SUM(od.Quantity) > 250

--1.3
SELECT  o.OrderID, c.CompanyName, SUM(od.Quantity) as 'Number'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID  = od.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP  BY o.OrderID, c.CompanyName
HAVING SUM(od.Quantity) > 250

--1.3
SELECT od.OrderID, c.CompanyName,  SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS 'TOTAL SUM'
FROM [Order Details] od
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY od.OrderID, c.CompanyName

--1.4
SELECT od.OrderID, c.CompanyName,  SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS 'TOTAL SUM'
FROM [Order Details] od
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY od.OrderID, c.CompanyName
HAVING SUM(od.Quantity) > 250

--1.5
SELECT od.OrderID, e.FirstName, e.LastName,c.CompanyName,  SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS 'TOTAL SUM'
FROM [Order Details] od
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
INNER JOIN Employees e
ON o.EmployeeID = e.EmployeeID
GROUP BY od.OrderID, e.FirstName,e.LastName, c.CompanyName
HAVING SUM(od.Quantity) > 250

--2.1
SELECT c.CategoryName, SUM(od.Quantity) AS 'Quantity'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY c.CategoryName

--2.2
SELECT c.CategoryName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Quantity'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY c.CategoryName

--2.3 a)
SELECT c.CategoryName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Total Sum'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY c.CategoryName
ORDER BY 'Total Sum' DESC

--2.3 b)
SELECT c.CategoryName, SUM(od.Quantity) AS 'Quantity'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY c.CategoryName
ORDER BY  'Quantity' DESC

--3.1
SELECT s.CompanyName, COUNT(o.ShippedDate) as 'Number'
FROM Shippers s
INNER JOIN Orders o
ON s.ShipperID = o.ShipVia
WHERE YEAR(o.ShippedDate) = 1997
GROUP BY s.CompanyName

--3.2
SELECT TOP 1 s.CompanyName, COUNT(o.ShippedDate) as 'Number'
FROM Shippers s
INNER JOIN Orders o
ON s.ShipperID = o.ShipVia
WHERE YEAR(o.ShippedDate) = 1997
GROUP BY s.CompanyName

--3.3
SELECT TOP 1 e.FirstName, E.LastName
FROM Employees e
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.FirstName, e.LastName
ORDER BY COUNT(o.EmployeeID) DESC

--4.1
SELECT e.FirstName, e.LastName, SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS 'Total sum serviced'
FROM Employees e
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName

--4.2
SELECT TOP 1 e.FirstName, e.LastName
FROM Employees e
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY e.FirstName, e.LastName
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC

--4.3 a)
SELECT e.FirstName, e.LastName, SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS 'Total sum serviced'
FROM Employees e
LEFT JOIN Employees AS ee
ON e.EmployeeID = ee.ReportsTo
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName
HAVING COUNT(ee.EmployeeID) > 0

--4.3 b)
SELECT e.FirstName, e.LastName, SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS 'Total sum serviced'
FROM Employees e
LEFT JOIN Employees AS ee
ON e.EmployeeID = ee.ReportsTo
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName
HAVING COUNT(ee.EmployeeID) = 0