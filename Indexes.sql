DROP INDEX IF EXISTS cargoes_weight_index;
DROP INDEX IF EXISTS vehicle_id_index;
DROP INDEX IF EXISTS vehicles_id_index;


-- B-дерево (B-tree): B-дерево является наиболее распространенным типом индекса в PostgreSQL.
-- Он подходит для равенства и диапазонных запросов, а также для сортировки данных.
-- B-дерево поддерживает эффективный поиск данных в порядке сортировки ключей и позволяет быстро находить значения в диапазоне.

-- Фильтрация данных в запросах с использованием предикатов

CREATE INDEX cargoes_weight_index ON cargoes USING btree(weight);

EXPLAIN (ANALYZE)
SELECT * from cargoes
WHERE weight = 120.0;

EXPLAIN (ANALYZE)
SELECT * FROM cargoes
WHERE weight BETWEEN 1 AND 11;

DROP INDEX cargoes_weight_index;

CREATE INDEX car_number_index ON vehicles USING btree(car_number); -- с индексом хуже

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

DROP INDEX car_number_index;

CREATE INDEX car_number_index ON vehicles USING btree(car_number varchar_pattern_ops); -- а так лучше

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

DROP INDEX car_number_index;

-- Запросы c использованием различных видов соединений

CREATE INDEX vehicles_id_index ON requests USING btree(vehicle_id);

EXPLAIN (ANALYZE)
SELECT requests.name, requests.date_created, vehicles.car_number
FROM requests
INNER JOIN vehicles ON vehicles.id = requests.vehicle_id;

DROP INDEX vehicles_id_index;

CREATE INDEX cargoes_request_id_index ON cargoes USING btree(request_id);

EXPLAIN (ANALYZE)
SELECT cargoes.name, cargoes.weight, requests.name
FROM cargoes
LEFT JOIN requests ON requests.id = cargoes.request_id;

DROP INDEX cargoes_request_id_index;

-- Запросы с использованием функций для работы со строками

CREATE INDEX cargoes_name_index ON cargoes USING btree(name);

EXPLAIN (ANALYZE)
SELECT id, REPLACE (name, 'Мешок картошки', 'Картоха') AS name FROM cargoes;

DROP INDEX cargoes_name_index;