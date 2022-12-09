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

