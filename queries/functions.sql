-- Процедура 1
-- Призначення: Вставити нову оплату в таблицю Payment
CREATE OR REPLACE PROCEDURE insertPayment(
        payment_id INT,
	credit_card_id INT,
	payment_price NUMERIC,
	payment_status VARCHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO Payment(PaymentID, CreditCardID, Price, PaymentTime, Status)
	VALUES (payment_id, credit_card_id, payment_price, CURRENT_TIMESTAMP, payment_status);
END;
$$;

CALL insertPayment(100001, 1, 1.23, 'C');

-- Процедура 2
-- Призначення: Змінити статус певної поїздки на вказаний
CREATE OR REPLACE PROCEDURE updateTripStatus (
	trip_id INT, 
	new_trip_status VARCHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE Trip
	SET Status = new_trip_status
	WHERE TripID = trip_id;
END;
$$;

CALL updateTripStatus(1, 'U');

-- Процедура 3
-- Призначення: Вставити новий відгук в таблицю Review
CREATE OR REPLACE PROCEDURE insertReview (
	review_id INT,
	trip_id INT,
	review_sender BOOL,
	review_rating INT,
	review_note VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO Review(ReviewID, TripID, Sender, Rating, Note)
	VALUES (review_id, trip_id, review_sender, review_rating, review_note);
END;
$$;

CALL insertReview(100001, 1, false, 50, 'abcd'); 

-- Функція 1
-- Призначення: Вивести чат (усі повідомлення) поїздки за її ідентифікатором
CREATE OR REPLACE FUNCTION getTripChat (trip_id INT)
RETURNS TABLE (
	message_sender VARCHAR(10),
	text_content VARCHAR(200),
	dispatch_time TIMESTAMP, 
	delivery_status VARCHAR(1)
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY 
		SELECT (
					CASE 
						WHEN Sender = true THEN 'Driver'::VARCHAR(10)
						ELSE 'Passenger'::VARCHAR(10)
					END
			   ),
			   TextContent,
			   DispatchTime, 
			   Status 
		FROM Message
		WHERE TripID = trip_id
		ORDER BY DispatchTime;
END;
$$;

SELECT * FROM getTripChat(1);


-- Функція 2
-- Призначення: Обчислити дохід водія за його ідентифікатором за певний період часу
CREATE OR REPLACE FUNCTION getDriverIncomeForPeriod (
	driver_id INT,
	start_date DATE,
	end_date DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE 
	income NUMERIC;
BEGIN
	SELECT SUM(Price)
	INTO income
	FROM Payment
	JOIN Trip USING (PaymentID)
	JOIN Driver_Car USING (Driver_CarID)
	WHERE Driver_Car.PersonID = driver_id
		AND Trip.StartTime > start_date
		AND Trip.StartTime < end_date;
	RETURN income;
END;
$$;

SELECT * FROM getDriverIncomeForPeriod(
	driver_id => 1,
	start_date => '2021-06-01',
	end_date => '2021-07-01'
);


-- Функція 3
-- Призначення: Вивести ідентифікатори поїздок та їх дати, за які водій отримав
--              погані відгуки, відсортувати за датою поїздки
CREATE OR REPLACE FUNCTION getTripsWithNegativeReviewsOfDriver(driver_id INT)
RETURNS TABLE (
	trip_id INT,
	trip_date DATE,
	review_id INT,
	review_rating INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
		SELECT Trip.TripID,
			   Trip.EndTime::DATE,
			   Review.ReviewID,
			   Review.Rating
		FROM Trip
		JOIN Review USING (TripID)
		JOIN Driver_Car USING (Driver_CarID)
		WHERE Driver_Car.PersonID = driver_id
			AND Review.Sender = false
			AND Review.Rating < 20
		ORDER BY Trip.EndTime;
END;
$$;

SELECT * FROM getTripsWithNegativeReviewsOfDriver(1);


-- Функція 4
-- Призначення: Вивести збережені адреси користувача
CREATE OR REPLACE FUNCTION getPersonSavedAdresses(person_id INT)
RETURNS TABLE (
	address_city VARCHAR(50),
	address_street VARCHAR(50),
	address_building VARCHAR(5)
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY 
		SELECT Address.City, Address.Street, Address.Building
		FROM Address
		JOIN SavedAddress USING (AddressID)
		WHERE SavedAddress.PersonID = person_id;
END;
$$;

SELECT * FROM getPersonSavedAdresses(person_id => 1);

-- Функція 5
-- Призначення: Обчислити сумарну вартість поїздок користувача за його 
--              ідентифікатором за певний період часу
CREATE OR REPLACE FUNCTION getPersonExpensesOfPeriod(
	person_id INT,
	start_date DATE,
	end_date DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql 
AS $$
DECLARE
	expenses NUMERIC;
BEGIN
	SELECT SUM(Payment.Price)
	INTO expenses
	FROM Payment
	JOIN Trip USING (PaymentID)
	WHERE Trip.PersonID = person_id
		AND Trip.StartTime > start_date
		AND Trip.StartTime < end_date;
	RETURN expenses;
END;
$$;

SELECT * FROM getPersonExpensesOfPeriod(
	person_id => 5,
	start_date => '2021-11-01',
	end_date => '2021-11-30'
);


-- Функція 6
-- Призначення: Вивести всі відгуки про водія за його ідентифікатором
CREATE OR REPLACE FUNCTION getAllReviewsAboutDriver(driver_id INT)
RETURNS TABLE (
	review_id INT,
	trip_id INT,
	trip_date DATE,
	review_rating INT, 
	review_note VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY 
		SELECT Review.ReviewID, 
			   Review.TripID, 
			   Trip.EndTime::DATE,
			   Review.Rating,
			   Review.Note
		FROM Review
		JOIN Trip USING (TripID)
		JOIN Driver_Car USING (Driver_CarID)
		WHERE Driver_Car.PersonID = driver_id
			AND Sender = false
		ORDER BY Trip.EndTime;
END;
$$;

SELECT * FROM getAllReviewsAboutDriver(driver_id => 10);


-- Функція 7 
-- Призначення: Обчислити загальну кількість поїздок водія за його ідентифікатором
CREATE OR REPLACE FUNCTION getTotalNumberOfTripsOfDriver(driver_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
	trips_number INT;
BEGIN
	SELECT COUNT(*)
	INTO trips_number
	FROM Trip 
	JOIN Driver_Car USING (Driver_CarID)
	WHERE Driver_Car.PersonID = driver_id;
	RETURN trips_number;
END;
$$;

SELECT * FROM getTotalNumberOfTripsOfDriver(driver_id => 15);


-- Функція 8 
-- Призначення: Вивести всі кредитні картки користувача за його ідентифікатором
CREATE OR REPLACE FUNCTION getAllCreditCardsOfPerson(person_id INT)
RETURNS TABLE (
	index_number INT,
	card_number VARCHAR(16)
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY 
		SELECT (ROW_NUMBER() OVER(ORDER BY CreditCard.Number))::INT,
			   CreditCard.Number
		FROM CreditCard
		WHERE CreditCard.PersonID = person_id
		ORDER BY CreditCard.Number;
END;
$$;

SELECT * FROM getAllCreditCardsOfPerson(person_id => 25);


-- Функція 9
-- Призначення: Вивести список останніх повідомлень з усіх чатів користувача
--              за його ідентифікатором
CREATE OR REPLACE FUNCTION getLastMessagesInPersonChat(person_id INT)
RETURNS TABLE (
	trip_id INT,
	sender_type VARCHAR(10),
	sender_name VARCHAR(100),
	text_content VARCHAR(200),
	dispatch_time TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY 
		SELECT Message.TripID,
		       (    CASE 
				   	  WHEN Message.Sender = false THEN 'Passenger' 
				      ELSE 'Driver'
				  	END
			   )::VARCHAR(10) AS SenderType,
			   (   CASE 
				   	  WHEN Message.Sender = false THEN 
				   			Passenger.FirstName || ' ' || Passenger.LastName
				      ELSE Driver.FirstName || ' ' || Driver.LastName
				  	END
			   )::VARCHAR(100) AS SenderName,
			   Message.TextContent,
			   Message.DispatchTime
		FROM Message 
		JOIN Trip AS tr USING (TripID)
		JOIN Person AS Passenger ON tr.PersonID = Passenger.PersonID
		JOIN Driver_Car USING (Driver_CarID)
		JOIN Person AS Driver ON Driver_Car.PersonID = Driver.PersonID
		WHERE Passenger.PersonID = person_id
			AND Message.DispatchTime = (
				SELECT MAX(Message.DispatchTime)
				FROM Message
				JOIN Trip USING (TripID)
				GROUP BY TripID
				HAVING TripID = tr.TripID 
			);
END;
$$;

SELECT * FROM getLastMessagesInPersonChat(50);


-- Функція 10
-- Призначення: Вивести список задану кількість рекордсменів (водіїв або пасажирів)
--              за кількістю поїздок та їх загальною тривалістю протягом заданого 
--              періоду часу
CREATE OR REPLACE FUNCTION getPeriodRecordholders(
    start_date DATE,
    end_date DATE,
    is_driver BOOL,
	recordholders_number INT
)
RETURNS TABLE (
    person_id INT,
    person_role VARCHAR(10),
    person_name VARCHAR(100),
    trips_number INT,
    time_in_trips INTERVAL
)
LANGUAGE plpgsql
AS $$
BEGIN
	CASE
        WHEN is_driver = false THEN
			RETURN QUERY 
				SELECT Person.PersonID,
                   'Passenger'::VARCHAR(10),
                   (FirstName || ' ' || LastName)::VARCHAR(100),
                   COUNT(*)::INT TripsNumber,
                   SUM(Trip.EndTime - Trip.StartTime) TotalTimeInTrips
				FROM Trip
				JOIN Person USING (PersonID)
				WHERE Trip.StartTime >= start_date AND Trip.EndTime <= end_date
				GROUP BY Person.PersonID
				ORDER BY TripsNumber DESC, TotalTimeInTrips DESC
				LIMIT recordholders_number;
		ELSE 
			RETURN QUERY
				SELECT Person.PersonID,
                   'Driver'::VARCHAR(10),
                   (FirstName || ' ' || LastName)::VARCHAR(100),
                   COUNT(*)::INT TripsNumber,
                   SUM(Trip.EndTime - Trip.StartTime) TotalTimeInTrips
				FROM Trip
				JOIN Driver_Car ON (Trip.Driver_CarID = Driver_Car.Driver_CarID)
				JOIN Person ON (Driver_Car.PersonID = Person.PersonID)
				WHERE Trip.StartTime >= start_date AND Trip.EndTime <= end_date
				GROUP BY Person.PersonID
				ORDER BY TripsNumber DESC, TotalTimeInTrips DESC
				LIMIT recordholders_number;
	END CASE;
END;
$$;

SELECT * FROM getPeriodRecordholders(start_date => '2021-01-01',
									 end_date => '2021-06-30',
									 is_driver => true,
									 recordholders_number => 10);
