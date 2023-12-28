CREATE VIEW TripPrice AS
	SELECT Trip.*, Price
	FROM Trip 
	JOIN Payment USING (PaymentID);

CREATE VIEW TripCar AS
	SELECT Trip.*, Car.* 
	FROM Trip 
	JOIN Driver_Car USING (Driver_CarID)
	JOIN Car USING (CarID);
	
CREATE VIEW CreditCardHolder AS
	SELECT CreditCard.*, FirstName, LastName
	FROM CreditCard
	JOIN Person USING (PersonID)