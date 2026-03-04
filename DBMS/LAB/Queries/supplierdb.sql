create database supplierdb;
use supplierdb;

CREATE TABLE Supplier (
    sid INT PRIMARY KEY,
    sname VARCHAR(30),
    city VARCHAR(30)
);

CREATE TABLE Parts (
    pid INT PRIMARY KEY,
    pname VARCHAR(30),
    color VARCHAR(20)
);

CREATE TABLE Catalog (
    sid INT,
    pid INT,
    cost DECIMAL(10,2),
    PRIMARY KEY (sid, pid),
    FOREIGN KEY (sid) REFERENCES Supplier(sid),
    FOREIGN KEY (pid) REFERENCES Parts(pid)
);

INSERT INTO Supplier VALUES
(1, 'Acme Widget Suppliers', 'Bangalore'),
(2, 'Global Parts Ltd', 'Mumbai'),
(3, 'Universal Supplies', 'Delhi');

INSERT INTO Parts VALUES
(101, 'Bolt', 'Red'),
(102, 'Nut', 'Green'),
(103, 'Screw', 'Red'),
(104, 'Washer', 'Blue');

INSERT INTO Catalog VALUES
(1, 101, 50),
(1, 102, 40),
(1, 103, 60),
(2, 101, 55),
(2, 104, 45),
(3, 102, 42),
(3, 103, 65),
(3, 104, 50);


desc supplier;
desc parts;
desc catalog;

Select * from supplier;
select * from parts;
select * from catalog;

SELECT DISTINCT p.pname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid;

SELECT s.sname
FROM Supplier s
WHERE NOT EXISTS (
    SELECT *
    FROM Parts p
    WHERE NOT EXISTS (
        SELECT *
        FROM Catalog c
        WHERE c.sid = s.sid AND c.pid = p.pid
    )
);

SELECT s.sname
FROM Supplier s
WHERE NOT EXISTS (
    SELECT *
    FROM Parts p
    WHERE p.color = 'Red'
    AND NOT EXISTS (
        SELECT *
        FROM Catalog c
        WHERE c.sid = s.sid AND c.pid = p.pid
    )
);

SELECT p.pname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid
JOIN Supplier s ON s.sid = c.sid
WHERE s.sname = 'Acme Widget Suppliers'
AND p.pid NOT IN (
    SELECT pid
    FROM Catalog c2
    JOIN Supplier s2 ON c2.sid = s2.sid
    WHERE s2.sname <> 'Acme Widget Suppliers'
);

SELECT DISTINCT
    c1.sid
FROM
    Catalog c1
WHERE
    c1.cost > (SELECT 
            AVG(c2.cost)
        FROM
            Catalog c2
        WHERE
            c2.pid = c1.pid);
            
            
SELECT p.pname, s.sname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid
JOIN Supplier s ON s.sid = c.sid
WHERE c.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = p.pid
);

SELECT p.pname, s.sname, c.cost
FROM Catalog c
JOIN Parts p ON c.pid = p.pid
JOIN Supplier s ON c.sid = s.sid
WHERE c.cost = (
    SELECT MAX(cost) FROM Catalog
);

SELECT s.sname
FROM Supplier s
WHERE s.sid NOT IN (
    SELECT c.sid
    FROM Catalog c
    JOIN Parts p ON c.pid = p.pid
    WHERE p.color = 'Red'
);

SELECT s.sname, SUM(c.cost) AS total_value
FROM Supplier s
JOIN Catalog c ON s.sid = c.sid
GROUP BY s.sname;

SELECT s.sname
FROM Supplier s
JOIN Catalog c ON s.sid = c.sid
WHERE c.cost < 20
GROUP BY s.sname
HAVING COUNT(DISTINCT c.pid) >= 2;

SELECT p.pname, s.sname, c.cost
FROM Catalog c
JOIN Parts p ON c.pid = p.pid
JOIN Supplier s ON c.sid = s.sid
WHERE c.cost = (
    SELECT MIN(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = c.pid
);

CREATE VIEW Supplier_Part_Count AS
SELECT s.sname, COUNT(DISTINCT c.pid) AS total_parts
FROM Supplier s
JOIN Catalog c ON s.sid = c.sid
GROUP BY s.sname;
SELECT * FROM Supplier_Part_Count;

CREATE VIEW Most_Expensive_Supplier AS
SELECT p.pname, s.sname, c.cost
FROM Catalog c
JOIN Parts p ON c.pid = p.pid
JOIN Supplier s ON c.sid = s.sid
WHERE c.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = c.pid
);
select * from Most_Expensive_Supplier;

            


