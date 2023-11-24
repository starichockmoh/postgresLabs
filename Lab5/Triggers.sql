-- триггер BEFORE INSERT OR UPDATE
CREATE FUNCTION requests_trig() RETURNS trigger AS $requests_trig$
    BEGIN
        -- Проверить, что указано название заявки
        IF NEW.name IS NULL THEN
            RAISE EXCEPTION 'request name cannot be null';
        END IF;
       
        -- Стоимость заявки не может быть отрицательной
        IF NEW.cost < 0 THEN
            RAISE EXCEPTION '% cannot have a negative cost', NEW.name;
        END IF;
       
        -- Дата создания заявки не может быть позже текущего дня
        IF NEW.date_created > now() THEN
            RAISE EXCEPTION '% date creacted cannot be in future', NEW.name;
        END IF;

        RETURN NEW;
    END;
$requests_trig$ LANGUAGE plpgsql;

CREATE TRIGGER requests_trigger BEFORE INSERT OR UPDATE ON requests
    FOR EACH ROW EXECUTE FUNCTION requests_trig();
   
UPDATE requests 
SET name = NULL
WHERE id = 4;
  

UPDATE requests 
SET cost = -23
WHERE id = 4;

UPDATE requests 
SET date_created = '2025-12-05'
WHERE id = 4;


DROP TRIGGER requests_trigger ON requests;
DROP FUNCTION requests_trig;


-- триггер BEFORE INSERT OR UPDATE
CREATE FUNCTION cargo_type_trig() RETURNS trigger AS $cargo_type_trig$
    BEGIN
        -- Проверить, что указано название типа грузов
        IF NEW.name IS NULL THEN
            RAISE EXCEPTION 'cargo type name cannot be null';
        END IF;
       
        IF length(NEW.name) > 20 THEN
       		NEW.name := substring(NEW.name FOR 20);
       	END IF;

        RETURN NEW;
    END;
$cargo_type_trig$ LANGUAGE plpgsql;

CREATE TRIGGER cargo_type_trigger BEFORE INSERT OR UPDATE ON cargo_types
    FOR EACH ROW EXECUTE FUNCTION cargo_type_trig();
   
UPDATE cargo_types 
SET name = NULL
WHERE id = 3;

UPDATE cargo_types 
SET name = 'Одежда Одежда Одежда Одежд'
WHERE id = 3;
   
DROP TRIGGER cargo_type_trigger ON cargo_types;
DROP FUNCTION cargo_type_trig;



-- триггер BEFORE DELETE
CREATE FUNCTION cargoes_delete_trig() RETURNS trigger AS $cargoes_delete_trig$
    BEGIN
        -- Проверить, что к грузу не привязано заявки
        IF OLD.request_id IS NOT NULL THEN
            RAISE EXCEPTION 'you cannot delete a cargo to which the request is linked';
        END IF;

        RETURN OLD;
    END;
$cargoes_delete_trig$ LANGUAGE plpgsql;

CREATE TRIGGER cargoes_delete_trigger BEFORE DELETE ON cargoes
    FOR EACH ROW EXECUTE FUNCTION cargoes_delete_trig();
   
DELETE FROM cargoes WHERE id = 9


DROP TRIGGER cargoes_delete_trigger ON cargoes;
DROP FUNCTION cargoes_delete_trig;

--триггер AFTER DELETE INSERT UPDATE
CREATE TABLE requests_audit(
    operation         char(1)   NOT NULL,
    stamp             timestamp NOT NULL,
    userid            text      NOT NULL,
    id                integer   NOT NULL
);

CREATE OR REPLACE FUNCTION requests_audit() RETURNS TRIGGER AS $requests_audit$
    BEGIN
        --
        -- Добавление строки в requests_audit, которая отражает операцию, выполняемую в requests;
        -- для определения типа операции применяется специальная переменная TG_OP.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO requests_audit SELECT 'D', now(), user, OLD.id;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO requests_audit SELECT 'U', now(), user, NEW.id;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO requests_audit SELECT 'I', now(), user, NEW.id;
        END IF;
        RETURN NULL; -- возвращаемое значение для триггера AFTER игнорируется
    END;
$requests_audit$ LANGUAGE plpgsql;

CREATE TRIGGER requests_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON requests
    FOR EACH ROW EXECUTE FUNCTION requests_audit();
   
UPDATE requests 
SET name = 'Заявочка'
WHERE id = 200007;
   
INSERT INTO requests (name, description, cost, date_created, driver_id, vehicle_id, status_id)
VALUES
('Хоп хэй', 'Текст', 2000, '2022-12-05', 1, 1, 2);

DELETE FROM requests WHERE id = 200009

DROP TRIGGER requests_audit_trigger ON requests;
DROP FUNCTION requests_audit;


-- триггер AFTER UPDATE компенсирующий
CREATE FUNCTION request_status_change() RETURNS trigger AS $request_status_change$
    BEGIN
	   -- если id заявки у груза равен NULL
	   IF NEW.request_id IS NULL THEN
	        -- то установим, что статус у заявки "Готово"
       		UPDATE requests
       		SET status_id = 1
       		WHERE id = OLD.request_id;
       END IF;
       RETURN NEW;
    END;
$request_status_change$ LANGUAGE plpgsql;

CREATE TRIGGER request_status_change_trigger AFTER UPDATE ON cargoes
    FOR EACH ROW EXECUTE FUNCTION request_status_change();
   

UPDATE cargoes
SET request_id = NULL
WHERE id = 11;

DROP TRIGGER request_status_change_trigger ON cargoes;
DROP FUNCTION request_status_change;

-- триггер AFTER UPDATE компенсирующий
CREATE FUNCTION request_cost_change() RETURNS trigger AS $request_cost_change$
    BEGIN
	   -- если у машины изменилась группа то увеличим стоимость заявки
	   IF NEW.group_id != OLD.group_id THEN
       		UPDATE requests
       		SET cost = cost + 1000
       		WHERE vehicle_id = OLD.id;
       END IF;
       RETURN NEW;
    END;
$request_cost_change$ LANGUAGE plpgsql;

CREATE TRIGGER request_cost_change_trigger AFTER UPDATE ON vehicles
    FOR EACH ROW EXECUTE FUNCTION request_cost_change();
   
UPDATE vehicles
SET group_id = 2
WHERE id = 5;

DROP TRIGGER request_cost_change_trigger ON vehicles;
DROP FUNCTION request_cost_change;


-- триггер AFTER UPDATE компенсирующий
CREATE FUNCTION request_cost2_change() RETURNS trigger AS $request_cost2_change$
    BEGIN
	   -- если у точки доставки сменился адрес, то примерное время прибытия пока неизвестно
	   IF NEW.town != OLD.town THEN
       		UPDATE pick_up_point_requests
       		SET date_delivery = NULL
       		WHERE pick_up_point_id = OLD.id;
       END IF;
       RETURN NEW;
    END;
$request_cost2_change$ LANGUAGE plpgsql;

CREATE TRIGGER request_cost2_change_trigger AFTER UPDATE ON pick_up_points
    FOR EACH ROW EXECUTE FUNCTION request_cost2_change();
   
UPDATE pick_up_points
SET town = 'Омск'
WHERE id = 3;

DROP TRIGGER request_cost2_change_trigger ON pick_up_points;
DROP FUNCTION request_cost2_change;


-- триггер INSTEAD OF
CREATE OR REPLACE VIEW vehicles_view AS
SELECT id, car_number
FROM vehicles;

SELECT * FROM vehicles_view;

CREATE OR REPLACE FUNCTION vehicles_view_func() RETURNS TRIGGER AS $$
BEGIN
    UPDATE requests
    SET vehicle_id = 100010
    WHERE vehicle_id = OLD.id;

    DELETE FROM vehicles h WHERE h.id = OLD.id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vehicles_view_trigger
INSTEAD OF DELETE ON vehicles_view
FOR EACH ROW
EXECUTE FUNCTION vehicles_view_func();


DELETE FROM vehicles_view where id = 5;

DROP TRIGGER vehicles_view_trigger ON vehicles_view;
DROP FUNCTION vehicles_view_func;



