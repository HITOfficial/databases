--1. Napisz polecenie, które wy?wietla list? dzieci b?d?cych cz?onkami biblioteki. Interesuje nas imi?, nazwisko i data urodzenia dziecka.
SELECT m.firstname, m.lastname, j.birth_date
FROM member m
INNER JOIN adult a
ON m.member_no = a.member_no
INNER JOIN juvenile j
ON a.member_no = j.adult_member_no

--2. Napisz polecenie, które podaje tytu?y aktualnie wypo?yczonych ksi??ek
SELECT DISTINCT t.title
FROM loanhist l
INNER JOIN title t
ON l.title_no = t.title_no

SELECT * FROM loanhist
--3. Podaj informacje o karach zap?aconych za przetrzymywanie ksi??ki o tytule ‘Tao Teh King’. Interesuje nas data oddania ksi??ki, ile dni by?a przetrzymywana i jak? zap?acono kar?
SELECT l.out_date, DATEDIFF(day, l.out_date, l.in_date) AS 'days', ISNULL(l.fine_paid,0) AS 'fine_paid'
FROM loanhist l
INNER JOIN title t
ON l.title_no = t.title_no
WHERE t.title = 'Tao Teh King'

--4. Napisz polecenie które podaje list? ksi??ek (mumery ISBN) zarezerwowanych przez  osob? o nazwisku: Stephen A. Graff
SELECT r.isbn
FROM member AS m
INNER JOIN reservation r
ON m.member_no = r.member_no
WHERE m.firstname = 'Stephen' AND m.middleinitial = 'A' AND m.lastname = 'Graff'

--1. Napisz polecenie, które wy?wietla list? dzieci b?d?cych cz?onkami biblioteki. Interesuje nas imi?, nazwisko, data urodzenia dziecka i adres zamieszkania dziecka.
SELECT m.firstname, m.lastname, j.birth_date, a.City, a.street
FROM member m
INNER JOIN juvenile j
ON m.member_no =j.member_no
INNER JOIN adult a
ON j.adult_member_no = a.member_no

--2. Napisz polecenie, które wy?wietla list? dzieci b?d?cych cz?onkami biblioteki. Interesuje nas imi?, nazwisko, data urodzenia dziecka, adres zamieszkania dziecka oraz imi? i nazwisko rodzica. 
SELECT m.firstname + ' ' + m.lastname 'Juvenile name', j.birth_date, a.City, a.street, ma.firstname + ' ' + ma.lastname 'Parent name'
FROM member m
INNER JOIN juvenile j
ON m.member_no =j.member_no
INNER JOIN adult a
ON j.adult_member_no = a.member_no
INNER JOIN member ma
ON a.member_no = ma.member_no


--3. Napisz polecenie, które wy?wietla adresy cz?onków biblioteki, którzy maj? dzieci
--urodzone przed 1 stycznia 1996
--4. Napisz polecenie, które wy?wietla adresy cz?onków biblioteki, którzy maj? dzieci
--urodzone przed 1 stycznia 1996. Interesuj? nas tylko adresy takich cz?onków
--biblioteki, którzy aktualnie nie przetrzymuj? ksi??ek.
