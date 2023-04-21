CREATE DATABASE sgs_db;

CREATE TABLE Centro_Medico(
	id_centro_medico VARCHAR(5) NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	
	PRIMARY KEY(id_centro_medico)
);

CREATE TABLE Persona(
	cui VARCHAR(20) NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	apellidos VARCHAR(60) NOT NULL,
	telefono VARCHAR(10) NOT NULL,
	id_centro_medico VARCHAR(5) NOT NULL,
	
	PRIMARY KEY(cui),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico)
);

CREATE TABLE Estado(
	id_estado SERIAL,
	descripcion VARCHAR(20) NOT NULL,
	
	PRIMARY KEY(id_estado)
);

CREATE TABLE Paciente(
	no_paciente SERIAL,
	cui VARCHAR(20) UNIQUE NOT NULL,
	no_paciente_padre INT,
	no_paciente_madre INT,
	id_estado INT NOT NULL,
	
	PRIMARY KEY(no_paciente),
	CONSTRAINT fk_persona
		FOREIGN KEY (cui) REFERENCES Persona(cui),
	CONSTRAINT fk_padre
		FOREIGN KEY (no_paciente_padre) REFERENCES Paciente(no_paciente),
	CONSTRAINT fk_madre
		FOREIGN KEY (no_paciente_madre) REFERENCES Paciente(no_paciente),
	CONSTRAINT fk_estado_paciente
		FOREIGN KEY (id_estado) REFERENCES Estado(id_estado)
);

CREATE TABLE Especialidad(
	id_especialidad SERIAL,
	nombre VARCHAR(20) NOT NULL,
	
	PRIMARY KEY(id_especialidad)
);

CREATE TABLE Medico(
	no_colegiado VARCHAR(20) NOT NULL,
	cui VARCHAR(20) UNIQUE NOT NULL,
	id_especialidad INT NOT NULL,
	usuario VARCHAR(10) UNIQUE NOT NULL,
	clave VARCHAR(10) NOT NULL,
	
	PRIMARY KEY(no_colegiado),
	CONSTRAINT fk_persona
		FOREIGN KEY (cui) REFERENCES Persona(cui),
	CONSTRAINT fk_especialidad
		FOREIGN KEY (id_especialidad) REFERENCES Especialidad(id_especialidad)
);

CREATE TABLE Medicamento(
	id_medicamento SERIAL,
	descripcion VARCHAR(30) NOT NULL,
	
	PRIMARY KEY(id_medicamento)
);

CREATE TABLE Material(
	id_material SERIAL,
	descripcion VARCHAR(100) NOT NULL,
	
	PRIMARY KEY(id_material)
);

CREATE TABLE Departamento(
	id_departamento SERIAL,
	nombre VARCHAR(100) NOT NULL,
	
	PRIMARY KEY(id_departamento)
);

CREATE TABLE Municipio(
	id_municipio SERIAL,
	nombre VARCHAR(100) NOT NULL,
	id_departamento INT NOT NULL,
	
	PRIMARY KEY(id_municipio),
	CONSTRAINT fk_departamento
		FOREIGN KEY (id_departamento) REFERENCES Departamento(id_departamento)
);

CREATE TABLE Direccion_Centro_Medico(
	id_centro_medico VARCHAR(5) NOT NULL,
	descripcion VARCHAR(100) NOT NULL,
	id_municipio INT NOT NULL,

	PRIMARY KEY(id_centro_medico),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico),
	CONSTRAINT fk_municipio
		FOREIGN KEY (id_municipio) REFERENCES Municipio(id_municipio)
);

CREATE TABLE Direccion_Persona(
	cui VARCHAR(20) NOT NULL,
	descripcion VARCHAR(100) NOT NULL,
	id_municipio INT NOT NULL,

	PRIMARY KEY(cui),
	CONSTRAINT fk_persona
		FOREIGN KEY (cui) REFERENCES Persona(cui),
	CONSTRAINT fk_municipio
		FOREIGN KEY (id_municipio) REFERENCES Municipio(id_municipio)
);

CREATE TABLE Adiccion(
	id_adiccion SERIAL,
	nombre VARCHAR(100) NOT NULL,
	informacion TEXT NOT NULL,
	mortalidad INT DEFAULT 0,

	PRIMARY KEY(id_adiccion)
);

CREATE TABLE Enfermedad(
	id_enfermedad SERIAL,
	nombre VARCHAR(100) NOT NULL,
	informacion TEXT NOT NULL,
	mortalidad INT DEFAULT 0,

	PRIMARY KEY(id_enfermedad)
);

CREATE TABLE Examen(
	id_examen SERIAL,
	nombre VARCHAR(100) NOT NULL,
	informacion TEXT NOT NULL,
	
	PRIMARY KEY(id_examen)
);

CREATE TABLE Cirugia(
	id_cirugia SERIAL,
	nombre VARCHAR(100) NOT NULL,
	descripcion TEXT NOT NULL,
	
	PRIMARY KEY(id_cirugia)
);

CREATE TABLE Incidencia_Historial_Medico(
	id_incidencia SERIAL,
	imc NUMERIC(5,2) NOT NULL,
	altura NUMERIC(5,2) NOT NULL,
	peso NUMERIC(5,2) NOT NULL,
	fecha_consulta DATE NOT NULL,
	hora_consulta TIME NOT NULL,
	no_paciente INT NOT NULL,
	no_colegiado VARCHAR(20) NOT NULL,
	id_centro_medico VARCHAR(5) NOT NULL,
	evolucion TEXT,
	resultado_tratamiento BOOLEAN,

	PRIMARY KEY(id_incidencia),
	CONSTRAINT fk_paciente
		FOREIGN KEY (no_paciente) REFERENCES Paciente(no_paciente),
	CONSTRAINT fk_medico
		FOREIGN KEY (no_colegiado) REFERENCES Medico(no_colegiado),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico)
);

CREATE TABLE Historial_Enfermedad(
	id_incidencia INT NOT NULL,
	id_enfermedad INT NOT NULL,

	PRIMARY KEY(id_incidencia,id_enfermedad),
	CONSTRAINT fk_incidencia
		FOREIGN KEY (id_incidencia) REFERENCES Incidencia_Historial_Medico(id_incidencia),
	CONSTRAINT fk_enfermedad
		FOREIGN KEY (id_enfermedad) REFERENCES Enfermedad(id_enfermedad)
);

CREATE TABLE Historial_Adiccion(
	id_incidencia INT NOT NULL,
	id_adiccion INT NOT NULL,

	PRIMARY KEY(id_incidencia,id_adiccion),
	CONSTRAINT fk_incidencia
		FOREIGN KEY (id_incidencia) REFERENCES Incidencia_Historial_Medico(id_incidencia),
	CONSTRAINT fk_adiccion
		FOREIGN KEY (id_adiccion) REFERENCES Adiccion(id_adiccion)
);

CREATE TABLE Historial_Examen(
	id_incidencia INT NOT NULL,
	id_examen INT NOT NULL,

	PRIMARY KEY(id_incidencia,id_examen),
	CONSTRAINT fk_incidencia
		FOREIGN KEY (id_incidencia) REFERENCES Incidencia_Historial_Medico(id_incidencia),
	CONSTRAINT fk_examen
		FOREIGN KEY (id_examen) REFERENCES Examen(id_examen)
);

CREATE TABLE Historial_Cirugia(
	id_incidencia INT NOT NULL,
	id_cirugia INT NOT NULL,

	PRIMARY KEY(id_incidencia,id_cirugia),
	CONSTRAINT fk_incidencia
		FOREIGN KEY (id_incidencia) REFERENCES Incidencia_Historial_Medico(id_incidencia),
	CONSTRAINT fk_cirugia
		FOREIGN KEY (id_cirugia) REFERENCES Cirugia(id_cirugia)
);

CREATE TABLE Historial_Tratamiento(
	id_incidencia INT NOT NULL,
	id_medicamento INT NOT NULL,
	dosis VARCHAR(50)
);

CREATE TABLE Inventario_Medicamento(
	id_centro_medico VARCHAR(5) NOT NULL,
    id_medicamento INT NOT NULL,
	disponibilidad INT NOT NULL,
    fecha_caducidad DATE NOT NULL,
	capacidad_maxima INT NOT NULL,
	
	PRIMARY KEY(id_centro_medico,id_medicamento),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico),
    CONSTRAINT fk_medicamento
		FOREIGN KEY (id_medicamento) REFERENCES Medicamento(id_medicamento)
);

CREATE TABLE Inventario_Material(
	id_centro_medico VARCHAR(5) NOT NULL,
	id_material INT NOT NULL,
	disponibilidad INT NOT NULL,
	primary key(id_centro_medico,id_material),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico),
	CONSTRAINT fk_material
		FOREIGN KEY (id_material) REFERENCES Material(id_material)
);

CREATE TABLE Bitacora_Historial(
	id_bitacora SERIAL,
	id_incidencia INT NOT NULL,
	fecha_hora TIMESTAMP NOT NULL,
	accion VARCHAR(100) NOT NULL,
	usuario TEXT NOT NULL,

	PRIMARY KEY(id_bitacora),
	CONSTRAINT fk_incidencia
		FOREIGN KEY (id_incidencia) REFERENCES Incidencia_Historial_Medico(id_incidencia)
);

CREATE TABLE Bitacora_Traspaso(
	id_bitacora SERIAL,
	cui VARCHAR(20) NOT NULL,
	fecha_ingreso DATE NOT NULL,
	fecha_retiro DATE,
	id_centro_medico VARCHAR(5) NOT NULL,

	PRIMARY KEY(id_bitacora),
	CONSTRAINT fk_persona
		FOREIGN KEY (cui) REFERENCES Persona(cui)
);

CREATE OR REPLACE PROCEDURE createPaciente(cui VARCHAR(20),nombre VARCHAR(50),apellidos VARCHAR(60),telefono VARCHAR(10),id_centro_medico VARCHAR(5), id_estado INT,direccion VARCHAR(100),id_municipio INT)
AS $BODY$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,telefono,id_centro_medico);
	INSERT INTO Paciente(cui,id_estado) VALUES (cui,id_estado);
	INSERT INTO Direccion_Persona(cui,descripcion,id_municipio) VALUES (cui,direccion,id_municipio);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE createMedico(cui VARCHAR(20),nombre VARCHAR(50),apellidos VARCHAR(60),telefono VARCHAR(10),id_centro_medico VARCHAR(5),no_colegiado VARCHAR(20),id_especialidad INT,usuario VARCHAR (10), clave VARCHAR(10),direccion VARCHAR(100),id_municipio INT)
AS $BODY$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,telefono,id_centro_medico);
	INSERT INTO Medico VALUES (no_colegiado,cui,id_especialidad,usuario,clave);
	INSERT INTO Direccion_Persona(cui,descripcion,id_municipio) VALUES (cui,direccion,id_municipio);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE createCentroMedico(id_centro_medico VARCHAR(5),nombre VARCHAR(50),direccion VARCHAR(100),id_municipio INT)
AS $BODY$
BEGIN
	INSERT INTO Centro_Medico VALUES (id_centro_medico,nombre);
	INSERT INTO Direccion_Centro_Medico(id_centro_medico,descripcion,id_municipio) VALUES (id_centro_medico,direccion,id_municipio);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE createIncidencia(imc NUMERIC(5,2),altura NUMERIC(5,2),peso NUMERIC(5,2),no_paciente INT,no_colegiado VARCHAR(20),id_centro_medico VARCHAR(5))
AS $BODY$
BEGIN
    INSERT INTO Incidencia_Historial_Medico(imc,altura,peso,fecha_consulta,hora_consulta,no_paciente,no_colegiado,id_centro_medico)
	VALUES (imc,altura,peso,(NOW()::DATE),(NOW()::TIME),no_paciente,no_colegiado,id_centro_medico);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION resumen_expediente(no_ INT)
RETURNS TABLE(fecha_consulta TEXT,hora_consulta TEXT,imc NUMERIC(5,2),altura NUMERIC(5,2),
			 peso NUMERIC(5,2),medico_tratante TEXT,especialidad_medico VARCHAR(20),
			  centro_medico_tratante VARCHAR(50),evolucion TEXT,resultado_tratamiento BOOLEAN) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT i.fecha_consulta::TEXT, TO_CHAR(i.hora_consulta, 'HH24:MI:SS'), i.imc, i.altura, i.peso, 
	CONCAT(pe.nombre,' ',pe.apellidos) as medico_tratante, e.nombre as especialidad_medico,
	cm.nombre as centro_medico_tratante, i.evolucion,i.resultado_tratamiento
	FROM Incidencia_Historial_Medico i
		INNER JOIN Centro_Medico cm ON i.id_centro_medico = cm.id_centro_medico
		INNER JOIN Medico me ON i.no_colegiado = me.no_colegiado
		INNER JOIN Persona pe ON me.cui = pe.cui
		INNER JOIN Especialidad e ON e.id_especialidad = me.id_especialidad
	WHERE no_paciente = no_;
END;
$BODY$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION enfermedades_incidencia(id_ INT)
RETURNS TABLE(nombre_enfermedad VARCHAR(100),informacion TEXT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT e.nombre, e.informacion
	FROM Historial_Enfermedad he
		INNER JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
	WHERE id_incidencia = id_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION examenes_incidencia(id_ INT)
RETURNS TABLE(nombre_examen VARCHAR(100),informacion TEXT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT e.nombre, e.informacion
	FROM Historial_Examen he
		INNER JOIN Examen e ON he.id_examen = e.id_examen
	WHERE id_incidencia = id_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION adicciones_incidencia(id_ INT)
RETURNS TABLE(nombre_adiccion VARCHAR(100),informacion TEXT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT ad.nombre, ad.informacion
	FROM Historial_Adiccion ha
		INNER JOIN Adiccion ad ON ha.id_adiccion = ad.id_adiccion
	WHERE id_incidencia = id_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cirugias_incidencia(id_ INT)
RETURNS TABLE(nombre_cirugia VARCHAR(100),descripcion TEXT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT ci.nombre, ci.descripcion
	FROM Historial_Cirugia hc
		INNER JOIN Cirugia ci ON hc.id_cirugia = ci.id_cirugia
	WHERE id_incidencia = id_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tratamiento_incidencia(id_ INT)
RETURNS TABLE(medicamento_recetado VARCHAR(30),dosis VARCHAR(50)) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT me.descripcion, ht.dosis
	FROM Historial_Tratamiento ht
		INNER JOIN Medicamento me ON ht.id_medicamento = me.id_medicamento
	WHERE id_incidencia = id_;
END;
$BODY$
LANGUAGE plpgsql;

SET my.app_user = 'Brian Carrillo';
SELECT CURRENT_SETTING('my.app_user');

CREATE OR REPLACE FUNCTION bitacora_historial_trigger() 
RETURNS TRIGGER AS $$
DECLARE accion VARCHAR;
BEGIN
	IF TG_OP = 'INSERT' THEN
		accion := 'INSERT';
	ELSIF TG_OP = 'UPDATE' THEN
		accion := 'UPDATE';
	ELSIF TG_OP = 'DELETE' THEN
		accion := 'DELETE';
	END IF;
	INSERT INTO Bitacora_Historial(id_incidencia,fecha_hora,accion,usuario) VALUES (NEW.id_incidencia,NOW(),accion,CURRENT_SETTING('my.app_user'));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER bitacora_historial_trigger
AFTER INSERT OR UPDATE OR DELETE ON Incidencia_Historial_Medico
FOR EACH ROW EXECUTE PROCEDURE bitacora_historial_trigger();

CREATE OR REPLACE FUNCTION verificar_registro() RETURNS TRIGGER AS $$
BEGIN
	IF (NEW.id_centro_medico != OLD.id_centro_medico) THEN
		-- Verificar si el registro ya existe
		IF EXISTS(SELECT cui FROM Bitacora_Traspaso WHERE cui = NEW.cui) THEN
			-- Actualizar el registro existente
			UPDATE Bitacora_Traspaso SET fecha_retiro = NOW()::DATE WHERE id_bitacora = (SELECT id_bitacora FROM Bitacora_Traspaso WHERE cui = NEW.cui ORDER BY id_bitacora DESC LIMIT 1);
		END IF;
		
		-- Insertar un nuevo registro
		INSERT INTO Bitacora_Traspaso (cui, fecha_ingreso, fecha_retiro, id_centro_medico) VALUES (NEW.cui, NOW()::DATE, NULL, NEW.id_centro_medico);
	END IF;

    RETURN NEW;
    
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actualizar_traspaso AFTER INSERT OR UPDATE ON Persona
FOR EACH ROW EXECUTE FUNCTION verificar_registro();

CREATE OR REPLACE PROCEDURE updatePaciente(cui_ VARCHAR(20),nombre_ VARCHAR(50),apellidos_ VARCHAR(60),telefono_ VARCHAR(10),
										   id_centro_medico_ VARCHAR(5),id_estado_ INT,no_paciente_padre_ INT,no_paciente_madre_ INT)
AS $BODY$
BEGIN
	UPDATE Persona SET nombre=nombre_,apellidos=apellidos_,telefono=telefono_,id_centro_medico=id_centro_medico_ WHERE cui = cui_;
	UPDATE Paciente SET id_estado=id_estado_,no_paciente_padre=no_paciente_padre_,no_paciente_madre=no_paciente_madre_ WHERE cui=cui_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getPatient(cui_ VARCHAR(20))
RETURNS TABLE(no_paciente INT,cui VARCHAR(20),no_paciente_padre INT,no_paciente_madre INT,id_estado INT,
			 nombre VARCHAR(50),apellidos VARCHAR(60),telefono VARCHAR(10),id_centro_medico VARCHAR(5)) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT pa.no_paciente,pa.cui,pa.no_paciente_padre,pa.no_paciente_madre,pa.id_estado,
	pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Paciente pa
		INNER JOIN Persona pe ON pa.cui = pe.cui
	WHERE pa.cui = cui_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE updateMedico(cui_ VARCHAR(20),nombre_ VARCHAR(50),apellidos_ VARCHAR(60),telefono_ VARCHAR(10),
										   id_centro_medico_ VARCHAR(5),id_especialidad_ INT)
AS $BODY$
BEGIN
	UPDATE Persona SET nombre=nombre_,apellidos=apellidos_,telefono=telefono_,id_centro_medico=id_centro_medico_ WHERE cui = cui_;
	UPDATE Medico SET id_especialidad=id_especialidad_ WHERE cui=cui_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getMedico(cui_ VARCHAR(20))
RETURNS TABLE(no_colegiado VARCHAR(20),cui VARCHAR(20),id_especialidad INT,
			  nombre VARCHAR(50),apellidos VARCHAR(60),telefono VARCHAR(10),id_centro_medico VARCHAR(5))as
$BODY$
BEGIN
	RETURN QUERY
	SELECT me.no_colegiado,me.cui,me.id_especialidad,pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Medico me
		INNER JOIN Persona pe ON me.cui = pe.cui
	WHERE me.cui = cui_;
END;
$BODY$
LANGUAGE plpgsql;

--Top 10 de las enfermedades mas mortales
CREATE OR REPLACE FUNCTION top_10_enfermedades()
RETURNS TABLE(nombre_enfermedad VARCHAR(100),cantidad INT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT e.nombre, COUNT(*)::INT as cantidad FROM Historial_Enfermedad he
		INNER JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
		INNER JOIN Incidencia_Historial_Medico i ON he.id_incidencia = i.id_incidencia
		INNER JOIN Paciente p ON i.no_paciente = p.no_paciente
		INNER JOIN Estado es ON p.id_estado = es.id_estado
	WHERE es.descripcion = 'Fallecido'
	GROUP BY e.nombre
	ORDER BY cantidad DESC
	LIMIT 10;
END;
$BODY$
LANGUAGE plpgsql;

--Top 10 medicos que mas pacientes han atendido
CREATE OR REPLACE FUNCTION top_10_medicos()
RETURNS TABLE(medico_tratante TEXT,Pacientes_atendidos INT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT CONCAT(pe.nombre,' ',pe.apellidos) as medico_tratante, COUNT(DISTINCT i.no_paciente)::INT as Pacientes_atendidos 
	FROM Incidencia_Historial_Medico i
		INNER JOIN Medico me ON i.no_colegiado = me.no_colegiado
		INNER JOIN Persona pe ON me.cui = pe.cui
	GROUP BY medico_tratante
	ORDER BY Pacientes_atendidos DESC
	LIMIT 10;
END;
$BODY$
LANGUAGE plpgsql;

--Top 5 pacientes con mas asistencia a unidades medicas
CREATE OR REPLACE FUNCTION top_5_pacientes(id_ VARCHAR(5))
RETURNS TABLE(no_paciente INT, nombre_paciente TEXT, cantidad INT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT i.no_paciente, CONCAT(pe.nombre,' ',pe.apellidos) as nombre_paciente, COUNT(*)::INT as cantidad
	FROM Incidencia_Historial_Medico i
		INNER JOIN Paciente p ON i.no_paciente = p.no_paciente
		INNER JOIN Persona pe ON pe.cui = p.cui
	WHERE i.id_centro_medico = id_
	GROUP BY i.no_paciente, nombre_paciente
	ORDER BY cantidad DESC
	LIMIT 5;
END;
$BODY$
LANGUAGE plpgsql;

--Nombre de medicamentos
CREATE OR REPLACE FUNCTION nombre_medicamentos()
RETURNS TABLE(id_medicina INT, nombre_medicamento VARCHAR(30)) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT * FROM Medicamento;
END;
$BODY$
LANGUAGE plpgsql;

--Reporte de medicinas y suministros que están por agotarse para una unidad de salud dada
CREATE OR REPLACE FUNCTION medicinas_agotarse(id_ VARCHAR(5))
RETURNS TABLE(nombre_medicamento VARCHAR(100),cantidad INT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT me.descripcion, im.disponibilidad
	FROM Inventario_Medicamento im
		INNER JOIN Medicamento me ON im.id_medicamento = me.id_medicamento
	WHERE id_centro_medico = id_
		AND disponibilidad < im.capacidad_maxima * 0.15;
END;
$BODY$
LANGUAGE plpgsql;

--Reporte de las 3 unidades medicas que más pacientes atienden
CREATE OR REPLACE FUNCTION top_3_unidades()
RETURNS TABLE(id_centro_medico VARCHAR(5),nombre_centro_medico VARCHAR(100),cantidad INT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT i.id_centro_medico, cm.nombre, COUNT(DISTINCT i.no_paciente)::INT as cantidad
	FROM Incidencia_Historial_Medico i
		INNER JOIN Centro_Medico cm ON i.id_centro_medico = cm.id_centro_medico
	GROUP BY i.id_centro_medico, nombre
	ORDER BY cantidad DESC
	LIMIT 3;
END;
$BODY$
LANGUAGE plpgsql;

--Recuperar pacientes que no coincidan con el mismo numero de cui
CREATE OR REPLACE FUNCTION getPosiblesPadres(id_ VARCHAR(20))
RETURNS TABLE(no_paciente INT,cui VARCHAR(20),no_paciente_padre INT,no_paciente_madre INT,id_estado INT,
			 nombre VARCHAR(50),apellidos VARCHAR(60),telefono VARCHAR(10),id_centro_medico VARCHAR(5)) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT pa.no_paciente,pa.cui,pa.no_paciente_padre,pa.no_paciente_madre,pa.id_estado,
	pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Paciente pa
		INNER JOIN Persona pe ON pa.cui = pe.cui
	WHERE pa.cui != id_;
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getPosiblesMedicos()
RETURNS TABLE(no_colegiado VARCHAR(20),cui VARCHAR(20),
			 nombre VARCHAR(50),apellidos VARCHAR(60),telefono VARCHAR(10),id_centro_medico VARCHAR(5)) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT me.no_colegiado,me.cui,
	pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Medico me
		INNER JOIN Persona pe ON me.cui = pe.cui;
END;
$BODY$
LANGUAGE plpgsql;

--Inventario de medicamentos por unidad de salud
CREATE OR REPLACE FUNCTION inventario_medicamentos(id_ VARCHAR(5))
RETURNS TABLE(id_medicamento INT,descripcion VARCHAR(100),disponibilidad INT,capacidad_maxima INT) as
$BODY$
BEGIN
	RETURN QUERY
	SELECT im.id_medicamento, me.descripcion, im.disponibilidad, im.capacidad_maxima
	FROM Inventario_Medicamento im
		INNER JOIN Medicamento me ON im.id_medicamento = me.id_medicamento
	WHERE id_centro_medico = id_;
END;
$BODY$
LANGUAGE plpgsql;
