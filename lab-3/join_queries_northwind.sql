--1. Dla ka?dego zam�wienia podaj ??czn? liczb? zam�wionych jednostek towaru oraz nazw? klienta.
SELECT od.OrderID, c.CompanyName, SUM(od.Quantity) AS 'Total quantity'
FROM [Order Details] od
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY  od.OrderID, c.CompanyName

--2. Zmodyfikuj poprzedni przyk?ad, aby pokaza? tylko takie zam�wienia, dla kt�rych ??czna liczb? zam�wionych jednostek jest wi?ksza ni? 250
SELECT od.OrderID, c.CompanyName, SUM(od.Quantity) AS 'Total quantity'
FROM [Order Details] od
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY  od.OrderID, c.CompanyName
HAVING SUM(od.Quantity) > 250

--3. Dla ka?dego zam�wienia podaj ??czn? warto?? tego zam�wienia oraz nazw? klienta.
SELECT o.OrderID, c.CompanyName, SUM(od.Quantity*od.UnitPrice*(1-Discount)) AS 'total sum'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CompanyName

--4. Zmodyfikuj poprzedni przyk?ad, aby pokaza? tylko takie zam�wienia, dla kt�rych ??czna liczba jednostek jest wi?ksza ni? 250.
SELECT o.OrderID, c.CompanyName, SUM(od.Quantity*od.UnitPrice*(1-Discount)) AS 'total sum'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CompanyName
HAVING SUM(od.Quantity) > 250

--5. Zmodyfikuj poprzedni przyk?ad tak ?eby doda? jeszcze imi? i nazwisko pracownika obs?uguj?cego zam�wienie
SELECT o.OrderID, c.CompanyName, e.FirstName, e.LastName ,SUM(od.Quantity*od.UnitPrice*(1-Discount)) AS 'total sum'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
INNER JOIN Employees e
ON o.EmployeeID = e.EmployeeID
GROUP BY o.OrderID, c.CompanyName, e.FirstName, e.LastName
HAVING SUM(od.Quantity) > 250

--?wiczenie 2
--1. Dla ka?dej kategorii produktu (nazwa), podaj ??czn? liczb? zam�wionych przez klient�w jednostek towar�w z tej kategorii.
SELECT c.CategoryName, Customers.CompanyName, COUNT(od.Quantity) AS 'Quantity'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID= od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers
ON o.CustomerID = Customers.CustomerID
GROUP BY c.CategoryName, CompanyName

--2. Dla ka?dej kategorii produktu (nazwa), podaj ??czn? warto?? zam�wionych przez klient�w jednostek towar�w z tej kategorii.
SELECT c.CategoryName, Customers.CompanyName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Sum'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID= od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers
ON o.CustomerID = Customers.CustomerID
GROUP BY c.CategoryName, CompanyName

--3. Posortuj wyniki w zapytaniu z poprzedniego punktu wg:
--a) ??cznej warto?ci zam�wie?
SELECT c.CategoryName, Customers.CompanyName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Sum'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID= od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers
ON o.CustomerID = Customers.CustomerID
GROUP BY c.CategoryName, CompanyName
ORDER BY SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC

--b) ??cznej liczby zam�wionych przez klient�w jednostek towar�w.
SELECT c.CategoryName, Customers.CompanyName, SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Sum'
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID= od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
INNER JOIN Customers
ON o.CustomerID = Customers.CustomerID
GROUP BY c.CategoryName, CompanyName
ORDER BY COUNT(od.Quantity) DESC

--4. Dla ka?dego zam�wienia podaj jego warto?? uwzgl?dniaj?c op?at? za przesy?k?
SELECT o.OrderID, SUM(od.UnitPrice*od.Quantity*(1-od.Discount)+ o.Freight) AS 'Total cost with freight'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID

--?wiczenie 3
--1. Dla ka?dego przewo?nika (nazwa) podaj liczb? zam�wie? kt�re przewie?li w 1997r
SELECT s.CompanyName, COUNT(o.OrderID) AS 'Orders Number'
FROM Shippers s
LEFT JOIN Orders o
ON s.ShipperID = o.ShipVia
WHERE YEAR(o.ShippedDate) = 1997
GROUP BY s.ShipperID, s.CompanyName

--2. Kt�ry z przewo?nik�w by? najaktywniejszy (przewi�z? najwi?ksz? liczb? zam�wie?) w 1997r, podaj nazw? tego przewo?nika
SELECT TOP 1 s.CompanyName, COUNT(o.OrderID) AS 'Orders Number'
FROM Shippers s
LEFT JOIN Orders o
ON s.ShipperID = o.ShipVia
WHERE YEAR(o.ShippedDate) = 1997
GROUP BY s.ShipperID, s.CompanyName
ORDER BY COUNT(o.OrderID) DESC

--3. Dla ka?dego pracownika (imi? i nazwisko) podaj ??czn? warto?? zam�wie? obs?u?onych przez tego pracownika
SELECT e.FirstName + ' ' + e.LastName AS 'Name', SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS 'Total orders cost'
FROM Employees e
LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName + ' ' + e.LastName

--4. Kt�ry z pracownik�w obs?u?y? najwi?ksz? liczb? zam�wie? w 1997r, podaj imi? i nazwisko takiego pracownika
SELECT TOP 1 e.FirstName + ' ' + e.LastName AS 'Name'
FROM Employees e
LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
WHERE YEAR(OrderDate) = 1997
GROUP BY e.FirstName + ' ' + e.LastName
ORDER BY COUNT(o.OrderID) DESC

--5. Kt�ry z pracownik�w obs?u?y? najaktywniejszy (obs?u?y? zam�wienia o najwi?kszej warto?ci) w 1997r, podaj imi? i nazwisko takiego pracownika
SELECT TOP 1 e.FirstName + ' ' + e.LastName AS 'Name'
FROM Employees e
LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 1997
GROUP BY e.FirstName + ' ' + e.LastName
ORDER BY SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) DESC

--?wiczenie 4
--1. Dla ka?dego pracownika (imi? i nazwisko) podaj ??czn? warto?? zam�wie? obs?u?onych przez tego pracownika � Ogranicz wynik tylko do pracownik�w
--a) kt�rzy maj? podw?adnych
SELECT e.FirstName + ' ' + e.LastName AS 'Name', SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS 'Total orders cost'
FROM Employees e
LEFT JOIN Employees ee
ON e.EmployeeID = ee.ReportsTo
LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName + ' ' + e.LastName
HAVING COUNT(ee.EmployeeID) > 0

--b) kt�rzy nie maj? podw?adnych
SELECT e.FirstName + ' ' + e.LastName AS 'Name', SUM(od.UnitPrice * od.Quantity * (1-od.Discount)) AS 'Total orders cost'
FROM Employees e
LEFT JOIN Employees ee
ON e.EmployeeID = ee.ReportsTo
LEFT JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName + ' ' + e.LastName
HAVING COUNT(ee.EmployeeID) = 0
