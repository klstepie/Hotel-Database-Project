-- Adding employees

CREATE PROCEDURE p_AddEmployee
@id_employee int,
@firstname varchar(20),
@lastname varchar(20),
@position varchar(30), 
@address varchar(30),
@city varchar(20),
@postcode varchar(10),
@country varchar(20),
@phone char(9),
@pesel char(11),
@deptno char(3)
AS
BEGIN
IF(@id_employee IN (SELECT ID_Employee FROM Employees))
BEGIN
RAISERROR ('The employee ID number already exists in the database.',16,1)
END
ELSE
BEGIN
IF(@pesel IN (SELECT PESEL FROM Employees))
BEGIN
RAISERROR ('PESEL number already exists in the database.',16,1)
END
ELSE
BEGIN
INSERT INTO Employees
(
ID_Employee, 
FirstName,
LastName,
Position, 
Address, 
City, 
Postcode, 
Country,
PhoneNumber, 
PESEL,
DeptNo
)
VALUES (
@id_employee, 
@firstname,
@lastname,
@position,
@address,
@city,
@postcode,
@country,
@phone,
@pesel,
@deptno
)
END
END
END
GO

-- Promoting employees

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

-- Adding guests

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

-- Adding rooms to reservations

CREATE PROCEDURE p_AddRoomToReservation
@id_booking int,
@id_room int
AS
IF(@id_booking IN (SELECT ID_Booking FROM Bookings) AND @id_room IN (SELECT ID_Room FROM Rooms))
	BEGIN
	IF(@id_room IN (SELECT ID_Room FROM BookingRooms WHERE ID_Booking = @id_booking))
		BEGIN
		-- We can't add two rooms with the same number.
		RAISERROR ('The room ID number is already added to this booking.',16,1)
		END
		ELSE
		BEGIN
		INSERT INTO BookingRooms
		(
		ID_Booking,
		ID_Room
		)
		VALUES
		(
		@id_booking,
		@id_room
		)
		END
	END
	ELSE
	BEGIN
	RAISERROR ('Incorrect booking/room identification number.',16,1)
	END
GO

