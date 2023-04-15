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

CREATE TABLE Direccion(
	id_centro_medico VARCHAR(5) NOT NULL,
	descripcion VARCHAR(100) NOT NULL,
	id_municipio INT NOT NULL,

	PRIMARY KEY(id_centro_medico),
	CONSTRAINT fk_centro_medico
		FOREIGN KEY (id_centro_medico) REFERENCES Centro_Medico(id_centro_medico),
	CONSTRAINT fk_municipio
		FOREIGN KEY (id_municipio) REFERENCES Municipio(id_municipio)
);

CREATE TABLE Adiccion(
	id_adiccion SERIAL,
	nombre VARCHAR(100) NOT NULL,
	informacion TEXT NOT NULL,
	mortalidad INT NOT NULL

	PRIMARY KEY(id_adiccion)
);

CREATE TABLE Enfermedad(
	id_enfermedad SERIAL,
	nombre VARCHAR(100) NOT NULL,
	informacion TEXT NOT NULL,
	mortalidad INT NOT NULL

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
	imc FLOAT NOT NULL,
	altura FLOAT NOT NULL,
	peso FLOAT NOT NULL,
	fecha_consulta DATE NOT NULL,
	hora_consulta TIME NOT NULL,
	no_paciente INT NOT NULL,
	no_colegiado VARCHAR(20) NOT NULL,
	id_centro_medico VARCHAR(5) NOT NULL,
	evolucion TEXT NOT NULL,
	resultado_tratamiento BOOLEAN NOT NULL,

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

CREATE OR REPLACE PROCEDURE createPaciente(cui VARCHAR(20),nombre VARCHAR(50),apellidos VARCHAR(60),direccion VARCHAR(100),telefono VARCHAR(10),id_centro_medico VARCHAR(5), id_estado INT)
AS $BODY$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,direccion,telefono,id_centro_medico);
	INSERT INTO Paciente(cui,id_estado) VALUES (cui,id_estado);
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

