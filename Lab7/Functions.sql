--------------------------------------------------1--------------------------------------------------------------
-- выводит все грузы, участвующие в заявке с req_id
-- Когда SQL-функция объявляется как возвращающая SETOF некий_тип, конечный 
-- запрос функции выполняется до завершения и каждая строка выводится как элемент результирующего множества.
CREATE OR REPLACE FUNCTION cargoes_in_request(req_id bigint) RETURNS SETOF cargoes AS $$
BEGIN
	RETURN query SELECT c.id, c.name, c.weight, c.request_id, c.client_id, c.type_id
				 FROM cargoes c
	             INNER JOIN requests r ON c.request_id = req_id AND c.request_id = r.id;
	RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM cargoes_in_request(2);
SELECT name, weight FROM cargoes_in_request(1);

DROP FUNCTION cargoes_in_request;

--------------------------------------------------1.1--------------------------------------------------------------
-- тажа функция но с кастомным типом
CREATE TYPE cargo_type AS ("name" VARCHAR(30), weight REAL);

CREATE OR REPLACE FUNCTION cargoes_in_request(req_id bigint) RETURNS SETOF cargo_type AS $$
BEGIN
	RETURN query SELECT c.name, c.weight
				 FROM cargoes c
	             INNER JOIN requests r ON c.request_id = req_id AND c.request_id = r.id;
	RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM cargoes_in_request(2);
SELECT name, weight FROM cargoes_in_request(1);

DROP FUNCTION cargoes_in_request;
DROP TYPE cargo_type;


--------------------------------------------------2--------------------------------------------------------------
-- функция, подсчитывающая суммарный доход от выполненных заявок до указанной даты
CREATE TYPE cost_type AS ("cost" DECIMAL);

CREATE OR REPLACE FUNCTION cost_calculate(date_cost DATE) RETURNS DECIMAL AS $$
DECLARE
    sum_cost DECIMAL := 0;
    r cost_type%rowtype;
BEGIN
	FOR r IN
        SELECT "cost" FROM requests WHERE date_created < date_cost
    LOOP
        sum_cost := sum_cost + r.cost;
    END LOOP;
    RETURN sum_cost;
END;
$$ LANGUAGE plpgsql;

SELECT cost_calculate('2023-12-05');

DROP FUNCTION cost_calculate;
DROP TYPE cost_type;

--------------------------------------------------3--------------------------------------------------------------
--функция выдает количество машин в данной группе
CREATE TYPE type_vehicles_count_type AS (group_id INT);

CREATE OR REPLACE FUNCTION type_vehicles_count(type_v_id INT) RETURNS INT AS $$
DECLARE
    vehicles_count INT := 0;
    r type_vehicles_count_type%rowtype;
BEGIN
	FOR r IN
        SELECT group_id FROM vehicles v
    LOOP
        IF (r.group_id = type_v_id) THEN
            vehicles_count := vehicles_count + 1;
        END IF;
    END LOOP;
    RETURN vehicles_count;
END;
$$ LANGUAGE plpgsql;

SELECT type_vehicles_count(1);

DROP FUNCTION type_vehicles_count;
DROP TYPE type_vehicles_count_type;

--------------------------------------------------4--------------------------------------------------------------
--функция выдает прибыль конкретного водителя в заявке с заданным коэффициентом рассчета
CREATE TYPE cost_type AS ("cost" DECIMAL);

CREATE OR REPLACE FUNCTION cost_driver_calculate(dr_id INT, coeff REAL) RETURNS DECIMAL AS $$
DECLARE
    sum_cost DECIMAL := 0;
    r cost_type%rowtype;
BEGIN
	FOR r IN
        SELECT "cost" FROM requests WHERE driver_id = dr_id
    LOOP
        sum_cost := sum_cost + r.cost;
    END LOOP;
    RETURN sum_cost * coeff;
END;
$$ LANGUAGE plpgsql;

SELECT cost_driver_calculate(2, 0.3);

DROP FUNCTION cost_driver_calculate;
DROP TYPE cost_type;


--------------------------------------------------5--------------------------------------------------------------
--функция выдает количество грузов в данной группе
CREATE TYPE type_cargoes_count_type AS (type_id INT);

CREATE OR REPLACE FUNCTION type_cargoes_count(type_c_id INT) RETURNS INT AS $$
DECLARE
    cargoes_count INT := 0;
    r type_cargoes_count_type%rowtype;
BEGIN
	FOR r IN
        SELECT type_id FROM cargoes
    LOOP
        IF (r.type_id = type_c_id) THEN
            cargoes_count := cargoes_count + 1;
        END IF;
    END LOOP;
    RETURN cargoes_count;
END;
$$ LANGUAGE plpgsql;

SELECT type_cargoes_count(1);

DROP FUNCTION type_cargoes_count;
DROP TYPE type_cargoes_count_type;

