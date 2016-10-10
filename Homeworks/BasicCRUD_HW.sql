-- 2
SELECT * 
FROM Departments

-- 3
SELECT d.Name
FROM Departments as d

-- 4
SELECT e.FirstName, e.LastName, e.Salary
FROM Employees as e

-- 5
SELECT e.FirstName, e.MiddleName, e.LastName
FROM Employees as e

-- 6
SELECT CONCAT(e.FirstName, '.', e.LastName, '@softuni.bg') AS [Full Email Address]
FROM Employees as e

-- 7
SELECT distinct e.Salary
FROM Employees as e

-- 8
SELECT *
FROM Employees as e
WHERE e.JobTitle = 'Sales Representative'

-- 9
SELECT e.FirstName, e.LastName, e.JobTitle
FROM Employees as e
WHERE e.Salary >= 20000 AND e.Salary <= 30000

-- 10
SELECT FirstName + ' ' + MiddleName + ' ' + LastName FROM Employees
WHERE Salary IN(25000, 14000, 12500, 23600)

-- 11
SELECT e.FirstName, e.LastName
FROM Employees as e
WHERE e.ManagerID IS NULL

-- 12
SELECT e.FirstName, e.LastName, e.Salary
FROM Employees AS e
WHERE e.Salary > 50000
ORDER BY E.Salary DESC

-- 13
SELECT TOP 5 
	e.FirstName, e.LastName
FROM Employees AS e
ORDER BY E.Salary DESC

-- 14
SELECT e.FirstName, e.LastName
FROM Employees AS e
WHERE E.DepartmentID <> 4

-- 15
SELECT *
FROM Employees AS e
ORDER BY e.Salary DESC,
		e.FirstName,
		e.LastName DESC,
		e.MiddleName

-- 16
CREATE VIEW V_EmployeesSalaries AS
SELECT e.FirstName, e.LastName, e.Salary
FROM Employees AS e

-- 17
CREATE VIEW V_EmployeeNameJobTitle AS
SELECT CONCAT(FirstName,' ',ISNULL (MiddleName, ''),' ', LastName) AS 'Full Name',
JobTitle AS 'Job Title'
FROM Employees

-- 18
SELECT 
	DISTINCT e.JobTitle 
FROM Employees AS e

--19
SELECT TOP 10 * 
FROM Projects AS e
ORDER BY e.StartDate, e.Name

-- 20
SELECT TOP 7 e.FirstName, e.LastName, e.HireDate 
FROM Employees AS e
ORDER BY e.HireDate DESC

-- 21
UPDATE [Employees]
   SET [Salary] *= 1.12
 WHERE [DepartmentId] IN 
	(SELECT [DepartmentId] 
	   FROM [Departments]
	  WHERE [Name] IN 
		('Engineering', 'Tool Design', 'Marketing', 'Information Services'))
						
SELECT [Salary] 
  FROM [Employees]

-- 22
select p.PeakName
from Peaks As p
order by p.PeakName

-- 23
select top 30
c.CountryName, c.Population
from Countries As c
where c.ContinentCode = 'EU'
order by c.Population DESC, c.CountryName

-- 24
SELECT 
	country.CountryName, country.CountryCode,
	CASE 
		WHEN currency.CurrencyCode = 'EUR' THEN 'Euro'
		ELSE 'Not Euro'
		END AS [Currency]
FROM Countries AS country
LEFT JOIN Currencies AS currency
 ON country.CurrencyCode = currency.CurrencyCode
ORDER BY CountryName

-- 25
select distinct c.Name
from Characters AS c