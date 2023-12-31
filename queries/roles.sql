CREATE ROLE admin_user
SUPERUSER 
LOGIN 
PASSWORD 'admin';

CREATE ROLE driver
LOGIN
PASSWORD 'driver';

GRANT SELECT 
ON Person, Car, Driver_Car, CreditCard, Address, SavedAddress, 
   Payment, Trip, Review, Message
TO driver;

GRANT UPDATE 
ON Person, CreditCard, Trip
TO driver;

GRANT INSERT 
ON CreditCard, SavedAddress, Review, Message
TO driver;

GRANT DELETE 
ON SavedAddress
TO driver;

CREATE ROLE passenger
LOGIN 
PASSWORD 'passenger';

GRANT SELECT 
ON Person, Address, SavedAddress, Payment, Trip, Car, 
   Driver_Car, CreditCard, Review, Message
TO passenger;

GRANT UPDATE
ON Person, CreditCard
TO passenger;

GRANT INSERT 
ON CreditCard, SavedAddress, Review, Message
TO passenger;

GRANT DELETE 
ON SavedAddress
TO passenger;





CREATE ROLE read_only_user
LOGIN
PASSWORD 'read_only_user'
VALID UNTIL '2024-12-31';

GRANT SELECT 
ON ALL TABLES IN SCHEMA public
TO read_only_user;
