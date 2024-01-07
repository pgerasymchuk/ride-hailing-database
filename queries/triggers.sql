-- Тригер 1 
-- Призначення: Оновити рейтинг водія або пасажира після додавання нового відгуку
CREATE OR REPLACE FUNCTION updatePersonRating()
RETURNS TRIGGER
LANGUAGE plpgsql 
AS $$
DECLARE 
    review_recipient_id INT;
BEGIN
    IF NEW.Sender = true THEN -- review is written by driver
        review_recipient_id = (
            SELECT Trip.PersonID
            FROM Trip 
            JOIN Review USING (TripID)
            WHERE Review.ReviewID = NEW.ReviewID
        );
        UPDATE Person
        SET Rating = (
            SELECT AVG(Review.Rating)
            FROM Review
            JOIN Trip USING (TripID)
            WHERE Trip.PersonID = review_recipient_id
                AND Review.Sender = true
        )
        WHERE Person.PersonID = review_recipient_id;
    ELSE -- review is written by passenger
        review_recipient_id = (
            SELECT Driver_Car.PersonID
            FROM Driver_Car
            JOIN Trip USING (Driver_CarID)
            JOIN Review USING (TripID)
            WHERE Review.ReviewID = NEW.ReviewID
        );
        UPDATE Person
        SET Rating = (
            SELECT AVG(Review.Rating)
            FROM Review
            JOIN Trip USING (TripID)
            JOIN Driver_Car USING (Driver_CarID)
            WHERE Driver_Car.PersonID = review_recipient_id
                AND Sender = false
        )
        WHERE Person.PersonID = review_recipient_id;
    END IF;
    RAISE NOTICE 'Rating of person with id = % was updated after adding or editing '
                 'review with id = %',review_recipient_id, NEW.ReviewID;
    RETURN NEW;
END;
$$;
 
CREATE TRIGGER updatePersonRatingOnNewReview
AFTER INSERT 
ON Review
FOR EACH ROW
EXECUTE PROCEDURE updatePersonRating();

-- Тригер 2 (функція updatePersonRating() з попереднього пункту)
-- Призначення: Оновити рейтинг водія або пасажира після редагування відгуку
CREATE TRIGGER updatePersonRatingOnUpdateReview
AFTER UPDATE 
ON Review
FOR EACH ROW
EXECUTE PROCEDURE updatePersonRating();

-- Тригер 3
-- Призначення: Відобразити попередження про спливання строку дії картки при 
--              проведенні оплати
CREATE OR REPLACE FUNCTION displayNoticeAboutCloseExpirationDate()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF ( 
		SELECT ExpirationDate
		FROM CreditCard
		WHERE CreditCard.CreditCardID = NEW.CreditCardID
	) - NOW() < '1 month'::INTERVAL THEN
		RAISE NOTICE 'Current credit card expires soon';
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER closeCreditCardExpirationDate
AFTER INSERT 
ON Payment
FOR EACH ROW
EXECUTE PROCEDURE displayNoticeAboutCloseExpirationDate();

-- Тригер 4
-- Призначення: Відобразити попередження про зміну статусу оплати
CREATE OR REPLACE FUNCTION displayNoticeAboutPaymentStatusChange()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF (NEW.Status != OLD.Status) THEN
		RAISE NOTICE 'Payment status for payment with id = % changed ' 
		             'from % to %',NEW.PaymentID, OLD.Status, NEW.Status;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER paymentStatusChange
AFTER UPDATE
ON Payment
FOR EACH ROW
EXECUTE PROCEDURE displayNoticeAboutPaymentStatusChange();

-- Тригер 5
-- Призначення: Не допускати створення більше 100 повідомлень, прив'язаних до однієї поїздки
CREATE OR REPLACE FUNCTION discardSpamMessages()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF (
	   	SELECT COUNT(*)
		FROM Message
		WHERE TripID = NEW.TripID
	) > 100 THEN
		RAISE NOTICE 'Message with id = % was declined because there are already more '
		             'than 100 messages in the trip chat',NEW.MessageID;
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER insertNewMessage
BEFORE INSERT 
ON Message
FOR EACH ROW
EXECUTE PROCEDURE discardSpamMessages();

do $$
BEGIN
	FOR i in 1..101 LOOP
		INSERT INTO Message(MessageID,TripID,Sender,DispatchTime,Status,TextContent)
		VALUES (100000+i,1,false,CURRENT_TIMESTAMP,'C','abc');
	END LOOP;
END;
$$;

-- Тригер 6
-- Призначення: Не допускати створення нової поїздки, якщо у пасажира є більше ніж 3 неоплачені поїздки
CREATE OR REPLACE FUNCTION declineTripOfDebtor()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF (
		SELECT COUNT(*)
		FROM Payment
		JOIN CreditCard USING (CreditCardID)
		WHERE Payment.Status = 'U'
			AND CreditCard.PersonID = NEW.PersonID
	) > 3 THEN
		RAISE NOTICE 'Trip with id = % was declined because passenger with id = % '
		             'has more than 3 unpaid trips',NEW.TripID,NEW.PersonID;
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER insertNewTripOfDebtor
BEFORE INSERT
ON Trip 
FOR EACH ROW
EXECUTE PROCEDURE declineTripOfDebtor();

-- Тригер 7
CREATE OR REPLACE FUNCTION declinePassengersInDriverCar()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF EXISTS (
		SELECT *
		FROM Person
		WHERE Person.PersonID = NEW.PersonID
			AND Person.IsDriver = false
	) THEN 
		RAISE NOTICE 'Insertion into Driver_Car was declined: person with id = % is not driver',
					 NEW.PersonID;
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER insertNewDriver_Car
BEFORE INSERT 
ON Driver_Car
FOR EACH ROW
EXECUTE PROCEDURE declinePassengersInDriverCar();
