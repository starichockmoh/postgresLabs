-- Хеш (hash): Индекс хеша используется для быстрого поиска по точному значению.
-- Он строит хеш-таблицу, где каждая запись имеет уникальный хеш-код, и поиск основан на хеш-значении.
-- Хеш-индекс подходит для точных поисковых запросов, но не поддерживает сортировку или диапазонные запросы.

CREATE INDEX weight_index ON cargoes USING hash(weight);

EXPLAIN (ANALYZE)
SELECT * FROM cargoes
WHERE weight = 10;

EXPLAIN (ANALYZE) -- не даёт преимущества
SELECT * FROM cargoes
WHERE weight BETWEEN 10 AND 100;

DROP INDEX weight_index;


CREATE INDEX name_index ON cargoes USING hash(name);

EXPLAIN (ANALYZE)
SELECT * FROM cargoes
WHERE name = 'Улей';

EXPLAIN (ANALYZE)  -- не даёт преимущества
SELECT * FROM cargoes
WHERE name LIKE 'Ул%';

DROP INDEX  name_index;
