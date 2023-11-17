-- Фильтрация данных в запросах с использованием предикатов 
-- 1.1) Простой btree
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

-- 1.2) Составной btree

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%' AND lifting_capacity = 19;

-- 1.3) Уникальный btree

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity = 19;

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity BETWEEN 1 AND 19;

-- 1.4) Покрывающий индекс btree

EXPLAIN (ANALYZE)
SELECT lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity = 19;

EXPLAIN (ANALYZE)
SELECT lifting_capacity, model 
FROM vehicles
WHERE lifting_capacity BETWEEN 1 AND 19;

EXPLAIN (ANALYZE)
SELECT car_number, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

-- 1.5) Частичный индекс btree

EXPLAIN (ANALYZE)
SELECT cost, name FROM requests
WHERE cost = 2000;

EXPLAIN (ANALYZE)
SELECT cost, name FROM requests
WHERE cost BETWEEN 3500 AND 3700;

EXPLAIN (ANALYZE)
SELECT cost, name FROM requests
WHERE cost BETWEEN 6000 AND 7000;

EXPLAIN (ANALYZE)
SELECT car_number, model 
FROM vehicles
WHERE car_number LIKE 'зз%';

EXPLAIN (ANALYZE)
SELECT car_number, model 
FROM vehicles
WHERE car_number LIKE 'eзeз%';


-- Запросы c использованием различных видов соединений
EXPLAIN (ANALYZE)
SELECT requests.name, requests.date_created, vehicles.car_number
FROM requests
INNER JOIN vehicles ON vehicles.id = requests.vehicle_id;

EXPLAIN (ANALYZE)
SELECT *
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT *
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model;

-- 2.2) Составной btree

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

             
             
-- 2.3) Уникальный btree

EXPLAIN (ANALYZE)
SELECT *
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT *
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model;

-- 2.4) Покрывающий btree

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicle_groups
LEFT JOIN vehicles ON vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicles
RIGHT JOIN vehicle_groups ON vehicle_groups.group_name = vehicles.model;

-- 2.5) Частичный btree

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicle_groups
LEFT JOIN vehicles ON model LIKE 'Ла%' AND vehicle_groups.group_name = vehicles.model;

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicles
RIGHT JOIN vehicle_groups ON model LIKE 'Ла%' AND vehicle_groups.group_name = vehicles.model;

-- Запросы с использованием функций для работы со строками
EXPLAIN (ANALYZE)
SELECT id, REPLACE (name, 'Мешок картошки', 'Картоха') AS name FROM cargoes;

EXPLAIN (ANALYZE)
SELECT id, substring (name, 1, 3) AS name FROM cargoes;

-- 3.2) Индексы по выражениям

EXPLAIN (ANALYZE)
SELECT * FROM cargoes WHERE lower(name) = 'мешок картошки';


-- Запросы с использованием функций даты и времени

EXPLAIN (ANALYZE)
SELECT id, name, date_created - interval '2 days' AS consideration_days, date_created FROM requests;

EXPLAIN (ANALYZE)
SELECT * FROM cargoes WHERE overlay(name PLACING '12 ' FROM 1 FOR 2) = '12 лки для дачи';
-- Запросы с использованием агрегатных функций, группировок ( GROUP BY ) и фильтрации групп ( HAVING )

EXPLAIN (ANALYZE)
SELECT
  requests.vehicle_id,
  SUM (requests.cost)
FROM
  requests
GROUP BY
  vehicle_id;

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id
HAVING SUM (requests.cost) > 200;

-- 5.2) Составной btree

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, requests.name, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id, requests.name;

EXPLAIN (ANALYZE)
SELECT requests.vehicle_id, requests.name, SUM (requests.cost)
FROM requests
GROUP BY vehicle_id, requests.name
HAVING SUM (requests.cost) > 200;

-- 5.3) Уникальный btree

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name;

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name
HAVING SUM (requests.cost) > 200;

-- 5.4) Покрывающий btree

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name;

EXPLAIN (ANALYZE)
SELECT requests.name, SUM (requests.cost)
FROM requests
GROUP BY requests.name
HAVING SUM (requests.cost) > 200;

-- 5.5) Частичный btree

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

-- Вложенные запросы

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

-- 6.2) Составной btree

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

-- 6.3) Уникальный btree

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

-- 6.4) Покрывающий btree
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

-- 6.5) Частичный btree

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


-- Запросы с использованием UNION и INTERSECT

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 INTERSECT SELECT cost from requests WHERE requests.cost = 10;

-- 7.2) Составной btree

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10 AND name LIKE '1%';

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
INTERSECT SELECT cost from requests WHERE requests.cost = 10;

-- 7.3) Уникальный btree

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
INTERSECT SELECT cost from requests WHERE requests.cost = 10;

-- 7.4) Покрывающий btree

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120.0 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT name from cargoes WHERE weight = 120.0 
INTERSECT SELECT name from requests WHERE requests.cost = 10;

-- 7.5) Частичный btree

EXPLAIN (ANALYZE)
SELECT weight from cargoes WHERE weight = 120 
UNION SELECT cost from requests WHERE requests.cost = 10;

EXPLAIN (ANALYZE)
SELECT name from cargoes WHERE weight = 120
INTERSECT SELECT name from requests WHERE requests.cost = 10;

