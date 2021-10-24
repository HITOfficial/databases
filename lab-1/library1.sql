-- Exercise 1

--1.
SELECT title, title_no
FROM title

--2.
SELECT title
FROM title
WHERE title_no = 10

--3.
SELECT member_no, fine_waived
FROM loanhist
WHERE fine_waived BETWEEN 8 AND 9

--4.
SELECT *
FROM title
WHERE author IN ('Charles Dickens', 'Jane Austen')

--5.
SELECT title_no, title
FROM title
WHERE title LIKE '%adventures%'

--6.
SELECT member_no, fine_assessed, fine_paid, fine_waived
FROM loanhist
WHERE fine_assessed IS NOT NULL and fine_assessed > 0 AND NOT (fine_assessed = fine_paid)

--7.
SELECT DISTINCT city, state
FROM adult
