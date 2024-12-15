DROP SCHEMA IF EXISTS etl CASCADE;
CREATE SCHEMA etl;

CREATE TABLE etl.restaurantes_platos (
  id INT NOT NULL,
  fecha_emision DATE NOT NULL,
  alquiler NUMERIC NOT NULL,
  personal NUMERIC NOT NULL,
  proveedores NUMERIC NOT NULL,
  extra NUMERIC NOT NULL,
  ingresos_presencial NUMERIC NOT NULL,
  ingresos_domicilio NUMERIC NOT NULL,
  numero_clientes_presencial INT NOT NULL,
  nuevos_clientes_presencial INT NOT NULL,
  numero_clientes_domicilio INT NOT NULL,
  nuevos_clientes_domicilio INT NOT NULL,
  plato_id INT NOT NULL,
  plato_nombre VARCHAR NOT NULL,
  plato_precio NUMERIC NOT NULL,
  plato_ventas INT NOT NULL,
  PRIMARY KEY (id, fecha_emision, plato_id)
);

DROP SCHEMA IF EXISTS public cascade;
CREATE SCHEMA public;

-- Dimensión tiempo
CREATE TABLE dim_tiempo (
    id SERIAL PRIMARY KEY,
    ano int not null,
    mes int not null,
    mes_texto varchar(10) not null
);

-- Dimensión restaurante
CREATE TABLE dim_restaurante (
    id SERIAL PRIMARY KEY,
    pais varchar(255) not null,
    ciudad varchar(255) not null
);

-- Dimensión productos
CREATE TABLE dim_productos (
    id SERIAL PRIMARY KEY,
    nombre varchar(255) not null,
    precio numeric(10, 2) not null
);


-- evitamos que se modifiquen o eliminen restaurantes y/o fechas si hay registros asociados en las tablas de hechos. GArantizamos la consistencia de los datos y la integridad referencial. 


-- Tabla de hechos finanzas
CREATE TABLE fact_finanzas (
    restaurante INT NOT NULL REFERENCES dim_restaurante(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    fecha INT NOT NULL REFERENCES dim_tiempo(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    ---
    alquiler NUMERIC(15, 2) DEFAULT 0,
    personal NUMERIC(15, 2) DEFAULT 0,
    proveedores NUMERIC(15, 2) DEFAULT 0,
    extra NUMERIC(15, 2) DEFAULT 0,
    ingresos_presencial NUMERIC(15, 2) DEFAULT 0,
    ingresos_domicilio NUMERIC(15, 2) DEFAULT 0,
    numero_clientes_presencial INT DEFAULT 0,
    nuevos_clientes_presencial INT DEFAULT 0,
    numero_clientes_domicilio INT DEFAULT 0,
    nuevos_clientes_domicilio INT DEFAULT 0,
    PRIMARY KEY (restaurante, fecha)
);

-- Tabla de hechos producto
CREATE TABLE fact_ventas (
    restaurante INT NOT NULL REFERENCES dim_restaurante(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    fecha INT NOT NULL REFERENCES dim_tiempo(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    producto INT NOT NULL REFERENCES dim_productos(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    ---
    ventas INT DEFAULT 0,
    ingresos INT DEFAULT 0,
    PRIMARY KEY (restaurante, fecha, producto)
);

-- Tabla de hechos feedback
CREATE TABLE fact_satisfaccion (
    restaurante INT NOT NULL REFERENCES dim_restaurante(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    fecha INT NOT NULL REFERENCES dim_tiempo(id) ON UPDATE RESTRICT ON DELETE RESTRICT,
    ---
    valoracion_ambiente NUMERIC(2, 1) CHECK (valoracion_ambiente >= 0 AND valoracion_ambiente <= 5),
    valoracion_personal NUMERIC(2, 1) CHECK (valoracion_personal >= 0 AND valoracion_personal <= 5),
    valoracion_comida NUMERIC(2, 1) CHECK (valoracion_comida >= 0 AND valoracion_comida <= 5),
    PRIMARY KEY (restaurante, fecha)
);





-- --Datos de prueba

-- -- Insertar en la tabla tiempo
-- INSERT INTO tiempo (id, ano, mes, mes_texto) VALUES
-- (1, 2021, 2, 'Febrero');

-- -- Insertar en la tabla restaurante
-- INSERT INTO restaurante (id, pais, ciudad) VALUES
-- (1, 'España', 'La Laguna');

-- -- Insertar en la tabla productos
-- INSERT INTO productos (id, nombre, precio) VALUES
-- (1, 'Almogrote Gomero', 5.00),
-- (2, 'Papas arrugadas con mojo', 6.50),
-- (3, 'Queso asado con mojo', 7.00),
-- (4, 'Escaldon', 7.00),
-- (5, 'Ropa vieja', 9.00),
-- (6, 'Costilla con papas y piña', 10.00),
-- (7, 'Carne fiesta', 9.50),
-- (8, 'Quesillo', 4.50),
-- (9, 'Bienmesabe', 4.50);

-- -- Insertar en la tabla finanzas
-- INSERT INTO finanzas (restaurante, fecha, alquiler, personal, proveedores, extra, ingresos_presencial, ingresos_domicilio, numero_clientes_presencial, nuevos_clientes_presencial, numero_clientes_domicilio, nuevos_clientes_domicilio) VALUES
-- (1, 1, 1300.00, 12000.00, 3254.40, 1045.11, 25911.13, 1741.15, 1798, 129, 188, 73);

-- -- Insertar en la tabla producto
-- INSERT INTO producto (restaurante, fecha, producto, ventas) VALUES
-- (1, 1, 1, 277),
-- (1, 1, 2, 337),
-- (1, 1, 3, 19),
-- (1, 1, 4, 131),
-- (1, 1, 5, 206),
-- (1, 1, 6, 160),
-- (1, 1, 7, 228),
-- (1, 1, 8, 388),
-- (1, 1, 9, 470);

-- -- Insertar en la tabla feedback
-- INSERT INTO feedback (restaurante, fecha, valoracion_ambiente, valoracion_personal, valoracion_comida) VALUES
-- (1, 1, 3.6, 2.3, 3.3);