--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

-- Started on 2023-04-21 20:50:44 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 295 (class 1255 OID 176627)
-- Name: actualizar_mortalidad(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizar_mortalidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
	id_ INT;
	contador INT;
BEGIN
	--Considerando que el estado de fallecido es 2
	IF (NEW.id_estado = 2) THEN
		--Obtener la enfermedad y la mortalidad
		id_ := (SELECT e.id_enfermedad
				FROM Historial_Enfermedad he
					INNER JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
					INNER JOIN Incidencia_Historial_Medico i ON he.id_incidencia = i.id_incidencia
				WHERE i.id_incidencia = (SELECT * FROM obtenerUltimaIncidencia(NEW.no_paciente)));
		
		contador := (SELECT e.mortalidad
					 FROM Historial_Enfermedad he
						INNER JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
						INNER JOIN Incidencia_Historial_Medico i ON he.id_incidencia = i.id_incidencia
					WHERE i.id_incidencia = (SELECT * FROM obtenerUltimaIncidencia(NEW.no_paciente)));

		--Actualizar la tabla de enfermedad
		UPDATE Enfermedad SET mortalidad = contador+1 WHERE id_enfermedad = id_;
	END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.actualizar_mortalidad() OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 176601)
-- Name: adicciones_incidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adicciones_incidencia(id_ integer) RETURNS TABLE(nombre_adiccion character varying, informacion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT ad.nombre, ad.informacion
	FROM Historial_Adiccion ha
		INNER JOIN Adiccion ad ON ha.id_adiccion = ad.id_adiccion
	WHERE id_incidencia = id_;
END;
$$;


ALTER FUNCTION public.adicciones_incidencia(id_ integer) OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 176625)
-- Name: bitacora_historial(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.bitacora_historial() RETURNS TABLE(id_bit integer, id_inc integer, fecha_h timestamp without time zone, descripcion character varying, userio text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT id_bitacora,id_incidencia,fecha_hora,accion,usuario
	FROM bitacora_historial;
END;
$$;


ALTER FUNCTION public.bitacora_historial() OWNER TO postgres;

--
-- TOC entry 282 (class 1255 OID 176604)
-- Name: bitacora_historial_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.bitacora_historial_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.bitacora_historial_trigger() OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 176626)
-- Name: bitacora_traspaso(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.bitacora_traspaso() RETURNS TABLE(id_bit integer, cuit character varying, fecha_i date, fecha_r date, id_cm character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT id_bitacora,cui,fecha_ingreso,fecha_retiro,id_centro_medico
	FROM bitacora_traspaso;
END;
$$;


ALTER FUNCTION public.bitacora_traspaso() OWNER TO postgres;

--
-- TOC entry 280 (class 1255 OID 176602)
-- Name: cirugias_incidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cirugias_incidencia(id_ integer) RETURNS TABLE(nombre_cirugia character varying, descripcion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT ci.nombre, ci.descripcion
	FROM Historial_Cirugia hc
		INNER JOIN Cirugia ci ON hc.id_cirugia = ci.id_cirugia
	WHERE id_incidencia = id_;
END;
$$;


ALTER FUNCTION public.cirugias_incidencia(id_ integer) OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 176596)
-- Name: createcentromedico(character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.createcentromedico(IN id_centro_medico character varying, IN nombre character varying, IN direccion character varying, IN id_municipio integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO Centro_Medico VALUES (id_centro_medico,nombre);
	INSERT INTO Direccion_Centro_Medico(id_centro_medico,descripcion,id_municipio) VALUES (id_centro_medico,direccion,id_municipio);
END;
$$;


ALTER PROCEDURE public.createcentromedico(IN id_centro_medico character varying, IN nombre character varying, IN direccion character varying, IN id_municipio integer) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 176597)
-- Name: createincidencia(numeric, numeric, numeric, integer, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.createincidencia(IN imc numeric, IN altura numeric, IN peso numeric, IN no_paciente integer, IN no_colegiado character varying, IN id_centro_medico character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Incidencia_Historial_Medico(imc,altura,peso,fecha_consulta,hora_consulta,no_paciente,no_colegiado,id_centro_medico)
	VALUES (imc,altura,peso,(NOW()::DATE),(NOW()::TIME),no_paciente,no_colegiado,id_centro_medico);
END;
$$;


ALTER PROCEDURE public.createincidencia(IN imc numeric, IN altura numeric, IN peso numeric, IN no_paciente integer, IN no_colegiado character varying, IN id_centro_medico character varying) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 176595)
-- Name: createmedico(character varying, character varying, character varying, character varying, character varying, character varying, integer, character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.createmedico(IN cui character varying, IN nombre character varying, IN apellidos character varying, IN telefono character varying, IN id_centro_medico character varying, IN no_colegiado character varying, IN id_especialidad integer, IN usuario character varying, IN clave character varying, IN direccion character varying, IN id_municipio integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,telefono,id_centro_medico);
	INSERT INTO Medico VALUES (no_colegiado,cui,id_especialidad,usuario,clave);
	INSERT INTO Direccion_Persona(cui,descripcion,id_municipio) VALUES (cui,direccion,id_municipio);
END;
$$;


ALTER PROCEDURE public.createmedico(IN cui character varying, IN nombre character varying, IN apellidos character varying, IN telefono character varying, IN id_centro_medico character varying, IN no_colegiado character varying, IN id_especialidad integer, IN usuario character varying, IN clave character varying, IN direccion character varying, IN id_municipio integer) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 176594)
-- Name: createpaciente(character varying, character varying, character varying, character varying, character varying, integer, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.createpaciente(IN cui character varying, IN nombre character varying, IN apellidos character varying, IN telefono character varying, IN id_centro_medico character varying, IN id_estado integer, IN direccion character varying, IN id_municipio integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Persona VALUES(cui,nombre,apellidos,telefono,id_centro_medico);
	INSERT INTO Paciente(cui,id_estado) VALUES (cui,id_estado);
	INSERT INTO Direccion_Persona(cui,descripcion,id_municipio) VALUES (cui,direccion,id_municipio);
END;
$$;


ALTER PROCEDURE public.createpaciente(IN cui character varying, IN nombre character varying, IN apellidos character varying, IN telefono character varying, IN id_centro_medico character varying, IN id_estado integer, IN direccion character varying, IN id_municipio integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 176599)
-- Name: enfermedades_incidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.enfermedades_incidencia(id_ integer) RETURNS TABLE(nombre_enfermedad character varying, informacion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT e.nombre, e.informacion
	FROM Historial_Enfermedad he
		INNER JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
	WHERE id_incidencia = id_;
END;
$$;


ALTER FUNCTION public.enfermedades_incidencia(id_ integer) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 176600)
-- Name: examenes_incidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.examenes_incidencia(id_ integer) RETURNS TABLE(nombre_examen character varying, informacion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT e.nombre, e.informacion
	FROM Historial_Examen he
		INNER JOIN Examen e ON he.id_examen = e.id_examen
	WHERE id_incidencia = id_;
END;
$$;


ALTER FUNCTION public.examenes_incidencia(id_ integer) OWNER TO postgres;

--
-- TOC entry 260 (class 1255 OID 176611)
-- Name: getmedico(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getmedico(cui_ character varying) RETURNS TABLE(no_colegiado character varying, cui character varying, id_especialidad integer, nombre character varying, apellidos character varying, telefono character varying, id_centro_medico character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT me.no_colegiado,me.cui,me.id_especialidad,pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Medico me
		INNER JOIN Persona pe ON me.cui = pe.cui
	WHERE me.cui = cui_;
END;
$$;


ALTER FUNCTION public.getmedico(cui_ character varying) OWNER TO postgres;

--
-- TOC entry 258 (class 1255 OID 176609)
-- Name: getpatient(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getpatient(cui_ character varying) RETURNS TABLE(no_paciente integer, cui character varying, no_paciente_padre integer, no_paciente_madre integer, id_estado integer, nombre character varying, apellidos character varying, telefono character varying, id_centro_medico character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT pa.no_paciente,pa.cui,pa.no_paciente_padre,pa.no_paciente_madre,pa.id_estado,
	pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Paciente pa
		INNER JOIN Persona pe ON pa.cui = pe.cui
	WHERE pa.cui = cui_;
END;
$$;


ALTER FUNCTION public.getpatient(cui_ character varying) OWNER TO postgres;

--
-- TOC entry 290 (class 1255 OID 176622)
-- Name: getposiblesmedicos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getposiblesmedicos() RETURNS TABLE(no_colegiado character varying, cui character varying, nombre character varying, apellidos character varying, telefono character varying, id_centro_medico character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT me.no_colegiado,me.cui,
	pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Medico me
		INNER JOIN Persona pe ON me.cui = pe.cui;
END;
$$;


ALTER FUNCTION public.getposiblesmedicos() OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 176621)
-- Name: getposiblespadres(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getposiblespadres(id_ character varying) RETURNS TABLE(no_paciente integer, cui character varying, no_paciente_padre integer, no_paciente_madre integer, id_estado integer, nombre character varying, apellidos character varying, telefono character varying, id_centro_medico character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT pa.no_paciente,pa.cui,pa.no_paciente_padre,pa.no_paciente_madre,pa.id_estado,
	pe.nombre,pe.apellidos,pe.telefono,pe.id_centro_medico
	FROM Paciente pa
		INNER JOIN Persona pe ON pa.cui = pe.cui
	WHERE pa.cui != id_;
END;
$$;


ALTER FUNCTION public.getposiblespadres(id_ character varying) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 176624)
-- Name: inventario_materiales(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inventario_materiales(id_ character varying) RETURNS TABLE(id_material integer, descripcion character varying, disponibilidad integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT im.id_material, ma.descripcion, im.disponibilidad
	FROM Inventario_Material im
		INNER JOIN Material ma ON im.id_material = ma.id_material
	WHERE id_centro_medico = id_;
END;
$$;


ALTER FUNCTION public.inventario_materiales(id_ character varying) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 176623)
-- Name: inventario_medicamentos(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inventario_medicamentos(id_ character varying) RETURNS TABLE(id_medicamento integer, descripcion character varying, disponibilidad integer, fecha_caducidad text, capacidad_maxima integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT im.id_medicamento, me.descripcion, im.disponibilidad,
	im.fecha_caducidad::TEXT,im.capacidad_maxima
	FROM Inventario_Medicamento im
		INNER JOIN Medicamento me ON im.id_medicamento = me.id_medicamento
	WHERE id_centro_medico = id_;
END;
$$;


ALTER FUNCTION public.inventario_medicamentos(id_ character varying) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 176615)
-- Name: listado_top_5_pacientes(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.listado_top_5_pacientes(id_ character varying) RETURNS TABLE(no_paciente integer, nombre_paciente text, cantidad integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.listado_top_5_pacientes(id_ character varying) OWNER TO postgres;

--
-- TOC entry 287 (class 1255 OID 176619)
-- Name: medicinas_agotarse(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.medicinas_agotarse(id_ character varying) RETURNS TABLE(id_medicamento integer, descripcion character varying, disponibilidad integer, fecha_caducidad text, capacidad_maxima integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT im.id_medicamento,me.descripcion,im.disponibilidad,im.fecha_caducidad::TEXT,im.capacidad_maxima
	FROM Inventario_Medicamento im
		INNER JOIN Medicamento me ON im.id_medicamento = me.id_medicamento
	WHERE im.id_centro_medico = id_
		AND (im.disponibilidad < im.capacidad_maxima * 0.15
		OR (im.fecha_caducidad<=NOW()));
END;
$$;


ALTER FUNCTION public.medicinas_agotarse(id_ character varying) OWNER TO postgres;

--
-- TOC entry 286 (class 1255 OID 176618)
-- Name: nombre_materiales(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nombre_materiales() RETURNS TABLE(id_material integer, nombre_material character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM Material;
END;
$$;


ALTER FUNCTION public.nombre_materiales() OWNER TO postgres;

--
-- TOC entry 285 (class 1255 OID 176617)
-- Name: nombre_medicamentos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nombre_medicamentos() RETURNS TABLE(id_medicina integer, nombre_medicamento character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT * FROM Medicamento;
END;
$$;


ALTER FUNCTION public.nombre_medicamentos() OWNER TO postgres;

--
-- TOC entry 261 (class 1255 OID 176612)
-- Name: obtenerultimaincidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obtenerultimaincidencia(no_ integer) RETURNS TABLE(id_incidencia integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT i.id_incidencia FROM Incidencia_Historial_Medico i WHERE i.no_paciente = no_ ORDER BY i.id_incidencia DESC LIMIT 1;
END;
$$;


ALTER FUNCTION public.obtenerultimaincidencia(no_ integer) OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 176598)
-- Name: resumen_expediente(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.resumen_expediente(no_ integer) RETURNS TABLE(id_incidencia integer, fecha_consulta text, hora_consulta text, imc numeric, altura numeric, peso numeric, medico_tratante text, especialidad_medico character varying, centro_medico_tratante character varying, evolucion text, resultado_tratamiento boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT i.id_incidencia,i.fecha_consulta::TEXT, TO_CHAR(i.hora_consulta, 'HH24:MI:SS'), i.imc, i.altura, i.peso, 
	CONCAT(pe.nombre,' ',pe.apellidos) as medico_tratante, e.nombre as especialidad_medico,
	cm.nombre as centro_medico_tratante, i.evolucion,i.resultado_tratamiento
	FROM Incidencia_Historial_Medico i
		INNER JOIN Centro_Medico cm ON i.id_centro_medico = cm.id_centro_medico
		INNER JOIN Medico me ON i.no_colegiado = me.no_colegiado
		INNER JOIN Persona pe ON me.cui = pe.cui
		INNER JOIN Especialidad e ON e.id_especialidad = me.id_especialidad
	WHERE no_paciente = no_;
END;
$$;


ALTER FUNCTION public.resumen_expediente(no_ integer) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 176613)
-- Name: top_10_enfermedades(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top_10_enfermedades() RETURNS TABLE(nombre_enfermedad character varying, cantidad integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT e.nombre, COUNT(*)::INT as cantidad
	FROM Historial_Enfermedad he
		INNER JOIN Enfermedad e ON he.id_enfermedad = e.id_enfermedad
		INNER JOIN Incidencia_Historial_Medico i ON he.id_incidencia = i.id_incidencia
		INNER JOIN Paciente p ON i.no_paciente = p.no_paciente
		INNER JOIN Estado es ON p.id_estado = es.id_estado
	WHERE es.descripcion ILIKE 'Fallecido' AND i.id_incidencia IN (SELECT obtenerUltimaIncidencia(no_paciente) FROM Paciente)
	GROUP BY e.nombre
	ORDER BY cantidad DESC
	LIMIT 10;
END;
$$;


ALTER FUNCTION public.top_10_enfermedades() OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 176614)
-- Name: top_10_medicos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top_10_medicos() RETURNS TABLE(medico_tratante text, pacientes_atendidos integer)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.top_10_medicos() OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 176620)
-- Name: top_3_unidades(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top_3_unidades() RETURNS TABLE(id_centro_medico character varying, nombre_centro_medico character varying, cantidad integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT i.id_centro_medico, cm.nombre, COUNT(DISTINCT i.no_paciente)::INT as cantidad
	FROM Incidencia_Historial_Medico i
		INNER JOIN Centro_Medico cm ON i.id_centro_medico = cm.id_centro_medico
	GROUP BY i.id_centro_medico, nombre
	ORDER BY cantidad DESC
	LIMIT 3;
END;
$$;


ALTER FUNCTION public.top_3_unidades() OWNER TO postgres;

--
-- TOC entry 284 (class 1255 OID 176616)
-- Name: top_5_pacientes(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top_5_pacientes(id_ character varying) RETURNS TABLE(no_paciente integer, nombre_paciente text, cantidad integer, imc_reciente numeric, peso_reciente numeric, altura_reciente numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT
	q.no_paciente, q.nombre_paciente, q.cantidad,i.imc,i.peso,i.altura
	FROM Incidencia_Historial_Medico i
		INNER JOIN listado_top_5_pacientes(id_) q ON i.no_paciente = q.no_paciente
	WHERE i.id_incidencia IN (SELECT obtenerUltimaIncidencia(pa.no_paciente) FROM Paciente pa)
	ORDER BY cantidad DESC;
END;
$$;


ALTER FUNCTION public.top_5_pacientes(id_ character varying) OWNER TO postgres;

--
-- TOC entry 281 (class 1255 OID 176603)
-- Name: tratamiento_incidencia(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tratamiento_incidencia(id_ integer) RETURNS TABLE(medicamento_recetado character varying, dosis character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT me.descripcion, ht.dosis
	FROM Historial_Tratamiento ht
		INNER JOIN Medicamento me ON ht.id_medicamento = me.id_medicamento
	WHERE id_incidencia = id_;
END;
$$;


ALTER FUNCTION public.tratamiento_incidencia(id_ integer) OWNER TO postgres;

--
-- TOC entry 259 (class 1255 OID 176610)
-- Name: updatemedico(character varying, character varying, character varying, character varying, character varying, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatemedico(IN cui_ character varying, IN nombre_ character varying, IN apellidos_ character varying, IN telefono_ character varying, IN id_centro_medico_ character varying, IN id_especialidad_ integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE Persona SET nombre=nombre_,apellidos=apellidos_,telefono=telefono_,id_centro_medico=id_centro_medico_ WHERE cui = cui_;
	UPDATE Medico SET id_especialidad=id_especialidad_ WHERE cui=cui_;
END;
$$;


ALTER PROCEDURE public.updatemedico(IN cui_ character varying, IN nombre_ character varying, IN apellidos_ character varying, IN telefono_ character varying, IN id_centro_medico_ character varying, IN id_especialidad_ integer) OWNER TO postgres;

--
-- TOC entry 283 (class 1255 OID 176608)
-- Name: updatepaciente(character varying, character varying, character varying, character varying, character varying, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.updatepaciente(IN cui_ character varying, IN nombre_ character varying, IN apellidos_ character varying, IN telefono_ character varying, IN id_centro_medico_ character varying, IN id_estado_ integer, IN no_paciente_padre_ integer, IN no_paciente_madre_ integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE Persona SET nombre=nombre_,apellidos=apellidos_,telefono=telefono_,id_centro_medico=id_centro_medico_ WHERE cui = cui_;
	UPDATE Paciente SET id_estado=id_estado_,no_paciente_padre=no_paciente_padre_,no_paciente_madre=no_paciente_madre_ WHERE cui=cui_;
END;
$$;


ALTER PROCEDURE public.updatepaciente(IN cui_ character varying, IN nombre_ character varying, IN apellidos_ character varying, IN telefono_ character varying, IN id_centro_medico_ character varying, IN id_estado_ integer, IN no_paciente_padre_ integer, IN no_paciente_madre_ integer) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 176606)
-- Name: verificar_registro(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_registro() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (NEW.id_centro_medico != OLD.id_centro_medico OR OLD.id_centro_medico IS NULL) THEN
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
$$;


ALTER FUNCTION public.verificar_registro() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 176414)
-- Name: adiccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adiccion (
    id_adiccion integer NOT NULL,
    nombre character varying(100) NOT NULL,
    informacion text NOT NULL,
    mortalidad integer DEFAULT 0
);


ALTER TABLE public.adiccion OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 176413)
-- Name: adiccion_id_adiccion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adiccion_id_adiccion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adiccion_id_adiccion_seq OWNER TO postgres;

--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 233
-- Name: adiccion_id_adiccion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adiccion_id_adiccion_seq OWNED BY public.adiccion.id_adiccion;


--
-- TOC entry 251 (class 1259 OID 176569)
-- Name: bitacora_historial; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bitacora_historial (
    id_bitacora integer NOT NULL,
    id_incidencia integer NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    accion character varying(100) NOT NULL,
    usuario text NOT NULL
);


ALTER TABLE public.bitacora_historial OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 176568)
-- Name: bitacora_historial_id_bitacora_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bitacora_historial_id_bitacora_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bitacora_historial_id_bitacora_seq OWNER TO postgres;

--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 250
-- Name: bitacora_historial_id_bitacora_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bitacora_historial_id_bitacora_seq OWNED BY public.bitacora_historial.id_bitacora;


--
-- TOC entry 253 (class 1259 OID 176583)
-- Name: bitacora_traspaso; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bitacora_traspaso (
    id_bitacora integer NOT NULL,
    cui character varying(20) NOT NULL,
    fecha_ingreso date NOT NULL,
    fecha_retiro date,
    id_centro_medico character varying(5) NOT NULL
);


ALTER TABLE public.bitacora_traspaso OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 176582)
-- Name: bitacora_traspaso_id_bitacora_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bitacora_traspaso_id_bitacora_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bitacora_traspaso_id_bitacora_seq OWNER TO postgres;

--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 252
-- Name: bitacora_traspaso_id_bitacora_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bitacora_traspaso_id_bitacora_seq OWNED BY public.bitacora_traspaso.id_bitacora;


--
-- TOC entry 214 (class 1259 OID 176273)
-- Name: centro_medico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.centro_medico (
    id_centro_medico character varying(5) NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.centro_medico OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 176443)
-- Name: cirugia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cirugia (
    id_cirugia integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text NOT NULL
);


ALTER TABLE public.cirugia OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 176442)
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cirugia_id_cirugia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cirugia_id_cirugia_seq OWNER TO postgres;

--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 239
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cirugia_id_cirugia_seq OWNED BY public.cirugia.id_cirugia;


--
-- TOC entry 228 (class 1259 OID 176365)
-- Name: departamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departamento (
    id_departamento integer NOT NULL,
    nombre character varying(100) NOT NULL
);


ALTER TABLE public.departamento OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 176364)
-- Name: departamento_id_departamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.departamento_id_departamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departamento_id_departamento_seq OWNER TO postgres;

--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 227
-- Name: departamento_id_departamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.departamento_id_departamento_seq OWNED BY public.departamento.id_departamento;


--
-- TOC entry 231 (class 1259 OID 176383)
-- Name: direccion_centro_medico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direccion_centro_medico (
    id_centro_medico character varying(5) NOT NULL,
    descripcion character varying(100) NOT NULL,
    id_municipio integer NOT NULL
);


ALTER TABLE public.direccion_centro_medico OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 176398)
-- Name: direccion_persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.direccion_persona (
    cui character varying(20) NOT NULL,
    descripcion character varying(100) NOT NULL,
    id_municipio integer NOT NULL
);


ALTER TABLE public.direccion_persona OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 176424)
-- Name: enfermedad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enfermedad (
    id_enfermedad integer NOT NULL,
    nombre character varying(100) NOT NULL,
    informacion text NOT NULL,
    mortalidad integer DEFAULT 0
);


ALTER TABLE public.enfermedad OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 176423)
-- Name: enfermedad_id_enfermedad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enfermedad_id_enfermedad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.enfermedad_id_enfermedad_seq OWNER TO postgres;

--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 235
-- Name: enfermedad_id_enfermedad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enfermedad_id_enfermedad_seq OWNED BY public.enfermedad.id_enfermedad;


--
-- TOC entry 221 (class 1259 OID 176325)
-- Name: especialidad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especialidad (
    id_especialidad integer NOT NULL,
    nombre character varying(20) NOT NULL
);


ALTER TABLE public.especialidad OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 176324)
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.especialidad_id_especialidad_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.especialidad_id_especialidad_seq OWNER TO postgres;

--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 220
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.especialidad_id_especialidad_seq OWNED BY public.especialidad.id_especialidad;


--
-- TOC entry 217 (class 1259 OID 176289)
-- Name: estado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estado (
    id_estado integer NOT NULL,
    descripcion character varying(20) NOT NULL
);


ALTER TABLE public.estado OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 176288)
-- Name: estado_id_estado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estado_id_estado_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.estado_id_estado_seq OWNER TO postgres;

--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 216
-- Name: estado_id_estado_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estado_id_estado_seq OWNED BY public.estado.id_estado;


--
-- TOC entry 238 (class 1259 OID 176434)
-- Name: examen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.examen (
    id_examen integer NOT NULL,
    nombre character varying(100) NOT NULL,
    informacion text NOT NULL
);


ALTER TABLE public.examen OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 176433)
-- Name: examen_id_examen_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.examen_id_examen_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.examen_id_examen_seq OWNER TO postgres;

--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 237
-- Name: examen_id_examen_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.examen_id_examen_seq OWNED BY public.examen.id_examen;


--
-- TOC entry 244 (class 1259 OID 176490)
-- Name: historial_adiccion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_adiccion (
    id_incidencia integer NOT NULL,
    id_adiccion integer NOT NULL
);


ALTER TABLE public.historial_adiccion OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 176520)
-- Name: historial_cirugia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_cirugia (
    id_incidencia integer NOT NULL,
    id_cirugia integer NOT NULL
);


ALTER TABLE public.historial_cirugia OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 176475)
-- Name: historial_enfermedad; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_enfermedad (
    id_incidencia integer NOT NULL,
    id_enfermedad integer NOT NULL
);


ALTER TABLE public.historial_enfermedad OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 176505)
-- Name: historial_examen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_examen (
    id_incidencia integer NOT NULL,
    id_examen integer NOT NULL
);


ALTER TABLE public.historial_examen OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 176535)
-- Name: historial_tratamiento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historial_tratamiento (
    id_incidencia integer NOT NULL,
    id_medicamento integer NOT NULL,
    dosis character varying(50)
);


ALTER TABLE public.historial_tratamiento OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 176452)
-- Name: incidencia_historial_medico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.incidencia_historial_medico (
    id_incidencia integer NOT NULL,
    imc numeric(5,2) NOT NULL,
    altura numeric(5,2) NOT NULL,
    peso numeric(5,2) NOT NULL,
    fecha_consulta date NOT NULL,
    hora_consulta time without time zone NOT NULL,
    no_paciente integer NOT NULL,
    no_colegiado character varying(20) NOT NULL,
    id_centro_medico character varying(5) NOT NULL,
    evolucion text,
    resultado_tratamiento boolean
);


ALTER TABLE public.incidencia_historial_medico OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 176451)
-- Name: incidencia_historial_medico_id_incidencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.incidencia_historial_medico_id_incidencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.incidencia_historial_medico_id_incidencia_seq OWNER TO postgres;

--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 241
-- Name: incidencia_historial_medico_id_incidencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.incidencia_historial_medico_id_incidencia_seq OWNED BY public.incidencia_historial_medico.id_incidencia;


--
-- TOC entry 249 (class 1259 OID 176553)
-- Name: inventario_material; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventario_material (
    id_centro_medico character varying(5) NOT NULL,
    id_material integer NOT NULL,
    disponibilidad integer NOT NULL
);


ALTER TABLE public.inventario_material OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 176538)
-- Name: inventario_medicamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventario_medicamento (
    id_centro_medico character varying(5) NOT NULL,
    id_medicamento integer NOT NULL,
    disponibilidad integer NOT NULL,
    fecha_caducidad date NOT NULL,
    capacidad_maxima integer NOT NULL
);


ALTER TABLE public.inventario_medicamento OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 176358)
-- Name: material; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.material (
    id_material integer NOT NULL,
    descripcion character varying(100) NOT NULL
);


ALTER TABLE public.material OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 176357)
-- Name: material_id_material_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.material_id_material_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.material_id_material_seq OWNER TO postgres;

--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 225
-- Name: material_id_material_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.material_id_material_seq OWNED BY public.material.id_material;


--
-- TOC entry 224 (class 1259 OID 176351)
-- Name: medicamento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicamento (
    id_medicamento integer NOT NULL,
    descripcion character varying(30) NOT NULL
);


ALTER TABLE public.medicamento OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 176350)
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.medicamento_id_medicamento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.medicamento_id_medicamento_seq OWNER TO postgres;

--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 223
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.medicamento_id_medicamento_seq OWNED BY public.medicamento.id_medicamento;


--
-- TOC entry 222 (class 1259 OID 176331)
-- Name: medico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medico (
    no_colegiado character varying(20) NOT NULL,
    cui character varying(20) NOT NULL,
    id_especialidad integer NOT NULL,
    usuario character varying(10) NOT NULL,
    clave character varying(10) NOT NULL
);


ALTER TABLE public.medico OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 176372)
-- Name: municipio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.municipio (
    id_municipio integer NOT NULL,
    nombre character varying(100) NOT NULL,
    id_departamento integer NOT NULL
);


ALTER TABLE public.municipio OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 176371)
-- Name: municipio_id_municipio_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.municipio_id_municipio_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.municipio_id_municipio_seq OWNER TO postgres;

--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 229
-- Name: municipio_id_municipio_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.municipio_id_municipio_seq OWNED BY public.municipio.id_municipio;


--
-- TOC entry 219 (class 1259 OID 176296)
-- Name: paciente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paciente (
    no_paciente integer NOT NULL,
    cui character varying(20) NOT NULL,
    no_paciente_padre integer,
    no_paciente_madre integer,
    id_estado integer NOT NULL
);


ALTER TABLE public.paciente OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 176295)
-- Name: paciente_no_paciente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paciente_no_paciente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.paciente_no_paciente_seq OWNER TO postgres;

--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 218
-- Name: paciente_no_paciente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paciente_no_paciente_seq OWNED BY public.paciente.no_paciente;


--
-- TOC entry 215 (class 1259 OID 176278)
-- Name: persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona (
    cui character varying(20) NOT NULL,
    nombre character varying(50) NOT NULL,
    apellidos character varying(60) NOT NULL,
    telefono character varying(10) NOT NULL,
    id_centro_medico character varying(5) NOT NULL
);


ALTER TABLE public.persona OWNER TO postgres;

--
-- TOC entry 3591 (class 2604 OID 176417)
-- Name: adiccion id_adiccion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adiccion ALTER COLUMN id_adiccion SET DEFAULT nextval('public.adiccion_id_adiccion_seq'::regclass);


--
-- TOC entry 3598 (class 2604 OID 176572)
-- Name: bitacora_historial id_bitacora; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora_historial ALTER COLUMN id_bitacora SET DEFAULT nextval('public.bitacora_historial_id_bitacora_seq'::regclass);


--
-- TOC entry 3599 (class 2604 OID 176586)
-- Name: bitacora_traspaso id_bitacora; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora_traspaso ALTER COLUMN id_bitacora SET DEFAULT nextval('public.bitacora_traspaso_id_bitacora_seq'::regclass);


--
-- TOC entry 3596 (class 2604 OID 176446)
-- Name: cirugia id_cirugia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cirugia ALTER COLUMN id_cirugia SET DEFAULT nextval('public.cirugia_id_cirugia_seq'::regclass);


--
-- TOC entry 3589 (class 2604 OID 176368)
-- Name: departamento id_departamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamento ALTER COLUMN id_departamento SET DEFAULT nextval('public.departamento_id_departamento_seq'::regclass);


--
-- TOC entry 3593 (class 2604 OID 176427)
-- Name: enfermedad id_enfermedad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enfermedad ALTER COLUMN id_enfermedad SET DEFAULT nextval('public.enfermedad_id_enfermedad_seq'::regclass);


--
-- TOC entry 3586 (class 2604 OID 176328)
-- Name: especialidad id_especialidad; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especialidad ALTER COLUMN id_especialidad SET DEFAULT nextval('public.especialidad_id_especialidad_seq'::regclass);


--
-- TOC entry 3584 (class 2604 OID 176292)
-- Name: estado id_estado; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado ALTER COLUMN id_estado SET DEFAULT nextval('public.estado_id_estado_seq'::regclass);


--
-- TOC entry 3595 (class 2604 OID 176437)
-- Name: examen id_examen; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examen ALTER COLUMN id_examen SET DEFAULT nextval('public.examen_id_examen_seq'::regclass);


--
-- TOC entry 3597 (class 2604 OID 176455)
-- Name: incidencia_historial_medico id_incidencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia_historial_medico ALTER COLUMN id_incidencia SET DEFAULT nextval('public.incidencia_historial_medico_id_incidencia_seq'::regclass);


--
-- TOC entry 3588 (class 2604 OID 176361)
-- Name: material id_material; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material ALTER COLUMN id_material SET DEFAULT nextval('public.material_id_material_seq'::regclass);


--
-- TOC entry 3587 (class 2604 OID 176354)
-- Name: medicamento id_medicamento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicamento ALTER COLUMN id_medicamento SET DEFAULT nextval('public.medicamento_id_medicamento_seq'::regclass);


--
-- TOC entry 3590 (class 2604 OID 176375)
-- Name: municipio id_municipio; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipio ALTER COLUMN id_municipio SET DEFAULT nextval('public.municipio_id_municipio_seq'::regclass);


--
-- TOC entry 3585 (class 2604 OID 176299)
-- Name: paciente no_paciente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente ALTER COLUMN no_paciente SET DEFAULT nextval('public.paciente_no_paciente_seq'::regclass);


--
-- TOC entry 3851 (class 0 OID 176414)
-- Dependencies: 234
-- Data for Name: adiccion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adiccion (id_adiccion, nombre, informacion, mortalidad) FROM stdin;
1	Tabaquismo	Adicción al tabaco y a sus componentes	0
2	Alcoholismo	Adicción al consumo de bebidas alcohólicas	0
3	Drogadicción	Adicción al consumo de drogas	0
4	Ludopatía	Adicción al juego de azar	0
5	Adicción al móvil	Adicción al uso excesivo del teléfono móvil	0
6	Adicción a las redes sociales	Adicción al uso excesivo de las redes sociales	0
7	Adicción al trabajo	Adicción al trabajo excesivo y compulsivo	0
8	Adicción al sexo	Adicción al sexo y a las conductas sexuales compulsivas	0
9	Adicción a las compras	Adicción a las compras compulsivas	0
10	Adicción a la comida	Adicción al consumo excesivo de alimentos	0
\.


--
-- TOC entry 3868 (class 0 OID 176569)
-- Dependencies: 251
-- Data for Name: bitacora_historial; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bitacora_historial (id_bitacora, id_incidencia, fecha_hora, accion, usuario) FROM stdin;
1	1	2023-04-21 17:47:12.174896	INSERT	jm
2	2	2023-04-21 17:51:59.72267	INSERT	jm
3	3	2023-04-21 17:55:35.921304	INSERT	jm
4	4	2023-04-21 18:08:46.800058	INSERT	jm
5	5	2023-04-21 18:23:43.643417	INSERT	jm
6	6	2023-04-21 18:29:59.716785	INSERT	jm
7	7	2023-04-21 19:46:20.326838	INSERT	jm
8	8	2023-04-21 19:48:59.12752	INSERT	jm
9	9	2023-04-21 20:03:29.465385	INSERT	jm
10	10	2023-04-21 20:04:37.449478	INSERT	jm
11	11	2023-04-21 20:05:46.165579	INSERT	jm
12	12	2023-04-21 20:07:38.115498	INSERT	jm
13	13	2023-04-21 20:16:01.167981	INSERT	jm
14	14	2023-04-21 20:19:19.815364	INSERT	jm
15	15	2023-04-21 20:24:38.931652	INSERT	jm
\.


--
-- TOC entry 3870 (class 0 OID 176583)
-- Dependencies: 253
-- Data for Name: bitacora_traspaso; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bitacora_traspaso (id_bitacora, cui, fecha_ingreso, fecha_retiro, id_centro_medico) FROM stdin;
2	243527381	2023-04-21	\N	CM005
3	89988336	2023-04-21	\N	CM001
5	6573829101	2023-04-21	\N	CM001
6	1234567890101	2023-04-21	\N	CM001
7	9876543210202	2023-04-21	\N	CM004
8	4567890120303	2023-04-21	\N	CM003
9	6543210980404	2023-04-21	\N	CM005
10	5678901230505	2023-04-21	\N	CM004
1	123456789	2023-04-21	2023-04-21	CM003
11	123456789	2023-04-21	\N	CM005
4	1234598765	2023-04-21	2023-04-21	CM001
12	1234598765	2023-04-21	\N	CM002
13	 0987654320606	2023-04-21	\N	CM005
\.


--
-- TOC entry 3831 (class 0 OID 176273)
-- Dependencies: 214
-- Data for Name: centro_medico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.centro_medico (id_centro_medico, nombre) FROM stdin;
CM001	Hospital San Juan de Dios
CM002	Centro Médico Nacional
CM003	Clínica Santa María
CM004	Hospital Universitario
CM005	Centro Médico ABC
CM006	Hospital General de México
CM007	Hospital Infantil de México
CM008	Centro Médico Siglo XXI
CM009	Clínica Las Condes
CM010	Hospital Clínico de la Universidad de Chile
\.


--
-- TOC entry 3857 (class 0 OID 176443)
-- Dependencies: 240
-- Data for Name: cirugia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cirugia (id_cirugia, nombre, descripcion) FROM stdin;
1	Cirugía de corazón abierto	Se realiza una incisión en el pecho para acceder al corazón y reparar problemas cardíacos
2	Cirugía de cataratas	Se reemplaza el cristalino del ojo con una lente artificial para mejorar la visión
3	Cirugía plástica	Se realizan procedimientos para mejorar la apariencia física
4	Cirugía de columna vertebral	Se corrigen problemas de la columna vertebral, como hernias de disco o escoliosis
5	Cirugía de reasignación de género	Se realiza una serie de procedimientos quirúrgicos para modificar los órganos sexuales y características físicas a la identidad de género deseada
6	Cirugía bariátrica	Se realiza una reducción de tamaño del estómago o una derivación intestinal para ayudar en la pérdida de peso
7	Cirugía de trasplante de órganos	Se reemplaza un órgano dañado por uno sano de un donante
8	Cirugía de apéndice	Se extirpa el apéndice en caso de inflamación o infección
9	Cirugía de hernia	Se repara una hernia que ocurre cuando un órgano o tejido empuja a través de un agujero en la pared abdominal
10	Cirugía de tiroides	Se extirpa la glándula tiroides para tratar el cáncer de tiroides o problemas de hipertiroidismo
11	Cirugía de vesícula biliar	Se extirpa la vesícula biliar en caso de inflamación o cálculos biliares
12	Cirugía de oído	Se corrigen problemas de audición o infecciones en el oído
13	Cirugía de próstata	Se extirpa la próstata para tratar el cáncer de próstata o problemas de próstata
14	Cirugía de reemplazo de rodilla	Se reemplaza una rodilla dañada por una prótesis
15	Cirugía de labio leporino	Se repara una abertura en el labio superior y/o en el paladar
16	Cirugía de mano	Se corrigen problemas de la mano, como fracturas o síndrome del túnel carpiano
17	Cirugía de hemorroides	Se extirpan las hemorroides inflamadas o agrandadas
18	Cirugía de glaucoma	Se realiza un procedimiento para reducir la presión en el ojo en caso de glaucoma
19	Cirugía de mastectomía	Se extirpa una o ambas mamas en caso de cáncer de mama
\.


--
-- TOC entry 3845 (class 0 OID 176365)
-- Dependencies: 228
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departamento (id_departamento, nombre) FROM stdin;
1	Alta Verapaz
2	Baja Verapaz
3	Chimaltenango
4	Chiquimula
5	El Progreso
6	Escuintla
7	Guatemala
8	Huehuetenango
9	Izabal
10	Jalapa
11	Jutiapa
12	Petén
13	Quetzaltenango
14	Quiché
15	Retalhuleu
16	Sacatepéquez
17	San Marcos
18	Santa Rosa
19	Sololá
20	Suchitepéquez
21	Totonicapán
22	Zacapa
\.


--
-- TOC entry 3848 (class 0 OID 176383)
-- Dependencies: 231
-- Data for Name: direccion_centro_medico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.direccion_centro_medico (id_centro_medico, descripcion, id_municipio) FROM stdin;
\.


--
-- TOC entry 3849 (class 0 OID 176398)
-- Dependencies: 232
-- Data for Name: direccion_persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.direccion_persona (cui, descripcion, id_municipio) FROM stdin;
123	15 Av. C	1
123456789	18 av 15-40 zona 15	7
987654321	18 av 15-40 zona 15	7
564738291	18 av 15-40 zona 15	7
4534167222	Km 35.6 Carretera a Antigua, Aldea Zorzoya.	16
243527381	13 av 11-20 zona 14	7
89988336	25 av 12-25 zona 11	7
1234598765	21 av 02-29 zona 13	7
6573829101	22 av 23-21 zona 13	7
1234567890101	Calle 10, Zona 1,	7
9876543210202	Avenida Central, Zona 2	13
4567890120303	Calle del Sol, Zona 3, 	6
6543210980404	Avenida Reforma, Zona 4	7
5678901230505	Calle Principal, Zona 5	7
 0987654320606	25 av 12-25 zona 11	7
\.


--
-- TOC entry 3853 (class 0 OID 176424)
-- Dependencies: 236
-- Data for Name: enfermedad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enfermedad (id_enfermedad, nombre, informacion, mortalidad) FROM stdin;
1	Gripe	Infección viral que afecta el tracto respiratorio superior	0
3	Enfermedad de Alzheimer	Enfermedad neurodegenerativa progresiva que afecta la memoria y la función cognitiva	0
6	Cáncer de mama	Tumor maligno que se desarrolla en el tejido mamario	0
8	VIH/SIDA	Infección viral que ataca el sistema inmunológico y puede llevar al SIDA	0
9	Enfermedad de Crohn	Trastorno inflamatorio crónico del tracto gastrointestinal que causa dolor abdominal y diarrea	0
2	Diabetes tipo 2	Enfermedad metabólica crónica que afecta la forma en que el cuerpo procesa el azúcar	1
5	Asma	Trastorno inflamatorio crónico de las vías respiratorias que dificulta la respiración	1
7	Artritis reumatoide	Enfermedad autoinmunitaria crónica que afecta las articulaciones y otros tejidos del cuerpo	1
10	Esclerosis múltiple	Enfermedad autoinmunitaria crónica que afecta el sistema nervioso central	3
4	Hipertensión arterial	Presión arterial elevada que puede provocar problemas de salud graves	2
\.


--
-- TOC entry 3838 (class 0 OID 176325)
-- Dependencies: 221
-- Data for Name: especialidad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.especialidad (id_especialidad, nombre) FROM stdin;
1	Cardiología
2	Oftalmología
3	Dermatología
4	Ginecología
5	Pediatría
6	Neurología
7	Oncología
8	Psiquiatría
9	Cirugía plástica
10	Ortopedia
11	Urología
12	Endocrinología
13	Medicina interna
14	Infectología
15	Hematología
\.


--
-- TOC entry 3834 (class 0 OID 176289)
-- Dependencies: 217
-- Data for Name: estado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estado (id_estado, descripcion) FROM stdin;
1	Saludable
2	Fallecido
3	En recuperacion
\.


--
-- TOC entry 3855 (class 0 OID 176434)
-- Dependencies: 238
-- Data for Name: examen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.examen (id_examen, nombre, informacion) FROM stdin;
1	Hemograma	Examen de sangre que mide los componentes sanguíneos
2	Biopsia	Examen que consiste en la extracción de un tejido o células para su posterior análisis
3	Colonoscopia	Examen para detectar anomalías en el colon
4	Mamografía	Examen para detectar cáncer de mama
5	Tomografía computarizada	Examen de imagen para obtener una imagen detallada del interior del cuerpo
6	Resonancia magnética	Examen de imagen que utiliza campos magnéticos para obtener una imagen detallada del cuerpo
7	Electrocardiograma	Examen para medir la actividad eléctrica del corazón
8	Espirometría	Examen para evaluar la función pulmonar
9	Ecocardiograma	Examen para evaluar la estructura y función del corazón
10	Endoscopia	Examen para observar el interior de un órgano o cavidad corporal
\.


--
-- TOC entry 3861 (class 0 OID 176490)
-- Dependencies: 244
-- Data for Name: historial_adiccion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_adiccion (id_incidencia, id_adiccion) FROM stdin;
1	2
6	8
9	8
11	8
13	2
\.


--
-- TOC entry 3863 (class 0 OID 176520)
-- Dependencies: 246
-- Data for Name: historial_cirugia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_cirugia (id_incidencia, id_cirugia) FROM stdin;
1	17
6	1
\.


--
-- TOC entry 3860 (class 0 OID 176475)
-- Dependencies: 243
-- Data for Name: historial_enfermedad; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_enfermedad (id_incidencia, id_enfermedad) FROM stdin;
1	4
6	4
8	2
9	5
11	7
13	10
14	10
2	3
\.


--
-- TOC entry 3862 (class 0 OID 176505)
-- Dependencies: 245
-- Data for Name: historial_examen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_examen (id_incidencia, id_examen) FROM stdin;
1	10
6	9
\.


--
-- TOC entry 3864 (class 0 OID 176535)
-- Dependencies: 247
-- Data for Name: historial_tratamiento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historial_tratamiento (id_incidencia, id_medicamento, dosis) FROM stdin;
1	17	1 tab cada 4 horas
6	13	1 Tab 25 mc al día 
2	7	1 tableta cada 8 horas
\.


--
-- TOC entry 3859 (class 0 OID 176452)
-- Dependencies: 242
-- Data for Name: incidencia_historial_medico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.incidencia_historial_medico (id_incidencia, imc, altura, peso, fecha_consulta, hora_consulta, no_paciente, no_colegiado, id_centro_medico, evolucion, resultado_tratamiento) FROM stdin;
1	100.00	178.00	190.00	2023-04-21	17:47:12.174896	1	Y200	CM001	\N	\N
2	100.00	178.00	190.00	2023-04-21	17:51:59.72267	1	Y200	CM003	\N	\N
3	100.00	178.00	190.00	2023-04-21	17:55:35.921304	1	Y175	CM003	\N	\N
4	100.00	178.00	190.00	2023-04-21	18:08:46.800058	1	Y175	CM001	\N	\N
5	100.00	167.00	190.00	2023-04-21	18:23:43.643417	4	Y175	CM005	\N	\N
6	100.00	156.00	135.00	2023-04-21	18:29:59.716785	6	Y200	CM001	\N	\N
7	90.00	157.00	135.00	2023-04-21	19:46:20.326838	2	Y222	CM005	\N	\N
8	78.00	167.00	180.00	2023-04-21	19:48:59.12752	8	Y224	CM001	\N	\N
9	100.00	178.00	135.00	2023-04-21	20:03:29.465385	10	Y175	CM001	\N	\N
10	100.00	167.00	135.00	2023-04-21	20:04:37.449478	8	Y222	CM001	\N	\N
11	100.00	178.00	135.00	2023-04-21	20:05:46.165579	7	Y224	CM001	\N	\N
12	90.00	156.00	135.00	2023-04-21	20:07:38.115498	5	Y224	CM002	\N	\N
13	67.00	189.00	180.00	2023-04-21	20:16:01.167981	4	Y224	CM004	\N	\N
14	98.00	167.00	187.00	2023-04-21	20:19:19.815364	1	Y222	CM004	\N	\N
15	90.00	167.00	135.00	2023-04-21	20:24:38.931652	10	Y224	CM002	\N	\N
\.


--
-- TOC entry 3866 (class 0 OID 176553)
-- Dependencies: 249
-- Data for Name: inventario_material; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario_material (id_centro_medico, id_material, disponibilidad) FROM stdin;
CM001	1	100
CM001	5	100
CM001	6	50
CM001	3	200
CM001	7	250
\.


--
-- TOC entry 3865 (class 0 OID 176538)
-- Dependencies: 248
-- Data for Name: inventario_medicamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario_medicamento (id_centro_medico, id_medicamento, disponibilidad, fecha_caducidad, capacidad_maxima) FROM stdin;
CM001	13	100	2022-12-31	200
CM001	1	50	2024-01-21	200
CM001	5	10	2024-09-01	200
CM001	11	100	2024-01-31	100
CM002	3	1000	2022-12-31	10000
\.


--
-- TOC entry 3843 (class 0 OID 176358)
-- Dependencies: 226
-- Data for Name: material; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.material (id_material, descripcion) FROM stdin;
1	Guantes de látex
2	Gasas estériles
3	Jeringas de 10 ml
4	Agua oxigenada
5	Alcohol etílico
6	Vendas elásticas
7	Apósitos adhesivos
8	Mascarillas quirúrgicas
9	Batas quirúrgicas
10	Solución salina
11	Suero fisiológico
\.


--
-- TOC entry 3841 (class 0 OID 176351)
-- Dependencies: 224
-- Data for Name: medicamento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medicamento (id_medicamento, descripcion) FROM stdin;
1	Enalapril
2	Hidroclorotiazida
3	Furosemida
4	Eritropoyetina
5	Sevelamer
6	Calcitriol
7	Cinacalcet
8	Eplerenona
9	Espironolactona
10	Darbepoetina alfa
11	Metformina
12	Atorvastatina
13	Levothyroxine
14	Losartan
15	Simvastatina
16	Azitromicina
17	Omeprazol
18	Lisinopril
19	Clopidogrel
20	Ranitidina
\.


--
-- TOC entry 3839 (class 0 OID 176331)
-- Dependencies: 222
-- Data for Name: medico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.medico (no_colegiado, cui, id_especialidad, usuario, clave) FROM stdin;
Y200	123	1	jm	admin
Y175	4534167222	11	mc	cristales
Y222	6543210980404	10	GG	garciag
Y224	5678901230505	9	MH	asdfasdf
Y777	 0987654320606	9	hh	admin
\.


--
-- TOC entry 3847 (class 0 OID 176372)
-- Dependencies: 230
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.municipio (id_municipio, nombre, id_departamento) FROM stdin;
1	Cobán	1
2	Salamá	2
3	Chimaltenango	3
4	Chiquimula	4
5	El Progreso	5
6	Escuintla	6
7	Guatemala	7
8	Huehuetenango	8
9	Izabal	9
10	Jalapa	10
11	Jutiapa	11
12	Flores	12
13	Quetzaltenango	13
14	Santa Cruz del Quiché	14
15	Retalhuleu	15
16	Antigua Guatemala	16
17	San Marcos	17
18	Cuilapa	18
19	Sololá	19
20	Mazatenango	20
\.


--
-- TOC entry 3836 (class 0 OID 176296)
-- Dependencies: 219
-- Data for Name: paciente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.paciente (no_paciente, cui, no_paciente_padre, no_paciente_madre, id_estado) FROM stdin;
2	987654321	\N	\N	1
3	564738291	\N	\N	1
9	9876543210202	3	2	2
10	4567890120303	6	3	2
8	1234567890101	5	2	2
7	6573829101	9	10	2
5	89988336	6	3	2
4	243527381	9	6	2
1	123456789	3	2	2
6	1234598765	5	7	2
\.


--
-- TOC entry 3832 (class 0 OID 176278)
-- Dependencies: 215
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persona (cui, nombre, apellidos, telefono, id_centro_medico) FROM stdin;
123	Josue	Morales	7780	CM001
987654321	Maria	Carrillo	55678654	CM001
564738291	Brian	Lopez	66789900	CM001
4534167222	Mario 	Cristales	77856644	CM003
6543210980404	Gabriel	García	55555558	CM005
5678901230505	Mariana	Hernández	 55555559	CM004
9876543210202	Carlos	Rodriguez	55555556	CM004
4567890120303	Laura	Perez	55555557	CM003
1234567890101	Ana	González	55555555	CM001
6573829101	Sara	Echeverría	56783452	CM001
89988336	Fabian	Tello	33445566	CM001
243527381	Carlos	Juarez	66789923	CM005
123456789	Javier	Chavez	55861742	CM005
1234598765	Melissa	Perez	77664432	CM002
 0987654320606	Hector	Hurtarte	77555739	CM005
\.


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 233
-- Name: adiccion_id_adiccion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adiccion_id_adiccion_seq', 10, true);


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 250
-- Name: bitacora_historial_id_bitacora_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bitacora_historial_id_bitacora_seq', 15, true);


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 252
-- Name: bitacora_traspaso_id_bitacora_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bitacora_traspaso_id_bitacora_seq', 13, true);


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 239
-- Name: cirugia_id_cirugia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cirugia_id_cirugia_seq', 19, true);


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 227
-- Name: departamento_id_departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.departamento_id_departamento_seq', 22, true);


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 235
-- Name: enfermedad_id_enfermedad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.enfermedad_id_enfermedad_seq', 10, true);


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 220
-- Name: especialidad_id_especialidad_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.especialidad_id_especialidad_seq', 15, true);


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 216
-- Name: estado_id_estado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estado_id_estado_seq', 3, true);


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 237
-- Name: examen_id_examen_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.examen_id_examen_seq', 10, true);


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 241
-- Name: incidencia_historial_medico_id_incidencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.incidencia_historial_medico_id_incidencia_seq', 15, true);


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 225
-- Name: material_id_material_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.material_id_material_seq', 11, true);


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 223
-- Name: medicamento_id_medicamento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.medicamento_id_medicamento_seq', 20, true);


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 229
-- Name: municipio_id_municipio_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.municipio_id_municipio_seq', 20, true);


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 218
-- Name: paciente_no_paciente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.paciente_no_paciente_seq', 10, true);


--
-- TOC entry 3632 (class 2606 OID 176422)
-- Name: adiccion adiccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adiccion
    ADD CONSTRAINT adiccion_pkey PRIMARY KEY (id_adiccion);


--
-- TOC entry 3654 (class 2606 OID 176576)
-- Name: bitacora_historial bitacora_historial_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora_historial
    ADD CONSTRAINT bitacora_historial_pkey PRIMARY KEY (id_bitacora);


--
-- TOC entry 3656 (class 2606 OID 176588)
-- Name: bitacora_traspaso bitacora_traspaso_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora_traspaso
    ADD CONSTRAINT bitacora_traspaso_pkey PRIMARY KEY (id_bitacora);


--
-- TOC entry 3601 (class 2606 OID 176277)
-- Name: centro_medico centro_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.centro_medico
    ADD CONSTRAINT centro_medico_pkey PRIMARY KEY (id_centro_medico);


--
-- TOC entry 3638 (class 2606 OID 176450)
-- Name: cirugia cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cirugia
    ADD CONSTRAINT cirugia_pkey PRIMARY KEY (id_cirugia);


--
-- TOC entry 3624 (class 2606 OID 176370)
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id_departamento);


--
-- TOC entry 3628 (class 2606 OID 176387)
-- Name: direccion_centro_medico direccion_centro_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion_centro_medico
    ADD CONSTRAINT direccion_centro_medico_pkey PRIMARY KEY (id_centro_medico);


--
-- TOC entry 3630 (class 2606 OID 176402)
-- Name: direccion_persona direccion_persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion_persona
    ADD CONSTRAINT direccion_persona_pkey PRIMARY KEY (cui);


--
-- TOC entry 3634 (class 2606 OID 176432)
-- Name: enfermedad enfermedad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enfermedad
    ADD CONSTRAINT enfermedad_pkey PRIMARY KEY (id_enfermedad);


--
-- TOC entry 3612 (class 2606 OID 176330)
-- Name: especialidad especialidad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especialidad
    ADD CONSTRAINT especialidad_pkey PRIMARY KEY (id_especialidad);


--
-- TOC entry 3605 (class 2606 OID 176294)
-- Name: estado estado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY (id_estado);


--
-- TOC entry 3636 (class 2606 OID 176441)
-- Name: examen examen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.examen
    ADD CONSTRAINT examen_pkey PRIMARY KEY (id_examen);


--
-- TOC entry 3644 (class 2606 OID 176494)
-- Name: historial_adiccion historial_adiccion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_adiccion
    ADD CONSTRAINT historial_adiccion_pkey PRIMARY KEY (id_incidencia, id_adiccion);


--
-- TOC entry 3648 (class 2606 OID 176524)
-- Name: historial_cirugia historial_cirugia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cirugia
    ADD CONSTRAINT historial_cirugia_pkey PRIMARY KEY (id_incidencia, id_cirugia);


--
-- TOC entry 3642 (class 2606 OID 176479)
-- Name: historial_enfermedad historial_enfermedad_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_enfermedad
    ADD CONSTRAINT historial_enfermedad_pkey PRIMARY KEY (id_incidencia, id_enfermedad);


--
-- TOC entry 3646 (class 2606 OID 176509)
-- Name: historial_examen historial_examen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_examen
    ADD CONSTRAINT historial_examen_pkey PRIMARY KEY (id_incidencia, id_examen);


--
-- TOC entry 3640 (class 2606 OID 176459)
-- Name: incidencia_historial_medico incidencia_historial_medico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia_historial_medico
    ADD CONSTRAINT incidencia_historial_medico_pkey PRIMARY KEY (id_incidencia);


--
-- TOC entry 3652 (class 2606 OID 176557)
-- Name: inventario_material inventario_material_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_material
    ADD CONSTRAINT inventario_material_pkey PRIMARY KEY (id_centro_medico, id_material);


--
-- TOC entry 3650 (class 2606 OID 176542)
-- Name: inventario_medicamento inventario_medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_medicamento
    ADD CONSTRAINT inventario_medicamento_pkey PRIMARY KEY (id_centro_medico, id_medicamento);


--
-- TOC entry 3622 (class 2606 OID 176363)
-- Name: material material_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id_material);


--
-- TOC entry 3620 (class 2606 OID 176356)
-- Name: medicamento medicamento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicamento
    ADD CONSTRAINT medicamento_pkey PRIMARY KEY (id_medicamento);


--
-- TOC entry 3614 (class 2606 OID 176337)
-- Name: medico medico_cui_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_cui_key UNIQUE (cui);


--
-- TOC entry 3616 (class 2606 OID 176335)
-- Name: medico medico_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_pkey PRIMARY KEY (no_colegiado);


--
-- TOC entry 3618 (class 2606 OID 176339)
-- Name: medico medico_usuario_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT medico_usuario_key UNIQUE (usuario);


--
-- TOC entry 3626 (class 2606 OID 176377)
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id_municipio);


--
-- TOC entry 3608 (class 2606 OID 176303)
-- Name: paciente paciente_cui_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_cui_key UNIQUE (cui);


--
-- TOC entry 3610 (class 2606 OID 176301)
-- Name: paciente paciente_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT paciente_pkey PRIMARY KEY (no_paciente);


--
-- TOC entry 3603 (class 2606 OID 176282)
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (cui);


--
-- TOC entry 3606 (class 1259 OID 176629)
-- Name: idx_estado_descripcion; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_estado_descripcion ON public.estado USING btree (descripcion);


--
-- TOC entry 3687 (class 2620 OID 176628)
-- Name: paciente actualizar_mortalidad; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_mortalidad AFTER INSERT OR UPDATE ON public.paciente FOR EACH ROW EXECUTE FUNCTION public.actualizar_mortalidad();


--
-- TOC entry 3686 (class 2620 OID 176607)
-- Name: persona actualizar_traspaso; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER actualizar_traspaso AFTER INSERT OR UPDATE ON public.persona FOR EACH ROW EXECUTE FUNCTION public.verificar_registro();


--
-- TOC entry 3688 (class 2620 OID 176605)
-- Name: incidencia_historial_medico bitacora_historial_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bitacora_historial_trigger AFTER INSERT OR DELETE OR UPDATE ON public.incidencia_historial_medico FOR EACH ROW EXECUTE FUNCTION public.bitacora_historial_trigger();


--
-- TOC entry 3674 (class 2606 OID 176500)
-- Name: historial_adiccion fk_adiccion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_adiccion
    ADD CONSTRAINT fk_adiccion FOREIGN KEY (id_adiccion) REFERENCES public.adiccion(id_adiccion);


--
-- TOC entry 3657 (class 2606 OID 176283)
-- Name: persona fk_centro_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT fk_centro_medico FOREIGN KEY (id_centro_medico) REFERENCES public.centro_medico(id_centro_medico);


--
-- TOC entry 3665 (class 2606 OID 176388)
-- Name: direccion_centro_medico fk_centro_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion_centro_medico
    ADD CONSTRAINT fk_centro_medico FOREIGN KEY (id_centro_medico) REFERENCES public.centro_medico(id_centro_medico);


--
-- TOC entry 3669 (class 2606 OID 176470)
-- Name: incidencia_historial_medico fk_centro_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia_historial_medico
    ADD CONSTRAINT fk_centro_medico FOREIGN KEY (id_centro_medico) REFERENCES public.centro_medico(id_centro_medico);


--
-- TOC entry 3680 (class 2606 OID 176543)
-- Name: inventario_medicamento fk_centro_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_medicamento
    ADD CONSTRAINT fk_centro_medico FOREIGN KEY (id_centro_medico) REFERENCES public.centro_medico(id_centro_medico);


--
-- TOC entry 3682 (class 2606 OID 176558)
-- Name: inventario_material fk_centro_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_material
    ADD CONSTRAINT fk_centro_medico FOREIGN KEY (id_centro_medico) REFERENCES public.centro_medico(id_centro_medico);


--
-- TOC entry 3678 (class 2606 OID 176530)
-- Name: historial_cirugia fk_cirugia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cirugia
    ADD CONSTRAINT fk_cirugia FOREIGN KEY (id_cirugia) REFERENCES public.cirugia(id_cirugia);


--
-- TOC entry 3664 (class 2606 OID 176378)
-- Name: municipio fk_departamento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT fk_departamento FOREIGN KEY (id_departamento) REFERENCES public.departamento(id_departamento);


--
-- TOC entry 3672 (class 2606 OID 176485)
-- Name: historial_enfermedad fk_enfermedad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_enfermedad
    ADD CONSTRAINT fk_enfermedad FOREIGN KEY (id_enfermedad) REFERENCES public.enfermedad(id_enfermedad);


--
-- TOC entry 3662 (class 2606 OID 176345)
-- Name: medico fk_especialidad; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT fk_especialidad FOREIGN KEY (id_especialidad) REFERENCES public.especialidad(id_especialidad);


--
-- TOC entry 3658 (class 2606 OID 176319)
-- Name: paciente fk_estado_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_estado_paciente FOREIGN KEY (id_estado) REFERENCES public.estado(id_estado);


--
-- TOC entry 3676 (class 2606 OID 176515)
-- Name: historial_examen fk_examen; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_examen
    ADD CONSTRAINT fk_examen FOREIGN KEY (id_examen) REFERENCES public.examen(id_examen);


--
-- TOC entry 3673 (class 2606 OID 176480)
-- Name: historial_enfermedad fk_incidencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_enfermedad
    ADD CONSTRAINT fk_incidencia FOREIGN KEY (id_incidencia) REFERENCES public.incidencia_historial_medico(id_incidencia);


--
-- TOC entry 3675 (class 2606 OID 176495)
-- Name: historial_adiccion fk_incidencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_adiccion
    ADD CONSTRAINT fk_incidencia FOREIGN KEY (id_incidencia) REFERENCES public.incidencia_historial_medico(id_incidencia);


--
-- TOC entry 3677 (class 2606 OID 176510)
-- Name: historial_examen fk_incidencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_examen
    ADD CONSTRAINT fk_incidencia FOREIGN KEY (id_incidencia) REFERENCES public.incidencia_historial_medico(id_incidencia);


--
-- TOC entry 3679 (class 2606 OID 176525)
-- Name: historial_cirugia fk_incidencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historial_cirugia
    ADD CONSTRAINT fk_incidencia FOREIGN KEY (id_incidencia) REFERENCES public.incidencia_historial_medico(id_incidencia);


--
-- TOC entry 3684 (class 2606 OID 176577)
-- Name: bitacora_historial fk_incidencia; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora_historial
    ADD CONSTRAINT fk_incidencia FOREIGN KEY (id_incidencia) REFERENCES public.incidencia_historial_medico(id_incidencia);


--
-- TOC entry 3659 (class 2606 OID 176314)
-- Name: paciente fk_madre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_madre FOREIGN KEY (no_paciente_madre) REFERENCES public.paciente(no_paciente);


--
-- TOC entry 3683 (class 2606 OID 176563)
-- Name: inventario_material fk_material; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_material
    ADD CONSTRAINT fk_material FOREIGN KEY (id_material) REFERENCES public.material(id_material);


--
-- TOC entry 3681 (class 2606 OID 176548)
-- Name: inventario_medicamento fk_medicamento; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario_medicamento
    ADD CONSTRAINT fk_medicamento FOREIGN KEY (id_medicamento) REFERENCES public.medicamento(id_medicamento);


--
-- TOC entry 3670 (class 2606 OID 176465)
-- Name: incidencia_historial_medico fk_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia_historial_medico
    ADD CONSTRAINT fk_medico FOREIGN KEY (no_colegiado) REFERENCES public.medico(no_colegiado);


--
-- TOC entry 3666 (class 2606 OID 176393)
-- Name: direccion_centro_medico fk_municipio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion_centro_medico
    ADD CONSTRAINT fk_municipio FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio);


--
-- TOC entry 3667 (class 2606 OID 176408)
-- Name: direccion_persona fk_municipio; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion_persona
    ADD CONSTRAINT fk_municipio FOREIGN KEY (id_municipio) REFERENCES public.municipio(id_municipio);


--
-- TOC entry 3671 (class 2606 OID 176460)
-- Name: incidencia_historial_medico fk_paciente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.incidencia_historial_medico
    ADD CONSTRAINT fk_paciente FOREIGN KEY (no_paciente) REFERENCES public.paciente(no_paciente);


--
-- TOC entry 3660 (class 2606 OID 176309)
-- Name: paciente fk_padre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_padre FOREIGN KEY (no_paciente_padre) REFERENCES public.paciente(no_paciente);


--
-- TOC entry 3661 (class 2606 OID 176304)
-- Name: paciente fk_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paciente
    ADD CONSTRAINT fk_persona FOREIGN KEY (cui) REFERENCES public.persona(cui);


--
-- TOC entry 3663 (class 2606 OID 176340)
-- Name: medico fk_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medico
    ADD CONSTRAINT fk_persona FOREIGN KEY (cui) REFERENCES public.persona(cui);


--
-- TOC entry 3668 (class 2606 OID 176403)
-- Name: direccion_persona fk_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.direccion_persona
    ADD CONSTRAINT fk_persona FOREIGN KEY (cui) REFERENCES public.persona(cui);


--
-- TOC entry 3685 (class 2606 OID 176589)
-- Name: bitacora_traspaso fk_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bitacora_traspaso
    ADD CONSTRAINT fk_persona FOREIGN KEY (cui) REFERENCES public.persona(cui);


-- Completed on 2023-04-21 20:50:44 CST

--
-- PostgreSQL database dump complete
--

