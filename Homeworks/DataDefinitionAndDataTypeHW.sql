-- 4
INSERT INTO Towns VALUES (1, 'Sofia');
INSERT INTO Towns VALUES (2, 'Plovdiv');
INSERT INTO Towns VALUES (3, 'Varna');

INSERT INTO Minions VALUES (1, 'Kevin', 22, 1);
INSERT INTO Minions VALUES (2, 'Bob', 15, 3);
INSERT INTO Minions VALUES (3, 'Steward', NULL, 2);

-- 7
-- Drop table if exists
	DROP TABLE IF EXISTS
		People
	GO
	

	-- Create table
	CREATE TABLE
		People(
			Id INT NOT NULL IDENTITY PRIMARY KEY,
			Name NVARCHAR(200) NOT NULL,
			Picture VARBINARY(2000),
			Height FLOAT(2),
			Weight FLOAT(2),
			Gender CHAR(1) NOT NULL,
			Birthdate DATE NOT NULL,
			Biography NVARCHAR(MAX),
	

			CONSTRAINT
				CH_Gender_Values
			CHECK
				(Gender IN ('m', 'f'))
		)
	GO
	

	-- Insert records
	INSERT INTO
		People(Name, Gender, Birthdate)
	VALUES
		('Zori', 'f', '01/01/1987'),
		('Zori2', 'f', '01/01/1987'),
		('Zori3', 'f', '01/01/1987'),
		('Zori4', 'f', '01/01/1987'),
		('Zori5', 'f', '01/01/1987')
	GO
-- 8
CREATE TABLE
		Users(
			Id INT NOT NULL IDENTITY
				CONSTRAINT PK_Users_Id PRIMARY KEY (Id),
			Username CHAR(30) NOT NULL,
			Password CHAR(30) NOT NULL,
			ProfilePicture VARBINARY(900),
			LastLoginTime DATETIME,
			IsDeleted CHAR(5) NOT NULL
				CONSTRAINT DF_IsDeleted_Default DEFAULT 'false'
				CONSTRAINT CH_IsDeleted_Value CHECK (IsDeleted IN ('true', 'false'))
		)
	GO
-- 13
CREATE TABLE
	Directors(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Directors_Id PRIMARY KEY (Id),
		DirectorName NVARCHAR(250) NOT NULL,
		Notes NVARCHAR(MAX)
	)

CREATE TABLE
	Genres(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Genres_Id PRIMARY KEY (Id),
		GenreName NVARCHAR(250) NOT NULL,
		Notes NVARCHAR(MAX)
	)

CREATE TABLE
	Categories(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Categories_Id PRIMARY KEY (Id),
		CategoryName NVARCHAR(250) NOT NULL,
		Notes NVARCHAR(MAX)
	)

CREATE TABLE
	Movies(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Movies_Id PRIMARY KEY (Id),
		Title NVARCHAR(250) NOT NULL,
		DirectorId INT
			CONSTRAINT FK_Movies_DirectorId_Directors REFERENCES Directors(Id),
		CopyrightYear SMALLINT,
		Length SMALLINT,
		GenreId INT NOT NULL
			CONSTRAINT FK_Movies_GenreId_Genres REFERENCES Genres(Id),
		CategoryId INT NOT NULL
			CONSTRAINT FK_Movies_CategoryId_Genres REFERENCES Categories(Id),
		Rating TINYINT,
		Notes NVARCHAR(MAX)
	)
  
INSERT INTO
	Directors(DirectorName)
VALUES
	('Miroslav'),
	('Galabov'),
	('Miroslav Galabov'),
	('Lucky Strike'),
	('Tobacco')

INSERT INTO
	Genres(GenreName)
VALUES
	('Action'),
	('Adventure'),
	('Comedy'),
	('Crime'),
	('Drama')

INSERT INTO
	Categories(CategoryName)
VALUES
	('War'),
	('Classic'),
	('Fantasy'),
	('Shit'),
	('Sci-Fi')

INSERT INTO
	Movies(Title, DirectorId, GenreId, CategoryId)
VALUES
	('Suicide Squad', 1, 1, 3),
	('Captain America: Civil War', 2, 2, 5),
	('The Secret Life of Pets', 3, 3, 3),
	('Pulp Fiction', 4, 4, 2),
	('Snowden', 5, 5, 4)
-- 14
CREATE TABLE
	Categories(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Categories_Id PRIMARY KEY,
		Category NVARCHAR(250) NOT NULL,
		DailyRate FLOAT(3),
		WeeklyRate FLOAT(3),
		MonthlyRate FLOAT(3),
		WeekendRate FLOAT(3)
	)

CREATE TABLE
	Cars(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Cars_Id PRIMARY KEY,
		PlateNumber NVARCHAR(100) NOT NULL,
		Make NVARCHAR(150),
		Model NVARCHAR(150),
		CarYear SMALLINT,
		CategoryId INT NOT NULL
			CONSTRAINT FK_Cars_CategoryId_Categories REFERENCES Categories(Id),
		Doors TINYINT,
		Picture VARBINARY(MAX),
		Condition NVARCHAR(250),
		Available NVARCHAR(150)
	)

CREATE TABLE
	Employees(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Employees_Id PRIMARY KEY,
		FirstName NVARCHAR(150) NOT NULL,
		LastName NVARCHAR(150) NOT NULL,
		Title NVARCHAR(150),
		Notes NVARCHAR(MAX)
	)

CREATE TABLE
	Customers(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_Customers_Id PRIMARY KEY,
		DriverLicenceNumber NVARCHAR(250) NOT NULL,
		FullName NVARCHAR(300) NOT NULL,
		Address NVARCHAR(300),
		City NVARCHAR(300),
		ZIPCode NVARCHAR(300),
		Notes NVARCHAR(MAX)
	)

CREATE TABLE
	RentalOrders(
		Id INT NOT NULL IDENTITY
			CONSTRAINT PK_RentalOrders_Id PRIMARY KEY,
		EmployeeId INT NOT NULL
			CONSTRAINT FK_RentalOrders_EmployeeId_Employees REFERENCES Employees(Id),
		CustomerId INT NOT NULL
			CONSTRAINT FK_RentalOrders_CustomerId_Customers REFERENCES Customers(Id),
		CarId INT NOT NULL
			CONSTRAINT FK_RentalOrders_CarId_Cars REFERENCES Cars(Id),
		CarCondition NVARCHAR(250),
		TankLevel NVARCHAR(100),
		KilometrageStart INT,
		KilometrageEnd INT,
		TotalKilometrage INT,
		StartDate DATETIME,
		EndDate DATETIME,
		TotalDays SMALLINT,
		RateApplied FLOAT(3),
		TaxRate FLOAT(3),
		OrderStatus NVARCHAR(300),
		Notes NVARCHAR(MAX)
	)
INSERT INTO
	Categories(Category)
VALUES
	('Economy'),
	('Medium'),
	('Premium')

INSERT INTO
	Cars(PlateNumber, CategoryId)
VALUES
	('CA8080', 1),
	('CA9090', 2),
	('CB1111', 3)

INSERT INTO
	Employees(FirstName, LastName)
VALUES
	('Miroslav', 'Galabov'),
	('John', 'Doe'),
	('Jane', 'Doe')

INSERT INTO
	Customers(DriverLicenceNumber, FullName)
VALUES
	('8762537839HH', 'Miroslav Galabov'),
	('82725163839JJ', 'John Doe'),
	('2158884458PP', 'Jane Doe')

INSERT INTO
	RentalOrders(EmployeeId, CustomerId, CarId)
VALUES
	(1, 1, 1),
	(2, 2, 2),
	(3, 3, 3)
-- 15
CREATE TABLE
		Employees(
			Id INT NOT NULL IDENTITY
				CONSTRAINT PK_Employees_Id PRIMARY KEY,
			FirstName NVARCHAR(150) NOT NULL,
			LastName NVARCHAR(150) NOT NULL,
			Title NVARCHAR(250),
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		Customers(
			Id INT NOT NULL IDENTITY
				CONSTRAINT PK_Customers_Id PRIMARY KEY,
			FirstName NVARCHAR(150) NOT NULL,
			LastName NVARCHAR(150) NOT NULL,
			PhoneNumber NVARCHAR(250),
			EmergencyName NVARCHAR(250),
			EmergencyNumber NVARCHAR(250),
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		RoomStatus(
			RoomStatus NVARCHAR(150) NOT NULL
				CONSTRAINT PK_RoomStatus_RoomStatus PRIMARY KEY,
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		RoomTypes(
			RoomType NVARCHAR(150) NOT NULL
				CONSTRAINT PK_RoomTypes_RoomType PRIMARY KEY,
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		BedTypes(
			BedType NVARCHAR(150) NOT NULL
				CONSTRAINT PK_BedTypes_BedType PRIMARY KEY,
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		Rooms(
			RoomNumber SMALLINT NOT NULL,
			RoomType NVARCHAR(150) NOT NULL
				CONSTRAINT FK_Rooms_RoomType_RoomTypes REFERENCES RoomTypes(RoomType),
			BedType NVARCHAR(150) NOT NULL
				CONSTRAINT FK_Rooms_BedType_BedTypes REFERENCES BedTypes(BedType),
			Rate SMALLINT,
			RoomStatus NVARCHAR(150) NOT NULL
				CONSTRAINT FK_Rooms_RoomStatus_RoomStatus REFERENCES RoomStatus(RoomStatus),
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		Payments(
			Id INT NOT NULL IDENTITY
				CONSTRAINT PK_Payments_Id PRIMARY KEY,
			EmployeeId INT NOT NULL
				CONSTRAINT FK_Payments_EmployeeId_Employees REFERENCES Employees(Id),
			PaymentDate DATETIME,
			AccountNumber NVARCHAR(500),
			FirstDateOccupied DATETIME,
			LastDateOccupied DATETIME,
			TotalDays INT,
			AmountCharged MONEY,
			TaxRate SMALLMONEY,
			TaxAmount MONEY,
			PaymentTotal MONEY,
			Notes NVARCHAR(MAX)
		)
	

	CREATE TABLE
		Occupancies(
			Id INT NOT NULL IDENTITY
				CONSTRAINT PK_Occupancies_Id PRIMARY KEY,
			EmployeeId INT NOT NULL
				CONSTRAINT FK_Occupancies_EmployeeId_Employees REFERENCES Employees(Id),
			DateOccupied DATETIME,
			AccountNumber NVARCHAR(200),
			RoomNumber SMALLINT,
			RateApplied FLOAT(3),
			PhoneCharge FLOAT(3),
			Notes NVARCHAR(MAX)
		)
-- 19
SELECT	*
FROM	Towns
SELECT	*
FROM	Departments
SELECT	*
FROM	Employees

-- 20
SELECT	*
FROM Towns
ORDER BY Name ASC
--------------------
SELECT	*
FROM Departments
ORDER BY Name ASC
--------------------
SELECT	*
FROM	Employees
ORDER BY Salary DESC

-- 21
SELECT	t.Name
FROM	Towns t
ORDER BY	t.Name ASC
--------------------
SELECT	d.Name
FROM	Departments d
ORDER BY d.Name ASC
--------------------
SELECT
	e.FirstName,
	e.LastName,
	e.JobTitle,
	e.Salary
FROM	Employees e
ORDER BY e.Salary DESC

-- 22
UPDATE [Employees] SET [Salary] *= 1.1  
SELECT [Salary] FROM [Employees]

-- 23
UPDATE Payments
SET TaxRate -= TaxRate*0.03
SELECT TaxRate FROM Payments

-- 24
TRUNCATE TABLE	Occupancies