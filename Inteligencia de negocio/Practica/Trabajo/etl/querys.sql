drop schema if exists etl cascade;
create schema etl;

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

drop schema if exists public cascade;
create schema public;


CREATE TABLE public.satisfacción_usuarios(
  id INT NOT NULL,
  ano_votacion INT NOT NULL, -- Año de la votación
  mes_votacion INT NOT NULL, -- Mes de la votación
  alquiler NUMERIC NOT NULL,
  proveedores NUMERIC NOT NULL,
  extra NUMERIC NOT NULL,
  ingresos_presencial NUMERIC NOT NULL,
  ingresos_domicilio NUMERIC NOT NULL,
  valoracion_ambiente NUMERIC(5, 2), -- Valoración del ambiente
  valoracion_personal NUMERIC(5, 2), -- Valoración del personal
  valoracion_comida NUMERIC(5, 2), -- Valoración de la comida
  PRIMARY KEY (id, mes_votacion,ano_votacion)
);


CREATE TABLE public.finanzas(
  id INT NOT NULL,
  ano INT NOT NULL, -- Año de la votación
  mes INT NOT NULL, -- Mes de la votación
  alquiler NUMERIC NOT NULL,
  proveedores NUMERIC NOT NULL,
  extra NUMERIC NOT NULL,
  ingresos_presencial NUMERIC NOT NULL,
  ingresos_domicilio NUMERIC NOT NULL,
  Porcentaje_nuevos_clientes_presencial NUMERIC NOT NULL,
  Porcentaje_nuevos_clientes_domicilio NUMERIC NOT NULL,
  Ratio_ingresos_presencial_domicilio NUMERIC NOT NULL,
  Ratio_presencial_domicilio NUMERIC NOT NULL,
  Ingresos_por_cliente_domicilio NUMERIC NOT NULL,
  Ingresos_por_cliente_presencial NUMERIC NOT NULL,
  PRIMARY KEY (id, mes,ano)
);


CREATE TABLE public.productos(
  id INT NOT NULL,
  ano INT NOT NULL,
  mes INT NOT NULL,
  plato_id INT NOT NULL,
  plato_precio NUMERIC NOT NULL,
  plato_ventas INT NOT NULL,
  plato_ingresos NUMERIC NOT NULL,
  PRIMARY KEY (id, ano, mes, plato_id)
);


CREATE TABLE public.restaurantes(
  id INT NOT NULL,
  ciudad VARCHAR NOT NULL,
  pais VARCHAR NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE public.platos(
  plato_id INT NOT NULL,
  plato_nombre VARCHAR NOT NULL,
  plato_precio NUMERIC NOT NULL,
  PRIMARY KEY (plato_id)
);

CREATE TABLE public.tiempo(
  ano INT NOT NULL,
  mes INT NOT NULL,
  mes_texto VARCHAR NOT NULL,
  PRIMARY KEY (ano,mes)
);


SELECT * 
FROM etl.restaurantes_platos
ORDER BY id, fecha_emision, plato_id;

SELECT * 
FROM public.satisfacción_usuarios
ORDER BY id, ano_votacion, mes_votacion;

SELECT * 
FROM public.productos
ORDER BY id, ano, mes, plato_id;

SELECT * 
FROM public.finanzas
ORDER BY id, ano, mes;


SELECT * 
FROM public.platos
ORDER BY plato_id;

SELECT * 
FROM public.tiempo
ORDER BY  ano, mes;

SELECT * 
FROM public.restaurantes
ORDER BY id;
