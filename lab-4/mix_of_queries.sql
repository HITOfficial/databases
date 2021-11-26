
-- Nazwy klientów którzy złożyli zamówienia w dniu 23/05/1997 oraz jeśli obsługiwali te zamówienia pracownicy którzy mają podwłanych to ich wypisz (imie i nazwisko)
USE Northwind
SELECT c.CompanyName,
(SELECT e.EmployeeID
FROM Employees e
INNER JOIN Employees ee ON
e.EmployeeID = ee.ReportsTo
WHERE e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID
HAVING COUNT(ee.EmployeeID) > 0
)
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate = '1997-05-23'

-- Dla każdego dostawcy wyswietl sumaryczna wartosc wykonanych zamowien w okresie 1996-1998. Podziel ta informacje na lata i miesiace. Wyswietl tylko tych, ktorychl sumaryczna wartosc wykonanych zamowien jest wieksza od sredniej wartosci wykonanych zamówień w danym okresie.
USE Northwind
SELECT s.SupplierID, YEAR(o.OrderDate) AS 'YEAR', MONTH(o.OrderDate) AS 'MONTH', SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS 'Orders value'
FROM Suppliers s
LEFT JOIN Products p
ON s.SupplierID = p.SupplierID
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
WHERE YEAR(o.ShippedDate) BETWEEN 1996 AND 1998
GROUP BY s.SupplierID, YEAR(o.OrderDate), MONTH(o.OrderDate)
HAVING SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) > (
	SELECT AVG(oodd.Quantity*oodd.UnitPrice*(1-oodd.Discount))
	FROM [Order Details] oodd
	INNER JOIN Orders oo 
	ON oodd.OrderID = oo.OrderID
	WHERE MONTH(oo.OrderDate) = MONTH(o.OrderDate) AND YEAR(oo.OrderDate) = YEAR(o.OrderDate)
	)

-- Wybierz dzieci wraz z adresem, które nie wypożyczyły książek w pazdzierniku 2002 autorstwa ‘Jane Austen’
USE library
SELECT DISTINCT m.member_no, a.state + ' ' + a.street
FROM member m
INNER JOIN juvenile j
ON m.member_no = j.adult_member_no
INNER JOIN adult a 
ON a.member_no = j.adult_member_no
WHERE m.member_no NOT IN (
	SELECT l.member_no
	FROM loan l
	INNER JOIN title t ON l.title_no = t.title_no AND t.author NOT LIKE 'Jane Austen'
	WHERE YEAR(l.due_date) = 2002 AND MONTH(l.due_date) = 10
	)

-- Wybierz kategorię, która w danym roku 1997 najwięcej zarobiła, podział na miesiące
USE Northwind
SELECT DISTINCT MONTH(o.OrderDate) AS 'MONTH', c.CategoryName
FROM Categories c
INNER JOIN Products p
ON c.CategoryID = p.CategoryID
INNER JOIN [Order Details] od
ON p.ProductID = od.ProductID
INNER JOIN Orders o
ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND c.CategoryID = (
	SELECT TOP 1 c.CategoryID
	FROM Categories c
	INNER JOIN Products p
	ON c.CategoryID = p.CategoryID
	INNER JOIN [Order Details] od
	ON p.ProductID = od.ProductID
	GROUP BY c.CategoryID
	ORDER BY MAX(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC
)

-- Dane pracownika i najczęstszy dostawca pracowników bez podwładnych
USE Northwind
SELECT e.FirstName, e.LastName, s.CompanyName FROM Employees e
RIGHT JOIN Employees ee
ON e.EmployeeID = ee.ReportsTo
CROSS JOIN Suppliers s
WHERE s.SupplierID = (
	SELECT TOP 1 ss.SupplierID FROM Suppliers ss
	INNER JOIN Products p 
	ON ss.SupplierID = p.SupplierID
	INNER JOIN [Order Details] od
	ON p.ProductID = od.ProductID
	GROUP BY ss.SupplierID
	ORDER BY COUNT(od.OrderID) DESC
)
GROUP BY e.EmployeeID, e.FirstName, e.LastName, s.CompanyName 
HAVING COUNT(ee.EmployeeID) = 0

-- Wypisz wszystkich czlonków biblioteki z adresami i info czy jest dzieckiem czy nie i ilosc wypozyczen w poszczególnych latach i miesiacach.
USE library
SELECT m.firstname + ' ' + m.lastname AS 'NAME', a.street + ' ' + a.city AS 'ADRESS', YEAR(l.due_date) AS 'YEAR', MONTH(l.due_date) AS 'MONTH', 'ADULT' AS 'ADULT/JUVENILE', COUNT(isbn) 'LOAN' FROM member m
INNER JOIN adult a
ON m.member_no = a.member_no
INNER JOIN loan l
ON m.member_no = l.member_no
GROUP BY m.member_no, m.firstname + ' ' + m.lastname, a.street + ' ' + a.city,  YEAR(l.due_date), MONTH(l.due_date)
UNION
SELECT m.firstname + ' ' + m.lastname AS 'NAME', a.street + ' ' + a.city AS 'ADRESS', YEAR(l.due_date) AS 'YEAR', MONTH(l.due_date) AS 'MONTH', 'ADULT' AS 'ADULT/JUVENILE', COUNT(isbn) 'LOAN' FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no
INNER JOIN adult a
ON j.adult_member_no = a.member_no
INNER JOIN loan l
ON m.member_no = l.member_no
GROUP BY m.member_no, m.firstname + ' ' + m.lastname, a.street + ' ' + a.city,  YEAR(l.due_date), MONTH(l.due_date)

-- Zamówienia z Freight wiekszym niz AVG danego roku.
USE Northwind
SELECT o.OrderID, o.Freight + SUM(od.Quantity*od.UnitPrice*(1-od.Discount))  AS 'ORDER WITH FREIGHT'
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.Freight, o.OrderDate
HAVING o.Freight + SUM(od.Quantity*od.UnitPrice*(1-od.Discount))  > (
SELECT AVG(oodd.Quantity*oodd.UnitPrice*(1-oodd.Discount))
FROM [Order Details] oodd
INNER JOIN Orders oo
ON oodd.OrderID = oo.OrderID
WHERE YEAR(oo.OrderDate) = YEAR(oo.OrderDate)
)

-- Klienci, którzy nie zamówili nigdy nic z kategorii 'Seafood' w trzech wersjach.
SELECT DISTINCT c.CompanyName FROM Customers c
LEFT JOIN Orders o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories ca
ON p.ProductID = ca.CategoryID AND ca.CategoryName = 'Seafood'
WHERE c.CustomerID IS NULL

SELECT DISTINCT c.CompanyName FROM Customers c
WHERE c.CustomerID NOT IN (
	SELECT o.CustomerID
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
				WHERE ca.CategoryName = 'Seafood'
			)
		)
	)
)

-- Dla kazdego klienta najczesciej zamawiana kategorie w dwóch wersjach.
SELECT TOP 13 c.CompanyName, ca.CategoryName, MAX(ca.CategoryID) AS 'MOST POPULAR CATEGORY' FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories ca
ON p.ProductID = ca.CategoryID
GROUP BY c.CustomerID, c.CompanyName, ca.CategoryName
ORDER BY 3 DESC

 --Podział na company, year month i suma freight
 SELECT c.CompanyName, YEAR(o.OrderDate), MONTH(o.OrderDate), o.Freight + SUM(od.Quantity*od.UnitPrice*(1-od.Discount))
 FROM Customers c
 LEFT JOIN Orders o
 ON c.CustomerID = o.CustomerID
 INNER JOIN [Order Details] od
 ON o.OrderID = od.OrderID
 GROUP BY c.CustomerID, c.CompanyName, YEAR(o.OrderDate), MONTH(o.OrderDate), o.Freight
