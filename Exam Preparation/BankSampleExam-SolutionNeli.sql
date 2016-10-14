----------------------- DDL -------------------------
use Bank

CREATE TABLE DepositTypes(
	DepositTypeID INT PRIMARY KEY,
	Name VARCHAR(20)
)

CREATE TABLE Deposits(
	DepositID INT IDENTITY PRIMARY KEY,
	Amount DECIMAL (10,2),
	StartDate DATE,
	EndDate DATE,
	DepositTypeID INT
		CONSTRAINT FK_Deposits_DepositTypes FOREIGN KEY REFERENCES DepositTypes(DepositTypeID),
	CustomerID INT NOT NULL
		CONSTRAINT FK_Deposits_Customers FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE EmployeesDeposits(
	EmployeeID INT NOT NULL
		CONSTRAINT FK_EmployeesDeposits_Employees FOREIGN KEY REFERENCES Employees(EmployeeID),
	DepositID INT NOT NULL
		CONSTRAINT FK_EmployeesDeposits_Deposits FOREIGN KEY REFERENCES Deposits(DepositID),
		CONSTRAINT PK_EmployeesDeposits PRIMARY KEY (EmployeeID, DepositID)
	)

CREATE TABLE CreditHistory(
	CreditHostoryID INT NOT NULL IDENTITY PRIMARY KEY,
	Mark char(1),
	StartDate DATE,
	EndDate DATE,	
	CustomerID INT NOT NULL
		CONSTRAINT FK_Credit_Customers FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE Payments
(
	PaymentID INT,
	[Date] DATE,
	Amount DECIMAL(10, 2),
	LoanID INT,
	CONSTRAINT PK_Payments PRIMARY KEY (PaymentID),
	CONSTRAINT FK_Payments_Loans FOREIGN KEY (LoanID) REFERENCES Loans(LoanID)
)

CREATE TABLE Users
(
	UserID INT,
	UserName VARCHAR(20),
	Password VARCHAR(20),
	CustomerID INT UNIQUE,
	CONSTRAINT PK_Users PRIMARY KEY (UserID),
	CONSTRAINT FK_Users_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID)
)

ALTER TABLE Employees
add ManagerID INT 
	CONSTRAINT FK_Employees_Employees FOREIGN KEY (ManagerID) references Employees(EmployeeID)

------------------------- DML ------------------------------------------
	
INSERT INTO DepositTypes(DepositTypeID, Name)
VALUES
(1, 'Time Deposit'),
(2, 'Call Deposit'),
(3, 'Free Deposit')

INSERT INTO Deposits(CustomerID, Amount, StartDate, EndDate, DepositTypeID)
SELECT 
CustomerID,
CASE 
	WHEN YEAR(DateOfBirth) >= 1980 THEN 1000 
	ELSE 1500 
END 
+ 
CASE 
	WHEN Gender = 'M' THEN 100 
	ELSE 200 END,
GETDATE(),
null,
CASE 
	WHEN CustomerID > 15 THEN 3 
	ELSE 
		CASE WHEN CustomerID % 2 = 1 THEN 1 
		ELSE 2 
	END 
end
FROM Customers
WHERE CustomerID <20


insert into EmployeesDeposits(EmployeeID, DepositID)
VALUES
(15, 4),
(20, 15),
(8, 7),
(4, 8),
(3, 13),
(3, 8),
(4, 10),
(10, 1),
(13, 4),
(14, 9)

-- UPDATE
UPDATE Employees
SET ManagerID =
CASE 	
	WHEN EmployeeId BETWEEN 2 AND 10 THEN 1
	WHEN EmployeeId BETWEEN 12 AND 20 THEN 11
	WHEN EmployeeId BETWEEN 22 AND 30 THEN 21
	WHEN EmployeeID IN(11, 21) then 1
END

-- delete
DELETE FROM EmployeesDeposits
WHERE DepositID = 9 or EmployeeID = 3

--- queries

--- 3.1.
select 
	e.EmployeeID,
	e.HireDate,
	e.Salary,
	e.BranchID
from Employees AS e
where e.Salary > 2000 and e.HireDate > '20090615'

--- 3.2. 
select 
	c.FirstName,
	c.DateOfBirth,
	DATEDIFF(YEAR, c.DateOfBirth, '20161001') as [Age]
from Customers As c
where DATEDIFF(YEAR, c.DateOfBirth, '20161001') >= 40 AND 
	DATEDIFF(YEAR, c.DateOfBirth, '20161001') <= 50

--- 3.3.
select 
	c.CustomerID,
	c.FirstName,
	c.LastName,
	c.Gender,
	city.CityName
from Customers AS c
join Cities AS city ON c.CityID = city.CityID
where (c.LastName LIKE 'Bu%' OR c.FirstName LIKE '%a') AND
		LEN(city.CityName) >= 8

--- 3.4.
SELECT TOP 5
	e.EmployeeID,
	e.FirstName,
	a.AccountNumber
FROM Employees AS e
JOIN EmployeesAccounts AS ea ON ea.EmployeeID = e.EmployeeID
JOIN Accounts AS a ON a.AccountID = ea.AccountID
WHERE YEAR(a.StartDate) > '2012'
ORDER BY e.FirstName DESC

--- 3.5.
SELECT	
	c.CityName,
	b.Name,
	COUNT(e.EmployeeID) AS [EmployeesCount]
FROM Branches AS b 
JOIN Employees AS e ON e.BranchID = b.BranchID
JOIN Cities AS c ON b.CityID = c.CityID 
	WHERE c.CityID NOT IN (4,5)
GROUP BY c.CityName, b.Name
HAVING COUNT(e.EmployeeID) >= 3

--- 3.6.
SELECT	
	SUM(l.Amount) AS TotalLoanAmount,
	MAX(l.Interest) AS MaxInterest,
	MIN(e.Salary) AS MinEmployeeSalary
FROM Employees AS e
JOIN EmployeesLoans AS el ON e.EmployeeID = el.EmployeeID
JOIN Loans AS l ON l.LoanID = el.LoanID

--- 3.7.

SELECT TOP 3 
	e.FirstName, c.CityName
FROM Employees AS e
JOIN Branches as B on b.BranchID = e.BranchID
JOIN Cities AS c ON c.CityID = b.CityID

UNION ALL

SELECT TOP 3
	c.FirstName,
	city.CityName
FROM Customers AS c
JOIN Cities AS city ON city.CityID = c.CityID

--- 3.8.

SELECT c.CustomerID, c.Height
FROM Customers AS c
LEFT JOIN Accounts AS a ON a.CustomerID = c.CustomerID
WHERE a.AccountID IS NULL AND c.Height BETWEEN 1.74 AND 2.04

--- 3.9.
SELECT TOP 5 
	c.CustomerID,
	l.Amount
FROM Customers AS c
JOIN Loans AS l ON l.CustomerID = c.CustomerID
WHERE l.Amount > (SELECT AVG(l.Amount)
						FROM Loans AS l
						JOIN Customers AS c ON l.CustomerID = c.CustomerID
						WHERE c.Gender = 'M')
ORDER BY c.LastName

--- 3.10
SELECT TOP 1 
	c.CustomerID, 
	c.FirstName, 
	a.StartDate
FROM Customers AS c
JOIN Accounts AS a ON a.CustomerID = c.CustomerID
ORDER BY a.StartDate

-------PROGRAMMING

--- 4.1.
CREATE FUNCTION udf_ConcatString(@stringOne VARCHAR(MAX), @stringTwo VARCHAR(MAX))
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @RESULT NVARCHAR(MAX);

	SET @RESULT = CONCAT(REVERSE(@stringOne), REVERSE(@stringTwo))

	RETURN @RESULT
END

--- 4.2.
CREATE PROCEDURE usp_CustomersWithUnexpiredLoans @CustomerID INT
AS
BEGIN
	SELECT 
		c.CustomerID,
		c.FirstName,
		l.LoanID
	FROM Customers AS c
	JOIN Loans AS l ON l.CustomerID = c.CustomerID
	WHERE l.ExpirationDate IS NULL AND c.CustomerID = @CustomerID
END

--- 4.3.

CREATE PROCEDURE usp_TakeLoan 
					@CustomerID INT, 
					@LoanAmount DECIMAL(10,2), 
					@Interest DECIMAL(4,2), 
					@StartDate DATE
AS
BEGIN
	BEGIN TRANSACTION

	INSERT INTO Loans(CustomerID, Amount, Interest, StartDate) 
	VALUES	(@CustomerID, @LoanAmount, @Interest, @StartDate)

	IF @LoanAmount NOT BETWEEN 0.01 AND 100000
	BEGIN 
		ROLLBACK
		RAISERROR('Invalid Loan Amount.', 16, 1);
		RETURN
	END
	
	COMMIT;
END

--- 4.4.
CREATE TRIGGER tr_HireEmployee
ON Employees
AFTER INSERT
AS
BEGIN
	UPDATE EmployeesLoans
		SET EmployeeID = i.EmployeeID
		FROM EmployeesLoans AS el
		JOIN inserted AS i
		ON el.EmployeeID + 1 = i.EmployeeID
END

--- bonus 5.1. ----
CREATE TRIGGER TR_ToAccountLogs
ON Accounts
INSTEAD OF DELETE
AS
BEGIN 
	DELETE FROM EmployeesAccounts 
	WHERE AccountID IN (SELECT d.AccountID FROM deleted AS d)

	INSERT INTO AccountLogs(AccountID,AccountNumber,CustomerID,StartDate)
	SELECT 
		D.AccountID,
		d.AccountNumber,
		d.CustomerID,
		d.StartDate
    FROM deleted AS d	

	DELETE FROM Accounts 
	WHERE AccountID IN (SELECT d.AccountID FROM deleted AS d)
END
