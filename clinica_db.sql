-- ============================================================
--  Usuario: root | Contraseña: anzu0172* | BD: clinica_db
-- ============================================================

CREATE DATABASE IF NOT EXISTS clinica_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE clinica_db;

-- ------------------------------------------------------------
--  TABLAS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS especialidad (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS paciente (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(150) NOT NULL,
    dni       VARCHAR(20)  NOT NULL UNIQUE,
    contacto  VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS consultorio (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    numero         INT          NOT NULL,
    id_especialidad INT         NOT NULL,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS cita (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente     INT          NOT NULL,
    id_consultorio  INT          NOT NULL,
    doctor          VARCHAR(150),
    fecha           DATE         NOT NULL,
    hora            TIME         NOT NULL,
    FOREIGN KEY (id_paciente)    REFERENCES paciente(id),
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS historia (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente  INT  NOT NULL,
    sintomas     TEXT,
    tratamiento  TEXT,
    fecha_reg    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS practicante (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    dni          VARCHAR(20)  NOT NULL UNIQUE,
    supervisor   INT,  -- Ahora es FK a doctor
    especialidad VARCHAR(100),
    FOREIGN KEY (supervisor) REFERENCES doctor(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Nueva tabla doctor
CREATE TABLE IF NOT EXISTS doctor (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    dni             VARCHAR(20)  NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    id_especialidad INT,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Modificar tabla cita para usar doctor como FK
ALTER TABLE cita DROP COLUMN doctor;
ALTER TABLE cita ADD COLUMN id_doctor INT;
ALTER TABLE cita ADD CONSTRAINT fk_cita_doctor FOREIGN KEY (id_doctor) REFERENCES doctor(id);

-- Modificar tabla historia para incluir doctor asignado
ALTER TABLE historia ADD COLUMN id_doctor INT;
ALTER TABLE historia ADD CONSTRAINT fk_historia_doctor FOREIGN KEY (id_doctor) REFERENCES doctor(id);

-- ------------------------------------------------------------
--  STORED PROCEDURES
--  Los servlets intentan primero el CALL y hacen fallback
--  a INSERT directo si el SP no existe. Con estos SPs
--  el flujo queda completo y devuelve ID + mensaje.
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_paciente;
DELIMITER $$
CREATE PROCEDURE sp_registrar_paciente(
    IN  p_nombre    VARCHAR(150),
    IN  p_dni       VARCHAR(20),
    IN  p_contacto  VARCHAR(100),
    OUT p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar paciente';
    END;

    INSERT INTO paciente(nombre, dni, contacto)
    VALUES (p_nombre, p_dni, p_contacto);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Paciente registrado con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_registrar_especialidad(
    IN  p_nombre  VARCHAR(100),
    OUT p_id      INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar especialidad (puede ya existir)';
    END;

    INSERT INTO especialidad(nombre) VALUES (p_nombre);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Especialidad registrada con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_registrar_consultorio(
    IN  p_numero          INT,
    IN  p_id_especialidad INT,
    OUT p_id              INT,
    OUT p_mensaje         VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar consultorio';
    END;

    INSERT INTO consultorio(numero, id_especialidad)
    VALUES (p_numero, p_id_especialidad);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Consultorio registrado con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_cita;
DELIMITER $$
CREATE PROCEDURE sp_registrar_cita(
    IN  p_id_paciente    INT,
    IN  p_id_consultorio INT,
    IN  p_doctor         VARCHAR(150),
    IN  p_fecha          DATE,
    IN  p_hora           TIME,
    OUT p_id             INT,
    OUT p_mensaje        VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar cita';
    END;

    INSERT INTO cita(id_paciente, id_consultorio, doctor, fecha, hora)
    VALUES (p_id_paciente, p_id_consultorio, p_doctor, p_fecha, p_hora);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Cita registrada con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_historia;
DELIMITER $$
CREATE PROCEDURE sp_registrar_historia(
    IN  p_id_paciente  INT,
    IN  p_sintomas     TEXT,
    IN  p_tratamiento  TEXT,
    OUT p_id           INT,
    OUT p_mensaje      VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar historia clínica';
    END;

    INSERT INTO historia(id_paciente, sintomas, tratamiento)
    VALUES (p_id_paciente, p_sintomas, p_tratamiento);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Historia registrada con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_registrar_practicante(
    IN  p_nombre      VARCHAR(150),
    IN  p_dni         VARCHAR(20),
    IN  p_supervisor  INT,
    IN  p_especialidad VARCHAR(100),
    OUT p_id          INT,
    OUT p_mensaje     VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar practicante (DNI puede duplicarse)';
    END;

    INSERT INTO practicante(nombre, dni, supervisor, especialidad)
    VALUES (p_nombre, p_dni, p_supervisor, p_especialidad);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Practicante registrado con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- STORED PROCEDURES PARA DOCTOR
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_registrar_doctor;
DELIMITER $$
CREATE PROCEDURE sp_registrar_doctor(
    IN  p_nombre          VARCHAR(150),
    IN  p_dni             VARCHAR(20),
    IN  p_telefono        VARCHAR(20),
    IN  p_id_especialidad INT,
    OUT p_id              INT,
    OUT p_mensaje         VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id      = -1;
        SET p_mensaje = 'Error al registrar doctor (DNI puede estar duplicado)';
    END;

    INSERT INTO doctor(nombre, dni, telefono, id_especialidad)
    VALUES (p_nombre, p_dni, p_telefono, p_id_especialidad);

    SET p_id      = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Doctor registrado con ID: ', p_id);
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_doctor;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_doctor(
    IN  p_id              INT,
    IN  p_nombre          VARCHAR(150),
    IN  p_dni             VARCHAR(20),
    IN  p_telefono        VARCHAR(20),
    IN  p_id_especialidad INT,
    OUT p_mensaje         VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar doctor';
    END;

    UPDATE doctor 
    SET nombre = p_nombre, dni = p_dni, telefono = p_telefono, id_especialidad = p_id_especialidad
    WHERE id = p_id;

    SET p_mensaje = 'Doctor actualizado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_doctor;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_doctor(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar doctor (tiene registros relacionados)';
    END;

    DELETE FROM doctor WHERE id = p_id;
    SET p_mensaje = 'Doctor eliminado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- STORED PROCEDURES PARA ACTUALIZAR Y ELIMINAR OTRAS ENTIDADES
-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_especialidad(
    IN  p_id        INT,
    IN  p_nombre    VARCHAR(100),
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar especialidad (nombre duplicado)';
    END;

    UPDATE especialidad SET nombre = p_nombre WHERE id = p_id;
    SET p_mensaje = 'Especialidad actualizada correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_especialidad(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE v_count INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar especialidad';
    END;

    SELECT COUNT(*) INTO v_count FROM doctor WHERE id_especialidad = p_id;
    IF v_count > 0 THEN
        SET p_mensaje = 'No se puede eliminar: hay doctores asignados';
    ELSE
        DELETE FROM especialidad WHERE id = p_id;
        SET p_mensaje = 'Especialidad eliminada correctamente';
    END IF;
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_paciente;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_paciente(
    IN  p_id        INT,
    IN  p_nombre    VARCHAR(150),
    IN  p_dni       VARCHAR(20),
    IN  p_contacto  VARCHAR(100),
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar paciente (DNI duplicado)';
    END;

    UPDATE paciente SET nombre = p_nombre, dni = p_dni, contacto = p_contacto WHERE id = p_id;
    SET p_mensaje = 'Paciente actualizado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_paciente;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_paciente(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar paciente (tiene registros relacionados)';
    END;

    DELETE FROM paciente WHERE id = p_id;
    SET p_mensaje = 'Paciente eliminado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_consultorio(
    IN  p_id              INT,
    IN  p_numero          INT,
    IN  p_id_especialidad INT,
    OUT p_mensaje         VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar consultorio';
    END;

    UPDATE consultorio SET numero = p_numero, id_especialidad = p_id_especialidad WHERE id = p_id;
    SET p_mensaje = 'Consultorio actualizado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_consultorio(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar consultorio (tiene citas relacionadas)';
    END;

    DELETE FROM consultorio WHERE id = p_id;
    SET p_mensaje = 'Consultorio eliminado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_cita;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_cita(
    IN  p_id             INT,
    IN  p_id_paciente    INT,
    IN  p_id_consultorio INT,
    IN  p_id_doctor      INT,
    IN  p_fecha          DATE,
    IN  p_hora           TIME,
    OUT p_mensaje        VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar cita';
    END;

    UPDATE cita 
    SET id_paciente = p_id_paciente, id_consultorio = p_id_consultorio, 
        id_doctor = p_id_doctor, fecha = p_fecha, hora = p_hora
    WHERE id = p_id;

    SET p_mensaje = 'Cita actualizada correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_cita;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_cita(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar cita';
    END;

    DELETE FROM cita WHERE id = p_id;
    SET p_mensaje = 'Cita eliminada correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_historia;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_historia(
    IN  p_id           INT,
    IN  p_id_paciente  INT,
    IN  p_id_doctor    INT,
    IN  p_sintomas     TEXT,
    IN  p_tratamiento  TEXT,
    OUT p_mensaje      VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar historia clínica';
    END;

    UPDATE historia 
    SET id_paciente = p_id_paciente, id_doctor = p_id_doctor, 
        sintomas = p_sintomas, tratamiento = p_tratamiento
    WHERE id = p_id;

    SET p_mensaje = 'Historia clínica actualizada correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_historia;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_historia(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar historia clínica';
    END;

    DELETE FROM historia WHERE id = p_id;
    SET p_mensaje = 'Historia clínica eliminada correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_actualizar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_practicante(
    IN  p_id           INT,
    IN  p_nombre       VARCHAR(150),
    IN  p_dni          VARCHAR(20),
    IN  p_supervisor   INT,
    IN  p_especialidad VARCHAR(100),
    OUT p_mensaje      VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar practicante';
    END;

    UPDATE practicante 
    SET nombre = p_nombre, dni = p_dni, supervisor = p_supervisor, especialidad = p_especialidad
    WHERE id = p_id;

    SET p_mensaje = 'Practicante actualizado correctamente';
END$$
DELIMITER ;

-- ------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_eliminar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_practicante(
    IN  p_id        INT,
    OUT p_mensaje   VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar practicante';
    END;

    DELETE FROM practicante WHERE id = p_id;
    SET p_mensaje = 'Practicante eliminado correctamente';
END$$
DELIMITER ;

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
