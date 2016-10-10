-- 1
SELECT E.FirstName, e.LastName 
FROM
Employees AS e
WHERE e.FirstName LIKE 'SA%'

-- 2
SELECT E.FirstName, e.LastName 
FROM
Employees AS e
WHERE e.LastName LIKE '%ei%'

-- 3
SELECT E.FirstName
FROM
Employees AS e
WHERE e.DepartmentID IN (3, 10)
	AND YEAR(e.HireDate) >= 1995 AND YEAR(e.HireDate) <= 2005 

-- 4
SELECT E.FirstName, e.LastName
FROM
Employees AS e
WHERE e.JobTitle NOT LIKE '%engineer%'

-- 5
SELECT t.Name
FROM Towns As t
where LEN(t.Name) = 5 or LEN(t.Name) = 6
order by t.Name

-- 6
SELECT t.TownID, t.Name
FROM Towns As t
where t.Name LIKE '[MKBE]%'
order by t.Name

-- 7
SELECT t.TownID, t.Name
FROM Towns As t
where t.Name not LIKE '[RBD]%'
order by t.Name

-- 8
CREATE VIEW V_EmployeesHiredAfter2000 as
SELECT e.FirstName, e.LastName
FROM Employees AS e
where YEAR(e.HireDate) > 2000

-- 9
SELECT e.FirstName, e.LastName
FROM Employees AS e
where LEN(E.LastName) = 5

-- 10
SELECT c.CountryName, c.IsoCode AS [ISO Code]
FROM Countries AS c
WHERE c.CountryName LIKE '%a%a%a%'
order by IsoCode

-- 11
SELECT 
	p.PeakName,
	r.RiverName,
	LOWER (SUBSTRING(p.PeakName, 1, LEN(p.PeakName)-1) + r.RiverName) AS Mix
FROM Peaks AS p,
	 Rivers AS r
WHERE RIGHT(p.PeakName, 1) = LEFT(r.RiverName, 1)
ORDER BY Mix ASC

-- 12
SELECT TOP 50
		g.Name AS Game,
		FORMAT(g.Start, 'yyy-MM-dd')
	FROM Games AS g
	WHERE YEAR(g.Start) IN (2011, 2012)
	ORDER BY
		g.Start ASC,
		g.Name ASC

-- 13
SELECT
	u.Username,
	RIGHT(u.Email, LEN(u.Email) - CHARINDEX('@', u.email)) AS [Email Provider]
FROM Users AS u
ORDER BY [Email Provider] ASC, u.Username ASC

-- 14
SELECT
	u.Username,
	u.IpAddress AS [IP Address]
FROM Users AS u
WHERE u.IpAddress LIKE ('___.1_%._%.___')
ORDER BY u.Username ASC

-- 15
select 
	g.Name as [Game],
	case 
		WHEN DATEPART(HOUR, g.Start) >=0 and DATEPART(HOUR, g.Start) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, g.Start) >= 12 AND DATEPART(HOUR, g.Start) < 18 THEN 'Afternoon'
		ELSE 'Evening'
	END AS [Part of the Day],
	case 
		when g.Duration <= 3 THEN 'Extra Short'
		when g.Duration > 3 AND g.Duration <= 6 THEN 'Short'
		when g.Duration > 6 THEN 'Long'
		when g.Duration IS NULL THEN 'Extra Long'
		END AS [Duration]
from Games as g
order by g.Name asc, Duration, [Part of the Day]

-- 16
SELECT
	o.ProductName,
	o.OrderDate,
	DATEADD(DAY, 3, o.OrderDate) AS 'Pay Due',
	DATEADD(MONTH, 1, o.OrderDate) AS 'Deliver Due'
FROM
	Orders o

-- 17
DECLARE @CurrentTime DATETIME = GETDATE()
	

	SELECT
		p.Name,
		DATEDIFF(YEAR, p.Birthdate, @CurrentTime) AS 'Age in Years',
		DATEDIFF(MONTH, p.Birthdate, @CurrentTime) AS 'Age in Months',
		DATEDIFF(DAY, p.Birthdate, @CurrentTime) AS 'Age in Days',
		DATEDIFF(MINUTE, p.Birthdate, @CurrentTime) AS 'Age in Minutes'
	FROM
		People p

