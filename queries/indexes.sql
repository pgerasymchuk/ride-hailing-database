SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    indexname;


-- optimization 1
SELECT City || ', ' || Street AS "Address", COUNT(*) AS TripsNumber
FROM Address
JOIN Trip ON (Trip.DepartureAddressID = Address.AddressID OR
Trip.DestinationAddressID = Address.AddressID)
GROUP BY City, Street
ORDER BY COUNT(*) DESC;

-- 3 s - 2.3 s
CREATE INDEX idx_tripdepartureaddressid
ON Trip(DepartureAddressID);

CREATE INDEX idx_tripdestinationaddressid
ON Trip(DestinationAddressID);

drop index idx_tripdepartureaddressid;
drop index idx_tripdestinationaddressid;


-- optimization 2
WITH PersonTripsByCities AS (
    SELECT PersonID, City
    FROM Person
	JOIN Trip USING (PersonID)
	JOIN Address ON (Trip.DepartureAddressID = Address.AddressID OR 
			 Trip.DestinationAddressID = Address.AddressID)
    GROUP BY PersonID, City
)
SELECT PersonID,
       COUNT(*) AS CitiesNumber
FROM PersonTripsByCities
GROUP BY PersonID
HAVING COUNT(*) < 5;

-- 2.8 s -> 1.7 s
CREATE INDEX idx_trip_personid 
ON Trip(PersonID);

