
-- Create Database
CREATE DATABASE Hotel
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Hotel', 
FILENAME = N'Z:\Hotel.mdf' , 
SIZE = 20MB , 
MAXSIZE = UNLIMITED, 
FILEGROWTH = 5MB )
 LOG ON 
( NAME = N'Hotel_Log', 
FILENAME = N'Z:Hotel_log.ldf' , 
SIZE = 10MB , 
MAXSIZE = 40MB , 
FILEGROWTH = 5MB )
GO

-- Create Tables

USE Hotel

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
	[PhoneNumber] [char](12) NULL,
	[PESEL] [char](11) NOT NULL,
	[EmploymentStatus] [varchar](11) NOT NULL
 CONSTRAINT PK_Employees PRIMARY KEY (ID_Employee))

ALTER TABLE [dbo].[Employees]
ADD CONSTRAINT DF_Employed DEFAULT ('Employed') FOR EmploymentStatus

ALTER TABLE [dbo].[Employees]
ADD CONSTRAINT CHK_Status
CHECK (([EmploymentStatus]='Employed' OR [EmploymentStatus]='Fired'))

ALTER TABLE [dbo].[Employees] 
ADD CHECK  (([PhoneNumber] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))

ALTER TABLE [dbo].[Employees]  
ADD CHECK  (([PESEL] LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))


-- Dumping data 

INSERT INTO Employees 
VALUES (1, N'Jan', N'Kowalski', N'Parkingowa/y', N'ul. Motylkowa 2', N'Wroc�aw', N'00-000', N'Polska', N'876321123   ', N'11111111111', N'Employed'),
(2, N'Maria', N'Nowak', N'Pokojowa/y', N'ul. R�ana 2', N'Rzesz�w', N'00-001', N'Polska', N'876321111   ', N'22222222222', N'Employed'),
(3, N'Monika', N'Wichura', N'Pokojowa/y', N'ul. Bratkowa 2', N'Krak�w', N'00-002', N'Polska', N'876321122   ', N'33333333333', N'Employed'),
(4, N'�ukasz', N'Biegun', N'Ratownik', N'ul. Irysowa 2', N'Hel', N'00-003', N'Polska', N'876321133   ', N'44444444444', N'Employed'),
(5, N'J�zef', N'Stachowski', N'Masa�ysta/ka', N'ul. Rzepakowa 2', N'Wroc�aw', N'00-004', N'Polska', N'876321144   ', N'55555555555', N'Employed'),
(6, N'Anna', N'Wo�niak', N'Kierownik recepcji', N'ul. Ziemniaczana 2', N'Wroc�aw', N'00-005', N'Polska', N'876321155   ', N'66666666666', N'Employed'),
(7, N'Krzysztof', N'P�k', N'Recepcjonista/ka', N'ul. Marchewkowa 2', N'Wroc�aw', N'00-006', N'Polska', N'876321166   ', N'77777777777', N'Employed')

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
VALUES (1, N'Marzena', N'Piach', N'ul. Kwiatowa 124', N'Gdynia', N'00-123', N'Polska', N'987654321   ', N'marzp@guest.com', 5, N'12312312312', NULL),
(2, N'Jerzy', N'Krak', N'ul. Basztowa 12', N'Gda�sk', N'00-123', N'Polska', N'983526421   ', N'jekr@guest.com', 5, N'32132132132', NULL),
(3, N'Danuta', N'Oliwka', N'ul. R�ana 124', N'Krak�w', N'00-123', N'Polska', N'432134514   ', N'daol@guest.com', 1, N'23423423423', NULL),
(4, N'Kamil', N'Dudek', N'ul. Makowa 124', N'Bia�ystok', N'00-123', N'Polska', N'911133333   ', N'kadu@guest.com', 1, N'45645645645', NULL),
(5, N'John', N'Taylor', N'ul. 68 Reegans Road', N'Barkes Vale', N'NSW 2474', N'Australia', N'346234235   ', N'jota@guest.com', 3, N'AU 1562351 ', NULL),
(6, N'Jadwiga', N'Oleszko', N'ul. Zielona 32', N'Przemy�l', N'00-123', N'Polska', N'123332211   ', N'jaol@guest.com', 4, N'90409437323', N'<Ankieta><Gosc><Imie>Jadwiga</Imie><Nazwisko>Oleszko</Nazwisko></Gosc><Informacje><Ocena><Wy�ywienie>4</Wy�ywienie><Rozrywki>4</Rozrywki><Rekreacja>5</Rekreacja><Czysto��>5</Czysto��><PotrzebyKlienta>4</PotrzebyKlienta><PracownicyObiektu>5</PracownicyObiektu><Cena>3</Cena></Ocena><Opis><Cel>Wypoczynek</Cel><Pochwa�a>Na pochwa�� zas�uguje pok�j nr 16. To m�j ulubiony pok�j. Widok z okna jest fenomenalny. </Pochwa�a><Poprawa>Mo�ecie pomy�le� o dodaniu opcji da� wega�skich w menu restauracji.</Poprawa></Opis></Informacje></Ankieta>'),
(7, N'Jan', N'Sikora', N'ul. Morska 4', N'Zielona G�ra', N'00-123', N'Polska', N'999888777   ', N'jasi@guest.com', 2, N'77351221365', NULL),
(8, N'Jolanta', N'Zych', N'ul. Nagietkowa 14', N'Wroc�aw', N'12-432', N'Polska', N'652123123   ', NULL, 5, N'12376317643', NULL),
(10, N'Marian', N'Oleksy', N'ul. Ko�ciuszki 21', N'Nowy Targ', N'11-111', N'Polska', N'982664123   ', N'maol@guest.com', 5, N'76312312312', NULL)
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

