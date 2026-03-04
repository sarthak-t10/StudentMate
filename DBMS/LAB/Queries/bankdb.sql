drop database insurancedb;
create database bankdb;
use bankdb;
CREATE TABLE Branch (
    branch_name VARCHAR(30) PRIMARY KEY,
    branch_city VARCHAR(30) NOT NULL,
    assets DECIMAL(15,2) NOT NULL,
    CHECK (assets >= 0)
);


CREATE TABLE BankAccount (
    accno INT PRIMARY KEY,
    branch_name VARCHAR(30) NOT NULL,
    balance DECIMAL(15,2) NOT NULL,
    CHECK (balance >= 0),
    FOREIGN KEY (branch_name)
        REFERENCES Branch(branch_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE BankCustomer (
    customer_name VARCHAR(30) PRIMARY KEY,
    customer_street VARCHAR(50),
    customer_city VARCHAR(30)
);


CREATE TABLE Depositer (
    customer_name VARCHAR(30),
    accno INT,
    PRIMARY KEY (customer_name, accno),
    FOREIGN KEY (customer_name)
        REFERENCES BankCustomer(customer_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (accno)
        REFERENCES BankAccount(accno)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


CREATE TABLE Loan (
    loan_number INT PRIMARY KEY,
    branch_name VARCHAR(30) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    CHECK (amount >= 0),
    FOREIGN KEY (branch_name)
        REFERENCES Branch(branch_name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

desc Branch;
desc BankAccount;
desc BankCustomer;
desc depositer;
desc Loan;


INSERT INTO Branch VALUES
('SBI_Chamrajpet','Bangalore',50000),
('SBI_ResidencyRoad','Bangalore',10000),
('SBI_ShivajiRoad','Bombay',20000),
('SBI_ParliamentRoad','Delhi',10000),
('SBI_Jantarmantar','Delhi',20000);

INSERT INTO BankAccount VALUES
(1,'SBI_Chamrajpet',2000),
(2,'SBI_ResidencyRoad',5000),
(3,'SBI_ShivajiRoad',6000),
(4,'SBI_ParliamentRoad',9000),
(5,'SBI_Jantarmantar',8000);

INSERT INTO BankCustomer VALUES
('Avinash','Bull_Temple_Road','Bangalore'),
('Dinesh','Bannerghatta_Road','Bangalore'),
('Mohan','NationalCollege_Road','Bangalore'),
('Nikil','Akbar_Road','Delhi'),
('Ravi','Prithviraj_Road','Delhi');

INSERT INTO Depositer VALUES
('Avinash',1),
('Dinesh',2),
('Nikil',4),
('Ravi',5),
('Avinash',3);

INSERT INTO Loan VALUES
(1,'SBI_Chamrajpet',1000),
(2,'SBI_ResidencyRoad',2000),
(3,'SBI_ShivajiRoad',3000),
(4,'SBI_ParliamentRoad',4000),
(5,'SBI_Jantarmantar',5000);

select *from Branch;
select *from BankAccount;
select *from BankCustomer;
select *from depositer;
select *from Loan;


SELECT branch_name, assets/100000 AS `assets in lakhs`
FROM Branch;


SELECT d.customer_name
FROM Depositer d
JOIN BankAccount b ON d.accno = b.accno
WHERE b.branch_name = 'SBI_ResidencyRoad'
GROUP BY d.customer_name
HAVING COUNT(*) >= 2;

CREATE VIEW BranchLoanSum AS
SELECT branch_name, SUM(amount) AS total_loan
FROM Loan
GROUP BY branch_name;
SELECT * FROM BranchLoanSum;


SELECT c.customer_name
FROM BankCustomer c
JOIN Depositer d ON c.customer_name = d.customer_name
JOIN BankAccount b ON d.accno = b.accno
JOIN Branch br ON b.branch_name = br.branch_name
WHERE br.branch_city = 'Delhi'
GROUP BY c.customer_name
HAVING COUNT(DISTINCT br.branch_name) = (
    SELECT COUNT(*)
    FROM Branch
    WHERE branch_city = 'Delhi'
);

SELECT DISTINCT l.loan_number
FROM Loan l
LEFT JOIN BankAccount b ON l.branch_name = b.branch_name
WHERE b.accno IS NULL;

SELECT DISTINCT d.customer_name
FROM Depositer d
JOIN BankAccount b ON d.accno = b.accno
JOIN Loan l ON b.branch_name = l.branch_name
JOIN Branch br ON b.branch_name = br.branch_name
WHERE br.branch_city = 'Bangalore';

SELECT branch_name
FROM Branch
WHERE assets > ALL (
    SELECT assets
    FROM Branch
    WHERE branch_city = 'Bangalore'
);

SET SQL_SAFE_UPDATES=0;
DELETE FROM Depositer
WHERE accno IN (
    SELECT accno
    FROM BankAccount
    WHERE branch_name IN (
        SELECT branch_name
        FROM Branch
        WHERE branch_city = 'Bombay'
    )
);

DELETE FROM BankAccount
WHERE branch_name IN (
    SELECT branch_name
    FROM Branch
    WHERE branch_city = 'Bombay'
);
SELECT * FROM BankAccount;
SET SQL_SAFE_UPDATES=1;

UPDATE BankAccount
SET balance = balance * 1.05;
SELECT * FROM BankAccount;

