\copy Credentials(CredentialsID,Login,Password) FROM 'import/Credentials.csv' DELIMITER ',' CSV HEADER

\copy Person(PersonID,FirstName,LastName,Gender,RegistrationDate,Rating,CredentialsID,IsDriver,LicenceNumber,PhotoURL) FROM 'import/Person.csv' DELIMITER ',' CSV HEADER

-- mockaroo FuelType values are replaced in additional_queries.sql
ALTER TABLE Car ALTER COLUMN FuelType TYPE VARCHAR(20);

\copy Car(CarID,RegistrationNumber,DateOfRegistration,Model,Type,Class,IdentificationNumber,FuelType,Color,NumberOfSeats) FROM 'import/Car.csv' DELIMITER ',' CSV HEADER

ALTER TABLE Car ALTER COLUMN FuelType TYPE VARCHAR(1) USING LEFT(FuelType, 1);

-- Filling Driver_Car (10 different random cars for each driver)
SELECT PersonID
INTO Driver
FROM Person
WHERE IsDriver = true;

INSERT INTO Driver_Car(PersonID, CarID)
	SELECT PersonID, CarID
	FROM (
		SELECT Driver.PersonID, Car.CarID,
			   ROW_NUMBER() OVER (PARTITION BY Driver.PersonID ORDER BY random()) AS CarNumber
		FROM Driver
		CROSS JOIN Car
	) AS RandomCars
	WHERE CarNumber <= 10;

DROP TABLE Driver;



\copy Address(AddressID,City,Street,Building,Note) FROM 'import/Address.csv' DELIMITER ',' CSV HEADER


\copy SavedAddress(SavedAddressID,PersonID,AddressID) FROM 'import/SavedAddress.csv' DELIMITER ',' CSV HEADER

\copy CreditCard(CreditCardID,Number,ExpirationDate,CVV,PersonID) FROM 'import/CreditCard.csv' DELIMITER ',' CSV HEADER

UPDATE CreditCard 
SET Number = concat(lpad(floor(random() * 10^8)::TEXT, 8, '0'),
					lpad(floor(random() * 10^8)::TEXT, 8, '0'));


\copy Payment(PaymentID,CreditCardID,Price,PaymentTime,Status) FROM 'import/Payment.csv' DELIMITER ',' CSV HEADER

UPDATE Payment
SET Status = 'C';


-- mockaroo Distance values are fractional, real distances are calculated in additional_queries.sql
ALTER TABLE Trip ALTER COLUMN Distance TYPE NUMERIC;

\copy Trip(TripID,Driver_CarID,PersonID,StartTime,EndTime,DepartureAddressID,DestinationAddressID,PaymentID,Distance,Status) FROM 'import/Trip.csv' DELIMITER ',' CSV HEADER

ALTER TABLE Trip ALTER COLUMN Distance TYPE INT USING ROUND(Distance);

UPDATE Trip
SET Status = 'C';



\copy Review(ReviewID,TripID,Sender,Rating,Note) FROM 'import/Review.csv' DELIMITER ',' CSV HEADER


\copy Message(MessageID,TripID,Sender,DispatchTime,Status,TextContent) FROM 'import/Message.csv' DELIMITER ',' CSV HEADER

UPDATE Message 
SET Status = 'C';


