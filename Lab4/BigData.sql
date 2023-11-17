INSERT INTO cargoes (name, weight, request_id, client_id, type_id)
SELECT cast(k as varchar), k + 1, 1, 1, 1
FROM generate_series(0, 100000) AS k;

INSERT INTO vehicles (car_number, model, lifting_capacity, date_of_manufacture, group_id)
SELECT cast(k as varchar), cast(k as varchar), k, '2022-12-05', 1
FROM generate_series(0, 100005) AS k;

INSERT INTO requests (name, description, cost, date_created, driver_id, vehicle_id, status_id)
SELECT cast(k as varchar), cast(k as varchar), k, '2022-12-05', 1, k, 1
FROM generate_series(1, 100000) AS k;
