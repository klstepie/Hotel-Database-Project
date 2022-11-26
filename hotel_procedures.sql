CREATE PROCEDURE p_PromoteEmployee
@Id_Employee int,
@Position varchar(30)
AS
DECLARE @employment_status varchar(11)
SET @employment_status = (SELECT EmploymentStatus FROM Employees WHERE ID_Employee = @Id_Employee)
IF(@Id_Employee IN (SELECT ID_Employee FROM Employees) AND @employment_status = 'Employed')
BEGIN
UPDATE Employees
SET Position = @Position
WHERE @Id_Employee = ID_Employee
END
ELSE
BEGIN
RAISERROR ('Incorrect employee identification number.',16,1)
END
GO


CREATE PROCEDURE p_AddGuest
@firstname varchar(20),
@lastname varchar(20),
@address varchar(30), 
@city varchar(20),
@postcode varchar(10),
@country varchar(20), 
@phone char(12),
@type int,
@document char(11),
@email varchar(30) = NULL
AS
IF (@document NOT IN (SELECT [PESEL/Passport] FROM Guests))
BEGIN
INSERT INTO Guests
(
FirstName,
LastName,
Address,
City,
PostCode,
Country,
PhoneNumber,
EmailAddress,
ID_GuestType,
[PESEL/Passport]
)
VALUES (
@firstname,
@lastname,
@address, 
@city,
@postcode,
@country, 
@phone,
@email,
@type,
@document
)
END
ELSE
BEGIN
RAISERROR ('The guest with this document number already exists in the database.',16,1)
END
GO
