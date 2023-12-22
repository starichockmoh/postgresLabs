-- 1. Запрос с использованием автономных подзапросов
SELECT cargoes.request_id, cargoes."name" FROM cargoes
WHERE cargoes.request_id IN (SELECT pick_up_point_requests.request_id FROM pick_up_point_requests);

-- 2. Создание запроса с использованием коррелированных подзапросов в предложении SELECT и WHERE
SELECT cargoes.request_id, cargoes."name",
  (SELECT count(*) FROM requests r WHERE r.id = cargoes.request_id) cnt
FROM cargoes;

-- 3. Запрос с использованием временных таблиц
DROP TABLE IF EXISTS temp_vehicles;

CREATE TEMPORARY TABLE temp_vehicles AS (
  SELECT vehicles.id, vehicles.car_number FROM vehicles
  WHERE vehicles.car_number LIKE 'зз%'
);

SELECT * FROM temp_vehicles;

-- 4. Запрос с использованием обобщенных табличных выражений (CTE).
WITH cte_vehicles AS (
  SELECT vehicles.id, vehicles.car_number FROM vehicles
  WHERE vehicles.car_number LIKE 'зз%'
)
SELECT * FROM cte_vehicles;

-- 5. Слияние данных (INSERT, UPDATE) c помощью инструкции MERGE.
CREATE TABLE favour_clients
(
  id serial PRIMARY KEY,
  last_name VARCHAR(30),
  first_name VARCHAR(30),
  patronymic VARCHAR(30),
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30)
);

INSERT INTO favour_clients (last_name, first_name, patronymic, username, password)
VALUES
('Петрова', 'Ольга', 'Петровичева', 'olga121', 'h12ash123'),
('Колян', 'Ира', 'Владиславовна', 'ira121', 'h12ash12323'),
('Букин', 'Петр', 'Алексевич', 'Petr229', 'ha223sh112423');

MERGE INTO favour_clients t
USING clients s
ON (t.id = s.id)
WHEN MATCHED THEN
  UPDATE SET username = s.username
WHEN NOT MATCHED THEN
  INSERT (last_name, first_name, patronymic, username, password)
  VALUES (s.last_name, s.first_name, s.patronymic, s.username, s.password);
 
DROP TABLE favour_clients;


-- 6. Запрос с использованием оператора PIVOT.
-- отсутствует в postgres

-- 7. Запрос с использованием оператора UNPIVOT.
-- отсутствует в postgres

-- 8. Запрос с использованием GROUP BY с операторами ROLLUP, CUBE и GROUPING SETS.

SELECT AVG (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY vehicles.group_id, vehicle_groups.group_name;

SELECT AVG (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY ROLLUP (vehicles.group_id, vehicle_groups.group_name);

SELECT AVG (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY CUBE (vehicles.group_id, vehicle_groups.group_name);

SELECT AVG (lifting_capacity)::numeric(10,2), vehicles.group_id, vehicle_groups.group_name
FROM vehicles
INNER JOIN vehicle_groups ON vehicle_groups.id = vehicles.group_id
GROUP BY GROUPING SETS ((vehicles.group_id, vehicle_groups.group_name), (vehicles.group_id), (vehicle_groups.group_name), ());

SELECT cargoes."name", cargoes.id, sum(cargoes.weight) total FROM cargoes
GROUP BY ROLLUP (name, id);

SELECT cargoes."name", cargoes.id, sum(cargoes.weight) total FROM cargoes
GROUP BY CUBE (name, id);

SELECT cargoes."name", cargoes.id, sum(cargoes.weight) total FROM cargoes
GROUP BY GROUPING SETS ((name, id), (name), (id), ());


-- 9. Секционирование с использованием OFFSET FETCH.
SELECT id, name FROM cargoes
OFFSET 10
FETCH NEXT 5 ROWS ONLY;


-- 10. Запросы с использованием ранжирующих оконных функций. ROW_NUMBER() нумерация строк. 
-- Использовать для нумерации внутри групп. RANK(), DENSE_RANK(), NTILE().
SELECT driver_id, name, row_number() OVER (PARTITION BY driver_id ORDER BY name) AS ROW_NUMBER FROM requests;

-- rank выдаёт порядковый номер в разделе текущей строки для каждого уникального 
-- значения, по которому выполняет сортировку предложение ORDER BY
SELECT driver_id, name, rank() OVER (PARTITION BY driver_id ORDER BY name) AS RANK FROM requests;

SELECT driver_id, name, dense_rank() OVER (PARTITION BY driver_id ORDER BY name) AS DENSE_RANK FROM requests;

--ранжирование по целым числам от 1 до значения аргумента так, чтобы размеры групп были максимально близки
SELECT driver_id, name, ntile(4) OVER (ORDER BY name) AS tile FROM requests;

-- 11. Перенаправление ошибки в TRY/CATCH
CREATE OR REPLACE FUNCTION catch_exception (arg_1 int, arg_2 int, OUT res int) LANGUAGE plpgsql AS $$
DECLARE 
	err_code text;
	msg_text text;
	exc_context text;
BEGIN
	BEGIN
		res := arg_1 / arg_2;
	EXCEPTION 
	WHEN OTHERS 
  THEN
		res := 0;
		GET STACKED DIAGNOSTICS
    	err_code = RETURNED_SQLSTATE,
		msg_text = MESSAGE_TEXT,
    	exc_context = PG_CONTEXT;

   		RAISE NOTICE 'ERROR CODE: % MESSAGE TEXT: % CONTEXT: %', 
   		err_code, msg_text, exc_context;
  END;
END;
$$;

DO $$
DECLARE 
	res int;
BEGIN
	SELECT e.res INTO res
	FROM catch_exception(4, 0) AS e;
	
	RAISE NOTICE 'Result: %', res;
END;
$$;

DROP FUNCTION catch_exception;

-- 12. Создание процедуры обработки ошибок в блоке CATCH с использованием функций ERROR
CREATE OR REPLACE FUNCTION catch_exception (arg_1 int, arg_2 int, OUT res int) LANGUAGE plpgsql AS $$
DECLARE 
	err_code text;
	msg_text text;
	exc_context text;
BEGIN
	BEGIN
		res := arg_1 / arg_2;
	EXCEPTION 
	WHEN OTHERS 
  THEN
		res := 0;
		GET STACKED DIAGNOSTICS
    	err_code = RETURNED_SQLSTATE,
		msg_text = MESSAGE_TEXT,
    	exc_context = PG_CONTEXT;

   		RAISE NOTICE 'ERROR CODE: % MESSAGE TEXT: % CONTEXT: %', 
   		err_code, msg_text, exc_context;
  END;
END;
$$;

DO $$
DECLARE 
	res int;
BEGIN
	SELECT e.res INTO res
	FROM catch_exception(4, 0) AS e;
	
	RAISE NOTICE 'Result: %', res;
END;
$$;

DROP FUNCTION catch_exception;

-- 13. Использование THROW, чтобы передать сообщение об ошибке клиенту
-- отсутствует в postgres

-- 14. Контроль транзакций с BEGIN и COMMIT
CREATE TABLE favour_clients
(
  id serial PRIMARY KEY,
  last_name VARCHAR(30),
  first_name VARCHAR(30),
  patronymic VARCHAR(30),
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30)
);

INSERT INTO favour_clients (last_name, first_name, patronymic, username, password)
VALUES
('Петрова', 'Ольга', 'Петровичева', 'olga121', 'h12ash123'),
('Колян', 'Ира', 'Владиславовна', 'ira121', 'h12ash12323'),
('Букин', 'Петр', 'Алексевич', 'Petr229', 'ha223sh112423');


BEGIN;
UPDATE favour_clients SET patronymic = 'AAAAA'
    WHERE username = 'olga121';
SAVEPOINT my_savepoint;
UPDATE favour_clients SET patronymic = 'BBBBB'
    WHERE username = 'ira121';
-- забыли, откатили, пошли дальше
ROLLBACK TO my_savepoint;
UPDATE favour_clients SET patronymic = 'ССССС'
    WHERE username = 'Petr229';
COMMIT;

DROP TABLE favour_clients;

-- 15. Использование XACT_ABORT
-- В PostgreSQL режим автоподтверждения (autocommit) включен по умолчанию. Каждый оператор 
-- автоматически обертывается в неявную транзакцию и подтверждается после выполнения. 

-- 16. Добавление логики обработки транзакций в блоке CATCH.
DO $$
BEGIN
  SELECT 3 / 0;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Ошибка деления на ноль. Откат транзакции';
    ROLLBACK;
END;
$$;
