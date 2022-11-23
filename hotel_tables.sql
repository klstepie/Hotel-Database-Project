
-- Create Database
CREATE DATABASE HotelDB
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'HotelDB', 
FILENAME = N'Z:\HotelDB.mdf' , 
SIZE = 20MB , 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 5MB )
 LOG ON 
( NAME = N'HotelDB_Log', 
FILENAME = N'Z:HotelDB_log.ldf' , 
SIZE = 10MB , 
MAXSIZE = 40MB , 
FILEGROWTH = 5MB )
GO

-- Create Tables

USE HotelDB

-- Departments

CREATE TABLE Departments (
[DeptNo] [char](3) NOT NULL PRIMARY KEY,
[DeptName] [varchar](30) NOT NULL,
[Description] [text] NULL
)

-- Dumping Data

INSERT  INTO Departments
VALUES (N'PS1', N'Ground floor service', N'A department dedicated to guest services, ensuring the safety and care of the guest.'),
(N'R1 ', N'Reception', N'The department dealing with visitor services at the reception desk.'),
(N'SP1', N'Floor service', N'A department dedicated to keeping the rooms clean and ready for the arrival of guests.'),
(N'UD1', N'Additional services', N'Department for the provision of sports and leisure services.')

-- Employees

CREATE TABLE Employees(
	[ID_Employee] [int] NOT NULL,
	[FirstName] [varchar](20) NOT NULL,
	[LastName] [varchar](20) NOT NULL,
	[Position] [varchar](30) NOT NULL,
	[Address] [varchar](30) NOT NULL,
	[City] [varchar](20) NOT NULL,
	[Postcode] [varchar](10) NOT NULL,
	[Country] [varchar](20) NOT NULL,
	[PhoneNumber] [char](9) NULL,
	[PESEL] [char](11) NOT NULL,
	[EmploymentStatus] [varchar](11) NOT NULL,
	[DeptNo] [char](3) NOT NULL,
 CONSTRAINT PK_Employees PRIMARY KEY (ID_Employee),
 CONSTRAINT FK_Employees_Departments FOREIGN KEY (DeptNo) REFERENCES Departments (DeptNo)
 )

ALTER TABLE [dbo].[Employees]
ADD CONSTRAINT DF_Employed DEFAULT ('Employed') FOR EmploymentStatus

ALTER TABLE [dbo].[Employees]
ADD CONSTRAINT CHK_Status
CHECK (([EmploymentStatus]='Employed' OR [EmploymentStatus]='Fired'))

ALTER TABLE [dbo].[Employees] 
ADD CONSTRAINT CHK_PhoneNumber
CHECK  (([PhoneNumber] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))

ALTER TABLE [dbo].[Employees]  
ADD CONSTRAINT CHK_PESEL
CHECK  (([PESEL] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))



-- Dumping data 

INSERT INTO Employees 
VALUES (1, N'Jan', N'Kowalski', N'Car park attendant', N'ul. Motylkowa 2', N'Wroclaw', N'00-000', N'Polska', N'876321123   ', N'11111111111', N'Employed', N'PS1'),
(2, N'Maria', N'Nowak', N'Maid', N'ul. Rozana 2', N'Rzeszow', N'00-001', N'Poland', N'876321111   ', N'22222222222', N'Employed', N'SP1'),
(3, N'Monika', N'Wichura', N'Maid', N'ul. Bratkowa 2', N'Krakow', N'00-002', N'Poland', N'876321122   ', N'33333333333', N'Employed',N'SP1'),
(4, N'Lukasz', N'Biegun', N'Lifeguard', N'ul. Irysowa 2', N'Hel', N'00-003', N'Poland', N'876321133   ', N'44444444444', N'Employed', N'UD1'),
(5, N'Jozef', N'Stachowski', N'Masseur/Masseuse', N'ul. Rzepakowa 2', N'Wroclaw', N'00-004', N'Poland', N'876321144   ', N'55555555555', N'Employed',N'UD1'),
(6, N'Anna', N'Wozniak', N'Reception Manager', N'ul. Ziemniaczana 2', N'Wroclaw', N'00-005', N'Poland', N'876321155   ', N'66666666666', N'Employed',N'R1 '),
(7, N'Krzysztof', N'Pak', N'Receptionist', N'ul. Marchewkowa 2', N'Wroclaw', N'00-006', N'Poland', N'876321166   ', N'77777777777', N'Employed', N'R1 ')

-- Guest types

CREATE TABLE GuestTypes(
	ID_GuestType int NOT NULL,
	Type varchar(40) NOT NULL,
 CONSTRAINT PK_GuestType PRIMARY KEY (ID_GuestType)
 )

 -- Dumping data 

INSERT INTO GuestTypes
VALUES (1, N'Family traveller'),
 (2, N'Business guest'),
(3, N'Foreign visitor'),
(4, N'Regular guest/VIP'),
(5, N'Individual guest')

-- Guests

CREATE TABLE Guests (
	ID_Guest int IDENTITY(1,1) NOT NULL,
	FirstName varchar(20) NOT NULL,
	LastName varchar(20) NOT NULL,
	Address varchar(30) NOT NULL,
	City varchar(20) NOT NULL,
	PostCode varchar(10) NOT NULL,
	Country varchar(20) NOT NULL,
	PhoneNumber char(12) NULL,
	EmailAddress varchar(30) NULL,
	ID_GuestType int NOT NULL,
	[PESEL/Passport] char(11) NOT NULL,
	AdditionalInformation xml NULL,
 CONSTRAINT PK_Guests PRIMARY KEY (ID_Guest)
 )

ALTER TABLE Guests  
ADD  CONSTRAINT FK_Guests_GuestTypes FOREIGN KEY(ID_GuestType)
REFERENCES GuestTypes (ID_GuestType)

-- Dumping data 

SET IDENTITY_INSERT Guests ON 

INSERT INTO Guests (ID_Guest,FirstName,LastName,Address,City,PostCode,Country,PhoneNumber,EmailAddress,ID_GuestType,[Pesel/Passport],AdditionalInformation) 
VALUES (1, N'Marzena', N'Piach', N'ul. Kwiatowa 124', N'Gdynia', N'00-123', N'Poland', N'987654321   ', N'marzp@guest.com', 5, N'12312312312', NULL),
(2, N'Jerzy', N'Krak', N'ul. Basztowa 12', N'Gdansk', N'00-123', N'Poland', N'983526421   ', N'jekr@guest.com', 5, N'32132132132', NULL),
(3, N'Danuta', N'Oliwka', N'ul. Rozana 124', N'Krakow', N'00-123', N'Poland', N'432134514   ', N'daol@guest.com', 1, N'23423423423', NULL),
(4, N'Kamil', N'Dudek', N'ul. Makowa 124', N'Bialystok', N'00-123', N'Poland', N'911133333   ', N'kadu@guest.com', 1, N'45645645645', NULL),
(5, N'John', N'Taylor', N'ul. 68 Reegans Road', N'Barkes Vale', N'NSW 2474', N'Australia', N'346234235   ', N'jota@guest.com', 3, N'AU 1562351 ', NULL),
(6, N'Jadwiga', N'Oleszko', N'ul. Zielona 32', N'Przemysl', N'00-123', N'Poland', N'123332211   ', N'jaol@guest.com', 4, N'90409437323', N'<Survey><Guest><FName>Jadwiga</FName><LName>Oleszko</LName></Guest><Information><Grade><Catering>4</Catering><Entertainment>4</Entertainment><Recreation>5</Recreation><Cleanness>5</Cleanness><CustomerNeeds>4</CustomerNeeds><Staff>5</Staff><Price>3</Price></Grade><Description><Aim>Wypoczynek</Aim><Praise>Na pochwałę zasługuje pokój nr 16. To mój ulubiony pokój. Widok z okna jest fenomenalny. </Praise><ToCorrection>Możecie pomyśleć o dodaniu opcji dań wegańskich w menu restauracji.</ToCorrection></Description></Information></Survey>'),
(7, N'Jan', N'Sikora', N'ul. Morska 4', N'Zielona Gora', N'00-123', N'Poland', N'999888777   ', N'jasi@guest.com', 2, N'77351221365', NULL),
(8, N'Jolanta', N'Zych', N'ul. Nagietkowa 14', N'Wroclaw', N'12-432', N'Poland', N'652123123   ', NULL, 5, N'12376317643', NULL),
(10, N'Marian', N'Oleksy', N'ul. Kosciuszki 21', N'Nowy Targ', N'11-111', N'Poland', N'982664123   ', N'maol@guest.com', 5, N'76312312312', NULL)

SET IDENTITY_INSERT Guests OFF

-- Room statuses 

CREATE TABLE RoomStates(
	ID_RoomState int NOT NULL,
	RoomState varchar(30) NOT NULL,
	Description text NULL,
 CONSTRAINT PK_RoomStates PRIMARY KEY (ID_RoomState)
 )

-- Dumping data 


INSERT INTO RoomStates
VALUES (1, N'Unoccupied', N'The room is cleaned and ready for the guest.'),
(2, N'Occupied', N'The room is not cleaned during the guest''s stay.'),
(3, N'Unoccupied - To clean', N'Requires cleaning after the guest has vacated the room.'),
(4, N'Occupied - with cleaning', N'The room is cleaned during the guest''s stay.')

-- Room types

CREATE TABLE RoomTypes(
	ID_RoomType int NOT NULL,
	Type varchar(30) NOT NULL,
	Price float NOT NULL,
	Description text NULL,
 CONSTRAINT PK_RoomTypes PRIMARY KEY (ID_RoomType)
 );

ALTER TABLE RoomTypes
ADD CONSTRAINT CHK_RoomPrice CHECK  (Price > 0);

-- Dumping data 

INSERT INTO RoomTypes
VALUES (1, N'Single', 359, N'Single room with a single bed.'),
(2, N'Double', 449, N'Double room with one double bed.'),
(3, N'Twin', 449, N'Twin room with two separate beds.'),
(4, N'Triple', 569, N'Triple room with three separate beds.'),
(5, N'Family', 650, N'Room for at least 2 adults and 2 children.'),
(6, N'Deluxe Single', 459, N'Single room with higher standard.'),
(7, N'Deluxe Double', 519, N'A double room with a higher standard.'),
(8, N'Apartment', 858, N'Two-room suite with double bed.');


-- Rooms 

CREATE TABLE Rooms (
	ID_Room int NOT NULL,
	Floor varchar(2) NOT NULL,
	ID_RoomType int NOT NULL,
	RoomNo varchar(2) NOT NULL,
	ID_RoomState int NOT NULL,
 CONSTRAINT PK_Rooms PRIMARY KEY (ID_Room)
 );

ALTER TABLE Rooms 
ADD  CONSTRAINT FK_Room_RoomType FOREIGN KEY (ID_RoomType)
REFERENCES RoomTypes (ID_RoomType)

ALTER TABLE Rooms 
ADD  CONSTRAINT FK_Room_RoomState FOREIGN KEY (ID_RoomState)
REFERENCES RoomStates (ID_RoomState)

-- Dumping data

INSERT INTO Rooms 
VALUES (1, N'1', 1, N'1', 2),
(2, N'2', 1, N'9', 3),
(3, N'1', 2, N'2', 1),
(4, N'2', 2, N'10', 1),
(5, N'1', 3, N'3', 1),
(6, N'2', 3, N'11', 1),
(7, N'1', 4, N'4', 1),
(8, N'2', 4, N'12', 1),
(9, N'1', 5, N'5', 1),
(10, N'2', 5, N'13', 1),
(11, N'1', 6, N'6', 1),
(12, N'2', 6, N'14', 1),
(13, N'1', 7, N'7', 1),
(14, N'2', 7, N'15', 1),
(15, N'1', 8, N'8', 3),
(16, N'2', 8, N'16', 1);

-- Services

CREATE TABLE HotelServices (
	ID_Service int NOT NULL,
	Name varchar(50) NOT NULL,
	Price float NOT NULL,
	TimeUnit char(1) NOT NULL,
	Description text NULL,
	AdditionalInformation XML NULL
 CONSTRAINT PK_HotelServices PRIMARY KEY (ID_Service)
 );

 ALTER TABLE HotelServices 
 ADD CHECK (Price > 0);

-- Dumping data

INSERT INTO HotelServices
VALUES (1, N'Bio Sauna', 30, N'H', N'The biosauna is a sauna with a lower temperature and dry humidity than in most saunas. 
In this sauna, water is not poured directly onto the stones and the aroma mixtures evaporate from the evaporator located on the stove.',NULL),
(2, N'Swimming pool', 50, N'H', N'Outdoor, year-round leisure pool measuring 5 x 10 m.',NULL),
(3, N'VIP Jacuzzi', 299, N'H', N'Romantic moments spent in the jacuzzi - exclusive hire (21:00-22:00)
including a fruity snack.',NULL),
(4, N'Car rental', 50, N'D', N'You can rent a car.',NULL),
(5, N'Conference room rental', 150, N'H', N'A room consisting of two modules, divided by a sliding wall,
with direct access to the garden with barbecue.',NULL),
(6, N'Guarded parking', 20, N'D', N'Guarded car park',NULL),
(7, N'Relaxing massage', 289, N'H', N'It is a very gentle treatment, conducted in a calm, calming atmosphere, 
which allows the patient to take their mind off their problems and relax fully.',NULL),
(8, N'Stone massage', 289, N'H', N'The hot stone massage has a physiotherapeutic effect.
It restores the efficiency of damaged organs and, at the same time, promotes rest and regeneration. 
It thus increases the body''s exercise capacity.',NULL),
(9, N'Chinese bubble massage', 159, N'H', N'The Chinese bubble massage acts like a lymphatic drainage. Improves blood circulation,
speeds up metabolism and removes excess toxic substances.',NULL),
(10, N'Mud bath', 120, N'H', N'A mud bath is an excellent spa treatment, regenerating the body and also beneficial to health. Mud is used for this.',NULL);



-- Reservations states

CREATE TABLE BookingStatuses(
	ID_BookingStatus int NOT NULL,
	BookingStatus varchar(15) NOT NULL,
	Description text NULL,
 CONSTRAINT PK_BookingStatuses PRIMARY KEY (ID_BookingStatus)
 );

-- Dumping data

INSERT INTO BookingStatuses
VALUES (1, N'Confirmed', N'A booking that is confirmed by a deposit paid.'),
(2, N'Unconfirmed', N'A booking that is unconfirmed.'),
(3, N'Awaiting', N'Booking status in case of no rooms available.');

-- Bookings  

CREATE TABLE Bookings(
	ID_Booking int IDENTITY(1,1) NOT NULL,
	ID_Guest int NOT NULL,
	DateFrom smalldatetime NULL,
	DateTo smalldatetime NULL,
	NumberOfRooms int NOT NULL,
	ID_BookingStatus int NOT NULL,
	BookingDate smalldatetime NULL,
	NumberOfGuests int NOT NULL,
	CONSTRAINT PK_Bookings PRIMARY KEY (ID_Booking)
);

ALTER TABLE Bookings
ADD CONSTRAINT FK_Bookings_Guests FOREIGN KEY (ID_Guest)
REFERENCES Guests (ID_Guest);

ALTER TABLE Bookings
ADD CONSTRAINT FK_Bookings_BookingStatuses FOREIGN KEY (ID_BookingStatus)
REFERENCES BookingStatuses (ID_BookingStatus);

-- Dumping data

SET IDENTITY_INSERT Bookings ON
INSERT INTO Bookings (ID_Booking, ID_Guest, DateFrom, DateTo, NumberOfRooms, ID_BookingStatus, BookingDate, NumberOfGuests)
VALUES (1, 2, CAST(N'2023-05-01T00:00:00' AS SmallDateTime), CAST(N'2023-05-04T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-03-02T00:00:00' AS SmallDateTime), 1),
(2, 3, CAST(N'2023-05-03T00:00:00' AS SmallDateTime), CAST(N'2023-05-08T00:00:00' AS SmallDateTime), 1, 1, CAST(N'2022-03-10T00:00:00' AS SmallDateTime), 2),
(3, 4, CAST(N'2023-05-05T00:00:00' AS SmallDateTime), CAST(N'2023-05-10T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-03-05T00:00:00' AS SmallDateTime), 3),
(4, 5, CAST(N'2023-05-04T00:00:00' AS SmallDateTime), CAST(N'2023-05-06T00:00:00' AS SmallDateTime), 2, 2, CAST(N'2022-03-11T00:00:00' AS SmallDateTime), 4),
(5, 6, CAST(N'2023-05-02T00:00:00' AS SmallDateTime), CAST(N'2023-05-10T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-03-16T00:00:00' AS SmallDateTime), 1),
(6, 7, CAST(N'2023-05-06T00:00:00' AS SmallDateTime), CAST(N'2023-05-10T00:00:00' AS SmallDateTime), 1, 1, CAST(N'2022-03-18T00:00:00' AS SmallDateTime), 2),
(7, 1, CAST(N'2023-05-11T00:00:00' AS SmallDateTime), CAST(N'2023-05-12T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-03-11T00:00:00' AS SmallDateTime), 1),
(8, 6, CAST(N'2023-01-01T00:00:00' AS SmallDateTime), CAST(N'2023-01-04T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-05-22T10:21:00' AS SmallDateTime), 1),
(9, 3, CAST(N'2022-06-12T00:00:00' AS SmallDateTime), CAST(N'2022-06-18T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-06-12T08:22:00' AS SmallDateTime), 1),
(10, 10, CAST(N'2023-05-06T00:00:00' AS SmallDateTime), CAST(N'2023-05-10T00:00:00' AS SmallDateTime), 1, 1, CAST(N'2022-08-15T14:28:00' AS SmallDateTime), 1),
(12, 4, CAST(N'2022-08-16T00:00:00' AS SmallDateTime), CAST(N'2022-08-20T00:00:00' AS SmallDateTime), 1, 1, CAST(N'2022-08-16T20:43:00' AS SmallDateTime), 1),
(14, 6, CAST(N'2022-08-16T00:00:00' AS SmallDateTime), CAST(N'2022-08-17T00:00:00' AS SmallDateTime), 1, 2, CAST(N'2022-08-16T21:13:00' AS SmallDateTime), 1),
(15, 2, CAST(N'2022-08-15T00:00:00' AS SmallDateTime), CAST(N'2022-08-20T00:00:00' AS SmallDateTime), 1, 1, CAST(N'2022-08-16T21:27:00' AS SmallDateTime), 1)
SET IDENTITY_INSERT Bookings OFF;

-- Rooms booked 

CREATE TABLE BookingRooms (
	ID_Booking int NOT NULL,
	ID_Room int NOT NULL,
	ID_BookingRoom int IDENTITY(1,1) NOT NULL,
CONSTRAINT PK_BookingRooms PRIMARY KEY (ID_BookingRoom)
);

ALTER TABLE BookingRooms 
ADD CONSTRAINT FK_BookingRooms_Rooms FOREIGN KEY(ID_Room)
REFERENCES Rooms (ID_Room);

ALTER TABLE BookingRooms
ADD  CONSTRAINT FK_BookingRooms_Bookings FOREIGN KEY (ID_Booking)
REFERENCES Bookings (ID_Booking);


-- Dumping data

SET IDENTITY_INSERT BookingRooms ON 

INSERT INTO BookingRooms (ID_Booking,ID_Room,ID_BookingRoom)
VALUES (1, 1, 1),
(2, 3, 2),
(3, 9, 3),
(4, 15, 4),
(5, 12, 5),
(6, 13, 6),
(7, 2, 7),
(4, 4, 8),
(8, 11, 9),
(9, 11, 10),
(10, 1, 11),
(12, 1, 14),
(14, 2, 16),
(15, 16, 17);

SET IDENTITY_INSERT BookingRooms OFF

-- Booking services

CREATE TABLE ReservationOfServices (
	ID_Booking int NOT NULL,
	ID_Service int NOT NULL,
	StartDate smalldatetime NOT NULL,
	ID_Employee int NOT NULL,
	Description text NULL,
	EndDate smalldatetime NOT NULL,
	ID_ReservationOfService int IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK_ID_ReservationOfService PRIMARY KEY (ID_ReservationOfService)
);

ALTER TABLE ReservationOfServices
ADD CONSTRAINT FK_ReservationOfServices_Employees FOREIGN KEY (ID_Employee)
REFERENCES Employees (ID_Employee);

ALTER TABLE ReservationOfServices
ADD CONSTRAINT FK_ReservationOfServices_HotelServices FOREIGN KEY (ID_Service)
REFERENCES HotelServices (ID_Service);

ALTER TABLE ReservationOfServices
ADD CONSTRAINT FK_ReservationOfServices_Bookings FOREIGN KEY (ID_Booking)
REFERENCES Bookings (ID_Booking);

ALTER TABLE ReservationOfServices
ADD CHECK (StartDate < EndDate);

-- Dumping data


SET IDENTITY_INSERT ReservationOfServices ON 

INSERT INTO ReservationOfServices (ID_Booking, ID_Service, StartDate, ID_Employee, Description, EndDate, ID_ReservationOfService) 
VALUES (5, 7, CAST(N'2023-05-04T13:30:00' AS SmallDateTime), 5, NULL, CAST(N'2023-05-04T14:30:00' AS SmallDateTime), 1),
(5, 6, CAST(N'2023-05-02T00:00:00' AS SmallDateTime), 1, NULL, CAST(N'2023-05-10T00:00:00' AS SmallDateTime), 2),
(3, 9, CAST(N'2023-05-05T14:30:00' AS SmallDateTime), 5, NULL, CAST(N'2023-05-05T15:30:00' AS SmallDateTime), 3),
(6, 2, CAST(N'2023-05-07T12:00:00' AS SmallDateTime), 4, NULL, CAST(N'2023-05-07T14:00:00' AS SmallDateTime), 4),
(10, 8, CAST(N'2023-05-08T14:00:00' AS SmallDateTime), 5, NULL, CAST(N'2023-05-08T15:00:00' AS SmallDateTime), 5),
(12, 8, CAST(N'2022-08-17T14:00:00' AS SmallDateTime), 5, NULL, CAST(N'2022-08-17T15:00:00' AS SmallDateTime), 7),
(14, 8, CAST(N'2022-08-16T14:00:00' AS SmallDateTime), 5, NULL, CAST(N'2022-08-16T15:00:00' AS SmallDateTime), 9)

SET IDENTITY_INSERT ReservationOfServices OFF

-- Method of payments

CREATE TABLE PaymentMethods (
	ID_PaymentMethod int NOT NULL,
	Method varchar(20) NOT NULL,
 CONSTRAINT PK_PaymentMethods PRIMARY KEY (ID_PaymentMethod)
 );

 -- Dumping data

 INSERT PaymentMethods
 VALUES (1, N'Cash'),
(2, N'Transfer'),
(3, N'Card'),
(4, N'Card + cash');

-- Payments 

CREATE TABLE Payments (
	ID_Payment int IDENTITY(1,1) NOT NULL,
	ID_Booking int NOT NULL,
	TotalAmountToPay float NOT NULL,
	ID_PaymentMethod int NOT NULL,
	PaymentTerm smalldatetime NULL,
	DateOfPayment smalldatetime NULL,
	Deposit float NULL,
	StatusOfAdditionalServices char(2) NULL,
 CONSTRAINT PK_Payments PRIMARY KEY (ID_Payment)
)

ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_PaymentMethods FOREIGN KEY (ID_PaymentMethod)
REFERENCES PaymentMethods (ID_PaymentMethod);

ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_Bookings FOREIGN KEY (ID_Booking)
REFERENCES Bookings (ID_Booking);

ALTER TABLE Payments
ADD UNIQUE (ID_Booking);

-- Dumping data


SET IDENTITY_INSERT Payments ON 

INSERT INTO Payments (ID_Payment, ID_Booking, TotalAmountToPay, ID_PaymentMethod, PaymentTerm, DateOfPayment, Deposit, StatusOfAdditionalServices) 
VALUES (1, 1, 1077, 1, CAST(N'2023-05-18T00:00:00' AS SmallDateTime), NULL, NULL, NULL),
(2, 2, 1796, 1, CAST(N'2023-05-22T00:00:00' AS SmallDateTime), NULL, 449, NULL),
(3, 3, 3250, 1, CAST(N'2023-05-24T00:00:00' AS SmallDateTime), NULL, NULL, NULL),
(4, 4, 1716, 1, CAST(N'2023-05-20T00:00:00' AS SmallDateTime), NULL, NULL, NULL),
(5, 5, 3672, 1, CAST(N'2023-05-24T00:00:00' AS SmallDateTime), NULL, NULL, NULL),
(6, 6, 1660.8, 1, CAST(N'2023-05-24T00:00:00' AS SmallDateTime), CAST(N'2022-05-22T11:32:00' AS SmallDateTime), 415.20000000000005, NULL),
(7, 7, 359, 3, CAST(N'2023-05-26T00:00:00' AS SmallDateTime), CAST(N'2022-05-21T09:32:00' AS SmallDateTime), NULL, NULL),
(9, 8, 1377, 1, CAST(N'2023-01-04T00:00:00' AS SmallDateTime), NULL, NULL, NULL),
(10, 10, 1148.8, 1, CAST(N'2023-05-10T00:00:00' AS SmallDateTime), NULL, 287.2, NULL),
(12, 12, 1437.8, 1, CAST(N'2022-08-20T00:00:00' AS SmallDateTime), NULL, 287.2, N'OK'),
(14, 14, 648, 3, CAST(N'2022-08-17T00:00:00' AS SmallDateTime), CAST(N'2022-08-17T19:44:00' AS SmallDateTime), NULL, N'OK'),
(15, 15, 3775.2, 1, CAST(N'2022-08-20T00:00:00' AS SmallDateTime), NULL, 514.80000000000007, NULL)

SET IDENTITY_INSERT Payments OFF

-- Reports types

CREATE TABLE ReportsTypes(
ID_ReportType char(2) NOT NULL,
Name varchar(20) NOT NULL,
Description text NULL,
CONSTRAINT PK_ReportsTypes PRIMARY KEY (ID_ReportType)
)

-- USALI Reports

CREATE TABLE USALIReports (
ID_Report int IDENTITY(1,1) NOT NULL,
ID_ReportType char(2) NOT NULL,
Report XML NOT NULL,
DateOfReport smalldatetime
CONSTRAINT PK_ID_Report PRIMARY KEY (ID_Report)
)

ALTER TABLE USALIReports 
ADD CONSTRAINT FK_USALIReports_ReportsTypes FOREIGN KEY(ID_ReportType)
REFERENCES ReportsTypes (ID_ReportType)
GO

-- Types of expenses

CREATE TABLE ExpensesType (
ID_ExpenseCode char(4) NOT NULL,
Name varchar(30) NOT NULL,
Description text NULL
CONSTRAINT PK_ID_ExpenseCode PRIMARY KEY (ID_ExpenseCode)
)

-- Expenses

CREATE TABLE Expenses (
ID_Expense int IDENTITY(1,1) NOT NULL,
DeptNo char(3) NOT NULL,
ID_ExpenseCode char(4) NOT NULL,
Amount float NOT NULL,
DateOfPurchase smalldatetime NOT NULL,
AdditionalInformation text NULL
CONSTRAINT PK_Expense PRIMARY KEY (ID_Expense)
)

ALTER TABLE Expenses 
ADD CONSTRAINT FK_Expenses_Department FOREIGN KEY(DeptNo)
REFERENCES Departments (DeptNo)
GO


ALTER TABLE Expenses
ADD CONSTRAINT FK_Expenses_ExpensesType FOREIGN KEY(ID_ExpenseCode)
REFERENCES ExpensesType (ID_ExpenseCode)
GO




