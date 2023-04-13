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

CREATE OR REPLACE PROCEDURE createPaciente(cui VARCHAR(20),nombre VARCHAR(50),apellidos VARCHAR(60),direccion VARCHAR(100),telefono VARCHAR(10),id_centro_medico VARCHAR(5))
AS $BODY$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,direccion,telefono,id_centro_medico);
	INSERT INTO Paciente(cui) VALUES (cui);
END;
$BODY$
LANGUAGE plpgsql;