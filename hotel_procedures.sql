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

-- Dismissal of employees

CREATE PROCEDURE p_FireEmployee
@id_employee int
AS
DECLARE @empl_status varchar(11)
SET @empl_status = (SELECT EmploymentStatus FROM Employees WHERE ID_Employee = @id_employee)
IF(@id_employee IN (SELECT ID_Employee FROM Employees) AND @empl_status = 'Employed')
BEGIN
SET NOCOUNT ON 
UPDATE Employees
SET EmploymentStatus = 'Fired'
WHERE ID_Employee = @id_employee
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

-- Summary of additional services

CREATE PROCEDURE p_SumUpAdditionalServices
@id_booking int
AS
IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
	DECLARE @status char(2)
	SET @status = (SELECT StatusOfAdditionalServices FROM Payments WHERE ID_Booking = @id_booking)
	IF(@status IS NULL)
	BEGIN
		DECLARE @service_amount float
		SET @service_amount= (SELECT SUM(AmountToPay) FROM v_CostOfServices
		WHERE ID_Booking = @id_booking)
		IF(@service_amount IS NOT NULL)
		BEGIN
			DECLARE @stay_amount float
			SET @stay_amount = (SELECT TotalAmountToPay FROM Payments WHERE ID_Booking = @id_booking)
			DECLARE @total float
			SET @total = @stay_amount + @service_amount
			UPDATE Payments
			SET TotalAmountToPay = @total, StatusOfAdditionalServices = 'OK'
			WHERE ID_Booking = @id_booking
		END
		ELSE
		BEGIN
		RAISERROR ('This guest did not use the additional services.',16,1)
		END
	END
	ELSE
	BEGIN
	RAISERROR ('Additional services have already been summarised for this booking.',16,1)
	END
END
ELSE
BEGIN
RAISERROR ('Incorrect booking number.',16,1)
END
GO

-- Checking out

CREATE PROCEDURE p_CheckOut
@id_booking int, @id_room int
AS

DECLARE @status int = 3;
DECLARE @paymentdate smalldatetime;
DECLARE @method int;

IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
	
	SET @paymentdate = (
	SELECT DateOfPayment
	FROM Payments
	WHERE ID_Booking = @id_booking
	)

	SET @method = (
	SELECT ID_PaymentMethod
	FROM Payments
	WHERE ID_Booking = @id_booking
	)

	IF(@paymentdate IS NOT NULL OR @method = 2 )
	BEGIN
		IF(@id_room IN (SELECT ID_Room FROM BookingRooms WHERE ID_Booking = @id_booking))
		BEGIN
		UPDATE Rooms
		SET ID_RoomState = @status
		WHERE ID_Room = @id_room
		END
		ELSE
		BEGIN
		RAISERROR ('A room with this ID number was not assigned to this booking.',16,1)
		END
	END
	ELSE
	BEGIN
		RAISERROR ('The guest did not pay for the stay.',16,1)
	END
END
ELSE
BEGIN
RAISERROR ('Incorrect booking number.',16,1)
END
GO

-- Searching for free rooms

CREATE PROCEDURE p_SearchFreeRooms
@dateFrom smalldatetime,
@dateTo smalldatetime
AS
BEGIN
DECLARE @currentDate date;
SET @currentDate = (SELECT CAST(GETDATE() AS date))
	IF(@dateFrom >= @currentDate AND @dateTo > @currentDate)
		BEGIN
		IF(@dateFrom > @dateTo OR @dateFrom = @dateTo)
			BEGIN
			RAISERROR('Incorrect date range.',16,1)
			END
			ELSE
			BEGIN
			SELECT DISTINCT R.ID_Room,R.Floor,R.RoomNo,RT.Type
			FROM Rooms AS R
			LEFT JOIN BookingRooms BR
			ON R.ID_Room = BR.ID_Room
			JOIN RoomTypes AS RT
			ON RT.ID_RoomType = R.ID_RoomType
			LEFT JOIN Bookings AS B
			ON B.ID_Booking = BR.ID_Booking
			WHERE R.ID_Room NOT IN (
			SELECT R.ID_Room
			FROM Rooms AS R
			JOIN BookingRooms BR
			ON R.ID_Room = BR.ID_Room
			JOIN Bookings AS B
			ON B.ID_Booking = BR.ID_Booking
			WHERE
			B.DateFrom BETWEEN @dateFrom AND @dateTo 
			OR
			B.DateTo BETWEEN @dateFrom AND @dateTo 
			OR
			@dateFrom BETWEEN B.DateFrom AND B.DateTo
			OR
			@dateTo  BETWEEN B.DateFrom AND B.DateTo
			)
			END
		END
ELSE
BEGIN
RAISERROR('Incorrect date range.',16,1)
END
END
GO

-- Changing arrival date

CREATE PROCEDURE p_ChangeArrival
@id_booking int,
@dateBefore smalldatetime,
@dateAfter smalldatetime
AS

DECLARE @currDatebefore smalldatetime

IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
	
	set @currDatebefore = (
	SELECT DateFrom
	FROM Bookings
	WHERE ID_Booking = @id_booking
	)

	IF(@dateBefore = @currDatebefore)
	BEGIN
		UPDATE Bookings
		SET DateFrom = @dateAfter
		WHERE ID_Booking = @id_booking
		
		DECLARE @newAmount float;
		SET @newAmount = (SELECT Total FROM v_AccomodationCost WHERE ID_Booking = @id_booking)
		DECLARE @ifDeposit float;
		SET @ifDeposit = (SELECT Deposit FROM Payments WHERE ID_Booking = @id_booking)
		
		IF(@ifDeposit IS NOT NULL)
		BEGIN
		DECLARE @sum float;
		SET @sum = @newAmount - @ifDeposit
		UPDATE Payments
		SET TotalAmountToPay = @sum
		WHERE ID_Booking = @id_booking
		END
		ELSE
		BEGIN
		UPDATE Payments
		SET TotalAmountToPay = @newAmount
		WHERE ID_Booking = @id_booking
		END
	END
	ELSE
	BEGIN
		RAISERROR ('The first date of the guest''s stay is different from the one entered.',1,1)
	END
END
ELSE
BEGIN
RAISERROR ('Incorrect booking number.',1,1)
END
GO

-- Changing departure date

CREATE PROCEDURE p_ChangeDeparture
@id_booking int,
@dateBefore smalldatetime,
@dateAfter smalldatetime
AS
DECLARE @currDatebefore smalldatetime
IF(@id_booking IN (SELECT ID_Booking FROM Bookings))
BEGIN
	SET @currDatebefore = (
	SELECT DateTo
	FROM Bookings
	WHERE ID_Booking = @id_booking
	)

	IF(@dateBefore = @currDatebefore)
	BEGIN
		UPDATE Bookings
		SET DateTo = @dateAfter
		WHERE ID_Booking = @id_booking
		
		DECLARE @newAmount float;
		SET @newAmount = (SELECT Total FROM v_AccomodationCost WHERE ID_Booking = @id_booking)
		DECLARE @ifDeposit float;
		SET @ifDeposit = (SELECT Deposit FROM Payments WHERE ID_Booking = @id_booking)
		DECLARE @term smalldatetime;
		DECLARE @method int;
		SET @method = (SELECT ID_PaymentMethod FROM Payments WHERE ID_Booking = @id_booking)
		
		IF(@ifDeposit IS NOT NULL)
		BEGIN
		DECLARE @total float;
		SET @total = @newAmount - @ifDeposit
		UPDATE Payments
		SET TotalAmountToPay = @total
		WHERE ID_Booking = @id_booking
		END
		ELSE
		BEGIN
		UPDATE Payments
		SET TotalAmountToPay = @newAmount
		WHERE ID_Booking = @id_booking
		END
		
		IF(@method = 2)
		BEGIN
		SET @term = (SELECT DATEADD(DAY,14,DateTo) FROM Bookings WHERE ID_Booking = @id_booking)
		UPDATE Payments
		SET PaymentTerm = @term
		WHERE ID_Booking = @id_booking
		END
		ELSE
		BEGIN
		SET @term = (SELECT DateTo FROM Bookings WHERE ID_Booking = @id_booking)
		UPDATE Payments
		SET PaymentTerm = @term
		WHERE ID_Booking = @id_booking
		END
	END
	ELSE
	BEGIN
		RAISERROR ('The first date of the guest''s stay is different from the one entered.',1,1)
	END
END
ELSE
BEGIN
RAISERROR ('Incorrect booking number.',1,1)
END
GO

-- USALI Reports 

---- SPA & Wellness

CREATE PROCEDURE p_GenerateSpaWellnessReport
AS
BEGIN
DECLARE @swimpool float;
SET @swimpool = (SELECT SUM(SumOfServices)
FROM v_TotalServicesPerBooking AS SU
JOIN Bookings AS B
ON B.ID_Booking = SU.ID_Booking
WHERE SU.ID_Service = 2 AND YEAR(B.DateFrom) = YEAR(GETDATE())
)
SELECT * FROM v_TotalServicesPerBooking
IF (@swimpool IS NULL) SET @swimpool = 0.0
DECLARE @skincare float;
SET @skincare = (
SELECT SUM(SumOfServices)
FROM v_TotalServicesPerBooking AS SU
JOIN Bookings AS B
ON B.ID_Booking = SU.ID_Booking
WHERE SU.ID_Service = 11 AND YEAR(B.DateFrom) = YEAR(GETDATE())
)
IF (@skincare IS NULL) SET @skincare= 0.0
DECLARE @bodytreatment float;
SET @bodytreatment = (
SELECT SUM(SumOfServices)
FROM v_TotalServicesPerBooking AS SU
JOIN Bookings AS B
ON B.ID_Booking = SU.ID_Booking
WHERE SU.ID_Service IN (1,3,7,8,9,10) AND YEAR(B.DateFrom) = YEAR(GETDATE())
)
IF (@bodytreatment IS NULL) SET @bodytreatment = 0.0
DECLARE @total float;
SET @total = @swimpool + @skincare + @bodytreatment;
DECLARE @cs float;
SET @cs = (
SELECT SUM(Amount) FROM Expenses WHERE ID_ExpenseCode = 'CS' AND YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)

DECLARE @l float;
SET @l = (
SELECT SUM(Amount) FROM Expenses WHERE ID_ExpenseCode = 'L' AND YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)
DECLARE @ladc float;
SET @ladc = (
SELECT SUM(Amount) FROM Expenses WHERE ID_ExpenseCode = 'LADC' AND YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)
DECLARE @sag float;
SET @sag = (
SELECT SUM(Amount) FROM Expenses WHERE ID_ExpenseCode = 'SAG' AND YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)
DECLARE @sp float;
SET @sp = (
SELECT SUM(Amount) FROM Expenses WHERE ID_ExpenseCode = 'SP' AND YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)
DECLARE @habp float;
SET @habp = (
SELECT SUM(Amount) FROM Expenses WHERE ID_ExpenseCode = 'HABP' AND YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)
DECLARE @totalexpenses float;
SET @totalexpenses = (
SELECT SUM(Amount) FROM Expenses WHERE YEAR(DateOfPurchase) = YEAR(GETDATE()) AND DeptNo = 'UD1'
)
DECLARE @profit float;
set @profit = @total - @totalexpenses
DECLARE @document xml
SET @document = (
SELECT CAST(@swimpool AS decimal(7,2)) AS 'Income/SwimmingPool', 
CAST(@skincare AS decimal(7,2)) AS 'Income/Skincare', 
CAST(@bodytreatment AS decimal(7,2)) AS 'Income/BodyTreatments',
CAST(@total AS decimal(7,2)) AS 'Income/TotalIncome', 
CAST(@cs AS decimal(7,2)) AS 'Expenses/CleaningSupplies', 
CAST(@l AS decimal(7,2)) AS 'Expenses/Linen', 
CAST(@ladc AS decimal(7,2)) AS 'Expenses/LaundryAndDryCleaning',
CAST(@sag AS decimal(7,2)) AS 'Expenses/ServicesAndGifts', 
CAST(@SP AS decimal(7,2)) AS 'Expenses/SwimmingPool', 
CAST(@habp AS decimal(7,2)) AS 'Expenses/HealthAndBeautyProducts', 
CAST(@totalexpenses AS decimal(7,2)) AS 'Expenses/TotalExpenses',  
CAST(@profit AS decimal(7,2)) AS 'Profit'
FOR XML PATH ('SpaAndWellness'), ELEMENTS
)
INSERT INTO USALIReports
VALUES ('U2',@document,GETDATE())
END
GO

----- Rooms


