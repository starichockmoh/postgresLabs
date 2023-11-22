-- триггер BEFORE UPDATE
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

CREATE TRIGGER requests_trigger BEFORE UPDATE ON requests
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


-- триггер BEFORE UPDATE
CREATE FUNCTION cargo_type_trig() RETURNS trigger AS $cargo_type_trig$
    BEGIN
        -- Проверить, что указано название типа грузов
        IF NEW.name IS NULL THEN
            RAISE EXCEPTION 'cargo type name cannot be null';
        END IF;
       
        IF NEW.name = 'Одежда' THEN
       		NEW.name := 'Детская одежда';
       	END IF;

        RETURN NEW;
    END;
$cargo_type_trig$ LANGUAGE plpgsql;

CREATE TRIGGER cargo_type_trigger BEFORE UPDATE ON cargo_types
    FOR EACH ROW EXECUTE FUNCTION cargo_type_trig();
   
UPDATE cargo_types 
SET name = NULL
WHERE id = 3;

UPDATE cargo_types 
SET name = 'Одежда'
WHERE id = 3;
   
DROP TRIGGER cargo_type_trigger ON cargo_types;
DROP FUNCTION cargo_type_trig;

