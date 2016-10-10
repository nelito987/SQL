-- 1
use TableRelationsHW

CREATE TABLE
	Passports(
		PassportID INT NOT NULL
			CONSTRAINT PK_Passports_PassportID PRIMARY KEY,
		PassportNumber NVARCHAR(200) NOT NULL
	)

CREATE TABLE
	Persons(
		PersonID INT NOT NULL
			CONSTRAINT PK_Persons_PersonID PRIMARY KEY,
		FirstName NVARCHAR(150) NOT NULL,
		Salary MONEY NOT NULL,
		PassportID INT UNIQUE FOREIGN KEY REFERENCES Passports(PassportID)
	)

	INSERT INTO
	Passports
VALUES
	(101, 'N34FG21B'),
	(102, 'K65LO4R7'),
	(103, 'ZE657QP2')
---------------------
INSERT INTO
	Persons
VALUES
	(1, 'Roberto', 43300.00, 102),
	(2, 'Tom', 56100.00, 103),
	(3, 'Yana',	60200.00, 101)

-- 2
CREATE TABLE Manufacturers
(
	ManufacturerID INT IDENTITY PRIMARY KEY,
	Name NVARCHAR(50),
	EstablishedOn DATE
)


CREATE TABLE Models
(
	ModelId INT IDENTITY(101, 1) PRIMARY KEY,
	Name NVARCHAR(50),
	ManufacturerID INT
	CONSTRAINT FK_Models_Manufacturers FOREIGN KEY(ManufacturerID) REFERENCES Manufacturers(ManufacturerID)
)


INSERT INTO Manufacturers(Name, EstablishedOn)
VALUES
('BMW', '07-03-1916'),
('Tesla', '01-01-2003'),
('Lada', '01-05-1966')


INSERT INTO Models (Name, ManufacturerID)
VALUES
('X1', 1),
('i6', 1),
('Model S', 2),
('Model X', 2),
('Model 3', 2),
('Nova', 3)


SELECT * FROM Manufacturers
SELECT ma.Name AS Manufacturer, mo.Name FROM Models as mo
JOIN Manufacturers ma ON
mo.ManufacturerID = ma.ManufacturerID

-- 3
CREATE TABLE
    Students(
        StudentID INT NOT NULL
            CONSTRAINT PK_Students_StudentID PRIMARY KEY,
        Name NVARCHAR(300) NOT NULL
    )
CREATE TABLE
	Exams(
		ExamID INT NOT NULL
			CONSTRAINT PK_Exams_ExamID PRIMARY KEY,
		Name NVARCHAR(300) NOT NULL	
	)
CREATE TABLE
	StudentsExams(
		StudentID INT NOT NULL
			CONSTRAINT FK_StudentsExams_StudentID_Students_StudentID REFERENCES Students(StudentID),
		ExamID INT NOT NULL
			CONSTRAINT FK_StudentsExams_ExamID_Exams_ExamID REFERENCES Exams(ExamID),

		CONSTRAINT PK_StudentsExams_StudentID_ExamID PRIMARY KEY (StudentID, ExamID)
	)
INSERT INTO
	Students
VALUES
	(1, 'Mila'),
	(2, 'Toni'),
	(3, 'Roni')
INSERT INTO
	Exams
VALUES
	(101, 'Spring MVC'),
	(102, 'Neoj'),
	(103, 'Oracle 11g')
INSERT INTO
	StudentsExams
VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103)

-- 4
CREATE TABLE
	Teachers(
		TeacherID INT NOT NULL
			CONSTRAINT PK_Teachers_TeacherID PRIMARY KEY,
		Name NVARCHAR(300) NOT NULL,
		ManagerID INT
			CONSTRAINT FK_Teachers_ManagerID_Teachers_TeacherID REFERENCES Teachers(TeacherID)
	)
INSERT INTO
	Teachers
VALUES
	(101, 'John', NULL),
	(102, 'Maya', 106),
	(103, 'Silvia', 106),
	(104, 'Ted', 105),
	(105, 'Mark', 101),
	(106, 'Greta', 101)

-- 5
CREATE TABLE Orders
(
	OrderID INT PRIMARY KEY,
	CustomerID INT,
)

CREATE TABLE Customers
(
	CustomerID INT PRIMARY KEY,
	Name VARCHAR(50),
	Birthday DATE,
	CityID INT
)

CREATE TABLE Cities
(
	CityID INT PRIMARY KEY,
	Name VARCHAR(50),
)

CREATE TABLE OrderItems
(
	OrderID INT,
	ItemID INT,
	CONSTRAINT PK_OrderItems PRIMARY KEY (OrderID, ItemID)
)

CREATE TABLE Items
(
	ItemID INT PRIMARY KEY,
	Name VARCHAR(50),
	ItemTypeID INT
)

CREATE TABLE ItemTypes
(
	ItemTypeID INT PRIMARY KEY,
	Name NVARCHAR(50)
)

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)

ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_Cities FOREIGN KEY (CityID) REFERENCES Cities(CityID)

ALTER TABLE OrderItems
ADD CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
CONSTRAINT FK_OrderItems_Items FOREIGN KEY (ItemID) REFERENCES Items(ItemID)

ALTER TABLE Items
ADD CONSTRAINT FK_Items_ItemTypes FOREIGN KEY (ItemTypeID) REFERENCES ItemTypes(ItemTypeID)

-- 6

CREATE TABLE Majors
(
	MajorID INT PRIMARY KEY,
	Name VARCHAR(50)
)

CREATE TABLE Students
(
	StudentID INT PRIMARY KEY,
	StudentNumber VARCHAR(12),
	StudentName VARCHAR(50),
	MajorID INT,
	CONSTRAINT FK_Students_Majors FOREIGN KEY(MajorID) REFERENCES Majors(MajorID)
)

CREATE TABLE Payments
(
	PaymentID INT PRIMARY KEY,
	PaymentDate DATE,
	PaymentAmount DECIMAL(8,2),
	StudentID INT
	CONSTRAINT FK_Payments_Students FOREIGN KEY (PaymentID) REFERENCES Students(StudentID)
)

CREATE TABLE Subjects
(
	SubjectID INT PRIMARY KEY,
	SubjectName VARCHAR(50)
)

CREATE TABLE Agenda
(
	StudentID INT,
	SubjectID INT
	CONSTRAINT PK_Agenda PRIMARY KEY (StudentID, SubjectID),
	CONSTRAINT FK_Agenda_Subjects FOREIGN KEY (StudentID) REFERENCES Subjects(SubjectID),
	CONSTRAINT FK_Agenda_Students FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
)

-- 9
SELECT top 5
	e.EmployeeID,
	e.JobTitle,
	e.AddressID,
	a.AddressText
FROM Employees as e
JOIN Addresses as a
	on e.AddressID = a.AddressID
order by e.AddressID

-- 10
SELECT top 5
	e.EmployeeID,
	e.FirstName,
	e.Salary,
	d.Name as [DepartmentName]
FROM Employees as e
JOIN Departments as d
	on e.DepartmentID = d.DepartmentID
where e.Salary > 15000
order by d.DepartmentID

-- 11
SELECT top 3
	e.EmployeeID,
	e.FirstName
FROM Employees as e
left JOIN EmployeesProjects as project
	on project.EmployeeID = e.EmployeeID
where project.ProjectID IS NULL
order by e.EmployeeID

-- 12
SELECT top 5
	e.EmployeeID,
	e.FirstName,
	p.Name
FROM Employees as e
JOIN EmployeesProjects as project
	on project.EmployeeID = e.EmployeeID
join Projects as p
	on p.ProjectID = project.ProjectID
where p.StartDate > CONVERT(smalldatetime, '13/08/2002', 104) AND p.EndDate is null
order by e.EmployeeID

-- 13
SELECT 
	e.EmployeeID,
	e.FirstName,
	case
		when year(p.StartDate) >= 2005 then NULL
		else p.Name
	end as [ProjectName]
FROM Employees as e
JOIN EmployeesProjects as project
	on project.EmployeeID = e.EmployeeID
join Projects as p
	on p.ProjectID = project.ProjectID
WHERE e.EmployeeID = 24

-- 14
SELECT 
	e.EmployeeID,
	e.FirstName,
	e.ManagerID,
	m.FirstName as [ManagerName]
FROM Employees as e
join Employees as m
	ON e.ManagerID = m.EmployeeID
where e.ManagerID in (3,7)
order by e.EmployeeID

-- 15
SELECT 
	mc.CountryCode,
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM MountainsCountries AS mc
join Mountains AS m ON mc.MountainId = m.Id
join Peaks as p ON m.Id = p.MountainId
where mc.CountryCode = 'BG' and p.Elevation > 2835
order by p.Elevation DESC

-- 16
SELECT 
	mc.CountryCode,
	COUNT(m.MountainRange) AS [MountainRanges]
FROM MountainsCountries AS mc
join Mountains AS m ON mc.MountainId = m.Id
where mc.CountryCode IN ('BG', 'US', 'RU')
group by mc.CountryCode

-- 17
SELECT top 5
	c.CountryName,
	r.RiverName
from
Countries As c
left join CountriesRivers as cr on cr.CountryCode = c.CountryCode
left join Rivers as r on r.Id = cr.RiverId
where c.ContinentCode = 'AF'
order by c.CountryName

-- 18
SELECT 
	C.ContinentCode,
	C.CurrencyCode,
	COUNT(C.CurrencyCode) AS CurrencyUsage
INTO ContinentCurrencyUsage
FROM Countries AS C
GROUP BY C.ContinentCode, C.CurrencyCode
HAVING COUNT(C.CurrencyCode) > 1
--------------------------------------------------

SELECT 
	ccu.ContinentCode,
	MAX(ccu.CurrencyUsage) AS [MaxUsage]
INTO MaxUSageByContinent
FROM ContinentCurrencyUsage AS ccu
group by ccu.ContinentCode
ORDER BY ccu.ContinentCode
-----------------------------------------------------

select 
	ccu.ContinentCode,
	ccu.CurrencyCode,
	maxUsage.MaxUsage as [CurrencyUsage]
from ContinentCurrencyUsage AS ccu
left join MaxUSageByContinent as maxUsage
	on ccu.ContinentCode = maxUsage.ContinentCode
where ccu.CurrencyUsage = maxUsage.MaxUsage
order by ccu.ContinentCode

 -- 19
 SELECT 
	COUNT(c.CountryCode)	
from
Countries As c
left join MountainsCountries as mc on mc.CountryCode = c.CountryCode
left join Mountains as m on m.Id = mc.MountainId
where m.MountainRange IS NULL

-- 20
SELECT top 5
	c.CountryName,
	MAX(p.Elevation) as [HighestPeakElevation],
	MAX(r.Length) as [LonghestRiverLength]
from
Countries As c
left join MountainsCountries as mc on mc.CountryCode = c.CountryCode
left join Mountains as m on m.Id = mc.MountainId
left join Peaks as p on p.MountainId = m.Id

left join CountriesRivers as cr on cr.CountryCode = c.CountryCode
left join Rivers as r on r.Id = cr.RiverId
group by c.CountryName
order by HighestPeakElevation desc, LonghestRiverLength desc, c.CountryName

-- 21
select top 5
	c.CountryName AS [Country],	
	ISNULL(p.PeakName,'(no highest peak)') AS [Highest Peak Name],
	ISNULL(HighestPeakInfo.HighestPeakElevation, 0) AS [HighestPeakElevation],
	ISNULL(m.MountainRange, '(no mountain)') AS Mountain
from Countries AS c
left JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
left JOIN Mountains AS m ON mc.MountainId = m.Id
left JOIN Peaks AS p ON p.MountainId = m.Id
left join 
(
	SELECT 
	c.CountryName AS [Country],
	MAX(p.Elevation) AS [HighestPeakElevation],
	m.MountainRange AS [Mountain]
FROM Countries AS c
left JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
left JOIN Mountains AS m ON mc.MountainId = m.Id
left JOIN Peaks AS p ON p.MountainId = m.Id
GROUP BY c.CountryName, m.MountainRange
)

AS HighestPeakInfo ON HighestPeakInfo.Country = c.CountryName
where HighestPeakInfo.HighestPeakElevation = p.Elevation OR HighestPeakInfo.HighestPeakElevation IS NULL
order by [Country], [Highest Peak Name]
