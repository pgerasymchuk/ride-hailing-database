ALTER TABLE Person 
ADD CONSTRAINT gender_check
CHECK (
	Gender IN ('M', 'F')
);

ALTER TABLE Person
ADD CONSTRAINT rating_check
CHECK (
	Rating BETWEEN 1 AND 100
);

ALTER TABLE Person
ADD CONSTRAINT driver_licence_check
CHECK (
	(IsDriver AND LicenceNumber IS NOT NULL) 
	OR 
	(NOT IsDriver AND LicenceNumber IS NULL)
);

ALTER TABLE Person
ADD CONSTRAINT unique_licence_number
UNIQUE (
	LicenceNumber
);

ALTER TABLE Person
ADD CONSTRAINT unique_credentials_id
UNIQUE (
	CredentialsID
);

ALTER TABLE Credentials
ADD CONSTRAINT unique_login
UNIQUE (
	Login
);
	
ALTER TABLE Car
ADD CONSTRAINT unique_registration_number
UNIQUE (
	RegistrationNumber
);
	
ALTER TABLE Car
ADD CONSTRAINT unique_identification_number
UNIQUE (
	IdentificationNumber
);

ALTER TABLE Car 
ADD CONSTRAINT fuel_type_check
CHECK (
	FuelType IN ('G', 'D', 'E')
);

ALTER TABLE CreditCard
ADD CONSTRAINT unique_card_number
UNIQUE (
	Number
);
	
ALTER TABLE Driver_Car 
ADD CONSTRAINT unique_driver_car
UNIQUE (
	PersonID, CarID
);

ALTER TABLE Review
ADD CONSTRAINT review_rating_check
CHECK (
	Rating BETWEEN 1 AND 100
);

ALTER TABLE Trip 
ADD CONSTRAINT departure_destination_check
CHECK (
	DepartureAddressID != DestinationAddressID
);

ALTER TABLE Trip
ADD CONSTRAINT unique_payment_id
UNIQUE (
	PaymentID
);

ALTER TABLE Trip
ADD CONSTRAINT departure_destination_time_check
CHECK (
	EndTime > StartTime
);