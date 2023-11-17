DROP INDEX IF EXISTS cargoes_weight_index;
DROP INDEX IF EXISTS vehicle_id_index;
DROP INDEX IF EXISTS vehicles_id_index;
-- SET enable_seqscan = ON;

-- B-дерево (B-tree): B-дерево является наиболее распространенным типом индекса в PostgreSQL.
-- Он подходит для равенства и диапазонных запросов, а также для сортировки данных.
-- B-дерево поддерживает эффективный поиск данных в порядке сортировки ключей и позволяет быстро находить значения в диапазоне.

-- 1)Фильтрация данных в запросах с использованием предикатов

-- 1.1) Простой btree
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

CREATE INDEX cost_index ON requests USING btree(cost);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost IN (100, 500);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ALL (
  SELECT avg(cost) FROM requests
);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ANY (
  SELECT avg(cost) FROM requests
);

DROP INDEX cost_index;

-- 1.2) Составной btree

CREATE INDEX car_number_index ON vehicles USING btree(car_number varchar_pattern_ops, lifting_capacity);

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%' AND lifting_capacity = 19;

DROP INDEX car_number_index;

-- 1.3) Уникальный btree

CREATE UNIQUE INDEX lifting_capacity_index ON vehicles USING btree(lifting_capacity);

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity = 19;

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity BETWEEN 1 AND 19;

DROP INDEX lifting_capacity_index;

CREATE UNIQUE INDEX car_number_index ON vehicles USING btree(car_number varchar_pattern_ops);

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

DROP INDEX car_number_index;

-- 1.4) Покрывающий индекс btree

CREATE INDEX lifting_capacity_index ON vehicles(lifting_capacity) INCLUDE (model);

EXPLAIN (ANALYZE)
SELECT lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity = 19;

EXPLAIN (ANALYZE)
SELECT lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity BETWEEN 1 AND 19;

DROP INDEX lifting_capacity_index;

CREATE INDEX car_number_index ON vehicles(car_number varchar_pattern_ops) INCLUDE (model);

EXPLAIN (ANALYZE)
SELECT car_number, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

DROP INDEX car_number_index;

-- 1.5) Частичный индекс btree

CREATE INDEX cost_index ON requests(cost) WHERE cost = 2000;

EXPLAIN (ANALYZE)
SELECT cost, name FROM requests
WHERE cost = 2000;

DROP INDEX cost_index;

CREATE INDEX cost_index ON requests(cost) WHERE cost > 2000 AND cost < 4000; 

EXPLAIN (ANALYZE)
SELECT cost, name FROM requests
WHERE cost BETWEEN 3500 AND 3700;

EXPLAIN (ANALYZE)
SELECT cost, name FROM requests
WHERE cost BETWEEN 6000 AND 7000;

DROP INDEX cost_index;

CREATE INDEX car_number_index ON vehicles(car_number varchar_pattern_ops) WHERE car_number LIKE 'зз%';

EXPLAIN (ANALYZE)
SELECT car_number, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

EXPLAIN (ANALYZE)
SELECT car_number, model 
FROM vehicles
WHERE car_number LIKE 'eзeз%';

DROP INDEX car_number_index;

-- 2)Запросы c использованием различных видов соединений

-- 2.1) Простой btree

CREATE INDEX vehicles_id_index ON requests USING btree(vehicle_id);

EXPLAIN (ANALYZE)
SELECT requests.name, requests.date_created, vehicles.car_number
FROM requests
INNER JOIN vehicles ON vehicles.id = requests.vehicle_id;

DROP INDEX vehicles_id_index;

CREATE INDEX vehicle_car_index ON vehicles USING btree(model);

EXPLAIN (ANALYZE)
SELECT *
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT *
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model;

DROP INDEX vehicle_car_index;

-- 2.2) Составной btree

CREATE INDEX vehicle_car_index ON vehicles USING btree(model, car_number);

EXPLAIN (ANALYZE)
SELECT *
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model 
           AND vehicle_groups.group_name = vehicles.car_number;

EXPLAIN (ANALYZE)
SELECT *
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model 
              AND vehicle_groups.group_name = vehicles.car_number;

DROP INDEX vehicle_car_index;

-- 2.3) Уникальный btree

CREATE UNIQUE INDEX vehicle_car_index ON vehicles USING btree(model);

EXPLAIN (ANALYZE)
SELECT *
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT *
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model;

DROP INDEX vehicle_car_index;

-- 2.4) Покрывающий btree

CREATE INDEX vehicle_car_index ON vehicles(model) INCLUDE (car_number);

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model;

DROP INDEX vehicle_car_index;

-- 2.5) Частичный btree
CREATE INDEX vehicle_car_index ON vehicles(model varchar_pattern_ops) WHERE model LIKE 'Ла%';

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicle_groups
LEFT JOIN vehicles ON model LIKE 'Ла%' AND vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicles
RIGHT JOIN vehicle_groups ON model LIKE 'Ла%' AND vehicle_groups.group_name = vehicles.model;

DROP INDEX vehicle_car_index;

-- 3)Запросы с использованием функций для работы со строками

-- 3.1) Простой btree

CREATE INDEX cargoes_name_index ON cargoes USING btree(name);

EXPLAIN (ANALYZE)
SELECT id, REPLACE (name, 'Мешок картошки', 'Картоха') AS name FROM cargoes;

EXPLAIN (ANALYZE)
SELECT id, substring (name, 1, 3) AS name FROM cargoes;

DROP INDEX cargoes_name_index;

-- 3.2) Индексы по выражениям
CREATE INDEX cargo_name_index ON cargoes (lower(name));

EXPLAIN (ANALYZE)
SELECT * FROM cargoes WHERE lower(name) = 'мешок картошки';

DROP INDEX cargo_name_index;

CREATE INDEX cargo_name_index ON cargoes (overlay(name PLACING '12 ' FROM 1 FOR 2));

EXPLAIN (ANALYZE)
SELECT * FROM cargoes WHERE overlay(name PLACING '12 ' FROM 1 FOR 2) = '12 лки для дачи';

DROP INDEX cargo_name_index;

-- 4)Запросы с использованием функций даты и времени

-- 4.1) Простой btree

CREATE INDEX date_index ON requests USING btree(date_created);

EXPLAIN (ANALYZE)
SELECT id, name, date_created - interval '2 days' AS consideration_days, date_created FROM requests;

DROP INDEX date_index;

-- 5)Запросы с использованием агрегатных функций, группировок ( GROUP BY ) и фильтрации групп ( HAVING )

-- 5.1) Простой btree

CREATE INDEX vehicle_id_index ON requests USING btree(vehicle_id);

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id;

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id
HAVING SUM (requests.cost) > 200;

DROP INDEX vehicle_id_index;

-- 5.2) Составной btree

CREATE INDEX vehicle_id_name_index ON requests USING btree(vehicle_id, name);

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, requests.name, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id, requests.name;

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, requests.name, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id, requests.name
HAVING SUM (requests.cost) > 200;

DROP INDEX vehicle_id_name_index;

-- 5.3) Уникальный btree

CREATE UNIQUE INDEX vehicle_name_index ON requests USING btree(name);

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name;

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name
HAVING SUM (requests.cost) > 200;

DROP INDEX vehicle_name_index;

-- 5.4) Покрывающий btree
CREATE INDEX vehicle_car_index ON requests(name) INCLUDE (cost);

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name;

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name
HAVING SUM (requests.cost) > 200;

DROP INDEX vehicle_car_index;

-- 5.5) Частичный btree

CREATE INDEX requests_index ON requests(name varchar_pattern_ops) WHERE name LIKE 'Пере%';

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
WHERE name LIKE 'Пере%'
GROUP BY requests.name;

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
WHERE name LIKE 'Пере%'
GROUP BY requests.name
HAVING SUM (requests.cost) > 200;

DROP INDEX requests_index;

-- 6)Вложенные запросы

-- 6.1) Простой btree

CREATE INDEX cost_index ON requests USING btree(cost);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ALL (
  SELECT avg(cost) FROM requests
);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ANY (
  SELECT avg(cost) FROM requests
);

DROP INDEX cost_index;

-- 6.2) Составной btree

CREATE INDEX cost_index ON requests USING btree(name varchar_pattern_ops, cost);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ALL (
  SELECT avg(cost) FROM requests
) AND requests.name LIKE '1%';

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ANY (
  SELECT avg(cost) FROM requests
) AND requests.name LIKE '1%';

DROP INDEX cost_index;

-- 6.3) Уникальный btree

CREATE UNIQUE INDEX cost_index ON requests USING btree(cost);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ALL (
  SELECT avg(cost) FROM requests
);

EXPLAIN (ANALYZE)
SELECT *
FROM requests
WHERE requests.cost > ANY (
  SELECT avg(cost) FROM requests
);

DROP INDEX cost_index;

-- 6.4) Покрывающий btree
CREATE INDEX requests_cost_index ON requests(cost) INCLUDE (name);

EXPLAIN (ANALYZE)
SELECT requests.name
FROM requests
WHERE requests.cost > ALL (
  SELECT avg(cost) FROM requests
);

EXPLAIN (ANALYZE)
SELECT requests.name
FROM requests
WHERE requests.cost > ANY (
  SELECT avg(cost) FROM requests
);

DROP INDEX requests_cost_index;

-- 6.5) Частичный btree
CREATE INDEX requests_cost_index ON requests(cost) WHERE cost = 2000;

EXPLAIN (ANALYZE)
SELECT requests.name
FROM requests
WHERE cost = 2000 AND requests.cost > ALL (
  SELECT avg(cost) FROM requests
);

EXPLAIN (ANALYZE)
SELECT requests.name
FROM requests
WHERE cost = 2000 AND requests.cost > ANY (
  SELECT avg(cost) FROM requests
);

DROP INDEX requests_cost_index;

-- 7)Запросы с использованием UNION и INTERSECT

-- 7.1) Простой btree

CREATE INDEX cargoes_weight_index ON cargoes USING btree(weight);
CREATE INDEX req_cost_index ON requests USING btree(cost);

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
INTERSECT SELECT cost from requests WHERE requests.cost = 10;

DROP INDEX cargoes_weight_index;
DROP INDEX req_cost_index;

-- 7.2) Составной btree

CREATE INDEX cargoes_weight_index ON cargoes USING btree(weight);
CREATE INDEX req_cost_name_index ON requests USING btree(cost, name varchar_pattern_ops);

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10 AND name LIKE '1%';

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
INTERSECT SELECT cost from requests WHERE requests.cost = 10;

DROP INDEX cargoes_weight_index;
DROP INDEX req_cost_name_index;

-- 7.3) Уникальный btree

CREATE INDEX cargoes_weight_index ON cargoes USING btree(weight);
CREATE UNIQUE INDEX req_cost_index ON requests USING btree(cost);

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
INTERSECT SELECT cost from requests WHERE requests.cost = 10;

DROP INDEX cargoes_weight_index;
DROP INDEX req_cost_index;

-- 7.4) Покрывающий btree
CREATE INDEX cargoes_weight_index ON cargoes(weight) INCLUDE (name);
CREATE INDEX req_cost_index ON requests(cost) INCLUDE (name);

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT name from cargoes WHERE weight = 120.0 
INTERSECT SELECT name from requests WHERE requests.cost = 10;

DROP INDEX cargoes_weight_index;
DROP INDEX req_cost_index;

-- 7.5) Частичный btree

CREATE INDEX cargoes_weight_index ON cargoes(weight) WHERE weight < 2000;
CREATE INDEX req_cost_index ON requests(cost) WHERE cost < 2000;

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT name from cargoes WHERE weight = 120
INTERSECT SELECT name from requests WHERE requests.cost = 10;

DROP INDEX cargoes_weight_index;
DROP INDEX req_cost_index;

