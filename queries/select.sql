-- Запит 1
-- Призначення: Обрати найкращих за рейтингом водіїв
-- Опис: Вивести ПІБ, логін та рейтинг користувачів, які є водіями 
--       та мають рейтинг, вищий за 95
SELECT FirstName, LastName, Login, Rating
FROM Person
JOIN Credentials USING (CredentialsID)
WHERE IsDriver = true AND Rating > 95
ORDER BY Rating DESC;

-- Запит 2
-- Призначення: Відсортувати автомобілі за кількістю поїздок
-- Опис: Для кожного автомобіля вивести його номер та кількість 
--       здійснених поїздок, відсортувати за спаданням кількості поїздок
SELECT IdentificationNumber, COUNT(*) AS NumberOfTrips
FROM Car 
JOIN Driver_Car USING (CarID)
JOIN Trip USING (Driver_CarID)
GROUP BY IdentificationNumber
ORDER BY COUNT(*) DESC;

-- Запит 3
-- Призначення: Обрати пасажирів, що залишили найбільше відгуків
-- Опис: Для кожного пасажира обчислити кількість залишених ним відгуків,
--       відсортувати за спаданням кількості відгуків та вивести 
--       ідентифікатори, ПІБ та кількість відгуків перших 100 пасажирів

SELECT PersonID, FirstName, LastName, COUNT(ReviewID) AS NumberOfReviews
FROM Person
JOIN Trip USING (PersonID)
JOIN Review USING (TripID)
WHERE Sender = false
GROUP BY PersonID
ORDER BY COUNT(ReviewID) DESC
LIMIT 100;

-- Запит 4
-- Призначення: Відсортувати водіїв за отриманим заробітком
-- Опис: Для кожного водія вивести ідентифікатор, ПІБ та суму вартостей усіх
--       поїздок, які він здійснив, відсортувати за спаданням цієї суми
SELECT Person.PersonID, FirstName, LastName, SUM(Price) AS PriceSum
FROM Person 
JOIN Driver_Car USING (PersonID)
JOIN Trip USING (Driver_CarID)
JOIN Payment USING (PaymentID)
GROUP BY Person.PersonID
ORDER BY SUM(Price) DESC;

-- Запит 5
-- Призначення: Обрати пасажирів, які їздили лише на автомобілях типу Van
-- Опис: Вивести ідентифікатори та ПІБ пасажирів в алфавітному порядку, усі поїздки 
--       яких були на автомобілях типу Van
SELECT DISTINCT Person.PersonID, FirstName, LastName
FROM Person 
JOIN Trip USING (PersonID)
JOIN Driver_Car USING (Driver_CarID)
JOIN Car USING (CarID)
WHERE Car.Type = 'Van'
	AND NOT EXISTS (
		SELECT *
		FROM Trip t2
		JOIN Driver_Car dc2 USING (Driver_CarID)
		JOIN Car c2 USING (CarID)
		WHERE t2.PersonID = Person.PersonID 
		  	AND c2.Type != 'Van' 
	)
ORDER BY FirstName, LastName;

-- Запит 6
-- Призначення: Відсортувати пасажирів за сумарним часом, витраченим на поїздки
-- Опис: Вивести ідентифікатори, ПІБ, загальний час, витрачений на поїздки,
--       та загальну кількість поїздок пасажирів, відсортувати за спаданням часу
SELECT Person.PersonID, FirstName, LastName, 
	   SUM(EndTime-StartTime) AS TotalTimeInTrips,
	   COUNT(TripID) AS TripSNumber
FROM Person 
JOIN Trip USING (PersonID)
GROUP BY Person.PersonID
ORDER BY SUM(EndTime-StartTime) DESC;

-- Запит 7
-- Призначення: Відсортувати дизельні автомобілі за величиою проїханого шляху
-- Опис: Вивести ідентифікатори, номери та загальний проїханий шлях 
--       автомобілів, типом пального яких є дизель, відсортувати за 
--       спаданням шляху 
SELECT CarID, IdentificationNumber, SUM(Distance) AS TotalDistance
FROM Car 
JOIN Driver_Car USING (CarID)
JOIN Trip USING (Driver_CarID)
WHERE FuelType = 'D'
GROUP BY CarID
ORDER BY SUM(Distance) DESC;

-- Запит 8
-- Призначення: Обрати користувачів, які мають банківські картки, 
--              строк дії яких спливе протягом місяця
-- Опис: Вивести ідентифікатори та ПІБ користувачів, номери карток та строки їх дії, 
--       до закінчення строку яких залишилося менше 1 місяця
SELECT Person.PersonID, Person.FirstName, Person.LastName, 
	   CreditCard.Number, CreditCard.ExpirationDate
FROM Person
JOIN CreditCard USING (PersonID)
WHERE (CreditCard.ExpirationDate - NOW()) < '1 month'::INTERVAL;

-- Запит 9
-- Призначення: Вивести кількість поїздок водіїв на електроавтомобілях
-- Опис: Вивести ідентифікатори, ПІБ водіїв та кількість їх поїздок на електроавтомобілях
SELECT Driver.PersonID, FirstName, LastName, COUNT(*) AS TripsOnElecticCars
FROM Person AS Driver
JOIN Driver_Car USING (PersonID)
JOIN Car USING (CarID)
JOIN Trip ON Trip.Driver_CarID = Driver_Car.Driver_CarID
WHERE Car.FuelType = 'E'
GROUP BY Driver.PersonID
ORDER BY Driver.PersonID;

-- Запит 10
-- Призначення: Обрати водіїв, які їздили лише на автомобілях із бензиновим двигуном
-- Опис: Вивести ідентифікатори та ПІБ водіїв, усі поїздки яких були лише на  
--       автомобілях, що мають бензиновий двигун
SELECT DISTINCT Person.PersonID, Person.FirstName, Person.LastName
FROM Person
JOIN Driver_Car USING (PersonID)
JOIN Car USING (CarID)
WHERE Car.FuelType = 'G'
	AND NOT EXISTS (
		SELECT 1 
		FROM Driver_Car dc2
		JOIN Car c2 USING (CarID)
		WHERE dc2.PersonID = Person.PersonID
			AND c2.FuelType != 'G'
	);

-- Запит 11
-- Призначення: Відсортувати марки автомобілів за популярністю
-- Опис: Вивести всі марки автомобілів в порядку спадання кількості поїздок	
SELECT Model, COUNT(*) AS TripsNumber
FROM Car
JOIN Driver_Car USING (CarID)
JOIN Trip USING (Driver_CarID)
GROUP BY Model
ORDER BY COUNT(*) DESC;


-- Запит 12
-- Призначення: Вивести 10 найпопулярніших адрес
-- Опис: Вивести перші за кількістю поїздок 10 адрес (місто+вулиця) та кількість 
--       поїздок з них або до них
SELECT City || ', ' || Street AS "Address", COUNT(*) AS TripsNumber
FROM Address
JOIN Trip ON (Trip.DepartureAddressID = Address.AddressID OR Trip.DestinationAddressID = Address.AddressID)
GROUP BY City, Street
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Запит 13
-- Призначення: Вивести кількість поїздок, здійснених кожним класом автомобілей
-- Опис: Вивести назву та кількість поїздок для кожного класу автомобілей 
SELECT Class AS CarClass, COUNT(*) AS TripsNumber
FROM Car
JOIN Driver_Car USING (CarID)
JOIN Trip USING (Driver_CarID)
GROUP BY Class;

-- Запит 14
-- Призначення: Вивести моделі автомобілі з відгуками вище середнього
-- Опис: Вивести марки та середні оцінки автомобілів, середні оцінки яких вищі за
--       середнє значення всіх оцінок пасажирів
SELECT Model, AVG(Rating)::DECIMAL(3,1) AS ModelRating
FROM Car 
JOIN Driver_Car USING (CarID)
JOIN Trip USING (Driver_CarID)
JOIN Review USING (TripID)
WHERE Sender = false
GROUP BY Model 
HAVING AVG(Rating) > (
	SELECT AVG(Rating)
	FROM Review
	WHERE Sender = false
)
ORDER BY AVG(Rating) DESC;

-- Запит 15
-- Призначення: Обрати 100 користувачів із найбільшим середнім значенням тривалості поїздки
-- Опис: Обрати користувачів, середня тривалість поїздок яких більша за 95% від середнього
--       значення тривалості усіх поїздок
SELECT PersonID, FirstName, LastName, AVG(EndTime - StartTime) AS AverageTripDuration
FROM Person
JOIN Trip USING (PersonID)
GROUP BY PersonID
HAVING AVG(EndTime - StartTime) > 0.95 * (
	SELECT AVG(EndTime - StartTime) 
	FROM Trip
)
ORDER BY AVG(EndTime - StartTime) DESC
LIMIT 100;

-- Запит 16
-- Призначення: Обрати водіїв, які їздили лише вранці
-- Опис: Вивести ідентифікатори та ПІБ водіїв, які не здійснювали поїздок після 12-ої години
SELECT DISTINCT Person.PersonID, FirstName, LastName
FROM Person
JOIN Driver_Car USING (PersonID)
WHERE NOT EXISTS (
	SELECT 1 
	FROM Trip 
	JOIN Driver_Car dc2 USING (Driver_CarID)
	WHERE EXTRACT(HOUR FROM Trip.StartTime) >= 12
		AND dc2.PersonID = Person.PersonID
);

-- Запит 17
-- Призначення: Відсортувати користувачів за  кількістю поїздок протягом останніх 2,5 років
-- Опис: Вивести ідентифікатори, ПІБ пасажирів та кількість їхніх поїздок протягом 
--       останніх 2,5 років, відсортувати в порядку зменшення кількості поїздок 
SELECT PersonID, FirstName, LastName, COUNT(TripID)
FROM Person
JOIN Trip USING (PersonID)
WHERE Trip.EndTime > NOW() - '2 year 6 month'::INTERVAL
GROUP BY PersonID
ORDER BY COUNT(TripID) desc;

-- Запит 18
-- Призначення: Обрати користувачів, не їздили на таксі жодного разу
-- Опис: Вивести ідентифікатори та ПІБ пасажирів, які не мають поїздок
SELECT PersonID, FirstName, LastName
FROM Person p
WHERE NOT EXISTS (
	SELECT 1
	FROM Trip
	WHERE Trip.PersonID = p.PersonID
);

-- Запит 19
-- Призначення: Обрати оплати зі статусом "Неуспішно"
-- Опис: Вивести ідентифікатори поїздок, оплат, які мають статус "Неуспішно"
--       та відповідні номери карт
SELECT TripID, PaymentID, Payment.PaymentTime, CreditCard.Number AS CardNumber
FROM Payment 
JOIN Trip USING (PaymentID)
JOIN CreditCard USING (CreditCardID)
WHERE Payment.Status = 'U';

-- Запит 20
-- Призначення: Відсортувати міста, в яких було здійснено найбільше поїздок
-- Опис: Вивести назви міст та кількість поїздок в них у порядку спадання 
--       цієї кількості
SELECT City, COUNT(*) TripsNumber
FROM Address
JOIN Trip ON (Trip.DepartureAddressID = Address.AddressID OR 
			  Trip.DestinationAddressID = Address.AddressID) 
GROUP BY City
ORDER BY COUNT(*) DESC;

-- Запит 21
-- Призначення: Обрати пасажирів, які їздили лише на автомобілях класу 'Premium' або 'Business'
-- Опис: Вивести ідентифікатори та ПІБ пасажирів, які мають поїздки лише на 
--       автомобілях класу 'Premium' або 'Business'
SELECT DISTINCT Person.PersonID, FirstName, LastName
FROM Person 
JOIN Trip USING (PersonID)
JOIN Driver_Car USING (Driver_CarID)
JOIN Car USING (CarID)
WHERE (Car.Class = 'Premium' OR Car.Class = 'Business')
	AND NOT EXISTS (
		SELECT *
		FROM Trip t2
		JOIN Driver_Car dc2 USING (Driver_CarID)
		JOIN Car c2 USING (CarID)
		WHERE t2.PersonID = Person.PersonID 
		  	AND c2.Class NOT IN ('Premium','Business') 
	)
ORDER BY FirstName, LastName;



	