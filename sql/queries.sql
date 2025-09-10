-- SQL Query Practice Answers

-- CRUD and Modification of Data Questions -----------------------------------------------------------
-- Question 1
insert into cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	values (9, 'Spa', 20, 30, 100000, 800);

-- Question 2
insert into cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;

-- Question 3
update cd.facilities set initialoutlay=10000 where facid=1;

-- Question 4
update cd.facilities facs
	set membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
		guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
	where facs.facid = 1;

-- Question 5
delete from cd.bookings;

-- Question 6
delete from cd.members where memid = 37;

-- Question 7
select facid, name, membercost, monthlymaintenance from cd.facilities
	where (membercost < (monthlymaintenance * 0.02)) and (membercost != 0);

-- Basic Questions -----------------------------------------------------------------------------------
-- Question 8
select * from cd.facilities where name like '%Tennis%';

-- Question 9
select * from cd.facilities
	where facid in (1,5);

-- Question 10
select memid, surname, firstname, joindate from cd.members
	where joindate > '2012-09-01';

-- Question 11
select surname from cd.members
union
select name from cd.facilities;

-- Question 12
select b.starttime from cd.bookings as b
	inner join cd.members as m
		on b.memid = m.memid
	where m.firstname = 'David' and m.surname = 'Farrell';

-- Join Questions -------------------------------------------------------------------------------------
-- Question 13
select bks.starttime as start, facs.name as name
	from cd.facilities facs
		inner join cd.bookings bks
				on facs.facid = bks.facid
	where
		facs.name in ('Tennis Court 2', 'Tennis Court 1') and
		bks.starttime >= '2012-09-21' and bks.starttime < '2012-09-22'
order by bks.starttime;

-- Question 14
SELECT m.firstname AS member_firstname,
	   m.surname AS member_surname,
	   r.firstname AS recommender_firstname,
	   r.surname AS recommender_surname
FROM cd.members as m
LEFT JOIN cd.members as r
	ON m.recommendedby = r.memid
	ORDER BY m.surname, m.firstname;

-- Question 15
SELECT DISTINCT r.firstname, r.surname FROM cd.members AS m
	INNER JOIN cd.members AS r
		ON m.recommendedby = r.memid
	ORDER BY r.surname, r.firstname;

-- Question 16
SELECT DISTINCT m.firstname || ' ' || m.surname AS member_name,
	(SELECT r.firstname || ' ' || r.surname
	 	FROM cd.members r
	 	WHERE r.memid = m.recommendedby) AS recommender_name

	 FROM cd.members m
ORDER BY member_name

-- Aggregation Questions ------------------------------------------------------------------------------
-- Question 17
SELECT recommendedby, count(*) FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby ASC;

-- Question 18
SELECT facid, sum(slots) as "Total Slots" FROM cd.bookings
	GROUP BY facid
	ORDER BY facid;

-- Question 19
SELECT facid, sum(slots) as "Total Slots" FROM cd.bookings
	WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
	GROUP BY facid
	ORDER BY sum(slots);

-- Question 20
SELECT facid, extract(month from starttime) as month, sum(slots) as "Total Slots" FROM cd.bookings
	WHERE extract(year from starttime)=2012
	GROUP BY facid, month
	ORDER BY facid, month;

-- Question 21
SELECT COUNT(DISTINCT memid) FROM cd.bookings;

-- Question 22
SELECT m.surname, m.firstname, m.memid, min(b.starttime) as starttime FROM cd.bookings b
	INNER JOIN cd.members m ON m.memid = b.memid
	WHERE starttime >= '2012-09-01'
	GROUP BY m.surname, m.firstname, m.memid
	ORDER BY m.memid;

-- Question 23
SELECT count(*) over(), firstname, surname FROM cd.members
	ORDER BY joindate;

-- Question 24
SELECT row_number() over(order by joindate), firstname, surname FROM cd.members
	ORDER BY joindate;

-- Question 25
SELECT facid, total
	from(select facid, sum(slots) total, rank() over(order by sum(slots) desc) rank
		 	FROM cd.bookings
		 	GROUP BY facid
		 ) AS ranked
		 WHERE rank = 1;

-- String Questions -----------------------------------------------------------------------------------
-- Question 26
SELECT surname || ', ' || firstname AS name FROM cd.members;

-- Question 27
SELECT memid, telephone FROM cd.members WHERE telephone~'[()]';

-- Question 28
SELECT substr(m.surname,1,1) as letter, count(*) as count FROM cd.members m
	GROUP BY letter
	ORDER BY letter;