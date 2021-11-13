-- Wybierz nazwy i ceny produktów (baza northwind) o cenie jednostkowej pomiedzy 20.00 a 30.00, dla kazdego produktu podaj dane adresowe dostawcy
SELECT p.ProductName, p.UnitPrice, s.Address 
FROM Products p
INNER JOIN Suppliers s
ON p.SupplierID = s.SupplierID
WHERE p.UnitPrice BETWEEN 20 AND 30

-- Wybierz nazwy produktów oraz inf. o stanie magazynu dla produktów dostarczanych przez firme ‘Tokyo Traders’
SELECT p.ProductName, p.UnitsInStock
FROM Products p
INNER JOIN Suppliers s
ON p.SupplierID = s.SupplierID
WHERE s.CompanyName = 'Tokyo Traders'

-- Czy sa jacys klienci którzy nie zlozyli zadnego zamówienia w 1997 roku, jesli tak to pokaz ich dane adresowe
SELECT c.CustomerID, c.Address
FROM Customers c
LEFT JOIN Orders o
ON c.CustomerID = o.CustomerID AND YEAR(o.OrderDate) = 1997
WHERE o.OrderID IS NULL

-- Wybierz nazwy i numery telefonów dostawców, dostarczajacych produkty,  których aktualnie nie ma w magazynie
SELECT s.CompanyName, s.Phone 
FROM Products p
INNER JOIN Suppliers s
ON p.SupplierID = s.SupplierID
WHERE p.UnitsInStock = 0

-- 1. Wybierz nazwy i ceny produktów o cenie jednostkowej pomiędzy 20.00 a 30.00, dla każdego produktu podaj dane adresowe dostawcy, interesują nas tylko produkty z kategorii ‘Meat/Poultry’
SELECT p.ProductName, p.UnitPrice,s.Address
FROM Products p
INNER JOIN Categories c
ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s
ON p.SupplierID = s.SupplierID
WHERE p.UnitPrice BETWEEN 20 AND 30 AND c.CategoryName = 'Meat/Poultry'

-- 2. Wybierz nazwy i ceny produktów z kategorii ‘Confections’ dla każdego produktu podaj nazwę dostawcy.
SELECT p.ProductName, p.UnitPrice, s.CompanyName
FROM Products p
INNER JOIN Categories c 
ON p.CategoryID = c.CategoryID
INNER JOIN Suppliers s
ON p.SupplierID = p.SupplierID
WHERE c.CategoryName = 'Confections'

-- 3. Wybierz nazwy i numery telefonów klientów , którym w 1997 roku przesyłki ostarczała firma ‘United Package’
SELECT c.CompanyName, c.Phone
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
INNER JOIN Shippers s
ON o.ShipVia = s.ShipperID
WHERE s.CompanyName = 'United Package'

-- 4. Wybierz nazwy i numery telefonów klientów, którzy kupowali produkty z kategorii‘Confections
SELECT c.CompanyName, c.Phone
FROM Customers c
INNER JOIN Orders o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od
ON o.OrderID = od.OrderId
INNER JOIN Products p
ON od.ProductID = p.ProductID
INNER JOIN Categories
ON p.CategoryID = Categories.CategoryID
WHERE Categories.CategoryName = 'Confections'

-- 1. Napisz polecenie, które wyświetla pracowników oraz ich podwładnych


-- 2. Napisz polecenie, które wyświetla pracowników, którzy nie mają podwładnych

