-- dimension tiempo
create table tiempo (
    id serial not null,
    ano int not null, -- check
    mes int not null, -- check
    mes_texto varchar(10) not null,
    constraint pk_tiempo primary key (id)
);

-- dimension director
create table director (
    id serial not null, 
    text_id varchar(255) not null,
    nombre varchar(255) not null,
    constraint pk_director primary key (id)
);

-- dimension productor
create table productor (
    id serial not null, 
    text_id varchar(255) not null,
    nombre varchar(255) not null,
    constraint pk_productor primary key (id)
);

-- dimension productora
create table productora (
    id serial not null, 
    id_productora int not null,
    nombre varchar(255) not null,
    constraint pk_productora primary key (id)
);

-- tabla de hechos finanzas 
-- aunque director o productor ya no existan, se mantiene el registro financiero en la tabla finanzas.
-- restrict para tiempo y productora para mantener el historial de transacciones de las productoras
create table finanzas (
    director int,
    productor int,
    productora int,
    tiempo int,
    coste numeric default 0, -- o NULL 
    ingresos numeric default 0, -- o NULL
    constraint pk_finanzas primary key (director, productor, productora, tiempo),
    constraint fk_director foreign key (director) references director(id) on delete set null on update cascade,
    constraint fk_productor foreign key (productor) references productor(id) on delete set null on update cascade,
    constraint fk_productora foreign key (productora) references productora(id) on delete restrict on update cascade,
    constraint fk_tiempo foreign key (tiempo) references tiempo(id) on delete restrict on update cascade
);

-- tabla de hechos satisfaccion_usuarios
create table satisfaccion_usuarios (
    director int,
    productor int,
    productora int,
    tiempo_emision int,
    tiempo_votacion int,
    votos int default 0,
    satisfaccion numeric(2, 1) check (satisfaccion >= 0 and satisfaccion <= 5) default 0,
    constraint pk_satisfaccion_usuarios primary key (director, productor, productora, tiempo_emision, tiempo_votacion),
    constraint fk_director foreign key (director) references director(id) on delete set null on update cascade,
    constraint fk_productor foreign key (productor) references productor(id) on delete set null on update cascade,
    constraint fk_productora foreign key (productora) references productora(id) on delete restrict on update cascade,
    constraint fk_tiempo_emision foreign key (tiempo_emision) references tiempo(id) on delete restrict on update cascade,
    constraint fk_tiempo_votacion foreign key (tiempo_votacion) references tiempo(id) on delete restrict on update cascade
);
-- 21284, 33744, 550, 36929, 36929

-- datos de prueba
insert into tiempo (ano, mes, mes_texto) values (2014, 11, 'November');
insert into tiempo (ano, mes, mes_texto) values (2001, 7, 'July');

insert into director (text_id, nombre) values ('D001', 'Christopher Nolan');
insert into director (text_id, nombre) values ('D002', 'Hayao Miyazaki');

insert into productor (text_id, nombre) values ('P001', 'Quentin Tarantino');
insert into productor (text_id, nombre) values ('P002', 'Toshio Suzuki');

insert into productora (id_productora, nombre) values (1, 'Warner Bros');
insert into productora (id_productora, nombre) values (2, 'Studio Ghibli');

insert into finanzas (director, productor, productora, tiempo, coste, ingresos) values (1, 1, 1, 1, 165000000, 773000000); -- interstellar
insert into finanzas (director, productor, productora, tiempo, coste, ingresos) values (2, 2, 2, 2, 15000000, 395580000); -- el viaje de chihiro

-- Insertar datos en la tabla satisfaccion_usuarios
insert into satisfaccion_usuarios (director, productor, productora, tiempo_emision, tiempo_votacion, votos, satisfaccion) values (1, 1, 1, 1, 1, 2200000, 4.4);
insert into satisfaccion_usuarios (director, productor, productora, tiempo_emision, tiempo_votacion, votos, satisfaccion) values (2, 2, 2, 2, 2, 873000, 4.3);