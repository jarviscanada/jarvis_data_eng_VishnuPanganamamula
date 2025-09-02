# Introduction

The purpose of this project is to understand and explore relational databases RDBMS and how to use SQL queries to get information.
The PostgreSQL database was used, with an example schema for a country club registration database. 
In terms of implementation, this project was largely a learning project, so the key objective was to understand SQL logic and syntax and how it is used to get, create, update and delete information as well as querying to get certain tabular results.
The testing of SQL queries was using the exercises website on PostgreSQL for this schema to see whether the queries were correct or not and why.

# SQL Queries

### Table Setup (DDL)

###### cd.members
```SQL
CREATE TABLE cd.members (
    memid INTEGER NOT NULL,
    surname character varying(200) NOT NULL,
    firstname character varying(200) NOT NULL, 
    address character varying(300) NOT NULL, 
    zipcode integer NOT NULL, 
    telephone character varying(20) NOT NULL, 
    recommendedby integer,
    joindate timestamp NOT NULL,
    CONSTRAINT members_pk PRIMARY KEY (memid),
    CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
        REFERENCES cd.members(memid) ON DELETE SET NULL
);
```

###### cd.facilities
```SQL
CREATE TABLE cd.facilities (
    facid INTEGER NOT NULL,
    name character varying(100) NOT NULL,
    membercost numeric NOT NULL,
    guestcost numeric NOT NULL,
    initialoutlay numeric NOT NULL,
    monthlymaintenance numeric NOT NULL,
    CONSTRAINT facilities_pk PRIMARY KEY (facid)
);
```

###### cd.bookings
```SQL
CREATE TABLE cd.bookings (
    bookid integer NOT NULL,
    facid integer NOT NULL,
    memid integer NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots integer NOT NULL,
    CONSTRAINT bookings_pk PRIMARY KEY (bookid),
    CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
    CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
);
```

###### ---------------------------------------------------------------------------------------------------------------------------------------------------------------

### Answers to Query Practice Questions

#### CRUD and Data Modification Questions (1 to 6):

###### Question 1: Insert Data into a Table
```SQL
insert into cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	values (9, 'Spa', 20, 30, 100000, 800);
```

###### Question 2: Insert calculated data into a table
```SQL
insert into cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
	select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;
```

###### Question 3: Update Existing Data
```SQL
update cd.facilities set initialoutlay=10000 where facid=1;
```

###### Question 4: Update a row based on the contents of another row
```SQL
update cd.facilities facs
	set membercost = (select membercost * 1.1 from cd.facilities where facid = 0),
		guestcost = (select guestcost * 1.1 from cd.facilities where facid = 0)
	where facs.facid = 1;
```

###### Question 5: Delete all bookings
```SQL
delete from cd.bookings;
```

###### Question 6: Delete a member from the cd.members table
```SQL
delete from cd.members where memid = 37;
```

#### Basic Questions (7 to 11):

###### Question 7: Control which rows are retrieved - part 2
```SQL
select facid, name, membercost, monthlymaintenance from cd.facilities
	where (membercost < (monthlymaintenance * 0.02)) and (membercost != 0);
```

###### Question 8: Basic String Searches
```SQL
select * from cd.facilities where name like '%Tennis%';
```

###### Question 9: Matching against multiple possible values
```SQL
select * from cd.facilities
	where facid in (1,5);
```

###### Question 10: Working with Dates
```SQL
select memid, surname, firstname, joindate from cd.members
	where joindate > '2012-09-01';
```

###### Question 11: Combining Results from Multiple Queries
```SQL
select surname from cd.members
union
select name from cd.facilities;
```

#### Join Questions (12 to 16):

###### Question 12: Retrieve start times of members' bookings
```SQL
select b.starttime from cd.bookings as b
	inner join cd.members as m
		on b.memid = m.memid
	where m.firstname = 'David' and m.surname = 'Farrell';
```

###### Question 13: Work out start times of bookings for tennis courts
```SQL
select bks.starttime as start, facs.name as name
	from cd.facilities facs
		inner join cd.bookings bks
				on facs.facid = bks.facid
	where
		facs.name in ('Tennis Court 2', 'Tennis Court 1') and
		bks.starttime >= '2012-09-21' and bks.starttime < '2012-09-22'
order by bks.starttime;
```

###### Question 14: Produce a list of all members along with their recommender
```SQL
SELECT m.firstname AS member_firstname,
	   m.surname AS member_surname,
	   r.firstname AS recommender_firstname,
	   r.surname AS recommender_surname
FROM cd.members as m
LEFT JOIN cd.members as r
	ON m.recommendedby = r.memid
	ORDER BY m.surname, m.firstname;
```

###### Question 15: roduce a list of all members along with their recommender (No duplicates)
```SQL
SELECT DISTINCT r.firstname, r.surname FROM cd.members AS m
	INNER JOIN cd.members AS r
		ON m.recommendedby = r.memid
	ORDER BY r.surname, r.firstname;
```

###### Question 16: List of all members, with recommender, using no joins
```SQL
SELECT DISTINCT m.firstname || ' ' || m.surname AS member_name,
	(SELECT r.firstname || ' ' || r.surname
	 	FROM cd.members r
	 	WHERE r.memid = m.recommendedby) AS recommender_name
	 
	 FROM cd.members m
ORDER BY member_name
```

#### Aggregation Questions (17 to 25):

###### Question 17: Count the Number of Recommendations Each Member Makes
```SQL
SELECT recommendedby, count(*) FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby ASC;
```

###### Question 18: List Total Slots Booked per Facility
```SQL
SELECT facid, sum(slots) as "Total Slots" FROM cd.bookings
	GROUP BY facid
	ORDER BY facid;
```

###### Question 19: Total Slots Booked per Facility in a Given Month
```SQL
SELECT facid, sum(slots) as "Total Slots" FROM cd.bookings
	WHERE starttime >= '2012-09-01' AND starttime < '2012-10-01'
	GROUP BY facid
	ORDER BY sum(slots);
```

###### Question 20: Total Slots Booked per Facility per Month
```SQL
SELECT facid, extract(month from starttime) as month, sum(slots) as "Total Slots" FROM cd.bookings
	WHERE extract(year from starttime)=2012
	GROUP BY facid, month
	ORDER BY facid, month;
```

###### Question 21: Find the Count of Members who Made at least One Booking
```SQL
SELECT COUNT(DISTINCT memid) FROM cd.bookings;
```

###### Question 22: List Each Member's Booking after September 1, 2012
```SQL
SELECT m.surname, m.firstname, m.memid, min(b.starttime) as starttime FROM cd.bookings b
	INNER JOIN cd.members m ON m.memid = b.memid
	WHERE starttime >= '2012-09-01'
	GROUP BY m.surname, m.firstname, m.memid
	ORDER BY m.memid;
```

###### Question 23: List of Member Names, each Row with Total Member Count
```SQL
SELECT count(*) over(), firstname, surname FROM cd.members
	ORDER BY joindate;
```

###### Question 24: Numbered List of Members
```SQL
SELECT row_number() over(order by joindate), firstname, surname FROM cd.members
	ORDER BY joindate;
```

###### Question 25: Output Facility ID with Highest Number of Slots Booked
```SQL
SELECT facid, total 
	from(select facid, sum(slots) total, rank() over(order by sum(slots) desc) rank
		 	FROM cd.bookings
		 	GROUP BY facid
		 ) AS ranked
		 WHERE rank = 1;
```


#### String Questions (26 to 28):

###### Question 26: Format Names of Members
```SQL
SELECT surname || ', ' || firstname AS name FROM cd.members;
```

###### Question 27: Find Telephone Numbers with Parentheses
```SQL
SELECT memid, telephone FROM cd.members WHERE telephone~'[()]';
```

###### Question 28: Count Number of Members whose Surname Starts With Each Letter of the Alphabet
```SQL
SELECT substr(m.surname,1,1) as letter, count(*) as count FROM cd.members m
	GROUP BY letter
	ORDER BY letter;
```
