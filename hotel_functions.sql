-- Checking how many employees get more than the stated rate

CREATE FUNCTION checkrate(@rate float = 0)
RETURNS int AS
BEGIN
DECLARE @number int
SELECT @number = COUNT(ID_Employee) FROM EmployeePayments WHERE Rate > @rate
RETURN @number
END

-- Execute

DECLARE @number int
SET @number = dbo.checkrate(21)
SELECT @number AS NumberOfEmployees

-- Displaying and counting all of the employee's payments 

CREATE FUNCTION payment_table(@id_employee int)
RETURNS @PaymentEmployee TABLE (Id_Employee int, FirstName varchar(20),
LastName varchar(20), Position varchar(30), DateYear smallint, DateMonth smallint, TotalPayment float)
AS
BEGIN
INSERT INTO @PaymentEmployee 
SELECT E.ID_Employee, FirstName,LastName,Position,YEAR(EH.Date), MONTH(EH.Date), SUM(WorkHours) * Rate 
FROM Employees E
JOIN EmployeeHoursPerDay EH
ON E.ID_Employee = EH.ID_Employee
JOIN  EmployeePayments AS EP
ON EH.ID_Employee = EP.ID_Employee
WHERE E.ID_Employee = @id_employee
GROUP BY E.ID_Employee,FirstName,LastName,Position, YEAR(Date), MONTH(Date), Rate
RETURN
END

-- Execute
SELECT * FROM dbo.payment_table(1)

-- Counting how many particular guest visits our hotel 
CREATE FUNCTION f_loyalfactor(@guest int)
RETURNS int
AS
BEGIN
DECLARE @factor int
SET @factor = (SELECT COUNT(ID_Booking) FROM Bookings WHERE ID_Guest = @guest)
RETURN @factor 
END

-- Execute
SELECT ID_Guest, FirstName, LastName, EmailAddress, PhoneNumber , dbo.f_loyalfactor(ID_Guest) AS NumberOfVisits,
CASE
WHEN dbo.f_loyalfactor(ID_Guest) > 2 THEN 'Loyal guest'
ELSE 'Not defined'
END
AS Loyalty
FROM Guests
