-- Задание 1

CREATE OR REPLACE VIEW requests_view AS
SELECT requests.name, requests.date_created, vehicles.car_number, drivers.last_name 
FROM requests
INNER JOIN vehicles ON vehicles.id = requests.vehicle_id
INNER JOIN drivers ON drivers.id = requests.driver_id;

SELECT * FROM requests_view WHERE name LIKE 'Перевозк%';

SELECT pg_get_viewdef('requests_view', FALSE);

SELECT pg_get_viewdef('requests_view', TRUE);

DROP VIEW requests_view;

-- Задание 2

CREATE OR REPLACE VIEW pick_date_view AS
SELECT *
FROM  pick_up_point_requests
WHERE date_delivery <= current_timestamp
WITH CHECK OPTION;

SELECT * FROM pick_date_view;

INSERT INTO pick_date_view VALUES (2, 1, '2022-11-30');

INSERT INTO pick_date_view VALUES (3, 2, '2024-11-30');

SELECT * FROM pick_date_view;

DROP VIEW pick_date_view;

-- Задание 3
CREATE MATERIALIZED VIEW requests_name_view AS
SELECT name, description, cost
FROM requests;

EXPLAIN (ANALYZE)
SELECT * FROM requests_name_view WHERE cost = 5;

CREATE INDEX requests_name_view_idx ON requests_name_view USING btree (cost);

EXPLAIN (ANALYZE)
SELECT * from requests_name_view WHERE cost = 5;

DROP MATERIALIZED VIEW requests_name_view;



