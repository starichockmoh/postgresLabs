:CONNECT localhost:5432
USE labaDatabase;
--joins
SELECT requests.name, requests.date_created, vehicles.car_number, drivers.last_name 
FROM requests
INNER JOIN vehicles ON vehicles.id = requests.vehicle_id
INNER JOIN drivers ON drivers.id = requests.driver_id;

SELECT cargoes.name, cargoes.weight, requests.name
FROM cargoes
LEFT JOIN requests ON requests.id = cargoes.request_id;

SELECT cargoes.name, cargoes.weight, requests.name
FROM cargoes
RIGHT JOIN requests ON requests.id = cargoes.request_id;

SELECT cargoes.name, cargoes.weight, requests.name
FROM cargoes
FULL JOIN requests ON requests.id = cargoes.request_id;

SELECT * FROM drivers CROSS JOIN vehicles;

SELECT *
FROM requests
CROSS JOIN LATERAL (
  SELECT cargoes.name
  FROM cargoes
  WHERE cargoes.request_id = requests.id
) AS subquery;

SELECT
  c1.name,
  c2.name,
  char_length(c1.name)
FROM cargoes c1
INNER JOIN cargoes c2 ON c1.client_id <> c2.client_id
AND char_length(c1.name) = char_length(c2.name);


--predicats
SELECT requests.name, requests.date_created
FROM requests
WHERE EXISTS (SELECT 1 FROM cargoes WHERE cargoes.request_id = requests.id);

SELECT requests.id, requests.name, requests.description, requests.status_id, request_statuses.name
FROM requests
INNER JOIN request_statuses ON request_statuses.id = requests.status_id AND requests.status_id IN (2, 3)

SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity BETWEEN 15.0 AND 30.0

SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%'

 SELECT AVG (lifting_capacity)::numeric(10,2)
            FROM vehicles
            GROUP BY vehicles.group_id

SELECT id, car_number, lifting_capacity, model
FROM vehicles
WHERE
    lifting_capacity::numeric(10,2) > ALL (
            SELECT AVG (lifting_capacity)
            FROM vehicles
            GROUP BY vehicles.group_id
    )
  
SELECT id, car_number, lifting_capacity, model
FROM vehicles
WHERE
    lifting_capacity::numeric(10,2) > ANY (
            SELECT AVG (lifting_capacity)
            FROM vehicles
            GROUP BY vehicles.group_id
    )
    

--case
SELECT cargoes.name, cargoes.weight,
CASE
	WHEN cargoes.request_id IS NULL
	THEN 'Круз без заявки!'
	ELSE (SELECT requests.name FROM requests WHERE requests.id = cargoes.request_id)
END AS request_name
FROM cargoes;

--func
SELECT cargoes.name, cargoes.weight, COALESCE (requests.name, 'Груз без заявки') as requests_name
FROM cargoes
LEFT JOIN requests ON requests.id = cargoes.request_id;

SELECT vehicle_groups.group_name, NULLIF (vehicle_groups.id, 1) as nullable_id
FROM vehicle_groups;

SELECT pick_up_points.id, pick_up_points.town, pick_up_points.street, 
	   pick_up_points.house_number, TO_CHAR (pick_up_point_requests.date_delivery, 'yyyy/mm/dd') AS string_date
FROM pick_up_points
INNER JOIN pick_up_point_requests ON pick_up_points.id = pick_up_point_requests.pick_up_point_id
AND CAST (pick_up_points.house_number AS INT) > 15;

--string
SELECT id, REPLACE (town, 'Саратов', 'Энгельс') AS town FROM pick_up_points;

SELECT id, substring (town, 1, 6) AS town_substr FROM pick_up_points;

SELECT id, upper (town) AS town_upper FROM pick_up_points;

SELECT id, lower (town) AS town_lower FROM pick_up_points;

SELECT id, ascii (town) AS town_code FROM pick_up_points;

SELECT id, overlay(street PLACING 'Ул. ' FROM 1 FOR 2) as street FROM pick_up_points;

SELECT id, 'г. ' || town || ' ул. ' || street || ' д. ' || house_number AS address FROM pick_up_points;

--date
SELECT pick_up_points.id, pick_up_points.town, pick_up_points.street, 
	   pick_up_points.house_number, date_part ('month', pick_up_point_requests.date_delivery) AS month_of_delivery
FROM pick_up_points
INNER JOIN pick_up_point_requests ON pick_up_points.id = pick_up_point_requests.pick_up_point_id;

SELECT id, name, date_created - interval '2 days' AS consideration_days, date_created FROM requests;

SELECT requests.id, requests.name, requests.description, 
	   'г. ' || pick_up_points.town || ' ул. ' || pick_up_points.street || ' д. ' || pick_up_points.house_number AS address,
	   requests.date_created, pick_up_point_requests.date_delivery, age (pick_up_point_requests.date_delivery, requests.date_created)
FROM requests
INNER JOIN pick_up_point_requests ON requests.id = pick_up_point_requests.request_id
INNER JOIN pick_up_points ON pick_up_points.id = pick_up_point_requests.pick_up_point_id;

SELECT current_timestamp;

SELECT current_timestamp AT TIME ZONE 'UTC-4';

--agr
SELECT AVG (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name;
            
SELECT SUM (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name;

SELECT MAX (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name;

SELECT MIN (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name;

SELECT COUNT (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name;

SELECT COUNT (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name
HAVING COUNT (lifting_capacity) > 1;