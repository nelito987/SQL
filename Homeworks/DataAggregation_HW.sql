-- 1
select COUNT(w.Id)
from WizzardDeposits AS w

-- 2
select MAX(w.MagicWandSize) AS [LongestMagicWand]
from WizzardDeposits AS w

-- 3
select 
	w.DepositGroup, 
	MAX(w.MagicWandSize) as [LongestMagicWand]
from WizzardDeposits AS w
group by w.DepositGroup

-- 4
declare @tempTableAverages table
	(DepositGroup NVARCHAR(250),
	AverageSize INT)

insert into @tempTableAverages
	select w.DepositGroup, 
	AVG(w.MagicWandSize)
	from WizzardDeposits AS w
	group by w.DepositGroup

select t.DepositGroup 
from @tempTableAverages AS t
where t.AverageSize = (select MIN(p.AverageSize) FROM @tempTableAverages as p)

-- 5
select w.DepositGroup,
	SUM(w.DepositAmount) AS [TotalSum]
from WizzardDeposits as w
group by w.DepositGroup

-- 6
select w.DepositGroup,
	SUM(w.DepositAmount) AS [TotalSum]
from WizzardDeposits as w
where w.MagicWandCreator = 'Ollivander family'
group by w.DepositGroup

-- 7
select w.DepositGroup,
	SUM(w.DepositAmount) AS [TotalSum]
from WizzardDeposits as w
where w.MagicWandCreator = 'Ollivander family'
group by w.DepositGroup
having SUM(w.DepositAmount) < 150000
order by TotalSum DESC

-- 8
select w.DepositGroup,
	w.MagicWandCreator,
	MIN(w.DepositCharge)
from WizzardDeposits as w
group by w.DepositGroup, w.MagicWandCreator
order by w.MagicWandCreator, w.DepositGroup

-- 9
select	
	p.range as [AgeGroup], 
	count(*) as [WizzardCount]
from (select 
	case 
		when Age >= 0 AND Age <= 10 then '[0-10]' 
		when Age >= 11 AND Age <= 20 then '[11-20]'
		when Age >= 21 AND Age <= 30 then '[21-30]' 
		when Age >= 31 AND Age <= 40 then '[31-40]' 
		when Age >= 41 AND Age <= 50 then '[41-50]' 
		when Age >= 51 AND Age <= 60 then '[51-60]' 
		when Age >= 61  then '[61+]'		 
	END as range
	from WizzardDeposits) as p
group by p.range

-- 10
select distinct(left(w.FirstName,1)) as [first letter]
from WizzardDeposits as w
where w.DepositGroup = 'Troll Chest'
order by [first letter]

-- 11
select 
	w.DepositGroup,
	w.IsDepositExpired,
	AVG(w.DepositInterest)
from WizzardDeposits as w
where w.DepositStartDate > '01-01-1985'
group by w.IsDepositExpired, w.DepositGroup
order by w.DepositGroup DESC, w.IsDepositExpired

-- 12
select sum(w1.DepositAmount - w2.DepositAmount) as [SumDiffernce]
from
	WizzardDeposits as w1,
	WizzardDeposits as w2
where w2.Id = w1.Id + 1

-- 13
select 
	e.DepartmentID,
	min(e.Salary)
from Employees as e
where e.DepartmentID in (2,5,7)
	and e.HireDate > '01/01/2000'
group by e.DepartmentID

-- 14
select * into HighestPaidEmpl
from Employees as e
where e.Salary > 30000

delete from HighestPaidEmpl where ManagerID = 42

update HighestPaidEmpl
set Salary+=5000
where DepartmentID = 1

select 
	h.DepartmentID, 
	avg(h.Salary) as [AverageSalary]
from HighestPaidEmpl as h
group by h.DepartmentID

-- 15
select 
	e.DepartmentID,
	max(e.Salary) as [MaxSalary]
from
Employees as e
group by e.DepartmentID
having max(e.Salary) < 30000 or max(e.Salary) > 70000

-- 16
select count(e.Salary)
from
Employees as e
where e.ManagerID IS NULL

-- 17
;with t as(
SELECT
		e.DepartmentId,
		e.Salary,
		DENSE_RANK() OVER(PARTITION BY e.DepartmentId ORDER BY e.Salary DESC) AS RowNumber
	FROM
		Employees e) 
SELECT DISTINCT DepartmentID, Salary  FROM t
where t.RowNumber = 3

-- 18
SELECT TOP 10
	e.FirstName,
	e.LastName,
	e.DepartmentID
FROM
	Employees e
WHERE
	e.Salary > (
		SELECT
			AVG(Salary)
		FROM
			Employees
		WHERE
			DepartmentID = e.DepartmentID
	)
