CREATE TABLE drivers
(
  id SERIAL PRIMARY KEY,
  last_name VARCHAR(30),
  first_name VARCHAR(30),
  patronymic VARCHAR(30),
  experience INT NOT NULL
);


CREATE TABLE vehicle_groups
(
  id SERIAL PRIMARY KEY,
  group_name VARCHAR(30) UNIQUE
);


CREATE TABLE vehicles
(
  id serial PRIMARY KEY,
  car_number VARCHAR(30) UNIQUE,
  model VARCHAR(256),
  lifting_capacity REAL not NULL,
  date_of_manufacture DATE not NULL,
  group_id INT not null,
  FOREIGN KEY (group_id) REFERENCES vehicle_groups (id)
);


CREATE TABLE clients
(
  id serial PRIMARY KEY,
  last_name VARCHAR(30),
  first_name VARCHAR(30),
  patronymic VARCHAR(30),
  username VARCHAR(30) NOT NULL UNIQUE,
  password VARCHAR(30)
);


CREATE TABLE request_statuses
(
  id serial PRIMARY KEY,
  name VARCHAR(30) UNIQUE
);


CREATE TABLE pick_up_points
(
  id serial PRIMARY KEY,
  town VARCHAR(30),
  street VARCHAR(30),
  house_number VARCHAR(30),
  corps VARCHAR(30)
);


CREATE TABLE requests
(
  id serial PRIMARY KEY,
  name VARCHAR(30),
  description VARCHAR(30),
  cost DECIMAL,
  date_created DATE NOT NULL,
  driver_id INT NOT null,
  vehicle_id INT NOT null,
  status_id INT NOT null,
  FOREIGN KEY (driver_id) REFERENCES drivers (id),
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id),
  FOREIGN KEY (status_id) REFERENCES request_statuses (id)
);


CREATE TABLE cargo_types
(
  id serial PRIMARY KEY,
  name VARCHAR(30) UNIQUE
);


CREATE TABLE cargoes
(
  id serial PRIMARY KEY,
  name VARCHAR(30),
  weight REAL,
  request_id INT,
  client_id INT NOT null,
  type_id INT NOT null,
  FOREIGN KEY (request_id) REFERENCES requests (id),
  FOREIGN KEY (client_id) REFERENCES clients (id),
  FOREIGN KEY (type_id) REFERENCES cargo_types (id)
);

CREATE TABLE cargo_vehicles_groups
(
  cargo_type_id INT NOT NULL,
  vehicle_group_id INT NOT null,
  FOREIGN KEY (cargo_type_id) REFERENCES cargo_types (id),
  FOREIGN KEY (vehicle_group_id) REFERENCES vehicle_groups (id),
  CONSTRAINT cargo_vehicles_groups_pk PRIMARY KEY(cargo_type_id,vehicle_group_id)
);

CREATE TABLE pick_up_point_requests
(
  pick_up_point_id INT NOT NULL,
  request_id INT NOT null,
  date_delivery DATE,
  FOREIGN KEY (pick_up_point_id) REFERENCES pick_up_points (id),
  FOREIGN KEY (request_id) REFERENCES requests (id),
  CONSTRAINT pick_up_point_requests_pk PRIMARY KEY(pick_up_point_id,request_id)
);


