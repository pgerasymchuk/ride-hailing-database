-- set LicenceNumber to NULL where IsDriver is false
UPDATE Person
SET LicenceNumber = NULL
WHERE IsDriver = False;


-- set 50% / 40% / 10% gasoline/diesel/electric fuel type
update car set fueltype = '0';

UPDATE Car
SET FuelType = 'G'
WHERE random() < 0.5;

UPDATE Car 
SET FuelType = 'D'
WHERE random() < 0.8 AND FuelType != 'G';

UPDATE Car 
SET FuelType = 'E'
WHERE FuelType != 'G' AND FuelType != 'D';


UPDATE Address
SET Street = SPLIT_PART(Street, ',', 1);


-- modifying trip attributes
ALTER TABLE Trip 
ALTER COLUMN StartTime TYPE timestamp;
ALTER TABLE Trip 
ALTER COLUMN EndTime TYPE timestamp;


UPDATE Trip
SET StartTime = timestamp '2021-01-01' + random()*interval '1 year';

UPDATE Trip 
SET StartTime = 
	CASE 
		WHEN EXTRACT(HOUR FROM StartTime) < 6 
			THEN StartTime + interval '6 hours'
		ELSE StartTime
	END;
	
UPDATE Trip
SET EndTime = StartTime + interval '10 minutes' + 
			  random()*interval '1 hour';


UPDATE Trip 
SET Distance = (EXTRACT(EPOCH FROM (EndTime - StartTime)))/60*500*
			   (1 + random()*0.2);


UPDATE Payment
SET Price = 50 * (1 + random()*0.2) + 0.01 * distance
			 FROM Trip 
			 WHERE Trip.PaymentID = Payment.PaymentID;


UPDATE Payment
SET PaymentTime = Trip.StartTime + 
                  random()*(Trip.EndTime - Trip.StartTime)
	FROM Trip 
	WHERE Trip.PaymentID = Payment.PaymentID;


UPDATE Message
SET DispatchTime = Trip.StartTime + 
                           random()*(Trip.EndTime - Trip.StartTime)
	FROM Trip 
	WHERE Trip.TripID = Message.TripID;


UPDATE Car 
SET Type = (ARRAY['Small','Usual','Van'])[ceiling(random()*3)];

UPDATE Car 
SET Class = (ARRAY['Classic','Business','Premium'])[ceiling(random()*3)];

UPDATE Car 
SET NumberOfSeats = (
	CASE 
		WHEN Type = 'Small' THEN 1
		WHEN Type = 'Usual' THEN 4
		WHEN Type = 'Van' THEN 8
	END
);

-- synchronyzing credit card holder with passenger
UPDATE Trip tr
SET PersonID = cc.PersonID
FROM CreditCard cc
JOIN Payment p ON cc.CreditCardID = p.CreditCardID
WHERE p.PaymentID = tr.PaymentID;

-- 1% unsuccessful payments
update payment
set status = 'U'
where random() < 0.01;


update review
set note = substring(md5(random()::TEXT),1, ceiling(random()*50)::INT)
where random() < 0.6;


update message
set textcontent = substring(textcontent,1,ceiling(random()*200)::INT);