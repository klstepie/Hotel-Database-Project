-- Creating views

CREATE VIEW v_EmployeesPosition
AS
SELECT ID_Employee, FirstName, LastName, Position
FROM Employees;

CREATE VIEW v_UnpaidBookings
AS
SELECT p.ID_Booking, g.FirstName, g.LastName, g.Address + ' ' + g.PostCode + ' ' + g.City AS Address,
r.RoomNo, CONVERT(varchar,b.DateFrom,105) as 'Arrival', CONVERT(varchar,b.DateTo,105) as 'Departure', 
p.TotalAmountToPay, p.PaymentTerm, p.DateOfPayment
FROM Payments AS p
JOIN Bookings AS b
ON b.ID_Booking = p.ID_Booking
JOIN Guests AS g
ON g.ID_Guest = b.ID_Guest
JOIN BookingRooms AS br
ON br.ID_Booking = b.ID_Booking
JOIN Rooms AS r
ON r.ID_Room = br.ID_Room
WHERE p.DateOfPayment IS NULL;


CREATE VIEW v_EmployeesAndBookingServices
AS
SELECT e.ID_Employee, e.FirstName + ' ' + e.LastName AS 'Name of employee', 
e.Position, hs.Name AS 'Name of service performed', 
CONVERT(varchar,rs.StartDate,105) AS 'Start date', 
CONVERT(varchar,rs.StartDate,8) AS 'Start time',
CONVERT(varchar,rs.EndDate,105) AS 'End date',
CONVERT(varchar,rs.EndDate,8) AS 'End time',
g.ID_Guest, g.FirstName + ' ' + g.LastName AS 'Name of guest'
FROM Employees AS e
JOIN ReservationOfServices AS rs
ON e.ID_Employee = rs.ID_Employee
JOIN HotelServices AS hs
ON rs.ID_Service = hs.ID_Service
JOIN Bookings AS b
ON rs.ID_Booking = b.ID_Booking
JOIN Guests AS g
ON g.ID_Guest = b.ID_Guest;

CREATE VIEW v_RoomsToClean
AS
SELECT 
r.ID_Room, r.Floor, t.Type, r.RoomNo, rs.RoomState
FROM Rooms AS r
JOIN RoomTypes AS t
ON t.ID_RoomType = r.ID_RoomType
JOIN RoomStates AS rs
ON rs.ID_RoomState = r.ID_RoomState
WHERE r.ID_RoomState = 4 OR r.ID_RoomState = 3;

CREATE VIEW v_DepartureList
AS
SELECT b.ID_Booking, g.FirstName , g.LastName, r.Floor, r.RoomNo,
CONVERT(varchar,b.DateFrom,105) as 'Arrival', 
CONVERT(varchar,b.DateTo,105) as 'Departure'
FROM Rooms AS r
JOIN RoomTypes AS rt
ON r.ID_RoomType = rt.ID_RoomType
JOIN BookingRooms AS br
ON br.ID_Room = r.ID_Room
JOIN Bookings AS b
ON b.ID_Booking = br.ID_Booking
JOIN Guests AS g
ON g.ID_Guest = b.ID_Guest
WHERE b.DateFrom >= GETDATE();


CREATE VIEW v_CostOfServices 
AS
SELECT rs.ID_Booking, rs.ID_Service,
CASE
WHEN hs.TimeUnit = 'D' THEN DATEDIFF(DAY,rs.StartDate,rs.EndDate) * hs.Price
WHEN hs.TimeUnit = 'H' THEN DATEDIFF(HOUR,rs.StartDate,rs.EndDate) * hs.Price
END AS AmountToPay
FROM ReservationOfServices AS rs
JOIN HotelServices AS hs
ON rs.ID_Service = hs.ID_Service;

CREATE VIEW v_AccomodationCost
AS
SELECT b.ID_Booking ,SUM(rt.Price * CONVERT(int,DATEDIFF(DAY,b.DateFrom,b.DateTo))) AS Total
FROM Rooms AS r
JOIN RoomTypes AS rt
ON r.ID_RoomType = rt.ID_RoomType
JOIN BookingRooms AS br
ON br.ID_Room = r.ID_Room
JOIN Bookings AS b
ON br.ID_Booking = b.ID_Booking
GROUP BY b.ID_Booking;

CREATE VIEW v_BookingsPaid
AS 
SELECT p.ID_Booking, g.FirstName, g.LastName, g.Address + ' ' + g.PostCode + ' ' + g.City AS 'Address',
r.RoomNo, CONVERT(char,b.DateFrom,105) AS 'Arrival', CONVERT(char,b.DateTo,105) AS 'Departure',
p.TotalAmountToPay, p.PaymentTerm, p.DateOfPayment, pm.Method
FROM Payments AS p
JOIN Bookings AS b
ON p.ID_Booking = b.ID_Booking
JOIN Guests AS g
ON b.ID_Guest = g.ID_Guest
JOIN BookingRooms AS br
ON br.ID_Booking = b.ID_Booking
JOIN Rooms AS r
ON r.ID_Room = br.ID_Room
JOIN PaymentMethods AS pm
ON pm.ID_PaymentMethod = p.ID_PaymentMethod
WHERE p.DateOfPayment IS NOT NULL;


CREATE VIEW v_RoomStatus
AS
SELECT r.ID_Room, r.Floor, rt.Type, r.RoomNo, rs.RoomState
FROM Rooms AS r
JOIN RoomTypes AS rt
ON r.ID_RoomType = rt.ID_RoomType
JOIN RoomStates AS rs
ON r.ID_RoomState = rs.ID_RoomState

-- Sum of the individual services on the booking

CREATE VIEW v_TotalServicesPerBooking
AS
SELECT ID_Booking, ID_Service, SUM(AmountToPay) AS SumOfServices
FROM v_CostOfServices
GROUP BY ID_Booking, ID_Service


