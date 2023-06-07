/* ---------------------------- SCRIPT DB ---------------------------- */

set @old_sql_mode=@@sql_mode, sql_mode='only_full_group_by,strict_trans_tables,no_zero_in_date,no_zero_date,error_for_division_by_zero,no_engine_substitution';

create schema if not exists `trabajopracticobd1` ;
USE `trabajopracticobd1` ;

create table if not exists `modelo` (
  `id_modelo` int not null,
  `nombre` varchar(45) not null,
  primary key (`id_modelo`));

create table `linea_de_montaje` (
  `id_linea_de_montaje` int not null,
  `promedio_productividad` float not null,
  `modelo_id_modelo` int not null,
  primary key (`id_linea_de_montaje`),
  foreign key (`modelo_id_modelo`) references `modelo` (`id_modelo`));

create table `estacion` (
  `id_estacion` int not null,
  `tarea` varchar(45) not null,
  `orden` int not null,
  `promedio_productividad` float not null,
  `linea_de_montaje_id_linea_de_montaje` int not null,
  primary key (`id_estacion`),
  foreign key (`linea_de_montaje_id_linea_de_montaje`) references `linea_de_montaje` (`id_linea_de_montaje`));

create table `empresa_proveedora` (
  `id_empresa_proveedora` int not null,
  `nombre` varchar(45) not null,
  `direccion` varchar(45) not null,
  `telefono` varchar(45) not null,
  `borrado` boolean not null,
  primary key (`id_empresa_proveedora`));

create table  `insumo` (
  `codigo` int not null,
  `descripcion` text(100) null,
  `borrado` boolean not null,
  primary key (`codigo`));

create table `empresa_concesionaria` (
  `id_empresa_concesionaria` int not null,
  `nombre` varchar(45) not null,
  `direccion` varchar(45) not null,
  `contacto` varchar(45) not null,
  `borrado` boolean not null,
  primary key (`id_empresa_concesionaria`));

create table `encabezado_pedido` (
  `id_pedido_empresa` int not null,
  `fecha_pedido` date not null,
  `activo` tinyint not null,
  `empresa_concesionaria_id_empresa_concesionaria` int not null,
  `borrado` boolean not null,
  primary key (`id_pedido_empresa`),
  foreign key (`empresa_concesionaria_id_empresa_concesionaria`) references `empresa_concesionaria` (`id_empresa_concesionaria`));

create table `vehiculo` (
  `nro_chasis` int not null,
  `fecha_finalizacion` date,
  `modelo_id_modelo` int not null,
  primary key (`nro_chasis`),
  foreign key (`modelo_id_modelo`) references `modelo` (`id_modelo`));

create table `estacion_has_insumo` (
  `estacion_id_estacion` int not null,
  `insumo_codigo` int not null,
  `tipo_de_cantidad` varchar(45) not null,
  `cantidad` int not null,
  primary key (`estacion_id_estacion`, `insumo_codigo`),
  foreign key (`estacion_id_estacion`) references `estacion` (`id_estacion`),
  foreign key (`insumo_codigo`) references `insumo` (`codigo`));

create table `stock` (
  `insumo_codigo` int not null,
  `empresa_proveedora_id_empresa_proveedora` int not null,
  `precio` float not null,
  `cantidad` int null,
  primary key (`insumo_codigo`, `empresa_proveedora_id_empresa_proveedora`),
  foreign key (`insumo_codigo`) references `insumo` (`codigo`),
  foreign key (`empresa_proveedora_id_empresa_proveedora`) references `empresa_proveedora` (`id_empresa_proveedora`));

create table `vehiculo_has_estacion` (
  `vehiculo_nro_chasis` int not null,
  `estacion_id_estacion` int not null,
  `fecha_ingreso` date not null,
  `hora_ingreso` time not null,
  `fecha_egreso` date,
  `hora_egreso` time,
  `finalizado` boolean not null,
  primary key (`vehiculo_nro_chasis`, `estacion_id_estacion`),
  foreign key (`vehiculo_nro_chasis`) references `vehiculo` (`nro_chasis`),
  foreign key (`estacion_id_estacion`) references `estacion` (`id_estacion`));

create table `encabezado_pedido_has_modelo` (
  `encabezado_pedido_id_pedido_empresa` int not null,
  `modelo_id_modelo` int not null,
  `cantidad` int not null,
  `borrado` boolean not null,
  primary key (`encabezado_pedido_id_pedido_empresa`, `modelo_id_modelo`),
  foreign key (`encabezado_pedido_id_pedido_empresa`) references `encabezado_pedido` (`id_pedido_empresa`),
  foreign key (`modelo_id_modelo`) references `modelo` (`id_modelo`));
  
/* -------------------------------------------------------- */

/* 
drop procedure if exists alta_insumo;
drop procedure if exists modificacion_insumo;
drop procedure if exists baja_insumo;
drop procedure if exists alta_empresa_concesionaria;
drop procedure if exists modificacion_empresa_concesionaria;
drop procedure if exists baja_empresa_concesionaria;
drop procedure if exists alta_empresa_proveedora;
drop procedure if exists modificacion_empresa_proveedora;
drop procedure if exists baja_empresa_proveedora;
drop procedure if exists alta_encabezado_pedido;
drop procedure if exists modificacion_encabezado_pedido;
drop procedure if exists baja_encabezado_pedido;
drop procedure if exists alta_detalle_pedido;
drop procedure if exists modificacion_detalle_pedido;
drop procedure if exists baja_detalle_pedido;
*/

/* ---------------------------- INSUMO  ---------------------------- */

/* ------- ALTA INSUMO ------- */

delimiter ;;
create procedure `alta_insumo`(
  in pcodigo int,
  in pdescripcion text(100),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
       declare nCantidad int default 0;
       select count(*) into nCantidad from insumo where codigo = pcodigo;
       
	    if (nCantidad > 0) then
		    select -1 into n_resultado;	
            select 'El insumo ya se encuentra en la base de datos.' into c_mensaje;
	    else
		    select 0 into n_resultado;	
            select 'Se dio de alta al insumo.' into c_mensaje;
            insert into insumo (codigo, descripcion,borrado) values (pcodigo, pdescripcion,'0');
		end if;
        select c_mensaje, n_resultado;
	end ;;
delimiter ;

call alta_insumo('1', 'hola',@mensaje,@cant);
call alta_insumo('2', 'hola2',@mensaje,@cant);

/* ------- MODIFICACIÓN INSUMO ------- */

delimiter ;;
create procedure `modificacion_insumo`(
  in pcodigo int,
  in pdescripcion text(100),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
       declare nCantidad int default 0;
       select count(*) into nCantidad from insumo where codigo = pcodigo and borrado='0';
       
	    if (nCantidad > 0) then
		    select 0 into n_resultado;	
            select 'Se modificó al insumo.' into c_mensaje;
            update insumo set descripcion=pdescripcion where codigo=pcodigo;
	    else
		    select -1 into n_resultado;	
            select 'El insumo no se encuentra en la base de datos.' into c_mensaje;
	    end if;
        select c_mensaje, n_resultado;
	end ;;
delimiter ;

call modificacion_insumo('1', 'rueda', @mensaje, @cant);

/* ------- BAJA INSUMO ------- */

delimiter ;;
create procedure `baja_insumo`(
  in pcodigo int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
       declare nCantidad int default 0;
       select count(*) into nCantidad from insumo where codigo = pcodigo and borrado='0';
       
	    if (nCantidad > 0) then
		    select 0 into n_resultado;	
            select 'Se eliminó al insumo.' into c_mensaje;
            update insumo set borrado='1' where codigo=pcodigo;
	    else
		    select -1 into n_resultado;	
            select 'El insumo no se encuentra en la base de datos.' into c_mensaje;
	    end if;
		select c_mensaje, n_resultado;
	end ;;
delimiter ;

call baja_insumo('2',@mensaje,@cant);

/* ---------------------------- EMPRESA CONCESIONARIA  ---------------------------- */

/* ------- ALTA EMPRESA CONCESIONARIA ------- */

delimiter ;;
create procedure `alta_empresa_concesionaria`(
  in p_id_empresa_concesionaria int,
  in p_nombre varchar(45),
  in p_direccion varchar(45),
  in p_contacto varchar(45),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
       declare nCantidad int default 0;
       select count(*) into nCantidad from empresa_concesionaria where id_empresa_concesionaria = p_id_empresa_concesionaria;
       
	    if (nCantidad > 0) then
		    select -1 into n_resultado;	
            select 'La concesionaria ya se encuentra en la base de datos.' into c_mensaje;
	    else
		    select 0 into n_resultado;	
            select 'Se dio de alta a la empresa concesionaria.' into c_mensaje;
            insert into empresa_concesionaria (id_empresa_concesionaria, nombre,direccion, contacto, borrado) 
            values (p_id_empresa_concesionaria, p_nombre,p_direccion,p_contacto, '0');
		end if;
		select c_mensaje, n_resultado;
	end ;;
delimiter ;

call alta_empresa_concesionaria('1', 'Renault',"calle falsa 123","contacto 1",@mensaje,@cant);
call alta_empresa_concesionaria('2', 'Renault2',"calle falsa 123","contacto 1",@mensaje,@cant);

/* ------- MODIFICACIÓN EMPRESA CONCESIONARIA ------- */

delimiter ;;
create procedure `modificacion_empresa_concesionaria`(
  in p_id_empresa_concesionaria int,
  in p_nombre varchar(45),
  in p_direccion varchar(45),
  in p_contacto varchar(45),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
       declare nCantidad int default 0;
       select count(*) into nCantidad from empresa_concesionaria where id_empresa_concesionaria = p_id_empresa_concesionaria and borrado='0';
       
	    if (nCantidad > 0) then
		    select 0 into n_resultado;	
            select 'Se modificó a la empresa concesionaria.' into c_mensaje;
            update empresa_concesionaria set nombre=p_nombre where id_empresa_concesionaria=p_id_empresa_concesionaria;
            update empresa_concesionaria set direccion=p_direccion where id_empresa_concesionaria=p_id_empresa_concesionaria;
            update empresa_concesionaria set contacto=p_contacto where id_empresa_concesionaria=p_id_empresa_concesionaria;
	    else
		    select -1 into n_resultado;	
            select 'El insumo no se encuentra en la base de datos.' into c_mensaje;
	    end if;
		select c_mensaje, n_resultado;
	end ;;
delimiter ;

call modificacion_empresa_concesionaria('1', 'Hola',"calle verdadera 123","contacto 2",@mensaje,@cant);

/* ------- BAJA EMPRESA CONCESIONARIA ------- */

delimiter ;;
create procedure `baja_empresa_concesionaria`(
  in p_id_empresa_concesionaria int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
       declare nCantidad int default 0;
       select count(*) into nCantidad from empresa_concesionaria where id_empresa_concesionaria = p_id_empresa_concesionaria and borrado='0';
       
	    if (nCantidad > 0) then
		    select 0 into n_resultado;	
            select 'Se eliminó a la empresa concesionaria.' into c_mensaje;
            update empresa_concesionaria set borrado='1' where id_empresa_concesionaria=p_id_empresa_concesionaria;
	    else
		    select -1 into n_resultado;	
            select 'La concesionaria no se encuentra en la base de datos.' into c_mensaje;
	    end if;
		select c_mensaje, n_resultado;
	end ;;
delimiter ;

call baja_empresa_concesionaria('2',@mensaje,@cant);

/* ---------------------------- EMPRESA PROVEEDORA  ---------------------------- */

/* ------- ALTA EMPRESA PROVEEDORA ------- */

delimiter ;;
create procedure `alta_empresa_proveedora`(
  in p_id_empresa_proveedora int,
  in p_nombre varchar(45),
  in p_direccion varchar(45),
  in p_telefono varchar(45),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		if(exists(select * from empresa_proveedora where id_empresa_proveedora = p_id_empresa_proveedora )) then
			select -1 into n_resultado;
            select 'La empresa proveedora ya se encuentra en la base de datos.' into c_mensaje;
		else
			insert into empresa_proveedora (id_empresa_proveedora, nombre, direccion, telefono, borrado) values (p_id_empresa_proveedora, p_nombre, p_direccion, p_telefono, '0');
			select 0 into n_resultado;
			select 'Se dio de alta a la empresa proveedora.' into c_mensaje;
        end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

call alta_empresa_proveedora(1,'empresa','direccion','232343', @msj, @cant);
call alta_empresa_proveedora(2,'empresa2','direccion2','232343', @msj, @cant);

/* ------- MODIFICACIÓN EMPRESA PROVEEDORA ------- */

delimiter ;;
create procedure `modificacion_empresa_proveedora`(
  in p_id_empresa_proveedora int,
  in p_nombre varchar(45),
  in p_direccion varchar(45),
  in p_telefono varchar(45),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		if(exists(select * from empresa_proveedora where id_empresa_proveedora = p_id_empresa_proveedora )) then
			update empresa_proveedora set nombre = p_nombre where id_empresa_proveedora = p_id_empresa_proveedora;
			update empresa_proveedora set direccion = p_direccion where id_empresa_proveedora = p_id_empresa_proveedora;
			update empresa_proveedora set telefono = p_telefono where id_empresa_proveedora = p_id_empresa_proveedora;
			set c_mensaje = "Se modificó a la empresa proveedora.";
			select 0 into n_resultado;
		else
			set c_mensaje = "La empresa proveedora indicada no existe.";
			select -1 into n_resultado;
		end if;
		select n_resultado, c_mensaje;
	end ;;
delimiter ;

call modificacion_empresa_proveedora('1','empresanueva','direccionnueva', '212312', @msj, @cant); 

/* ------- BAJA EMPRESA PROVEEDORA ------- */

delimiter ;;
create procedure `baja_empresa_proveedora`(
  in p_id_empresa_proveedora int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		if(exists(select * from empresa_proveedora where id_empresa_proveedora = p_id_empresa_proveedora )) then
			update empresa_proveedora set borrado = 1  where id_empresa_proveedora = p_id_empresa_proveedora;
			select "Se eliminó a la empresa proveedora." into c_mensaje;
			select 0 into n_resultado;
		else 
			select "No se encontró a la empresa proveedora." into c_mensaje;
			select -1 into n_resultado;
		end if;
		select n_resultado, c_mensaje;
	end ;;
delimiter ;

call baja_empresa_proveedora(2, @msj, @cant); 

/* ---------------------------- ENCABEZADO  ---------------------------- */

/* ------- ALTA ENCABEZADO ------- */

delimiter ;;
create procedure `alta_encabezado_pedido`(
  in p_id_pedido int,
  in p_fecha_pedido date,
  in p_id_empresa_concesionaria int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		declare cantidad_c int default 0;
		declare cantidad int default 0;
        select count(*) into cantidad from encabezado_pedido where id_pedido_empresa = p_id_pedido;
        
        if (cantidad > 0) then
			select -1 into n_resultado;
            select 'El encabezado ya se encuentra en la base de datos.' into c_mensaje;
		else
			select count(*) into cantidad_c from empresa_concesionaria where id_empresa_concesionaria = p_id_empresa_concesionaria;
            if (cantidad_c > 0) then
				select 0 into n_resultado;
				select 'Se dio de alta al encabezado.' into c_mensaje;
				insert into encabezado_pedido (id_pedido_empresa, fecha_pedido, activo,
				empresa_concesionaria_id_empresa_concesionaria, borrado) values
				(p_id_pedido, p_fecha_pedido, '1', p_id_empresa_concesionaria, '0');
			else
				select -1 into n_resultado;
				select 'La empresa concesionaria indicada no existe.' into c_mensaje;
            end if;
        end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

call alta_encabezado_pedido(1, '2020-9-22', 1, @cant, @msj);
call alta_encabezado_pedido(2, '2020-9-24', 1, @cant, @msj);

/* ------- MODIFICACIÓN ENCABEZADO ------- */

delimiter ;;
create procedure `modificacion_encabezado_pedido`(
  in p_id_pedido int,
  in p_fecha_pedido date,
  in p_activo tinyint,
  in p_id_empresa_concesionaria int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		declare cantidad_c int default 0;
		declare cantidad int default 0;
        select count(*) into cantidad from encabezado_pedido where id_pedido_empresa = p_id_pedido and borrado='0';
        
        if (cantidad > 0) then
			select count(*) into cantidad_c from empresa_concesionaria where id_empresa_concesionaria = p_id_empresa_concesionaria;
            if (cantidad_c > 0) then
				select 0 into n_resultado;
				select 'Se modificó al encabezado pedido' into c_mensaje;
				update encabezado_pedido set fecha_pedido = p_fecha_pedido where id_pedido_empresa = p_id_pedido;
				update encabezado_pedido set activo = p_activo where id_pedido_empresa = p_id_pedido;
				update encabezado_pedido set empresa_concesionaria_id_empresa_concesionaria = p_id_empresa_concesionaria where id_pedido_empresa = p_id_pedido;
			else
				select -1 into n_resultado;
				select 'La empresa concesionaria por la que desea modificar no existe.' into c_mensaje;
            end if;
        else
            select -1 into n_resultado;
            select 'El encabezado no se encuentra en la base de datos.' into c_mensaje;
		end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

call modificacion_encabezado_pedido(1, '2020-9-23','1', 1, @cant, @msj); 

/* ------- BAJA ENCABEZADO ------- */

delimiter ;;
create procedure `baja_encabezado_pedido`(
  in p_id_pedido int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		declare cantidad int default 0;
        declare cantidad_detalle int default 0;
        select count(*) into cantidad from encabezado_pedido where id_pedido_empresa = p_id_pedido and borrado='0';
        
      if (cantidad > 0) then
            select count(*) into cantidad_detalle from encabezado_pedido_has_modelo where encabezado_pedido_id_pedido_empresa = p_id_pedido and borrado = '0';
			if (cantidad_detalle > 0) then
				select -1 into n_resultado;
				select 'El encabezado no puede ser borrado ya que tiene datos relacionados.' into c_mensaje;
            else
				select 0 into n_resultado;
				select 'Se eliminó al encabezado pedido' into c_mensaje;
				update encabezado_pedido set borrado = '1' where id_pedido_empresa = p_id_pedido;
			end if;
        else
            select -1 into n_resultado;
            select 'El encabezado no se encuentra en la base de datos.' into c_mensaje;
		end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

call baja_encabezado_pedido(1, @cant, @msj); 

/* ---------------------------- DETALLE  ---------------------------- */

/* ------- ALTA DETALLE ------- */

delimiter ;;
create procedure `alta_detalle_pedido`(
  in p_id_pedido int,
  in p_id_modelo int,
  in p_cantidad int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		declare cantidad_m int default 0;
		declare cantidad int default 0;
        select count(*) into cantidad from encabezado_pedido_has_modelo where encabezado_pedido_id_pedido_empresa = p_id_pedido and modelo_id_modelo = p_id_modelo;
        select count(*) into cantidad_m from modelo where id_modelo = p_id_modelo;
        
        if (cantidad_m > 0) then
			if (cantidad > 0) then
				select -1 into n_resultado;
				select 'El detalle para el encabezado y modelo indicados ya se encuentran en la base de datos.' into c_mensaje;
			else
				select 0 into n_resultado;
				select 'Se dio de alta al detalle pedido.' into c_mensaje;
				insert into encabezado_pedido_has_modelo (encabezado_pedido_id_pedido_empresa, modelo_id_modelo,
				cantidad, borrado) values
				(p_id_pedido, p_id_modelo, p_cantidad, '0');
			end if;
		else 
			select -1 into n_resultado;
				select 'El modelo no se encuentra en la base de datos.' into c_mensaje;
        end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

insert into modelo values (1, 'Renault');
insert into vehiculo values (1, null, 1);
call alta_detalle_pedido(1, 1, 1, @cant, @msj);
insert into modelo values (2, 'Mansory');
insert into vehiculo values (2, null, 1);
call alta_detalle_pedido(2, 2, 1, @cant, @msj);

/* ------- MODIFICACIÓN DETALLE ------- */

delimiter ;;
create procedure `modificacion_detalle_pedido`(
  in p_id_pedido int,
  in p_id_modelo varchar(45),
  in p_cantidad int,
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		declare cantidad_m int default 0;
		declare cantidad int default 0;
        select count(*) into cantidad from encabezado_pedido_has_modelo where encabezado_pedido_id_pedido_empresa = p_id_pedido and modelo_id_modelo = p_id_modelo and borrado='0';
        
		if (cantidad > 0) then
			select 0 into n_resultado;
			select 'Se modificó al detalle pedido.' into c_mensaje;
			update encabezado_pedido_has_modelo set cantidad = p_cantidad where encabezado_pedido_id_pedido_empresa = p_id_pedido and modelo_id_modelo = p_id_modelo;
		else
			select -1 into n_resultado;
			select 'El detalle para el encabezado y con ese modelo no se encuentra en la base de datos.' into c_mensaje;
		end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

call modificacion_detalle_pedido(2,2 , 50, @cant, @msj);

/* ------- BAJA DETALLE ------- */

delimiter ;;
create procedure `baja_detalle_pedido`(
  in p_id_pedido int,
  in p_id_modelo varchar(45),
  out c_mensaje varchar(500),
  out n_resultado int
)
	begin
		declare cantidad_m int default 0;
		declare cantidad int default 0;
		select count(*) into cantidad from encabezado_pedido_has_modelo where encabezado_pedido_id_pedido_empresa = p_id_pedido and modelo_id_modelo = p_id_modelo and borrado='0';
        
		if (cantidad > 0) then
			select 0 into n_resultado;
			select 'Se eliminó al detalle pedido.' into c_mensaje;
			update encabezado_pedido_has_modelo set borrado = '1' where encabezado_pedido_id_pedido_empresa = p_id_pedido and modelo_id_modelo = p_id_modelo;
		else
			select -1 into n_resultado;
			select 'El detalle para el encabezado y con ese modelo no se encuentra en la base de datos.' into c_mensaje;
		end if;
		select n_resultado, c_mensaje;
    end ;;
delimiter ;

call baja_detalle_pedido(1,1, @cant, @msj);

/* -------------------------------------------------------- */

/*
select * from modelo;
select * from linea_de_montaje;
select * from insumo;
select * from empresa_proveedora;
select * from stock;
select * from estacion;
select * from vehiculo;
select * from empresa_concesionaria;
select * from encabezado_pedido;
select * from estacion_has_insumo;
select * from vehiculo_has_estacion;
select * from encabezado_pedido_has_vehiculo;
*/

/*Entrega N° 3 Construcción de procedimientos de negocio */

/* ejercicio 3*/

delimiter ;;
create procedure `alta_vehiculos`(
  in p_idPedidoParametro int,
  out n_insertado int,
  out c_mensaje varchar(500),
  out n_resultado int
)
begin
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE p_nroChasis INTEGER DEFAULT 1;
    DECLARE idModeloParametro INTEGER;
	DECLARE nCantidadDetalle INT; 

	DECLARE curDetallePedido CURSOR FOR SELECT modelo_id_modelo,cantidad FROM encabezado_pedido_has_modelo WHERE encabezado_pedido_id_pedido_empresa = p_idPedidoParametro and borrado='0';
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
    select count(*) into p_nroChasis from vehiculo;
    
    SET p_nroChasis = p_nroChasis +1;
    SET n_insertado = 0;
    
    OPEN curDetallePedido;
	 
	getDetalle: LOOP

		FETCH curDetallePedido INTO idModeloParametro, nCantidadDetalle;
				IF finished = 1 THEN
					LEAVE getDetalle;
				END IF;
	
					WHILE n_insertado < nCantidadDetalle DO
					INSERT INTO vehiculo (nro_chasis,fecha_finalizacion,modelo_id_modelo) VALUES (p_nroChasis,null, idModeloParametro);
					SET n_insertado = n_insertado  +1;
					SET p_nroChasis = p_nroChasis  +1;
					END WHILE;

		END LOOP getDetalle;

	CLOSE curDetallePedido;

	if (n_insertado > 0) then
				select 1 into n_resultado;
				select 'se agregaron los vehiculos' into c_mensaje;
			else
				select -1 into n_resultado;
				select 'No se pudo agregar los vehiculos' into c_mensaje;
			end if;
			select n_resultado, c_mensaje, n_insertado;

end ;;
delimiter ;

call alta_vehiculos(2,@insertado,@mensaje,@resultado);

/* ejercicio 4*/

drop procedure if exists inicio_montaje_vehiculo;

/*insert into linea_de_montaje values (1,0,1);*/
insert into linea_de_montaje values (1,0,2);
insert into estacion values(1, 'Armado', 1,0, 1);
insert into estacion values(2, 'Pintura',2,0, 1);

delimiter ;;
create procedure `inicio_montaje_vehiculo`(
  in p_nro_chasis int,
  out c_mensaje varchar(500),
  out n_resultado int
)
begin
	DECLARE nro_chasis_estacion INTEGER;
    DECLARE estacion integer;
	
    select vehiculo_nro_chasis into nro_chasis_estacion from vehiculo_has_estacion ve 
    inner join estacion e on ve.estacion_id_estacion=e.id_estacion
    inner join linea_de_montaje lm on e.linea_de_montaje_id_linea_de_montaje=lm.id_linea_de_montaje
    inner join modelo m on lm.modelo_id_modelo=m.id_modelo
    where m.id_modelo = (select modelo_id_modelo from vehiculo where nro_chasis=p_nro_chasis)
    and e.orden = 1
    and ve.finalizado='0'; /*finalizado sea falso*/
    
    if nro_chasis_estacion > 0 then
		select nro_chasis_estacion into n_resultado;
		select 'la estacion esta ocupada por el siguiente vehiculo' into c_mensaje;
    else 
		select id_estacion into estacion from estacion e
        inner join linea_de_montaje lm on e.linea_de_montaje_id_linea_de_montaje=lm.id_linea_de_montaje
		inner join modelo m on lm.modelo_id_modelo=m.id_modelo
		where m.id_modelo = (select modelo_id_modelo from vehiculo where nro_chasis=p_nro_chasis)
		and e.orden = 1;
		insert into vehiculo_has_estacion values(p_nro_chasis,estacion, CURDATE(), CURTIME(), null, null, '0');
        select p_nro_chasis into n_resultado;
		select 'El vehiculo fue  ingresado en la primer estacion' into c_mensaje;
    end if;
    
    select n_resultado, c_mensaje;
    
end ;;
delimiter ;

call inicio_montaje_vehiculo(3,@nro_chasis,@mensaje);
/*call inicio_montaje_vehiculo(3,@nro_chasis,@mensaje);*/

/* ejercicio 5*/

drop procedure if exists cambio_estacion_montaje_vehiculo;

delimiter ;;
create procedure `cambio_estacion_montaje_vehiculo`(
  in p_nro_chasis int,
  out c_mensaje varchar(500),
  out n_resultado int
)
begin
    DECLARE nro_estacion integer;
    DECLARE nro_orden INTEGER;
    DECLARE nro_estacion_siguiente INTEGER;
    DECLARE nro_orden_siguiente INTEGER;
    DECLARE ultima_estacion INTEGER;
    DECLARE nro_orden_ultima_estacion INTEGER;
    DECLARE nro_modelo INTEGER;
    
	/*  Guardo la estacion actual y orden */
    select estacion_id_estacion into nro_estacion from vehiculo_has_estacion ve
    where ve.vehiculo_nro_chasis = p_nro_chasis and ve.finalizado='0';
    
	select orden into nro_orden from estacion e
    where e.id_estacion = nro_estacion;
    
    SET nro_orden_siguiente = nro_orden +1;
    
    /* Guardo modelo*/
    select modelo_id_modelo into nro_modelo from vehiculo where nro_chasis=p_nro_chasis;
    
    /*  Guardo la ultima estacion y orden */
    select id_estacion into ultima_estacion from estacion e
        inner join linea_de_montaje lm on e.linea_de_montaje_id_linea_de_montaje=lm.id_linea_de_montaje
		inner join modelo m on lm.modelo_id_modelo=m.id_modelo
		where m.id_modelo = (select modelo_id_modelo from vehiculo where nro_chasis=p_nro_chasis)
        order by e.orden desc
        limit 1;
        
     select orden into nro_orden_ultima_estacion from estacion e
     where e.id_estacion = ultima_estacion;
     
	 /* Sale el vehiculo de la estacion*/   
	update vehiculo_has_estacion set fecha_egreso=CURDATE(), hora_egreso=CURTIME(),
    finalizado=1 where vehiculo_nro_chasis=p_nro_chasis and estacion_id_estacion=nro_estacion;
    
    if nro_orden_siguiente > nro_orden_ultima_estacion then
        update vehiculo set fecha_finalizacion=CURDATE() where nro_chasis=p_nro_chasis
        and modelo_id_modelo = nro_modelo;
		select 'Vehiculo terminado' into c_mensaje;
	else
     /* Entra el vehiculo a la estacion siguiente*/  
        select id_estacion into nro_estacion_siguiente from estacion e
        inner join linea_de_montaje lm on e.linea_de_montaje_id_linea_de_montaje=lm.id_linea_de_montaje
		inner join modelo m on lm.modelo_id_modelo=m.id_modelo
        where m.id_modelo = (select modelo_id_modelo from vehiculo where nro_chasis=p_nro_chasis)
        and e.orden = nro_orden_siguiente;
		insert into vehiculo_has_estacion values(p_nro_chasis,nro_estacion_siguiente, CURDATE(), CURTIME(), date_add(CURDATE(), interval 80 day), CURTIME(), '0');
		select 'El vehiculo fue  ingresado en la siguiente estacion' into c_mensaje;
    end if;
    
    select p_nro_chasis into n_resultado;
    select n_resultado, c_mensaje;
    
end ;;
delimiter ;

call cambio_estacion_montaje_vehiculo(3,@nro_chasis,@mensaje);

/* Ejercicio 6 */

delimiter ;;
create procedure `reporte_vehiculos`(
  in p_idPedidoParametro int,
  out n_insertado int,
  out c_mensaje varchar(500)
)
begin
	DECLARE finished INTEGER DEFAULT 0;
    DECLARE p_nroChasis INTEGER DEFAULT 1;
    DECLARE p_nro_chasis_actual integer;
    DECLARE idModeloParametro INTEGER;
	DECLARE nCantidadDetalle INT; 
    DECLARE n_estado varchar(45);
    DECLARE n_estacion int;
    DECLARE n_fecha date;

	DECLARE curDetallePedido CURSOR FOR SELECT modelo_id_modelo,cantidad FROM encabezado_pedido_has_modelo WHERE encabezado_pedido_id_pedido_empresa = p_idPedidoParametro and borrado='0';
 
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
    SET n_insertado = 0;
    set n_estacion = null;
    set n_fecha = null;
    
    select  nro_chasis into p_nro_chasis_actual from vehiculo 
    where modelo_id_modelo=(select modelo_id_modelo from encabezado_pedido_has_modelo where encabezado_pedido_id_pedido_empresa = p_idPedidoParametro and borrado='0')
    order by nro_chasis asc
	limit 1;
    
    drop table if exists `reporte_vehiculos`;
    create table if not exists `reporte_vehiculos` (
    `chasis` int not null,
    `estado` varchar(45) not null,
    `estacion` int,
     primary key (`chasis`));
    
    OPEN curDetallePedido;
	 
	getDetalle: LOOP

		FETCH curDetallePedido INTO idModeloParametro, nCantidadDetalle;
				IF finished = 1 THEN
					LEAVE getDetalle;
				END IF;
	
					WHILE n_insertado < nCantidadDetalle DO
                    
					select nro_chasis into p_nroChasis from vehiculo v
                    where modelo_id_modelo = idModeloParametro and
                    nro_chasis =p_nro_chasis_actual;
                    select fecha_finalizacion into n_fecha from vehiculo v
                    where nro_chasis = p_nro_chasis_actual;
                    
                    if n_fecha is null then
                       select estacion_id_estacion into n_estacion from vehiculo_has_estacion ve
                       where ve.vehiculo_nro_chasis = p_nro_chasis_actual and ve.finalizado='0';
                       set n_estado = 'En proceso';
					else
                       set n_estado = 'Finalizado';
					end if;
                    
					SET n_insertado = n_insertado  +1;
                    set p_nro_chasis_actual = p_nro_chasis_actual +1;
                    insert into reporte_vehiculos values(p_nroChasis,n_estado,n_estacion);
                    set n_fecha=null;
                    set n_estacion =null;
                    set n_estado =null;
                    
					END WHILE;

		END LOOP getDetalle;

	CLOSE curDetallePedido;
    
    select 'consulte la tabla reporte_vehiculos' into c_mensaje;
    select n_insertado,c_mensaje;

end ;;
delimiter ;

call reporte_vehiculos(2,@resultado,@mensaje);
select * from reporte_vehiculos;

/* Ejercicio 7 */
/*agregamos insumos y datos a la tabla estacion_has_insumos*/

call alta_insumo(3,"pintura",@mesaje,@resultado);
call alta_insumo(4,"paragolpes",@mesaje,@resultado);

insert into estacion_has_insumo values(1,1,"tipo de cantidad",4);
insert into estacion_has_insumo values(2,3,"tipo de cantidad",10);

delimiter ;;
create procedure `reporte_insumos`(
  in p_id_pedido_parametro int  
)
begin
	DECLARE id_modelo_parametro INTEGER;
    DECLARE id_linea_montaje_parametro integer;
    DECLARE nombre_modelo_parametro varchar(45);
    DECLARE c_menstaje varchar(100);
    
	select modelo_id_modelo  into id_modelo_parametro  from encabezado_pedido_has_modelo where encabezado_pedido_id_pedido_empresa = p_id_pedido_parametro;
    select  nombre into nombre_modelo_parametro  from modelo where id_modelo=id_modelo_parametro;
	select id_linea_de_montaje into id_linea_montaje_parametro from linea_de_montaje where modelo_id_modelo=id_modelo_parametro;
    select "insumos que se necesitaran para crear el auto del pedido" into c_menstaje;

    select  c_menstaje, ei.cantidad, i.descripcion,p_id_pedido_parametro,nombre_modelo_parametro from estacion e 
	inner join estacion_has_insumo ei on e.id_estacion = ei.estacion_id_estacion
	inner join insumo i on ei.insumo_codigo=i.codigo
	where e.linea_de_montaje_id_linea_de_montaje = id_linea_montaje_parametro;
end ;;
delimiter ;

call reporte_insumos(2);


/* Ejercicio 8*/

/* casos para sacar un promedio de productivida*/

insert into encabezado_pedido values (3, '2020-06-01', '1', 1, '0');
insert into encabezado_pedido_has_modelo values (3, 2, 5, '0');
insert into vehiculo values (53, '2020-08-04', 2);
insert into vehiculo values (54, '2020-9-21', 2);
insert into vehiculo values (55, '2020-10-23', 2);
insert into vehiculo values (56, '2020-11-05', 2);
insert into vehiculo values (57, null, 2);

insert into vehiculo_has_estacion values(53, 1, '2020-06-02', '08:00', '2020-07-02', '15:00', '1');
insert into vehiculo_has_estacion values(53, 2, '2020-07-03', '08:00', '2020-08-04', '15:00', '1');

insert into vehiculo_has_estacion values(54, 1, '2020-08-05', '08:00', '2020-08-25', '15:00', '1');
insert into vehiculo_has_estacion values(54, 2, '2020-08-26', '08:00', '2020-09-21', '15:00', '1');

insert into vehiculo_has_estacion values(55, 1, '2020-09-22', '08:00', '2020-10-02', '15:00', '1');
insert into vehiculo_has_estacion values(55, 2, '2020-10-03', '08:00', '2020-10-23', '15:00', '1');

insert into vehiculo_has_estacion values(56, 1, '2020-10-24', '08:00', '2020-10-31', '15:00', '1');
insert into vehiculo_has_estacion values(56, 2, '2020-11-01', '08:00', '2020-11-05', '15:00', '1');

insert into vehiculo_has_estacion values(57, 1, '2020-11-06', '08:00', null, null, '0');

delimiter ;;
create procedure `promedio_productividad`(
  in p_linea_montaje int,
  out promedio float,
  out mensaje varchar(100)
)
begin
	DECLARE suma_dias INTEGER DEFAULT 0;
    DECLARE cantidad_registros INTEGER DEFAULT 0;
    
	select sum(TIMESTAMPDIFF(day, fecha_ingreso, fecha_egreso)), count(*) into suma_dias, cantidad_registros from vehiculo_has_estacion ve
    inner join estacion e on ve.estacion_id_estacion=e.id_estacion 
    inner join linea_de_montaje lm on e.linea_de_montaje_id_linea_de_montaje=lm.id_linea_de_montaje
    where lm.id_linea_de_montaje=p_linea_montaje and ve.finalizado='1'
    group by ve.estacion_id_estacion and ve.vehiculo_nro_chasis;
    
    select suma_dias/cantidad_registros into promedio;
    
	update linea_de_montaje lm set promedio_productividad=promedio where lm.id_linea_de_montaje=p_linea_montaje;
    
    select 'Promedio de productividad en dias para la linea de montaje ingresado: ' into mensaje;
    select mensaje, promedio;

end ;;
delimiter ;

call promedio_productividad(1,@promedio,@mensaje);