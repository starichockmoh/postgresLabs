-- Фильтрация данных в запросах с использованием предикатов 
EXPLAIN (ANALYZE)
SELECT * FROM cargoes
WHERE weight = 120.0;

EXPLAIN (ANALYZE)
SELECT * FROM cargoes
WHERE weight BETWEEN 1 AND 11;

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

-- Запросы c использованием различных видов соединений
EXPLAIN (ANALYZE)
SELECT requests.name, requests.date_created, vehicles.car_number
FROM requests
INNER JOIN vehicles ON vehicles.id = requests.vehicle_id;

EXPLAIN (ANALYZE)
SELECT cargoes.name, cargoes.weight, requests.name
FROM cargoes
LEFT JOIN requests ON requests.id = cargoes.request_id;

-- Запросы с использованием функций для работы со строками
EXPLAIN (ANALYZE)
SELECT id, REPLACE (name, 'Мешок картошки', 'Картоха') AS name FROM cargoes;