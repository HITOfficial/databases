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
SELECT e.FirstName, e.LastName, (
	SELECT s.CompanyName FROM Suppliers s
	WHERE s.SupplierID = (
		SELECT TOP 1 o.ShipVia
		FROM Orders o
		WHERE e.EmployeeID = o.EmployeeID
		GROUP BY o.ShipVia
		ORDER BY COUNT(o.ShipVia) DESC
	)
)
FROM Employees e
WHERE (
	SELECT COUNT(ee.EmployeeID)
	FROM Employees ee
	WHERE ee.ReportsTo = e.EmployeeID
	) = 0

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
SELECT Customers.CompanyName, (
	SELECT TOP 1 COUNT(c.CategoryID) FROM Categories c
	INNER JOIN Products p
	ON c.CategoryID = p.CategoryID
	INNER JOIN [Order Details] od
	ON p.ProductID = od.ProductID
	INNER JOIN Orders
	ON od.OrderID = Orders.OrderID AND Orders.CustomerID = Customers.CustomerID
	ORDER BY COUNT(c.CategoryID) DESC
) AS 'Category Count', (
	SELECT TOP 1 c.CategoryName FROM Categories c
	INNER JOIN Products p
	ON c.CategoryID = p.CategoryID
	INNER JOIN [Order Details] od
	ON p.ProductID = od.ProductID
	INNER JOIN Orders
	ON od.OrderID = Orders.OrderID AND Orders.CustomerID = Customers.CustomerID
	GROUP BY c.CategoryName
	ORDER BY COUNT(c.CategoryID) DESC
) AS 'Category Name'
FROM Customers

 --Podział na company, year month i suma freight
 SELECT c.CompanyName, YEAR(o.OrderDate), MONTH(o.OrderDate), o.Freight + SUM(od.Quantity*od.UnitPrice*(1-od.Discount))
 FROM Customers c
 LEFT JOIN Orders o
 ON c.CustomerID = o.CustomerID
 INNER JOIN [Order Details] od
 ON o.OrderID = od.OrderID
 GROUP BY c.CustomerID, c.CompanyName, YEAR(o.OrderDate), MONTH(o.OrderDate), o.Freight
 
 --Wypisać wszystkich czytelników, którzy nigdy nie wypożyczyli książki dane adresowe i podział czy ta osoba jest dzieckiem (joiny, in, exists)
 USE library
 SELECT m.firstname, m.lastname, 'adult' AS 'adult / juvenile', a.street + ' ' + a.city + ' ' + a.zip AS 'adress'
 FROM member m
 INNER JOIN adult a
 ON m.member_no = a.member_no
 WHERE m.member_no NOT IN (
	SELECT mm.member_no
	FROM member mm
	INNER JOIN loanhist lh
	ON mm.member_no = lh.member_no
 )
 UNION
 SELECT m.firstname, m.lastname, 'juvenile' AS 'adult / juvenile', a.street + ' ' + a.city + ' ' + a.zip AS 'adress'
 FROM member m
 INNER JOIN juvenile j
 ON m.member_no = j.member_no
 INNER JOIN adult a
 ON j.adult_member_no = a.member_no
 WHERE m.member_no NOT IN (
	SELECT mm.member_no
	FROM member mm
	INNER JOIN loanhist lh
	ON mm.member_no = lh.member_no
 )

 --Najczęściej wybierana kategoria w 1997 dla każdego klienta
 USE Northwind
 SELECT c.CompanyName, ca.CategoryName FROM Customers c
 INNER JOIN Orders o
 ON c.CustomerID = o.CustomerID
 INNER JOIN [Order Details] od
 ON o.OrderID = od.OrderID
 INNER JOIN Products p 
 ON od.ProductID = p.ProductID
 INNER JOIN Categories ca 
 ON p.CategoryID = ca.CategoryID
WHERE ca.CategoryName = (
	SELECT TOP 1 ccaa.CategoryName FROM Customers cc
	INNER JOIN Orders oo
	ON cc.CustomerID = oo.CustomerID
	INNER JOIN [Order Details] oodd
	ON oo.OrderID = oodd.OrderID
	INNER JOIN Products pp
	ON oodd.ProductID = pp.ProductID
	INNER JOIN Categories ccaa 
	ON pp.CategoryID = ccaa.CategoryID
	WHERE c.CustomerID = cc.CustomerID AND YEAR(o.OrderDate) = 1997
	GROUP BY cc.CustomerID, cc.CompanyName, ccaa.CategoryName
	ORDER BY COUNT(ccaa.CategoryName) DESC
)

 --Dla każdego czytelnika imię nazwisko, suma książek wypożyczony przez tą osobę i jej dzieci, który żyje w Arizona ma mieć więcej niż 2 dzieci lub kto żyje w Kalifornii ma mieć więcej niż 3 dzieci
 USE library
 SELECT m.firstname, m.lastname, m.member_no,
 (SELECT COUNT(loanhist.isbn) FROM loanhist WHERE loanhist.member_no = m.member_no) +
 (SELECT COUNT(loanhist.isbn) FROM loanhist WHERE loanhist.member_no IN 
	(SELECT juvenile.member_no FROM juvenile WHERE juvenile.adult_member_no = m.member_no)
) AS 'loaned books'
 FROM member m
 INNER JOIN adult a
 ON m.member_no = a.member_no
 INNER JOIN juvenile j
 ON a.member_no = j.adult_member_no
 WHERE a.state = 'AZ'
 GROUP BY m.member_no, m.firstname, m.lastname
 HAVING COUNT(j.member_no) > 2
 UNION
 SELECT m.firstname, m.lastname, m.member_no,
 (SELECT COUNT(loanhist.isbn) FROM loanhist WHERE loanhist.member_no = m.member_no) +
 (SELECT COUNT(loanhist.isbn) FROM loanhist WHERE loanhist.member_no IN 
	(SELECT juvenile.member_no FROM juvenile WHERE juvenile.adult_member_no = m.member_no)
)
 FROM member m
 INNER JOIN adult a
 ON m.member_no = a.member_no
 INNER JOIN juvenile j
 ON a.member_no = j.adult_member_no
 WHERE a.state = 'CA'
 GROUP BY m.member_no, m.firstname, m.lastname
 HAVING COUNT(j.member_no) > 3

-- Jaki był najpopularniejszy autor wśród dzieci w Arizonie w 2001
SELECT TOP 1 t.author FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no
INNER JOIN adult a 
ON j.adult_member_no = a.member_no
INNER JOIN loanhist lh
ON lh.member_no = m.member_no
RIGHT JOIN title t
ON lh.title_no = t.title_no
WHERE a.state = 'AZ' AND YEAR(lh.in_date) = 2001 
GROUP BY t.author
ORDER BY COUNT(t.title_no) DESC

-- Dla każdego dziecka wybierz jego imię nazwisko, adres, imię i nazwisko rodzica i ilość książek, które oboje przeczytali w 2001
SELECT m.firstname + ' ' + m.lastname AS 'Children',
(SELECT member.firstname + ' ' +  member.lastname FROM member  WHERE j.adult_member_no = member.member_no) AS 'Parent',
(SELECT adult.street + ' ' +  adult.city FROM adult  WHERE j.adult_member_no = adult.member_no) AS 'Adress',
(SELECT COUNT(loanhist.title_no) FROM loanhist WHERE loanhist.member_no = m.member_no AND YEAR(loanhist.due_date) = 2001) +
(SELECT COUNT(loanhist.title_no) FROM loanhist WHERE loanhist.member_no = j.adult_member_no AND YEAR(loanhist.due_date) = 2001)
FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no

-- Kategorie które w roku 1997 grudzień były obsłużone wyłącznie przez ‘United Package’
USE Northwind
SELECT c.CategoryName 
FROM Orders o
INNER JOIN Suppliers s
ON s.SupplierID = o.ShipVia
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 12
GROUP BY c.CategoryID, c.CategoryName
HAVING (
	SELECT COUNT(Orders.OrderID)
	FROM Orders
	INNER JOIN [Order Details]
	ON Orders.OrderID = [Order Details].OrderID
	INNER JOIN Products 
	ON [Order Details].ProductID = Products.ProductID
	INNER JOIN Categories
	ON Products.CategoryID = Categories.CategoryID 
	WHERE Orders.ShipVia NOT IN (
		SELECT Shippers.ShipperID
		FROM Shippers
		WHERE Shippers.CompanyName <> 'United Package'
	) AND YEAR(Orders.OrderDate) = 1997 AND MONTH(Orders.OrderDate) = 12 AND Categories.CategoryID = c.CategoryID
) = 0

-- Wybierz klientów, którzy kupili przedmioty wyłącznie z jednej kategorii w marcu 1997 i wypisz nazwę tej kategorii
SELECT c.CompanyName, ca.CategoryName
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories ca
ON p.CategoryID = ca.CategoryID
WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
GROUP BY c.CompanyName, ca.CategoryID, ca.CategoryName, c.CustomerID
HAVING COUNT(o.OrderID) > 0 AND (SELECT COUNT(Orders.OrderID)
	FROM Orders
	INNER JOIN [Order Details]
	ON Orders.OrderID = [Order Details].OrderID
	INNER JOIN Products 
	ON [Order Details].ProductID = Products.ProductID
	INNER JOIN Categories
	ON Products.CategoryID = Categories.CategoryID AND Categories.CategoryID <> ca.CategoryID AND c.CustomerID = Orders.CustomerID AND YEAR(Orders.OrderDate) = 1997 AND MONTH(Orders.OrderDate) = 3
) = 0
ORDER BY 1 DESC

-- Wybierz tytuły książek, gdzie ilość wypożyczeń książki jest większa od średniej ilości wypożyczeń książek tego samego autora.
USE library
SELECT t.title, (
	SELECT COUNT(loanhist.title_no) FROM loanhist
	WHERE t.title_no = loanhist.title_no
) AS 'AVG borrows',
(
	SELECT COUNT(loanhist.title_no)
	FROM loanhist
	WHERE loanhist.title_no IN (
		SELECT title_no FROM title
		WHERE title.author = t.author
	)
) / (
	SELECT COUNT(title.title_no)
	FROM title 
	WHERE title.author = t.author) AS 'AVG  author books borrows'
FROM title t
GROUP BY t.title, t.title_no, t.author
HAVING (
	SELECT COUNT(loanhist.title_no) FROM loanhist
	WHERE t.title_no = loanhist.title_no
) > (
	SELECT COUNT(loanhist.title_no)
	FROM loanhist
	WHERE loanhist.title_no IN (
		SELECT title_no FROM title
		WHERE title.author = t.author
	)
) / (
	SELECT COUNT(title.title_no)
	FROM title 
	WHERE title.author = t.author)

-- 3)Dla każdego dziecka zapisanego w bibliotece wyświetl jego imię i nazwisko, adres zamieszkania, imię i nazwisko rodzica (opiekuna) oraz liczbę wypożyczonych książek w grudniu 2001 roku przez dziecko i opiekuna. *) Uwzględnij tylko te dzieci, dla których liczba wypożyczonych książek jest większa od 1
SELECT m.firstname+ ' ' + m.lastname AS 'CHILDREN',
(SELECT member.firstname + ' ' + member.lastname FROM member WHERE j.adult_member_no = member.member_no) AS 'PARENT',
(SELECT adult.street + ' ' + adult.city FROM adult WHERE j.adult_member_no = adult.member_no) AS 'ADRESS', 
(SELECT COUNT(*) 
FROM loanhist
WHERE YEAR(loanhist.due_date) = 2001 AND MONTH(loanhist.due_date) = 12 AND loanhist.member_no = m.member_no
) + (
	SELECT COUNT(*) 
	FROM loanhist
	WHERE YEAR(loanhist.due_date) = 2001 AND MONTH(loanhist.due_date) = 12 AND loanhist.member_no = j.adult_member_no
) AS 'TOTAL BORROWED BOOKS' 
FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no
WHERE (
	SELECT COUNT(*) FROM loanhist
	WHERE YEAR(loanhist.due_date) = 2001 AND MONTH(loanhist.due_date) = 12 AND loanhist.member_no = m.member_no
) > 1

-- Dla każdego produktu podaj nazwę jego kategorii, nazwę produktu, cenę, średnią cenę wszystkich produktów danej kategorii, różnicę między ceną produktu a średnią ceną wszystkich produktów danej kategorii, dodatkowo dla każdego produktu podaj wartośc jego sprzedaży w marcu 1997
USE Northwind
SELECT p.ProductName,
(SELECT CategoryName FROM Categories WHERE Categories.CategoryID = p.CategoryID) AS 'Category',
p.UnitPrice, (SELECT AVG(Products.UnitPrice) FROM Products WHERE p.CategoryID = Products.CategoryID) AS 'Category AVG', 
ABS((SELECT AVG(Products.UnitPrice) FROM Products WHERE p.CategoryID = Products.CategoryID) - p.UnitPrice) AS 'ABS AVG DIFFERENCE',
ISNULL((SELECT SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) 
FROM [Order Details] od 
INNER JOIN Orders o
ON od.OrderID = o.OrderID
WHERE od.ProductID = p.ProductID AND YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 3
),0) AS 'SELLS SUM IN 03/2001'
FROM Products p

-- Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki. Interesuje nas imię, nazwisko, data urodzenia dziecka, adres zamieszkania, imię i nazwisko rodzica oraz liczba aktualnie wypożyczonych książek.
USE library
SELECT m.firstname+ ' ' + m.lastname AS 'CHILDREN',
j.birth_date,
(SELECT member.firstname + ' ' + member.lastname FROM member WHERE j.adult_member_no = member.member_no) AS 'PARENT',
(SELECT adult.street + ' ' + adult.city FROM adult WHERE j.adult_member_no = adult.member_no) AS 'ADRESS', (
SELECT COUNT(*) 
FROM loan l
WHERE l.member_no = m.member_no
)
FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no

-- Który klient złożył największą liczbę zamówień, a który zamówienia o najwyższej łącznej wartości (podaj nazwy i numer telefonu tych klientów)
USE Northwind
SELECT c.CompanyName, c.Phone FROM Customers c
WHERE c.CustomerID = (
	SELECT TOP 1 o.CustomerID FROM Orders o
	INNER JOIN [Order Details] od
	ON o.OrderID = od.OrderID
	GROUP BY o.CustomerID
	ORDER BY SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC
)
UNION
SELECT c.CompanyName, c.Phone FROM Customers c
WHERE c.CustomerID = (
	SELECT TOP 1 o.CustomerID FROM Orders o
	GROUP BY o.CustomerID
	ORDER BY COUNT(*) DESC
)

-- Dla każdego klienta podaj imię i nazwisko pracownika, który w 1997r obsłużył najwięcej jego zamówień, podaj także liczbę tych zamówień (jeśli jest kilku takich pracownikow to wystarczy podać imię nazwisko jednego nich). Zbiór wynikowy powinien zawierać nazwę klienta, imię i nazwisko pracownika oraz liczbę obsłużonych zamówień. (baza northwind)
SELECT c.CompanyName, (
	SELECT TOP 1 e.FirstName + ' ' + e.LastName 
	FROM Employees e
	INNER JOIN Orders o
	ON e.EmployeeID = o.EmployeeID
	WHERE o.CustomerID = c.CustomerID AND YEAR(o.OrderDate) = 1997
	GROUP BY e.FirstName, e.LastName ,e.EmployeeID
	ORDER BY COUNT(e.EmployeeID) DESC
) AS 'Employee Name', (
	SELECT COUNT(*) FROM Orders
	WHERE Orders.CustomerID = c.CustomerID AND Orders.EmployeeID = (
		SELECT TOP 1 e.EmployeeID
		FROM Employees e
		INNER JOIN Orders o
		ON e.EmployeeID = o.EmployeeID
		WHERE o.CustomerID = c.CustomerID AND YEAR(o.OrderDate) = 1997
		GROUP BY e.EmployeeID
		ORDER BY COUNT(e.EmployeeID) DESC
	)
) AS 'Orders Number'
FROM Customers c

-- Podaj liczbę zamówień oraz wartość zamówień (uwzględnij opłatę za przesyłkę) obsłużonych przez każdego pracownika w lutym 1997. Za datę obsłużenia zamówienia należy uznać datę jego złożenia (orderdate). Jeśli pracownik nie obsłużył w tym okresie żadnego zamówienia, to też powinien pojawić się na liście (liczba obsłużonych zamówień oraz ich wartość jest w takim przypadku równa 0). Zbiór wynikowy powinien zawierać: imię i nazwisko pracownika, liczbę obsłużonych zamówień, wartość obsłużonych zamówień. (baza northwind)
SELECT e.FirstName, e.LastName,
ISNULL(
	(SELECT SUM(Orders.Freight) 
	FROM Orders 
	WHERE YEAR(Orders.OrderDate) = 1997 AND MONTH(Orders.OrderDate) = 2 AND Orders.EmployeeID = e.EmployeeID) +
	(SELECT SUM(od.Quantity*od.UnitPrice*(1-od.Discount))
	FROM [Order Details] od 
	WHERE od.OrderID IN ( 
		SELECT Orders.OrderID 
		FROM Orders
		WHERE YEAR(Orders.OrderDate) = 1997 AND MONTH(Orders.OrderDate) = 2 AND Orders.EmployeeID = e.EmployeeID)
	)
,0) AS 'Orders Cost',
(SELECT COUNT(Orders.OrderID)
FROM Orders
WHERE YEAR(Orders.OrderDate) = 1997 AND MONTH(Orders.OrderDate) = 2 AND Orders.EmployeeID = e.EmployeeID) AS 'Orders Realized'
FROM Employees e

 -- Podaj listę dzieci będących członkami biblioteki, które w dniu '2001-12-14' zwróciły do biblioteki książkę o tytule 'Walking'. Zbiór wynikowy powinien zawierać imię i nazwisko oraz dane adresowe dziecka. (baza library) 
USE library
SELECT m.firstname, m.lastname, a.city, a.state, a.street
FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no
INNER JOIN adult a ON j.adult_member_no = a.member_no
WHERE m.member_no IN (
	SELECT member_no FROM loanhist
	WHERE m.member_no = loanhist.member_no 
	AND YEAR(loanhist.in_date) = 2001 AND MONTH(loanhist.in_date) = 12 AND DAY(loanhist.in_date) = 14 
	AND loanhist.title_no = (
		SELECT title.title_no
		FROM title
		WHERE title.title = 'Walking'
	)
)

-- Podaj produkty, dostawców i kategorie produktów które były zamówione 1997 roku pomiedzy 20 a 25 lutym
USE Northwind
SELECT DISTINCT c.CategoryName, p.ProductName, e.FirstName, e.LastName  
FROM Orders o
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderID
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories c
ON p.CategoryID = c.CategoryID
INNER JOIN Employees e
ON e.EmployeeID = o.EmployeeID
WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 2 AND DAY(o.OrderDate) BETWEEN 20 AND 25

-- produkt, ktory w 1996 roku ktorego totalna sprzedaz byla najmniejsza
USE Northwind
SELECT p.ProductName FROM Products p
WHERE p.ProductID IN (
	SELECT od.ProductID FROM [Order Details] od
	INNER JOIN Orders o 
	ON od.OrderID = o.OrderID
	WHERE YEAR(o.OrderDate) = 1996
	GROUP BY od.ProductID
	HAVING SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) = (
		SELECT TOP 1 SUM(oodd.UnitPrice*oodd.Quantity*(1-oodd.Discount)) FROM [Order Details] oodd
		WHERE oodd.OrderID IN (
			SELECT Orders.OrderID FROM Orders
			WHERE YEAR(Orders.OrderDate) = 1996
		)
		GROUP BY oodd.ProductID
		ORDER BY  1 
	)
)

--  wszyscy uzytkownicy biblioteki, ktorzy nigdy nie wyporzyczyli ksiazki
USE library
SELECT m.firstname, m.lastname,
(SELECT adult.street FROM adult
WHERE adult.member_no = j.adult_member_no
) AS 'Adress', 'juvenile' AS 'juvenile/ adult number of childrens'
FROM member m
INNER JOIN juvenile j
ON m.member_no = j.member_no
WHERE m.member_no NOT IN (
	SELECT loanhist.member_no FROM loanhist
	UNION
	SELECT loan.member_no FROM loan
)
UNION ALL
SELECT m.firstname, m.lastname, a.street+ ' ' + a.city, Str((
	SELECT COUNT(juvenile.adult_member_no) FROM juvenile WHERE juvenile.adult_member_no = a.member_no
))
FROM member m
INNER JOIN adult a
ON m.member_no = a.member_no
WHERE m.member_no NOT IN (
	SELECT loanhist.member_no FROM loanhist
	UNION
	SELECT loan.member_no FROM loan
)