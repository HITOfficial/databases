--1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki. Interesuje nas imię, nazwisko i data urodzenia dziecka.
SELECT m.firstname, m.lastname, j.birth_date
FROM member m
INNER JOIN adult a
ON m.member_no = a.member_no
INNER JOIN juvenile j
ON a.member_no = j.adult_member_no

--2. Napisz polecenie, które podaje tytuły aktualnie wypożyczonych książek
SELECT DISTINCT t.title
FROM loanhist l
INNER JOIN title t
ON l.title_no = t.title_no

SELECT * FROM loanhist
--3. Podaj informacje o karach zapłaconych za przetrzymywanie książki o tytule ‘Tao Teh King’. Interesuje nas data oddania książki, ile dni była przetrzymywana i jaką zapłacono karę
SELECT l.out_date, DATEDIFF(day, l.out_date, l.in_date) AS 'days', ISNULL(l.fine_paid,0) AS 'fine_paid'
FROM loanhist l
INNER JOIN title t
ON l.title_no = t.title_no
WHERE t.title = 'Tao Teh King'

--4. Napisz polecenie które podaje listę książek (mumery ISBN) zarezerwowanych przez  osobę o nazwisku: Stephen A. Graff
SELECT r.isbn
FROM member AS m
INNER JOIN reservation r
ON m.member_no = r.member_no
WHERE m.firstname = 'Stephen' AND m.middleinitial = 'A' AND m.lastname = 'Graff'

--1. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki. Interesuje nas imię, nazwisko, data urodzenia dziecka i adres zamieszkania dziecka.
SELECT m.firstname, m.lastname, j.birth_date, a.City, a.street
FROM member m
INNER JOIN juvenile j
ON m.member_no =j.member_no
INNER JOIN adult a
ON j.adult_member_no = a.member_no

--2. Napisz polecenie, które wyświetla listę dzieci będących członkami biblioteki. Interesuje nas imię, nazwisko, data urodzenia dziecka, adres zamieszkania dziecka oraz imię i nazwisko rodzica. 
SELECT m.firstname + ' ' + m.lastname 'Juvenile name', j.birth_date, a.City, a.street, ma.firstname + ' ' + ma.lastname 'Parent name'
FROM member m
INNER JOIN juvenile j
ON m.member_no =j.member_no
INNER JOIN adult a
ON j.adult_member_no = a.member_no
INNER JOIN member ma
ON a.member_no = ma.member_no

--3. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci urodzone przed 1 stycznia 1996
SELECT DISTINCT a.street + ' ' + a.city 'Adress'
FROM adult a
INNER JOIN juvenile j
ON a.member_no = j.adult_member_no
WHERE a.member_no NOT IN (
		SELECT DISTINCT adult_member_no
		FROM juvenile
		WHERE birth_date >= '1996-01-01'
	)

--4. Napisz polecenie, które wyświetla adresy członków biblioteki, którzy mają dzieci urodzone przed 1 stycznia 1996. Interesują nas tylko adresy takich członków biblioteki, którzy aktualnie nie przetrzymują książek.
SELECT DISTINCT a.street + ' ' + a.city AS Adress
FROM adult a
RIGHT JOIN juvenile j
ON a.member_no = j.adult_member_no
INNER JOIN member m
ON a.member_no = m.member_no
LEFT JOIN loan l
ON m.member_no = l.member_no
WHERE a.member_no NOT IN (
		SELECT DISTINCT adult_member_no
		FROM juvenile
		WHERE birth_date >= '1996-01-01'
	)
GROUP BY a.member_no, a.street + ' ' + a.city
HAVING COUNT(l.isbn) = 0

-- 1. Napisz polecenie które zwraca imię i nazwisko (jako pojedynczą kolumnę –name), oraz informacje o adresie: ulica, miasto, stan kod (jako pojedynczą kolumnę – address) dla wszystkich dorosłych członków biblioteki
SELECT m.firstname + ' ' + m.lastname AS name, a.street + ' ' + a.city + ' ' + a.state + ' ' + a.zip AS adress
FROM member m
INNER JOIN adult a
ON m.member_no = a.member_no

-- 2. Napisz polecenie, które zwraca: isbn, copy_no, on_loan, title, translation, cover, dla książek o isbn 1, 500 i 1000. Wynik posortuj wg ISBN
SELECT i.isbn, c.copy_no, c.on_loan, t.title, i.translation, i.cover
FROM item i
INNER JOIN copy c
ON i.isbn = c.isbn
INNER JOIN title t
ON c.title_no = t.title_no
WHERE i.isbn = 1 OR i.isbn = 500 OR i.isbn = 1000
ORDER BY i.isbn

-- 3. Napisz polecenie które zwraca o użytkownikach biblioteki o nr 250, 342, i 1675 (dla każdego użytkownika: nr, imię i nazwisko członka biblioteki), oraz informację o zarezerwowanych książkach (isbn, data)
SELECT m.member_no, m.firstname, m.lastname, r.isbn, r.log_date
FROM member m
LEFT JOIN reservation r
ON m.member_no = r.member_no

-- 4. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) mają więcej niż dwoje dzieci zapisanych do biblioteki
SELECT m.member_no, m.firstname, m.lastname
FROM adult a
INNER JOIN member m
ON a.member_no = m.member_no
LEFT JOIN juvenile j
ON a.member_no = j.adult_member_no
WHERE a.state = 'AZ'
GROUP BY m.member_no, m.firstname, m.lastname
HAVING COUNT(j.member_no) > 2


-- 1. Podaj listę członków biblioteki mieszkających w Arizonie (AZ) którzy mają więcej niż dwoje dzieci zapisanych do biblioteki oraz takich którzy mieszkają w Kaliforni (CA) i mają więcej niż troje dzieci zapisanych do biblioteki
SELECT m.member_no, m.firstname, m.lastname
FROM adult a
INNER JOIN member m
ON a.member_no = m.member_no
LEFT JOIN juvenile j
ON a.member_no = j.adult_member_no
WHERE a.state = 'AZ'
GROUP BY m.member_no, m.firstname, m.lastname
HAVING COUNT(j.member_no) > 2
UNION
SELECT m.member_no, m.firstname, m.lastname
FROM adult a
INNER JOIN member m
ON a.member_no = m.member_no
LEFT JOIN juvenile j
ON a.member_no = j.adult_member_no
WHERE a.state = 'CA'
GROUP BY m.member_no, m.firstname, m.lastname
HAVING COUNT(j.member_no) > 3