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

-- Adding reservation

CREATE PROCEDURE p_AddBooking
@id_guest int, 
@datefrom smalldatetime, 
@dateto smalldatetime, 
@numofrooms int, 
@numofguests int 
AS
SET NOCOUNT ON 
IF(@id_guest IN (SELECT ID_Guest FROM Guests))
BEGIN
	IF(@datefrom < @dateto AND @datefrom != @dateto)
	BEGIN
	DECLARE @status int = 2
	DECLARE @dateofbooking smalldatetime = GETDATE()
	INSERT INTO Bookings
	(
	ID_Guest, 
	DateFrom,
	DateTo,
	NumberOfRooms,
	ID_BookingStatus,
	BookingDate,
	NumberOfGuests
	)
	VALUES (
	@id_guest,
	@datefrom,
	@dateto,
	@numofrooms,
	@status,
	@dateofbooking,
	@numofguests
	)

	SELECT 
	ID_Booking, 
	G.FirstName,
	G.LastName,
	DateFrom,
	DateTo,
	NumberOfRooms,
	NumberOfGuests
	FROM Bookings B
	JOIN Guests G
	ON B.ID_Guest = G.ID_Guest
	WHERE B.ID_Guest = @id_guest

	END
	ELSE
	BEGIN
	RAISERROR ('Wrong date is entered.',16,1)
	END
END
ELSE
BEGIN
RAISERROR ('There is no such guest.',16,1)
END
GO

-- Generating summary

CREATE procedure p_GenerateSummaryOfServices
@id_booking int
AS
BEGIN
	IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
		BEGIN
		SELECT B.ID_Booking, RT.Type AS 'Service name', B.DateFrom AS 'Start date of service', 
		B.DateTo AS 'End date of service', 
		DATEDIFF(DAY,B.DateFrom,B.DateTo) AS 'Quantity','D' AS 'Unit',
		RT.Price AS 'Gross unit price',RT.Price * (DATEDIFF(DAY,B.DateFrom,B.DateTo)) AS 'Gross amount'
		INTO #TempSummaryOfStay
		FROM Bookings B
		JOIN BookingRooms BR
		ON B.ID_Booking = BR.ID_Booking
		JOIN Rooms R
		ON R.ID_Room = BR.ID_Room
		JOIN RoomTypes RT
		ON RT.ID_RoomType = R.ID_RoomType


		SELECT B.ID_Booking, HS.Name AS 'Service name', RS.StartDate AS 'Start date of service', 
		RS.EndDate AS 'End date of service', 
		CASE
		WHEN HS.TimeUnit = 'H' THEN DATEDIFF(HOUR,RS.StartDate,RS.EndDate) 
		WHEN HS.TimeUnit = 'D' THEN DATEDIFF(DAY,RS.StartDate,RS.EndDate) 
		END AS 'Quantity',
		HS.TimeUnit AS 'Unit',
		HS.Price AS 'Gross unit price',
		CASE
		WHEN HS.TimeUnit = 'H' THEN HS.Price * DATEDIFF(HOUR,RS.StartDate,RS.EndDate) 
		WHEN HS.TimeUnit = 'D' THEN HS.Price * DATEDIFF(DAY,RS.StartDate,RS.EndDate) 
		END AS 'Gross amount'
		INTO #TempSummaryOfServices
		FROM Bookings B
		JOIN ReservationOfServices RS
		ON RS.ID_Booking = B.ID_Booking
		JOIN HotelServices HS
		ON HS.ID_Service = RS.ID_Service

		Create Table #FinalStatement(
		ID_Booking int,
		[Name of service/room] varchar(50),
		[Start date of service] smalldatetime,
		[End date of service] smalldatetime,
		[Quantity] INT,
		[Unit] CHAR(1),
		[Gross unit price] FLOAT,
		[Gross amount] FLOAT


		)

		INSERT INTO #FinalStatement
		SELECT *
		FROM #TempSummaryOfServices
		UNION ALL
		SELECT *
		FROM #TempSummaryOfStay

		SELECT *
		FROM #FinalStatement
		WHERE ID_Booking = @id_booking

		DROP table #TempSummaryOfStay
		DROP table #TempSummaryOfServices
		DROP table #FinalStatement
		END
	ELSE
	BEGIN
	RAISERROR ('Invalid booking number.',16,1)
	END

END
GO

-- Check in

CREATE PROCEDURE p_CheckIn
@id_booking int,
@id_room int,
@status int = 2
AS
DECLARE @datefrom date;
DECLARE @dateto date;
DECLARE @id_roombook int;


IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
	SET @id_roombook = (SELECT ID_BookingRoom
	FROM BookingRooms
	WHERE ID_Room = @id_room AND ID_Booking = @id_booking)
	IF(@id_roombook IN (SELECT ID_BookingRoom FROM BookingRooms))
	BEGIN
	
		IF(@status = 2 OR @status = 4)
		BEGIN
        set @datefrom = (
			SELECT DateFrom
		FROM Bookings
			WHERE ID_Booking = @id_booking
		)

		set @dateto = (
			SELECT DateTo
			FROM Bookings
			WHERE ID_Booking = @id_booking
			)

		IF (GETDATE() BETWEEN @datefrom AND @dateto)
				  BEGIN
					UPDATE Rooms
					SET ID_RoomState = @status
				WHERE ID_Room = @id_room
				 END
				  ELSE
				 BEGIN
				RAISERROR ('The guest arrived not on the date he had booked.',16,1)
			END
			END
			ELSE
			BEGIN
			RAISERROR ('Incorrect status number.',16,1)
			END
	END
	ELSE
	BEGIN
	RAISERROR ('Incorrect room number.',16,1)
	END
END
ELSE
BEGIN
RAISERROR ('Incorrect booking number.',16,1)
END
GO

-- Collecting payment

CREATE procedure p_CollectPayment
@id_booking int,
@amount float,
@method int
AS
IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
	DECLARE @debt float
	DECLARE @dateofpayment smalldatetime
	SET @dateofpayment = (SELECT DateOfPayment from Payments where ID_Booking= @id_booking)

	IF(@dateofpayment IS NULL)
	BEGIN
		SET @debt = (SELECT TotalAmountToPay from Payments where ID_Booking = @id_booking)
		IF(@amount = @debt and @method IN (SELECT ID_PaymentMethod from PaymentMethods))
		BEGIN
			UPDATE Payments
			SET DateOfPayment = GETDATE(), ID_PaymentMethod = @method
			WHERE ID_Booking = @id_booking
		END
		ELSE
		BEGIN
		RAISERROR ('Incorrect amount charged. /Incorrect payment method selected. ',16,1)
		END
	END
	ELSE
	BEGIN
	RAISERROR ('This guest has already made payment.',16,1)
	END
END
ELSE
BEGIN
	RAISERROR ('Incorrect booking number.',16,1)
END
GO

-- Opening payment

CREATE PROCEDURE p_OpenPaymentForBooking
@id_booking int,
@method int = 1
AS
IF(@id_booking IN (SELECT ID_Booking from Bookings))
BEGIN
IF(@id_booking NOT IN (SELECT ID_Booking from Payments))
BEGIN
	declare @amount float
	set @amount = (SELECT Total from v_AccomodationCost where ID_Booking = @id_booking )
	declare @term smalldatetime
	IF(@method = 2)
	BEGIN
	set @term = (Select DATEADD(DAY,14,DateTo) From Bookings where ID_Booking = @id_booking )
	END
	ELSE
	BEGIN
	set @term = (Select DateTo From Bookings where ID_Booking = @id_booking )
	END
	INSERT INTO Payments
	(
	ID_Booking,
	TotalAmountToPay,
	ID_PaymentMethod,
	PaymentTerm
	)
	VALUES (
	@id_booking,
	@amount,
	@method,
	@term
	)
END
ELSE
BEGIN
RAISERROR ('There is already payment for this booking.',16,1)
END
END
ELSE 
BEGIN
RAISERROR ('There is no such reservation number.',16,1)
END
GO


-- Accepting deposit

CREATE PROCEDURE p_AcceptDeposit
@id_booking int
AS
IF(@id_booking IN (SELECT ID_Booking from Payments) AND 
(SELECT Deposit From Payments WHERE ID_Booking = @id_booking) IS NULL)
BEGIN
	DECLARE @correct_amount float
	SET @correct_amount = (SELECT TotalAmountToPay * 0.2 
	FROM Payments WHERE ID_Booking = @id_booking)
	BEGIN
	UPDATE Payments
	SET Deposit = @correct_amount, TotalAmountToPay = (TotalAmountToPay - @correct_amount)
	WHERE ID_Booking = @id_booking
	UPDATE Bookings
	SET ID_BookingStatus = 1
	WHERE ID_Booking = @id_booking
	END
END
ELSE
BEGIN
	RAISERROR ('There is no such reservation.',1,1) 
END
GO

-- Booking services

CREATE PROCEDURE p_BookServices
@id_booking int,
@id_service int,
@datestart smalldatetime,
@datestop smalldatetime,
@id_employee int,
@desc text = NULL
AS 
IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
IF(@datestart < @datestop)
BEGIN
INSERT INTO ReservationOfServices
(ID_Booking,
ID_Service,
StartDate,
ID_Employee,
Description,
EndDate
)
VALUES
(
@id_booking,
@id_service,
@datestart,
@id_employee,
@desc,
@datestop
)
END
ELSE
BEGIN
RAISERROR ('Wrong date was entered.',16,1)
END
END
ELSE
BEGIN
RAISERROR ('There is no such booking.',16,1)
END
GO


