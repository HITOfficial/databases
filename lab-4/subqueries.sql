-- Two solutions: first using subqueries, second using joins and group by

--1. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki dostarczała firma United Package.
SELECT c.CompanyName, c.Phone
FROM Customers c
WHERE c.CustomerID IN (
	SELECT CustomerId
	FROM Orders o
	WHERE o.ShipVia IN (
		SELECT s.ShipperID
		FROM Shippers s
		WHERE s.CompanyName = 'United Package'
	) AND YEAR(o.ShippedDate) = 1997
)

SELECT DISTINCT c.CompanyName, c.Phone 
FROM Orders o
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID
INNER JOIN Shippers s
ON o.ShipVia = s.ShipperID
WHERE YEAR(o.ShippedDate) = 1997 AND s.CompanyName = 'United Package'

--2. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii Confections.
SELECT c.CompanyName, c.Phone
FROM Customers c
WHERE c.CustomerID IN (
	SELECT CustomerId
	FROM Orders o
	WHERE o.OrderID IN (
		SELECT od.OrderID
		FROM [Order Details] od
		WHERE od.ProductID IN (
			SELECT p.ProductID
			FROM Products p
			WHERE p.CategoryID IN (
				SELECT ca.CategoryID
				FROM Categories ca
				WHERE ca.CategoryName = 'Confections'
			)
		)
	)
)

SELECT DISTINCT c.CompanyName, c.Phone
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories ca
ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = 'Confections'

--3. Wybierz nazwy i numery telefonów klientów, którzy nie kupowali produktów z kategorii Confections.
SELECT c.CompanyName, c.Phone
FROM Customers c
WHERE c.CustomerID NOT IN (
	SELECT CustomerId
	FROM Orders o
	WHERE o.OrderID IN (
		SELECT od.OrderID
		FROM [Order Details] od
		WHERE od.ProductID IN (
			SELECT p.ProductID
			FROM Products p
			WHERE p.CategoryID IN (
				SELECT ca.CategoryID
				FROM Categories ca
				WHERE ca.CategoryName = 'Confections'
			)
		)
	)
)

--Cw 2
--1. Dla każdego produktu podaj maksymalną liczbę zamówionych jednostek
SELECT p.ProductID, (SELECT MAX(od.Quantity) FROM [Order Details] od WHERE p.ProductID = od.ProductID) AS 'Max quantity'
FROM Products p

SELECT p.ProductID, MAX(od.Quantity) AS 'Max quantity'
FROM Products p 
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
GROUP BY p.ProductID

--2. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu
SELECT ProductName
FROM Products
WHERE UnitPrice < (
	SELECT AVG(UnitPrice)
	FROM Products
)

SELECT p.ProductName
FROM Products p
CROSS JOIN Products pp
GROUP BY p.ProductID, p.ProductName, p.UnitPrice
HAVING p.UnitPrice < AVG(pp.UnitPrice)

--3. Podaj wszystkie produkty których cena jest mniejsza niż średnia cena produktu danej kategorii
SELECT p_outer.ProductName
FROM Products p_outer
WHERE p_outer.UnitPrice < (
	SELECT AVG(UnitPrice)
	FROM Products p_inner
	WHERE p_outer.CategoryID = p_inner.CategoryID
)

SELECT p.ProductName
FROM Products p
INNER JOIN Products pp
ON p.CategoryID = pp.CategoryID
GROUP BY p.ProductID, p.ProductName, p.UnitPrice
HAVING p.UnitPrice < AVG(pp.UnitPrice)

--Cw 3
--1. Dla każdego produktu podaj jego nazwę, cenę, średnią cenę wszystkich produktów oraz różnicę między ceną produktu a średnią ceną wszystkich produktów
SELECT p_outer.ProductName,
p_outer.UnitPrice, (SELECT AVG(UnitPrice) FROM Products),
ABS(p_outer.UnitPrice - (SELECT AVG(UnitPrice) FROM Products))
FROM Products p_outer

SELECT p.ProductName, p.UnitPrice, AVG(pp.UnitPrice) AS 'All products avg', ABS(p.UnitPrice- AVG(pp.UnitPrice)) AS 'Difference' 
FROM Products p
CROSS JOIN Products pp
GROUP BY p.ProductName, p.UnitPrice

--2. Dla każdego produktu podaj jego nazwę kategorii, nazwę produktu, cenę, średnią cenę wszystkich produktów danej kategorii oraz różnicę między ceną produktu a średnią ceną wszystkich produktów danej kategorii
SELECT (SELECT c.CategoryName 
FROM Categories c 
WHERE p_outer.CategoryID = c.CategoryID) AS 'Category Name',
p_outer.ProductName,
p_outer.UnitPrice,
(SELECT AVG(UnitPrice)
FROM Products p_inner 
WHERE p_outer.CategoryID = p_inner.CategoryID) AS 'Category AVG',
ABS( p_outer.UnitPrice - (SELECT AVG(UnitPrice) FROM Products p_inner WHERE p_outer.CategoryID = p_inner.CategoryID)) AS 'Diffenere'
FROM Products p_outer

SELECT p.ProductName, p.UnitPrice, AVG(pp.UnitPrice) AS 'Category avg', ABS(p.UnitPrice- AVG(pp.UnitPrice)) AS 'Difference' 
FROM Products p
INNER JOIN Products pp
ON p.CategoryID = pp.CategoryID
GROUP BY p.ProductName, p.UnitPrice

--Cw 4
--1. Podaj łączną wartość zamówienia o numerze 10250 (uwzględnij cenę za przesyłkę)
SELECT o.Freight + (SELECT SUM(od_inner.UnitPrice*od_inner.Quantity*(1-od_inner.Discount)) FROM [Order Details] od_inner WHERE od_inner.OrderID = o.OrderID) AS 'Order SUM'
FROM Orders o
WHERE o.OrderID = 10250

SELECT o.Freight + SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS 'Order price'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
WHERE o.OrderID = 10250
GROUP BY o.OrderID, o.Freight

--2. Podaj łączną wartość zamówień każdego zamówienia (uwzględnij cenę za przesyłkę)
SELECT o.OrderID, 
o.Freight + (SELECT SUM(od_inner.UnitPrice*od_inner.Quantity*(1-od_inner.Discount))
FROM [Order Details] od_inner
WHERE od_inner.OrderID = o.OrderID) AS 'Order SUM'
FROM Orders o

SELECT o.OrderID, o.Freight + SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS 'Order price'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.Freight

--3. Czy są jacyś klienci którzy nie złożyli żadnego zamówienia w 1997 roku, jeśli tak to pokaż ich dane adresowe
SELECT c.CustomerID, c.Address
FROM Customers c
WHERE c.CustomerID NOT IN (
	SELECT o.CustomerID
	FROM Orders o
	WHERE YEAR(o.OrderDate) = 1997
)

SELECT c.CustomerID, c.Address
FROM Customers c
LEFT JOIN Orders o
ON c.CustomerID = o.CustomerID AND YEAR(o.OrderDate) = 1997
WHERE o.OrderID IS NULL

--4. Podaj produkty kupowane przez więcej niż jednego klienta
SELECT p.ProductName
FROM Products p
WHERE (
	SELECT COUNT(CustomerID)
	FROM Orders o
	WHERE o.OrderID IN (
		SELECT od.OrderID 
		FROM [Order Details] od
		WHERE od.ProductID = p.ProductID
	)
) > 1

SELECT p.ProductName
FROM Products p
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
GROUP BY p.ProductName
HAVING COUNT(o.CustomerID) > 1

--Cw 5
--1. Dla każdego pracownika (imię i nazwisko) podaj łączną wartość zamówień obsłużonych przez tego pracownika (przy obliczaniu wartości zamówień uwzględnij cenę za przesyłkę
SELECT e.FirstName, e.LastName,
(SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od WHERE
	od.OrderID IN (SELECT o.OrderID FROM Orders o WHERE o.EmployeeID= e.EmployeeID)) 
+ (SELECT SUM(o.Freight) FROM Orders o WHERE o.EmployeeID = e.EmployeeID) AS 'Total Orders Cost'
FROM Employees e

SELECT e.FirstName, e.LastName, SUM(o.Freight) + SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Total Orders Cost'
FROM Employees e
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName

--2. Który z pracowników obsłużył najaktywniejszy (obsłużył zamówienia o największej wartości) w 1997r, podaj imię i nazwisko takiego pracownika
SELECT TOP 1 e.FirstName, e.LastName
FROM Employees e
ORDER BY (SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od WHERE
	od.OrderID IN (SELECT o.OrderID FROM Orders o WHERE o.EmployeeID= e.EmployeeID AND YEAR(o.OrderDate) = 1997)) 
+ (SELECT SUM(o.Freight) FROM Orders o WHERE o.EmployeeID = e.EmployeeID AND YEAR(o.OrderDate) = 1997) DESC

SELECT TOP 1 e.FirstName, e.LastName
FROM Employees e
INNER JOIN Orders o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY e.FirstName, e.LastName
ORDER BY  SUM(o.Freight) + SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC

--3. Ogranicz wynik z pkt 1 tylko do pracowników
--a) którzy mają podwładnych
SELECT e.FirstName, e.LastName,
(SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od WHERE
	od.OrderID IN (SELECT o.OrderID FROM Orders o WHERE o.EmployeeID= e.EmployeeID)) 
+ (SELECT SUM(o.Freight) FROM Orders o WHERE o.EmployeeID = e.EmployeeID) AS 'Total Orders Cost'
FROM Employees e
WHERE (SELECT COUNT(ee.ReportsTo) FROM Employees ee WHERE e.EmployeeID = ee.ReportsTo) > 0
ORDER BY 3 DESC

--b) którzy nie mają podwładnych
SELECT e.FirstName, e.LastName,
(SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od WHERE
	od.OrderID IN (SELECT o.OrderID FROM Orders o WHERE o.EmployeeID= e.EmployeeID)) 
+ (SELECT SUM(o.Freight) FROM Orders o WHERE o.EmployeeID = e.EmployeeID) AS 'Total Orders Cost'
FROM Employees e
WHERE (SELECT COUNT(ee.ReportsTo) FROM Employees ee WHERE e.EmployeeID = ee.ReportsTo) = 0
ORDER BY 3 DESC

--4. Zmodyfikuj rozwiązania z pkt 3 tak aby dla pracowników pokazać jeszcze datę ostatnio obsłużonego zamówienia
--a)
SELECT e.FirstName, e.LastName,
(SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od WHERE
	od.OrderID IN (SELECT o.OrderID FROM Orders o WHERE o.EmployeeID= e.EmployeeID)) 
+ (SELECT SUM(o.Freight) FROM Orders o WHERE o.EmployeeID = e.EmployeeID) AS 'Total Orders Cost',
(SELECT MAX(o.OrderDate) FROM Orders o WHERE e.EmployeeID = o.EmployeeID) AS 'Last executed order'
FROM Employees e
WHERE (
	SELECT COUNT(ee.ReportsTo) FROM Employees ee WHERE e.EmployeeID = ee.ReportsTo
	) > 0
ORDER BY 3 DESC

--b)
SELECT e.FirstName, e.LastName,
(SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) FROM [Order Details] od WHERE
	od.OrderID IN (SELECT o.OrderID FROM Orders o WHERE o.EmployeeID= e.EmployeeID)) 
+ (SELECT SUM(o.Freight) FROM Orders o WHERE o.EmployeeID = e.EmployeeID) AS 'Total Orders Cost',
(SELECT MAX(o.OrderDate) FROM Orders o WHERE e.EmployeeID = o.EmployeeID) AS 'Last executed order'
FROM Employees e
WHERE (
	SELECT COUNT(ee.ReportsTo) FROM Employees ee WHERE e.EmployeeID = ee.ReportsTo
	) = 0
ORDER BY 3 DESC