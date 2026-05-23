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
    supervisor   VARCHAR(150),
    especialidad VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
    IN  p_supervisor  VARCHAR(150),
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

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
