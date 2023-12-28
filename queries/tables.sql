CREATE TABLE Credentials (
	CredentialsID SERIAL PRIMARY KEY,
	Login VARCHAR(10) NOT NULL,
	Password VARCHAR(10) NOT NULL
);

CREATE TABLE Person (
	PersonID SERIAL PRIMARY KEY, 
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Gender VARCHAR(1) NOT NULL, 
	RegistrationDate DATE NOT NULL, 
	Rating INT NOT NULL,
	CredentialsID INT NOT NULL,
	IsDriver BOOL NOT NULL, 
	LicenceNumber VARCHAR(10),
	PhotoURL VARCHAR(50), 
	FOREIGN KEY(CredentialsID) 
		REFERENCES Credentials(CredentialsID) 
);

CREATE TABLE Car (
	CarID SERIAL PRIMARY KEY,
	RegistrationNumber VARCHAR(20) NOT NULL,
	DateOfRegistration DATE NOT NULL,
	Model VARCHAR(30) NOT NULL,
	Type VARCHAR(20) NOT NULL,
	Class VARCHAR(20) NOT NULL,
	IdentificationNumber VARCHAR(8) NOT NULL,
	FuelType VARCHAR(1) NOT NULL,
	Color VARCHAR(10) NOT NULL, 
	NumberOfSeats INT NOT NULL
);

CREATE TABLE Driver_Car (
	Driver_CarID SERIAL PRIMARY KEY,
	PersonID INT NOT NULL,
	CarID INT NOT NULL,
	FOREIGN KEY(PersonID) 
		REFERENCES Person(PersonID),
	FOREIGN KEY(CarID)
		REFERENCES Car(CarID)
);

CREATE TABLE CreditCard (
	CreditCardID SERIAL PRIMARY KEY, 
	Number VARCHAR(16) NOT NULL,
	ExpirationDate DATE NOT NULL,
	CVV VARCHAR(3) NOT NULL,
	PersonID INT NOT NULL,
	FOREIGN KEY (PersonID) 
		REFERENCES Person(PersonID)
);

CREATE TABLE Payment (
	PaymentID SERIAL PRIMARY KEY, 
	CreditCardID INT NOT NULL, 
	Price NUMERIC(6,2) NOT NULL,
	PaymentTime TIMESTAMP NOT NULL,
	Status VARCHAR(1) NOT NULL,
	FOREIGN KEY(CreditCardID) 
		REFERENCES CreditCard(CreditCardID)
);

CREATE TABLE Address (
	AddressID SERIAL PRIMARY KEY,
	City VARCHAR(50) NOT NULL,
	Street VARCHAR(50) NOT NULL,
	Building VARCHAR(5) NOT NULL,
	Note VARCHAR(50)
);

CREATE TABLE Trip (
	TripID SERIAL PRIMARY KEY,
	Driver_CarID INT NOT NULL,
	PersonID INT NOT NULL,
	StartTime TIMESTAMP NOT NULL,
	EndTime TIMESTAMP NOT NULL,
	DepartureAddressID INT NOT NULL,
	DestinationAddressID INT NOT NULL,
	PaymentID INT NOT NULL, 
	Distance INT NOT NULL,
	Status VARCHAR(1) NOT NULL,
	FOREIGN KEY(Driver_CarID)
		REFERENCES Driver_Car(Driver_CarID),
	FOREIGN KEY(PersonID)
		REFERENCES Person(PersonID),
	FOREIGN KEY(DepartureAddressID)
		REFERENCES Address(AddressID),
	FOREIGN KEY(DestinationAddressID)
		REFERENCES Address(AddressID),
	FOREIGN KEY(PaymentID)
		REFERENCES Payment(PaymentID)
);

CREATE TABLE Review (
	ReviewID SERIAL PRIMARY KEY,
	TripID INT NOT NULL,
	Sender BOOL NOT NULL,
	Rating INT NOT NULL,
	Note VARCHAR(50),
	FOREIGN KEY(TripID) 
		REFERENCES Trip(TripID)
);

CREATE TABLE Message (
	MessageID SERIAL PRIMARY KEY,
	TripID INT NOT NULL,
	Sender BOOL NOT NULL,
	DispatchTime TIMESTAMP NOT NULL,
	Status VARCHAR(1) NOT NULL,
	TextContent VARCHAR(200) NOT NULL,
	FOREIGN KEY(TripID)
		REFERENCES Trip(TripID)
);

CREATE TABLE SavedAddress (
	SavedAddressID SERIAL PRIMARY KEY, 
	PersonID INT NOT NULL,
	AddressID INT NOT NULL,
	FOREIGN KEY(PersonID) 
		REFERENCES Person(PersonID),
	FOREIGN KEY(AddressID)
		REFERENCES Address(AddressID)
);

