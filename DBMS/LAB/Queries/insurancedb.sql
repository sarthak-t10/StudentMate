create database insurancedb;
use insurancedb;

CREATE TABLE PERSON(
    driver_id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(30),
    address VARCHAR(50)
);


CREATE TABLE CAR(
    reg_num VARCHAR(15) PRIMARY KEY,
    model VARCHAR(20),
    year INT,
    CONSTRAINT chk_year_range CHECK (year >= 1886 AND year <= 2100)
);


CREATE TABLE ACCIDENT(
    report_num INT PRIMARY KEY,
    accident_date DATE,
    location VARCHAR(50)
);

CREATE TABLE OWNS(
    driver_id VARCHAR(10),
    reg_num VARCHAR(15),
    PRIMARY KEY(driver_id, reg_num),
    FOREIGN KEY(driver_id) REFERENCES PERSON(driver_id)
        ON DELETE RESTRICT,
    FOREIGN KEY(reg_num) REFERENCES CAR(reg_num)
        ON DELETE RESTRICT
);

CREATE TABLE PARTICIPATED(
    driver_id VARCHAR(10),
    reg_num VARCHAR(15),
    report_num INT,
    damage_amount INT CHECK(damage_amount >= 0),
    PRIMARY KEY(driver_id, reg_num, report_num),
    FOREIGN KEY(driver_id) REFERENCES PERSON(driver_id)
        ON DELETE RESTRICT,
    FOREIGN KEY(reg_num) REFERENCES CAR(reg_num)
        ON DELETE RESTRICT,
    FOREIGN KEY(report_num) REFERENCES ACCIDENT(report_num)
        ON DELETE CASCADE
);

desc person;
desc car;
desc accident;
desc owns;
desc participated;



INSERT INTO PERSON VALUES
('A01','Richard','Srinivas nagar'),
('A02','Pradeep','Rajaji nagar'),
('A03','Smith','Ashok nagar'),
('A04','Venu','N R Colony'),
('A05','Jhon','Hanumanth nagar');


INSERT INTO CAR VALUES
('KA052250','Indica',1990),
('KA031181','Lancer',1957),
('KA095477','Toyota',1998),
('KA053408','Honda',2008),
('KA041702','Audi',2005);


INSERT INTO ACCIDENT VALUES
(11,'2003-01-01','Mysore Road'),
(12,'2004-02-02','South end Circle'),
(13,'2003-01-21','Bull temple Road'),
(14,'2008-02-17','Mysore Road'),
(15,'2005-03-04','Kanakpura Road');


INSERT INTO OWNS VALUES
('A01','KA052250'),
('A02','KA053408'),
('A03','KA031181'),
('A04','KA095477'),
('A05','KA041702');


INSERT INTO PARTICIPATED VALUES
('A01','KA052250',11,10000),
('A02','KA053408',12,50000),
('A03','KA095477',13,25000),
('A04','KA031181',14,3000),
('A05','KA041702',15,5000);


select * from person;
select * from car;
select * from owns;
select * from participated;
select * from accident;


SELECT accident_date, location
FROM ACCIDENT;

UPDATE PARTICIPATED
SET damage_amount = 25000
WHERE reg_num = 'KA053408'
AND report_num = 12;
select * from partcicipated;

INSERT INTO ACCIDENT (report_num, accident_date, location)
VALUES (16, '2024-03-10', 'MG Road');
select * from accident;

SELECT DISTINCT driver_id
FROM PARTICIPATED
WHERE damage_amount >= 25000;

SELECT *
FROM CAR
ORDER BY year ASC;

SELECT COUNT(DISTINCT p.report_num)
FROM PARTICIPATED p
JOIN CAR c ON p.reg_num = c.reg_num
WHERE c.model = 'Lancer';

SELECT COUNT(DISTINCT o.driver_id)
FROM OWNS o
JOIN PARTICIPATED p ON o.reg_num = p.reg_num
JOIN ACCIDENT a ON p.report_num = a.report_num
WHERE YEAR(a.accident_date) = 2008;

SELECT *
FROM PARTICIPATED
ORDER BY damage_amount DESC;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM PARTICIPATED
WHERE damage_amount < (
    SELECT avg_damage
    FROM (
        SELECT AVG(damage_amount) AS avg_damage
        FROM PARTICIPATED
    ) AS temp
);
select * from participated;
SET SQL_SAFE_UPDATES = 1;


SELECT AVG(damage_amount) AS avg_damage
FROM PARTICIPATED;

SELECT DISTINCT pe.name
FROM PERSON pe
JOIN PARTICIPATED p ON pe.driver_id = p.driver_id
WHERE p.damage_amount > (
    SELECT AVG(damage_amount)
    FROM PARTICIPATED
);

SELECT MAX(damage_amount) AS max_damage
FROM PARTICIPATED;












