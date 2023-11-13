INSERT INTO drivers (last_name, first_name, patronymic, experience)
VALUES
('Петров', 'Кирилл', 'Петрович', 2),
('Тяпков', 'Олег', 'Владиславович', 23),
('Букин', 'Петр', 'Алексеевич', 8);


INSERT INTO vehicle_groups (group_name)
VALUES
('Легковые авто'),
('Грузовые авто'),
('Авто с прицепом');


INSERT INTO vehicles (car_number, model, lifting_capacity, date_of_manufacture, group_id)
VALUES
('ззз123цу', 'Лада', 11.3, '2022-12-05', 1),
('ыв123цу', 'Киа', 11.1, '2020-12-05', 1),
('ыв2543йу', 'Камаз', 21.3, '2000-12-05', 2),
('ззз45123цу', 'Лада с прицепом', 15.3, '2018-12-05', 3);


INSERT INTO clients (last_name, first_name, patronymic, username, password)
VALUES
('Петрова', 'Ольга', 'Петровичева', 'olga121', 'hash123'),
('Тяпкова', 'Ирина', 'Владиславовна', 'ira121', 'hash12323'),
('Букина', 'Петрина', 'Алексеевна', 'Petrina', 'hash112423');


INSERT INTO request_statuses (name)
VALUES
('В пункте выдачи'),
('На складе у поставщика'),
('В дороге');


INSERT INTO pick_up_points (town, street, house_number, corps)
VALUES
('Саратов', 'Вольская', '12', 'Б'),
('Энгельс', 'Тельмана', '23', 'Ф'),
('Москва', 'Комсомольская', '23', 'А');


INSERT INTO requests (name, description, cost, date_created, driver_id, vehicle_id, status_id)
VALUES
('Перевозка продуктов', 'Текст', 2000, '2022-12-05', 1, 1, 2),
('Перевозка одежды для ребенка', 'Текст', 300, '2022-12-05', 3, 3, 2),
('Перевозка балок', 'Текст', 3000, '2022-12-05', 2, 2, 1),
('Перевозка улья', 'Текст', 5000, '2023-12-05', 2, 2, 2);


INSERT INTO cargo_types (name)
VALUES
('Продукты'),
('Строй материалы'),
('Одежда');


INSERT INTO cargoes (name, weight, request_id, client_id, type_id)
VALUES
('Мешок картошки', 10.0, 1, 1, 1),
('Кофта и куртка', 1.2, 2, 2, 3),
('Балки для дачи', 120.0, 3, 3, 2),
('Улей', 110.0, NULL, 3, 2);


INSERT INTO cargo_vehicles_groups (cargo_type_id, vehicle_group_id)
VALUES
(1, 1),
(1, 3),
(2, 2),
(3, 1),
(3, 2),
(3, 3);


INSERT INTO pick_up_point_requests (pick_up_point_id, request_id, date_delivery)
VALUES
(1, 1, '2022-12-05'),
(1, 2, '2022-12-05'),
(2, 2, '2022-12-05'),
(3, 3, '2022-12-05');

INSERT INTO cargoes (name, weight, request_id, client_id, type_id)
SELECT cast(k as varchar), k + 1, 1, 1, 1
FROM generate_series(0, 100000) AS k;

INSERT INTO vehicles (car_number, model, lifting_capacity, date_of_manufacture, group_id)
SELECT cast(k as varchar), cast(k as varchar), k, '2022-12-05', 1
FROM generate_series(0, 100005) AS k;


INSERT INTO requests (name, description, cost, date_created, driver_id, vehicle_id, status_id)
SELECT cast(k as varchar), cast(k as varchar), k, '2022-12-05', 1, k, 1
FROM generate_series(1, 100000) AS k;
