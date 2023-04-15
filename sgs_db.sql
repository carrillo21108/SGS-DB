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
	direccion VARCHAR(100) NOT NULL,
	telefono VARCHAR(10) NOT NULL,
	id_centro_medico VARCHAR(5) NOT NULL,
	
	PRIMARY KEY(cui),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico)
);

CREATE TABLE Paciente(
	no_paciente SERIAL,
	cui VARCHAR(20) UNIQUE NOT NULL,
	no_paciente_padre INT,
	no_paciente_madre INT,
	
	PRIMARY KEY(no_paciente),
	CONSTRAINT fk_persona
		FOREIGN KEY (cui) REFERENCES Persona(cui),
	CONSTRAINT fk_padre
		FOREIGN KEY (no_paciente_padre) REFERENCES Paciente(no_paciente),
	CONSTRAINT fk_madre
		FOREIGN KEY (no_paciente_madre) REFERENCES Paciente(no_paciente)
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

CREATE OR REPLACE PROCEDURE createPaciente(cui VARCHAR(20),nombre VARCHAR(50),apellidos VARCHAR(60),direccion VARCHAR(100),telefono VARCHAR(10),id_centro_medico VARCHAR(5))
AS $BODY$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,direccion,telefono,id_centro_medico);
	INSERT INTO Paciente(cui) VALUES (cui);
END;
$BODY$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE createMedico(cui VARCHAR(20),nombre VARCHAR(50),apellidos VARCHAR(60),direccion VARCHAR(100),telefono VARCHAR(10),
										 id_centro_medico VARCHAR(5),no_colegiado VARCHAR(20),id_especialidad INT,usuario VARCHAR (10), clave VARCHAR(10))
AS $BODY$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,direccion,telefono,id_centro_medico);
	INSERT INTO Medico VALUES (no_colegiado,cui,id_especialidad,usuario,clave);
END;
$BODY$
LANGUAGE plpgsql;

CREATE TABLE Medicamento(
	id_medicamento SERIAL,
	descripcion VARCHAR(30) NOT NULL,
	
	PRIMARY KEY(id_medicamento)
);

CREATE TABLE Inventario_Medicamento(
	id_centro_medico VARCHAR(5) NOT NULL,
    id_medicamento INT NOT NULL,
	disponibilidad INT NOT NULL,
    fecha_caducidad DATE NOT NULL,
	
	PRIMARY KEY(id_centro_medico,id_medicamento),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico),
    CONSTRAINT fk_medicamento
		FOREIGN KEY (id_medicamento) REFERENCES Medicamento(id_medicamento)
);