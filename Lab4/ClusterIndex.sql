-- PostgreSQL не имеет прямой реализации индекса CLUSTER, как Microsoft SQL Server.
-- После создания первичного ключа таблицы или любого другого индекса вы можете 
-- выполнить команду CLUSTER, указав имя этого индекса, чтобы добиться физического порядка данных таблицы.
-- Когда таблица кластеризована, ее порядок физически переупорядочивается на основе информации об индексе. 
-- Кластеризация — это однократная операция: при последующем обновлении таблицы изменения не кластеризуются. 
-- То есть не предпринимается никаких попыток сохранить новые или обновленные строки в соответствии с порядком их индекса.

CREATE INDEX car_num_index
  ON vehicles (car_number varchar_pattern_ops);
CLUSTER vehicles USING car_num_index;

EXPLAIN (ANALYZE)
SELECT id, car_number, lifting_capacity, model 
FROM vehicles
WHERE car_number LIKE 'зз%' AND lifting_capacity = 19;

EXPLAIN (ANALYZE)
SELECT car_number
FROM vehicle_groups
LEFT JOIN vehicles ON car_number LIKE 'зз%' AND vehicle_groups.group_name = vehicles.model;

DROP INDEX car_num_index;
