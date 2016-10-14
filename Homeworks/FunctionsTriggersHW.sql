-- Functions, Procedures and Triggers Homework

--1 ----------------------------------------------------------
---------------------------------------------------------------

CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT e.FirstName, e.LastName
	FROM Employees AS e
	WHERE e.Salary > 35000
END
GO

-- 2 ----------------------------------------------------------
---------------------------------------------------------------

CREATE PROC usp_GetEmployeesSalaryAboveNumber @SalaryCheck MONEY
AS
BEGIN
	SELECT e.FirstName, e.LastName
	FROM Employees AS e
	WHERE e.Salary >= @SalaryCheck
END

-- 3 ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROC usp_GetTownsStartingWith  @startingString nvarchar(MAX)
AS
BEGIN
	SELECT t.Name
	FROM Towns AS t
	WHERE t.Name LIKE (@startingString + '%')		
END


-- 4 ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROC usp_GetEmployeesFromTown @TownName NVARCHAR(MAX)
AS
BEGIN
	SELECT e.FirstName, e.LastName
	FROM Employees as e
	JOIN Addresses as a ON a.AddressID = e.AddressID
	JOIN Towns as t ON t.TownID = a.TownID
	WHERE t.Name = @TownName
END

-- 5 ----------------------------------------------------------
---------------------------------------------------------------
CREATE FUNCTION ufn_GetSalaryLevel(@salary MONEY)
RETURNS NVARCHAR(7)
AS
BEGIN
	DECLARE @salaryLevel NVARCHAR(7)
	IF(@salary < 30000)
		SET @salaryLevel = 'Low'
	ELSE IF (@salary BETWEEN 30000 AND 50000)
		SET @salaryLevel = 'Average'
	ELSE
		SET @salaryLevel = 'High'

	RETURN (@salaryLevel)
END

-- 6  ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROC usp_EmployeesBySalaryLevel @SalaryLevel NVARCHAR(7)
AS
BEGIN
	;WITH EmployeesAndSalaryLevel as
	(SELECT 
		e.FirstName, 
		e.LastName,
		CASE 
			WHEN e.Salary > 50000 THEN 'High'
			WHEN e.Salary >= 30000 AND e.Salary <= 30000 THEN 'Average'
			ELSE 'Low'
		END AS SalaryLevel
	FROM [dbo].[Employees] AS e)

	SELECT esl.FirstName, esl.LastName
	FROM
	EmployeesAndSalaryLevel AS esl
	WHERE esl.SalaryLevel = @SalaryLevel
END

-- 7 ----------------------------------------------------------
---------------------------------------------------------------
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters nvarchar(max), @word nvarchar(max)) 
RETURNS INT
AS
BEGIN
	
	DECLARE @result INT;
	DECLARE @currentLetter NVARCHAR;
	DECLARE @wordLenght INT;
	DECLARE @currentLetterPosition INT;	

	SET @currentLetterPosition = 1;
	SET @wordLenght  = LEN(@word);

	WHILE @currentLetterPosition <= @wordLenght
	BEGIN
		SET @currentLetter = SUBSTRING(@word, @currentLetterPosition, 1)
		SET @result = CHARINDEX(@currentLetter, @setOfLetters, 1)
		
		IF(@result = 0)
		BEGIN 
			RETURN 0
			BREAK
		END
		SET @currentLetterPosition +=1
	END

	RETURN 1
END

-- 8 !!!  ----------------------------------------------------------
---------------------------------------------------------------

BEGIN TRAN

USE SoftUni

SELECT FirstName,
	   LastName,
	   Employees.DepartmentId,
	   Departments.Name
  FROM Employees
LEFT JOIN Departments ON
Departments.DepartmentID = Employees.DepartmentID

DELETE FROM EmployeesProjects
WHERE EmployeeID IN
(SELECT Employees.EmployeeID 
FROM Employees
JOIN Departments ON
Employees.DepartmentID = Departments.DepartmentID
WHERE Departments.Name IN ('Production', 'Production Control'))

DELETE FROM Employees
WHERE DepartmentID IN 
(SELECT DepartmentID FROM Departments WHERE Name IN ('Production', 'Production Control'))

DELETE FROM Departments
WHERE DepartmentID IN 
(SELECT DepartmentID FROM Departments WHERE Name IN ('Production', 'Production Control'))

SELECT * FROM Departments

ROLLBACK

-- 9 ----------------------------------------------------------
---------------------------------------------------------------

CREATE TABLE AccountHolders(
	Id INT IDENTITY PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	SSN DECIMAL)

CREATE TABLE Accounts1(
	Id INT PRIMARY KEY,
	AccountHolderId INT NOT NULL
		CONSTRAINT FK_Accounts1_AccountHolders REFERENCES AccountHolders(Id),
	Balance MONEY)


CREATE PROCEDURE
	usp_GetHoldersFullName
AS
BEGIN
	SELECT
		ah.FirstName + ' ' + ah.LastName AS 'Full Name'
	FROM
		AccountHolders ah
END

-- 10 ----------------------------------------------------------
---------------------------------------------------------------

CREATE PROC usp_GetHoldersWithBalanceHigherThan @balance MONEY
AS
SELECT FirstName, LastName FROM AccountHolders
JOIN Accounts ON Accounts.AccountHolderId = AccountHolders.Id
GROUP BY FirstName, LastName
HAVING SUM(Balance) > @balance

-- 11 ----------------------------------------------------------
---------------------------------------------------------------
CREATE FUNCTION ufn_CalculateFutureValue(@I MONEY, @R FLOAT, @T INT)
RETURNS MONEY
AS
BEGIN
	DECLARE @FutureValue MONEY;
	SET @FutureValue = @I * POWER((1+@R),@T)
	RETURN @FutureValue
END

-- 12 ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROC usp_CalculateFutureValueForAccount @AccountId INT, @InterestRate FLOAT
AS
BEGIN
	SELECT 
		a.Id AS 'Account Id',
		ah.FirstName AS 'First Name',
		ah.LastName AS 'Last Name',
		a.Balance AS 'Current Balance',
		dbo.ufn_CalculateFutureValue(a.Balance, @InterestRate, 5) AS 'Balance in 5 years'
	FROM AccountHolders AS ah
	JOIN Accounts AS a
		ON a.AccountHolderId = ah.Id
		WHERE a.Id = @AccountId
END

-- 13 ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROCEDURE usp_DepositMoney @AccountId INT, @moneyAmount MONEY
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Accounts 
		SET Balance += @moneyAmount
		WHERE Id = @AccountId	
	COMMIT TRANSACTION	
END

-- 14 ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROCEDURE usp_WithdrawMoney @AccountId INT, @moneyAmount MONEY
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Accounts 
		SET Balance -= @moneyAmount
		WHERE Id = @AccountId	
	COMMIT TRANSACTION	
END

-- 15 m gulubov  ----------------------------------------------------------
---------------------------------------------------------------
CREATE PROCEDURE
	usp_TransferMoney
		@FromAccountId INT,
		@ToAccountId INT,
		@TransferAmount MONEY
AS
BEGIN

BEGIN TRY

	BEGIN TRANSACTION MainTransaction

		BEGIN
			IF @TransferAmount <= 0
				THROW 50001, 'Money amount cant be less than or equal to 0', 0
	
			IF @TransferAmount IS NULL
				THROW 50002, 'Money amount cant be NULL', 0
		END

		BEGIN
			IF NOT EXISTS(SELECT * FROM Accounts WHERE Id = @FromAccountId)
				THROW 50003, 'Invalid Account ID in FromAccountId', 0

			IF NOT EXISTS(SELECT * FROM Accounts WHERE Id = @ToAccountId)
				THROW 50004, 'Invalid Account ID in ToAccountId', 0
		END

		BEGIN
			IF (SELECT Balance FROM Accounts WHERE Id = @FromAccountId) < @TransferAmount
				THROW 50005, 'Invalid Tranasfer amount: Insufficient funds in FromAccount', 0
		END

		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION DeductMoneyTransaction
					BEGIN
						UPDATE
							Accounts
						SET
							Balance = Balance - @TransferAmount
						WHERE
							Id = @FromAccountId
					END
				COMMIT TRANSACTION DeductMoneyTransaction
			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE()
				ROLLBACK TRANSACTION DeductMoneyTransaction
			END CATCH
		END

		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION AddMoneyTransaction
					BEGIN
						UPDATE
							Accounts
						SET
							Balance = Balance + @TransferAmount
						WHERE
							Id = @ToAccountId
					END
				COMMIT TRANSACTION AddMoneyTransaction
			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE()
				ROLLBACK TRANSACTION AddMoneyTransaction
			END CATCH
		END

	COMMIT TRANSACTION MainTransaction

END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION MainTransaction
END CATCH

END
GO

-- 16  ----------------------------------------------------------
---------------------------------------------------------------
-- Create table
CREATE TABLE
	Logs(
		LogId INT IDENTITY NOT NULL
			CONSTRAINT PK_Logs_LogId PRIMARY KEY,
		AccountId INT NOT NULL
			CONSTRAINT FK_Logs_AccountId_Accounts_Id FOREIGN KEY REFERENCES Accounts(Id),
		OldSum MONEY NOT NULL,
		NewSum MONEY NOT NULL
	)
GO

-- Create trigger
CREATE TRIGGER
	LogAccountBalanceChangeTrigger
ON
	Accounts
AFTER UPDATE
AS
BEGIN

	IF UPDATE(Balance)
		BEGIN
			DECLARE @AccountId INT
			DECLARE @NewSum MONEY
			DECLARE @OldSum MONEY

			SELECT
				@AccountId = ins.Id,
				@NewSum = ins.Balance,
				@OldSum = del.Balance
			FROM
				INSERTED ins,
				DELETED del

			INSERT INTO
				Logs
			VALUES
				(@AccountId, @OldSum, @NewSum)
		END
END

-- 17 ----------------------------------------------------------
---------------------------------------------------------------
-- Create tables
CREATE TABLE
	Logs(
		LogId INT IDENTITY NOT NULL
			CONSTRAINT PK_Logs_LogId PRIMARY KEY,
		AccountId INT NOT NULL
			CONSTRAINT FK_Logs_AccountId_Accounts_Id FOREIGN KEY REFERENCES Accounts(Id),
		OldSum MONEY NOT NULL,
		NewSum MONEY NOT NULL
	)

CREATE TABLE
	NotificationEmails(
		Id INT IDENTITY NOT NULL
			CONSTRAINT PK_NotificationEmails_Id PRIMARY KEY,
		Recipient INT NOT NULL
			CONSTRAINT FK_NotificationEmails_Recepient_Accounts_Id FOREIGN KEY REFERENCES Accounts(Id),
		Subject NVARCHAR(500),
		Body NVARCHAR(MAX)
	)
GO
-------------
-------------
-- Create triggers
CREATE TRIGGER
	LogAccountBalanceChangeTrigger
ON
	Accounts
AFTER UPDATE
AS
BEGIN

	IF UPDATE(Balance)
		BEGIN
			DECLARE @AccountId INT
			DECLARE @NewSum MONEY
			DECLARE @OldSum MONEY

			SELECT
				@AccountId = ins.Id,
				@NewSum = ins.Balance,
				@OldSum = del.Balance
			FROM
				INSERTED ins,
				DELETED del

			INSERT INTO
				Logs
			VALUES
				(@AccountId, @OldSum, @NewSum)
		END
END
GO

CREATE TRIGGER
	AddEmailOnAccountBalanceLog
ON
	Logs
AFTER INSERT
AS
BEGIN

	DECLARE @RecepientId INT
	DECLARE @Curdate DATETIME
	DECLARE @OldSum MONEY
	DECLARE @NewSum MONEY

	DECLARE @Subject NVARCHAR(150)
	DECLARE @Body NVARCHAR(MAX)

	BEGIN
		SELECT
			@RecepientId = ins.AccountId,
			@Curdate = GETDATE(),
			@OldSum = ins.OldSum,
			@NewSum = ins.NewSum
		FROM
			INSERTED ins
	END

	BEGIN
		SET @Subject = (
			SELECT
				CONCAT('Balance change for account: ', @RecepientId)
		)

		SET @Body = (
			SELECT
				CONCAT(
						'On ', 
						CONVERT(NVARCHAR, @Curdate, 100),
						' your balance was changed from ',
						@OldSum,
						' to ',
						@NewSum, '.')
		)
	END

	BEGIN
		INSERT INTO
			NotificationEmails
		VALUES
			(
				@RecepientId, 
				@Subject,
				@Body
			)
	END
END
GO

-- 18 ----------------------------------------------------------
---------------------------------------------------------------
CREATE FUNCTION	ufn_CashInUsersGames(@GameName NVARCHAR(250))
RETURNS @Result TABLE(CashSum MONEY)
AS
BEGIN

	DECLARE @GamesWithRowNums TABLE(Cash MONEY,	RowNum INT)

	INSERT INTO	@GamesWithRowNums
	SELECT
		ug.Cash,
		ROW_NUMBER() OVER(ORDER BY ug.Cash DESC) AS RowNum 
	FROM
		UsersGames ug
		JOIN Games g ON g.Id = ug.GameId
	WHERE g.Name = @GameName

	INSERT INTO	@Result
	SELECT	SUM(grn.Cash)
	FROM	@GamesWithRowNums grn
	WHERE	grn.RowNum % 2 = 1

	RETURN

END

-- 19 ----------------------------------------------------------
---------------------------------------------------------------
create trigger tr_UserGameItems on UserGameItems
instead of insert
as
	insert into UserGameItems
	select ItemId, UserGameId from inserted
	where 
		ItemId in (
			select Id 
			from Items 
			where MinLevel <= (
				select [Level]
				from UsersGames 
				where Id = UserGameId
			)
		)
go

-- Add bonus cash for users

update UsersGames
set Cash = Cash + 50000 + (SELECT SUM(i.Price) FROM Items i JOIN UserGameItems ugi ON ugi.ItemId = i.Id WHERE ugi.UserGameId = UsersGames.Id)
where UserId in (
	select Id 
	from Users 
	where Username in ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
)
and GameId = (select Id from Games where Name = 'Bali')

-- Buy items for users

insert into UserGameItems (UserGameId, ItemId)
select  UsersGames.Id, i.Id 
from UsersGames, Items i
where UserId in (
	select Id 
	from Users 
	where Username in ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
) and GameId = (select Id from Games where Name = 'Bali' ) and ((i.Id > 250 and i.Id < 300) or (i.Id > 500 and i.Id < 540))


-- Get cash from users
update UsersGames
set Cash = Cash - (SELECT SUM(i.Price) FROM Items i JOIN UserGameItems ugi ON ugi.ItemId = i.Id WHERE ugi.UserGameId = UsersGames.Id)
where UserId in (
	select Id 
	from Users 
	where Username in ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
)
and GameId = (select Id from Games where Name = 'Bali')


select u.Username, g.Name, ug.Cash, i.Name [Item Name] from UsersGames ug
join Games g on ug.GameId = g.Id
join Users u on ug.UserId = u.Id
join UserGameItems ugi on ugi.UserGameId = ug.Id
join Items i on i.Id = ugi.ItemId
where g.Name = 'Bali'
order by Username, [Item Name]
-- 20 ----------------------------------------------------------
---------------------------------------------------------------
BEGIN TRANSACTION [Tran1]

DECLARE @UserGameId1 INT = (SELECT Id FROM UsersGames 
			WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat') AND 
				  GameId = (SELECT Id FROM Games WHERE Name = 'Safflower'))

BEGIN TRY

INSERT UserGameItems(ItemId, UserGameId)

-- selecting the id of all items with minlevel between 11 and 12

SELECT Id, (@UserGameId1) FROM Items 
WHERE MinLevel BETWEEN 11 AND 12

UPDATE UsersGames
SET Cash -= (SELECT SUM(i.Price) FROM Items AS i WHERE i.MinLevel BETWEEN 11 AND 12)
where Id = @UserGameId1

COMMIT TRANSACTION [Tran1]

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [Tran1]
END CATCH


-- TRANSACTION 2 ---

BEGIN TRANSACTION [Tran2]

DECLARE @UserGameId INT = (SELECT Id FROM UsersGames 
			WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Stamat') AND 
				  GameId = (SELECT Id FROM Games WHERE Name = 'Safflower'))

BEGIN TRY

INSERT UserGameItems(ItemId, UserGameId)

-- selecting the id of all items with minlevel between 11 and 12

SELECT Id, (@UserGameId) FROM Items 
WHERE MinLevel BETWEEN 11 AND 12

UPDATE UsersGames
SET Cash -= (SELECT SUM(i.Price) FROM Items AS i WHERE i.MinLevel BETWEEN 19 AND 21)
where Id = @UserGameId

COMMIT TRANSACTION [Tran2]

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [Tran2]
END CATCH


select i.Name AS [Item Name]
from Items AS i
	join UserGameItems AS ugi on ugi.ItemId = i.Id
	join UsersGames AS ug ON ug.Id = ugi.UserGameId
	JOIN Games AS g	ON ug.GameId = g.Id AND g.Name = 'Safflower'
ORDER BY I.Name

-- 21 ----------------------------------------------------------
---------------------------------------------------------------
;WITH UsersEmailProviders AS
(SELECT 
	u.Id,
	RIGHT(u.Email, LEN(u.Email) - CHARINDEX('@', U.Email)) as [EmailProvider]
FROM Users AS u)

SELECT 
	usp.EmailProvider AS [Email Provider],
	COUNT(*) AS [Number Of Users] 
FROM UsersEmailProviders AS usp
GROUP BY usp.EmailProvider
ORDER BY [Number Of Users] DESC, [Email Provider] ASC

-- 22 ----------------------------------------------------------
---------------------------------------------------------------

SELECT 
	g.Name AS Game,
	gt.Name AS [Game Type],
	u.Username,
	ug.Level,
	ug.Cash,
	c.Name AS [Character]
FROM Games AS g
JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
JOIN UsersGames AS ug ON ug.GameId = g.Id
JOIN Users AS u ON u.Id = ug.UserId
JOIN Characters AS c ON c.Id = ug.CharacterId
ORDER BY UG.Level DESC, U.Username ASC, Game

-- 23 ----------------------------------------------------------
---------------------------------------------------------------

SELECT 
	u.Username,	
	g.Name AS [Game],
	COUNT(i.Id) AS [Items Count],
	SUM(i.Price) AS [Items Price]
FROM Games AS g
JOIN UsersGames AS ug ON ug.GameId = g.Id
JOIN Users AS u ON u.Id = ug.UserId
JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
JOIN Items AS i ON i.Id = ugi.ItemId
GROUP BY u.Username, g.Name
HAVING COUNT(i.Id) > = 10
ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username ASC

-- 24 ----------------------------------------------------------
---------------------------------------------------------------
Select 
	u.Username,
	g.Name AS [Game],
	Max(c.Name) As [Character],
	SUM(itemStat.Strength) + MAX(gameStat.Strength) + MAX(characterStat.Strength) AS Strength,
    SUM(itemStat.Defence) + MAX(gameStat.Defence) + MAX(characterStat.Defence) AS Defence,
    SUM(itemStat.Speed) + MAX(gameStat.Speed) + MAX(characterStat.Speed) AS Speed,
    SUM(itemStat.Mind) + MAX(gameStat.Mind) + MAX(characterStat.Mind) AS Mind,
    SUM(itemStat.Luck) + MAX(gameStat.Luck) + MAX(characterStat.Luck) AS Luck
FROM Users AS u
	JOIN UsersGames AS ug ON u.Id = ug.UserId
	JOIN Games AS g ON g.Id = ug.GameId
	JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
	JOIN Characters AS c ON c.Id = ug.CharacterId
	JOIN [Statistics] AS characterStat ON characterStat.Id = c.StatisticId
	JOIN [Statistics] AS gameStat ON gameStat.Id = gt.BonusStatsId
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
	JOIN [Statistics] AS itemStat ON itemStat.Id = i.StatisticId
GROUP BY u.Username, g.Name
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

-- 25 ----------------------------------------------------------
---------------------------------------------------------------
SELECT 
	i.Name,
	i.Price,
	i.MinLevel,
	s.Strength,
	s.Defence,
	s.Speed,
	s.Luck,
	s.Mind 
FROM Items AS i
JOIN [Statistics] AS s
	ON i.StatisticId = s.Id
WHERE 
	s.Mind > (SELECT AVG(s.Mind) FROM [Statistics] AS s) AND
	s.Luck > (SELECT AVG(s.Luck) FROM [Statistics] AS s) AND
	s.Speed > (SELECT AVG(s.Speed) FROM [Statistics] AS s)

-- 26 ----------------------------------------------------------
---------------------------------------------------------------
SELECT 
	i.Name AS [Item],
	i.Price,
	i.MinLevel,
	gt.Name as [Forbidden Game Type]
FROM Items AS i
	LEFT JOIN GameTypeForbiddenItems AS forbidden ON forbidden.ItemId = i.Id
	LEFT JOIN GameTypes AS gt ON gt.Id = forbidden.GameTypeId
ORDER BY gt.Name DESC, i.Name

-- 27 ----------------------------------------------------------
---------------------------------------------------------------
DECLARE @UG_ID INT
SET @UG_ID = (Select ug.Id 
			FROM UsersGames AS ug
			JOIN Users AS u ON u.Id = ug.UserId
			JOIN Games As g ON g.Id = ug.GameId
		where u.Username = 'Alex' AND g.Name = 'Edinburgh')

INSERT INTO UserGameItems(ItemId, UserGameId)
VALUES((Select i.Id FROM Items as i WHERE I.Name = 'Blackguard'),@UG_ID)

update UsersGames
set Cash = Cash - (Select i.Price FROM Items as i WHERE I.Name = 'Blackguard')
WHERE Id = @UG_ID

INSERT INTO UserGameItems(ItemId, UserGameId)
VALUES((Select i.Id FROM Items as i WHERE I.Name = 'Bottomless Potion of Amplification'),@UG_ID)

update UsersGames
set Cash = Cash - (Select i.Price FROM Items as i WHERE I.Name = 'Bottomless Potion of Amplification')
WHERE Id = @UG_ID

INSERT INTO UserGameItems(ItemId, UserGameId)
VALUES((Select i.Id FROM Items as i WHERE I.Name = 'Eye of Etlich (Diablo III)'),@UG_ID)

update UsersGames
set Cash = Cash - (Select i.Price FROM Items as i WHERE I.Name = 'Eye of Etlich (Diablo III)')
WHERE Id = @UG_ID

INSERT INTO UserGameItems(ItemId, UserGameId)
VALUES((Select i.Id FROM Items as i WHERE I.Name = 'Gem of Efficacious Toxin'),@UG_ID)

update UsersGames
set Cash = Cash - (Select i.Price FROM Items as i WHERE I.Name = 'Gem of Efficacious Toxin')
WHERE Id = @UG_ID

INSERT INTO UserGameItems(ItemId, UserGameId)
VALUES((Select i.Id FROM Items as i WHERE I.Name = 'Golden Gorget of Leoric'),@UG_ID)

update UsersGames
set Cash = Cash - (Select i.Price FROM Items as i WHERE I.Name = 'Golden Gorget of Leoric')
WHERE Id = @UG_ID

INSERT INTO UserGameItems(ItemId, UserGameId)
VALUES((Select i.Id FROM Items as i WHERE I.Name = 'Hellfire Amulet'),@UG_ID)

update UsersGames
set Cash = Cash - (Select i.Price FROM Items as i WHERE I.Name = 'Hellfire Amulet')
WHERE Id = @UG_ID

SELECT 
	u.Username,
	g.Name,
	ug.Cash,
	i.Name AS[Item Name]
FROM Users AS u
	JOIN UsersGames AS ug ON ug.UserId = u.Id
	JOIN Games AS g ON g.Id = ug.GameId 
	JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
	JOIN Items AS i ON i.Id = ugi.ItemId
WHERE g.Name = 'Edinburgh'
ORDER BY i.Name

-- 28 ----------------------------------------------------------
---------------------------------------------------------------
SELECT 
	P.PeakName,
	M.MountainRange AS [Mountain],
	p.Elevation
FROM Mountains AS m
JOIN Peaks AS p ON p.MountainId = m.Id
order by p.Elevation desc, p.PeakName asc

-- 29 ----------------------------------------------------------
---------------------------------------------------------------
SELECT 
	P.PeakName,
	M.MountainRange AS [Mountain],
	c.CountryName,
	cont.ContinentName

FROM Mountains AS m
JOIN Peaks AS p ON p.MountainId = m.Id
JOIN MountainsCountries AS mc ON mc.MountainId = m.Id
JOIN Countries AS c ON c.CountryCode = mc.CountryCode
JOIN Continents AS cont ON cont.ContinentCode = c.ContinentCode
GROUP BY p.PeakName, M.MountainRange, c.CountryName, CONT.ContinentName
order by p.PeakName ASC, c.CountryName ASC

-- 30  ----------------------------------------------------------
---------------------------------------------------------------
SELECT 
	c.CountryName,
	cont.ContinentName,
	ISNULL(COUNT(r.Id), 0) AS [RiversCount],
	ISNULL(SUM(r.Length), 0) AS [TotalLength]
FROM Countries AS c 
LEFT JOIN Continents AS cont ON cont.ContinentCode = c.ContinentCode
LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY c.CountryName, cont.ContinentName
ORDER BY RiversCount DESC, TotalLength DESC, c.CountryName ASC

-- 31 ----------------------------------------------------------
---------------------------------------------------------------
SELECT 
	cur.CurrencyCode, 
	cur.Description AS [Currency], 
	COUNT(c.CountryCode) AS [NumberOfCountries]
FROM Currencies AS cur
LEFT JOIN Countries AS c ON c.CurrencyCode = cur.CurrencyCode
GROUP BY cur.CurrencyCode, cur.Description
ORDER BY NumberOfCountries DESC, CUR.Description ASC

-- 32 ----------------------------------------------------------
---------------------------------------------------------------

SELECT 
	cont.ContinentName,
	SUM(CAST(c.AreaInSqKm AS DECIMAL)) AS [CountriesArea],
	SUM(CAST(c.Population AS DECIMAL)) AS [CountriesPopulation]
FROM Continents AS cont
JOIN Countries AS c ON c.ContinentCode = cont.ContinentCode
GROUP BY cont.ContinentName
ORDER BY CountriesPopulation desc

-- 33 ----------------------------------------------------------
---------------------------------------------------------------
CREATE TABLE Monasteries(
	Id INT IDENTITY PRIMARY KEY,
	Name nvarchar(50),
	CountryCode char(2)
		CONSTRAINT FK_Monasteries_Countries
		FOREIGN KEY (CountryCode) REFERENCES Countries(CountryCode))

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')

--ALTER TABLE Countries
--ADD IsDeleted BIT NOT NULL DEFAULT 0

UPDATE Countries
SET IsDeleted = 1
WHERE CountryCode IN
(SELECT	
	c.CountryCode
FROM Countries AS c
JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
GROUP BY c.CountryCode
HAVING COUNT(r.Id) > 3) 

SELECT 
	m.Name AS [Monastery],
	c.CountryName as [Country]
FROM Monasteries as m
JOIN Countries AS c ON c.CountryCode = m.CountryCode
where c.IsDeleted  <> 1
ORDER BY Monastery ASC

-- 34 ----------------------------------------------------------
---------------------------------------------------------------
UPDATE Countries
SET CountryName = 'Burma'
WHERE CountryName = 'Myanmar'

INSERT INTO Monasteries(Name, CountryCode)
VALUES 
('Hanga Abbey', (SELECT CountryCode FROM Countries WHERE CountryName = 'Tanzania')),
('Myin-Tin-Daik', (SELECT CountryCode FROM Countries WHERE CountryName = 'Myanmar'))

select 
	cont.ContinentName,
	c.CountryName,
	COUNT(m.Id) as [MonasteriesCount]
from Monasteries As m
RIGHT JOIN Countries AS c ON m.CountryCode = c.CountryCode
RIGHT JOIN Continents AS cont ON c.ContinentCode = cont.ContinentCode and c.IsDeleted = 0
GROUP BY cont.ContinentName, c.CountryName
ORDER BY MonasteriesCount dESC, c.CountryName
