-- Dimensión tiempo
create table tiempo (
    id serial not null,
    ano int not null,
    mes int not null,
    mes_texto varchar(10) not null,
    constraint pk_tiempo primary key (id)
);

-- Dimensión restaurante
create table restaurante (
    id int not null,
    pais varchar(255) not null,
    ciudad varchar(255) not null,
    constraint pk_restaurante primary key (id)
);

-- Dimensión productos
create table productos (
    id int not null,
    nombre varchar(255) not null,
    precio numeric(10, 2) not null,
    constraint pk_productos primary key (id)
);


-- evitamos que se modifiquen o eliminen restaurantes y/o fechas si hay registros asociados en las tablas de hechos. GArantizamos la consistencia de los datos y la integridad referencial. 


-- Tabla de hechos finanzas
create table finanzas (
    restaurante int,
    fecha int,
    alquiler numeric(15, 2) default 0,
    personal numeric(15, 2) default 0,
    proveedores numeric(15, 2) default 0,
    extra numeric(15, 2) default 0,
    ingresos_presencial numeric(15, 2) default 0,
    ingresos_domicilio numeric(15, 2) default 0,
    numero_clientes_presencial int default 0,
    nuevos_clientes_presencial int default 0,
    numero_clientes_domicilio int default 0,
    nuevos_clientes_domicilio int default 0,
    constraint pk_finanzas primary key (restaurante, fecha),
    constraint fk_finanzas_restaurante foreign key (restaurante) references restaurante(id) on update restrict on delete restrict,
    constraint fk_finanzas_fecha foreign key (fecha) references tiempo(id) on update restrict on delete restrict
);

-- Tabla de hechos producto
create table producto (
    restaurante int,
    fecha int,
    producto int,
    ventas int default 0,
    constraint pk_producto primary key (restaurante, fecha, producto),
    constraint fk_producto_restaurante foreign key (restaurante) references restaurante(id) on update restrict on delete restrict,
    constraint fk_producto_fecha foreign key (fecha) references tiempo(id) on update restrict on delete restrict,
    constraint fk_producto_producto foreign key (producto) references productos(id) on update restrict on delete restrict
);

-- Tabla de hechos feedback
create table feedback (
    restaurante int not null,
    fecha int not null,
    valoracion_ambiente numeric(2, 1) check (valoracion_ambiente >= 0 and valoracion_ambiente <= 5),
    valoracion_personal numeric(2, 1) check (valoracion_personal >= 0 and valoracion_personal <= 5),
    valoracion_comida numeric(2, 1) check (valoracion_comida >= 0 and valoracion_comida <= 5),
    constraint pk_feedback primary key (restaurante, fecha),
    constraint fk_feedback_restaurante foreign key (restaurante) references restaurante(id) on update restrict on delete restrict,
    constraint fk_feedback_fecha foreign key (fecha) references tiempo(id) on update restrict on delete restrict
);





--Datos de prueba

-- Insertar en la tabla tiempo
INSERT INTO tiempo (id, ano, mes, mes_texto) VALUES
(1, 2021, 2, 'Febrero');

-- Insertar en la tabla restaurante
INSERT INTO restaurante (id, pais, ciudad) VALUES
(1, 'España', 'La Laguna');

-- Insertar en la tabla productos
INSERT INTO productos (id, nombre, precio) VALUES
(1, 'Almogrote Gomero', 5.00),
(2, 'Papas arrugadas con mojo', 6.50),
(3, 'Queso asado con mojo', 7.00),
(4, 'Escaldon', 7.00),
(5, 'Ropa vieja', 9.00),
(6, 'Costilla con papas y piña', 10.00),
(7, 'Carne fiesta', 9.50),
(8, 'Quesillo', 4.50),
(9, 'Bienmesabe', 4.50);

-- Insertar en la tabla finanzas
INSERT INTO finanzas (restaurante, fecha, alquiler, personal, proveedores, extra, ingresos_presencial, ingresos_domicilio, numero_clientes_presencial, nuevos_clientes_presencial, numero_clientes_domicilio, nuevos_clientes_domicilio) VALUES
(1, 1, 1300.00, 12000.00, 3254.40, 1045.11, 25911.13, 1741.15, 1798, 129, 188, 73);

-- Insertar en la tabla producto
INSERT INTO producto (restaurante, fecha, producto, ventas) VALUES
(1, 1, 1, 277),
(1, 1, 2, 337),
(1, 1, 3, 19),
(1, 1, 4, 131),
(1, 1, 5, 206),
(1, 1, 6, 160),
(1, 1, 7, 228),
(1, 1, 8, 388),
(1, 1, 9, 470);

-- Insertar en la tabla feedback
INSERT INTO feedback (restaurante, fecha, valoracion_ambiente, valoracion_personal, valoracion_comida) VALUES
(1, 1, 3.6, 2.3, 3.3);