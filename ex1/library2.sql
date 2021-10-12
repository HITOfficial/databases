-- Exercise 2

--1.
SELECT title
FROM title
ORDER BY title ASC

--2.
SELECT member_no, isbn, out_date, fine_assessed*2 AS 'double fine'
FROM loanhist
WHERE GETDATE() > out_date
	AND fine_waived IS NOT NULL
		AND fine_waived > 0

--3.
SELECT TOP 1 LOWER(firstname + LEFT(lastname,1) + LEFT(lastname,2)) AS 'email_name'
FROM member
WHERE  lastname = 'Anderson'
ORDER BY NEWID()



--4.
SELECT 'The title is: '+ title + 'title number ' + CONVERT(varchar(10),title_no)
FROM title