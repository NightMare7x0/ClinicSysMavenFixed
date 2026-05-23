-- ============================================================
--  Sistema de Gestión Clínica - ClinicSys
--  Usuario: root | Contraseña: anzu0172* | BD: clinica_db
-- ============================================================

DROP DATABASE IF EXISTS clinica_db;
CREATE DATABASE clinica_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinica_db;

-- ============================================================
--  TABLAS
-- ============================================================

CREATE TABLE especialidad (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE paciente (
    id       INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(150) NOT NULL,
    dni      VARCHAR(20)  NOT NULL UNIQUE,
    contacto VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE doctor (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    dni             VARCHAR(20)  NOT NULL UNIQUE,
    telefono        VARCHAR(20),
    id_especialidad INT,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE consultorio (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    numero          INT NOT NULL,
    id_especialidad INT NOT NULL,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE cita (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente    INT NOT NULL,
    id_consultorio INT,
    id_doctor      INT,
    fecha          DATE NOT NULL,
    hora           TIME NOT NULL,
    FOREIGN KEY (id_paciente)    REFERENCES paciente(id) ON DELETE CASCADE,
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id) ON DELETE SET NULL,
    FOREIGN KEY (id_doctor)      REFERENCES doctor(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE historia_clinica (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_doctor   INT,
    sintomas    TEXT,
    tratamiento TEXT,
    fecha_reg   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id) ON DELETE CASCADE,
    FOREIGN KEY (id_doctor)   REFERENCES doctor(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE practicante (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    dni          VARCHAR(20)  NOT NULL UNIQUE,
    id_supervisor INT,
    especialidad VARCHAR(100),
    FOREIGN KEY (id_supervisor) REFERENCES doctor(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
--  STORED PROCEDURES - ESPECIALIDAD
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_crear_especialidad(
    IN p_nombre VARCHAR(100),
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error: Nombre duplicado o error de base de datos';
    END;
    
    INSERT INTO especialidad (nombre) VALUES (p_nombre);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Especialidad registrada con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_leer_especialidad(IN p_id INT)
BEGIN
    SELECT id, nombre FROM especialidad WHERE id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todas_especialidades;
DELIMITER $$
CREATE PROCEDURE sp_leer_todas_especialidades(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT id, nombre FROM especialidad ORDER BY ';
    CASE p_order
        WHEN 'nombre_desc' THEN SET @sql = CONCAT(@sql, 'nombre DESC');
        ELSE SET @sql = CONCAT(@sql, 'nombre ASC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_especialidad(
    IN p_id INT,
    IN p_nombre VARCHAR(100),
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: Nombre duplicado o error al actualizar';
    END;
    
    UPDATE especialidad SET nombre = p_nombre WHERE id = p_id;
    SET p_mensaje = 'Especialidad actualizada correctamente';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_especialidad(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(*) INTO v_count FROM doctor WHERE id_especialidad = p_id;
    IF v_count > 0 THEN
        SET p_mensaje = 'Error: Hay doctores asignados a esta especialidad';
    ELSE
        DELETE FROM especialidad WHERE id = p_id;
        SET p_mensaje = 'Especialidad eliminada correctamente';
    END IF;
END$$
DELIMITER ;

-- ============================================================
--  STORED PROCEDURES - PACIENTE
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_paciente;
DELIMITER $$
CREATE PROCEDURE sp_crear_paciente(
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_contacto VARCHAR(100),
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error: DNI duplicado o error de base de datos';
    END;
    
    INSERT INTO paciente (nombre, dni, contacto) VALUES (p_nombre, p_dni, p_contacto);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Paciente registrado con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_paciente;
DELIMITER $$
CREATE PROCEDURE sp_leer_paciente(IN p_id INT)
BEGIN
    SELECT id, nombre, dni, contacto FROM paciente WHERE id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todos_pacientes;
DELIMITER $$
CREATE PROCEDURE sp_leer_todos_pacientes(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT id, nombre, dni, contacto FROM paciente ORDER BY ';
    CASE p_order
        WHEN 'nombre_desc' THEN SET @sql = CONCAT(@sql, 'nombre DESC');
        WHEN 'contacto' THEN SET @sql = CONCAT(@sql, 'contacto ASC');
        WHEN 'dni' THEN SET @sql = CONCAT(@sql, 'dni ASC');
        ELSE SET @sql = CONCAT(@sql, 'nombre ASC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_paciente;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_paciente(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_contacto VARCHAR(100),
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: DNI duplicado o error al actualizar';
    END;
    
    UPDATE paciente SET nombre = p_nombre, dni = p_dni, contacto = p_contacto WHERE id = p_id;
    SET p_mensaje = 'Paciente actualizado correctamente';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_paciente;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_paciente(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: El paciente tiene registros relacionados';
    END;
    
    DELETE FROM paciente WHERE id = p_id;
    SET p_mensaje = 'Paciente eliminado correctamente';
END$$
DELIMITER ;

-- ============================================================
--  STORED PROCEDURES - DOCTOR
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_doctor;
DELIMITER $$
CREATE PROCEDURE sp_crear_doctor(
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_telefono VARCHAR(20),
    IN p_id_especialidad INT,
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error: DNI duplicado o error de base de datos';
    END;
    
    INSERT INTO doctor (nombre, dni, telefono, id_especialidad) VALUES (p_nombre, p_dni, p_telefono, p_id_especialidad);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Doctor registrado con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_doctor;
DELIMITER $$
CREATE PROCEDURE sp_leer_doctor(IN p_id INT)
BEGIN
    SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre
    FROM doctor d
    LEFT JOIN especialidad e ON d.id_especialidad = e.id
    WHERE d.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todos_doctores;
DELIMITER $$
CREATE PROCEDURE sp_leer_todos_doctores(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre 
                FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id ORDER BY ';
    CASE p_order
        WHEN 'nombre_desc' THEN SET @sql = CONCAT(@sql, 'd.nombre DESC');
        WHEN 'telefono' THEN SET @sql = CONCAT(@sql, 'd.telefono ASC');
        WHEN 'dni' THEN SET @sql = CONCAT(@sql, 'd.dni ASC');
        ELSE SET @sql = CONCAT(@sql, 'd.nombre ASC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_doctor;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_doctor(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_telefono VARCHAR(20),
    IN p_id_especialidad INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: DNI duplicado o error al actualizar';
    END;
    
    UPDATE doctor SET nombre = p_nombre, dni = p_dni, telefono = p_telefono, id_especialidad = p_id_especialidad WHERE id = p_id;
    SET p_mensaje = 'Doctor actualizado correctamente';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_doctor;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_doctor(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: El doctor tiene registros relacionados';
    END;
    
    DELETE FROM doctor WHERE id = p_id;
    SET p_mensaje = 'Doctor eliminado correctamente';
END$$
DELIMITER ;

-- ============================================================
--  STORED PROCEDURES - CONSULTORIO
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_crear_consultorio(
    IN p_numero INT,
    IN p_id_especialidad INT,
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error al registrar consultorio';
    END;
    
    INSERT INTO consultorio (numero, id_especialidad) VALUES (p_numero, p_id_especialidad);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Consultorio registrado con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_leer_consultorio(IN p_id INT)
BEGIN
    SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre
    FROM consultorio c
    LEFT JOIN especialidad e ON c.id_especialidad = e.id
    WHERE c.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todos_consultorios;
DELIMITER $$
CREATE PROCEDURE sp_leer_todos_consultorios(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre 
                FROM consultorio c LEFT JOIN especialidad e ON c.id_especialidad = e.id ORDER BY ';
    CASE p_order
        WHEN 'numero_desc' THEN SET @sql = CONCAT(@sql, 'c.numero DESC');
        WHEN 'especialidad' THEN SET @sql = CONCAT(@sql, 'e.nombre ASC');
        ELSE SET @sql = CONCAT(@sql, 'c.numero ASC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_consultorio(
    IN p_id INT,
    IN p_numero INT,
    IN p_id_especialidad INT,
    OUT p_mensaje VARCHAR(255)
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

DROP PROCEDURE IF EXISTS sp_eliminar_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_consultorio(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: El consultorio tiene citas relacionadas';
    END;
    
    DELETE FROM consultorio WHERE id = p_id;
    SET p_mensaje = 'Consultorio eliminado correctamente';
END$$
DELIMITER ;

-- ============================================================
--  STORED PROCEDURES - CITA
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_cita;
DELIMITER $$
CREATE PROCEDURE sp_crear_cita(
    IN p_id_paciente INT,
    IN p_id_consultorio INT,
    IN p_id_doctor INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error al registrar cita';
    END;
    
    INSERT INTO cita (id_paciente, id_consultorio, id_doctor, fecha, hora) VALUES (p_id_paciente, p_id_consultorio, p_id_doctor, p_fecha, p_hora);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Cita registrada con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_cita;
DELIMITER $$
CREATE PROCEDURE sp_leer_cita(IN p_id INT)
BEGIN
    SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, c.id_consultorio, co.numero as consultorio_numero,
           c.id_doctor, d.nombre as doctor_nombre, c.fecha, c.hora
    FROM cita c
    LEFT JOIN paciente p ON c.id_paciente = p.id
    LEFT JOIN consultorio co ON c.id_consultorio = co.id
    LEFT JOIN doctor d ON c.id_doctor = d.id
    WHERE c.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todas_citas;
DELIMITER $$
CREATE PROCEDURE sp_leer_todas_citas(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, c.id_consultorio, co.numero as consultorio_numero,
                       c.id_doctor, d.nombre as doctor_nombre, c.fecha, c.hora
                FROM cita c
                LEFT JOIN paciente p ON c.id_paciente = p.id
                LEFT JOIN consultorio co ON c.id_consultorio = co.id
                LEFT JOIN doctor d ON c.id_doctor = d.id ORDER BY ';
    CASE p_order
        WHEN 'fecha_desc' THEN SET @sql = CONCAT(@sql, 'c.fecha DESC, c.hora DESC');
        WHEN 'paciente' THEN SET @sql = CONCAT(@sql, 'p.nombre ASC');
        WHEN 'doctor' THEN SET @sql = CONCAT(@sql, 'd.nombre ASC');
        ELSE SET @sql = CONCAT(@sql, 'c.fecha ASC, c.hora ASC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_cita;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_cita(
    IN p_id INT,
    IN p_id_paciente INT,
    IN p_id_consultorio INT,
    IN p_id_doctor INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar cita';
    END;
    
    UPDATE cita SET id_paciente = p_id_paciente, id_consultorio = p_id_consultorio,
                    id_doctor = p_id_doctor, fecha = p_fecha, hora = p_hora WHERE id = p_id;
    SET p_mensaje = 'Cita actualizada correctamente';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_cita;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_cita(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
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

-- ============================================================
--  STORED PROCEDURES - HISTORIA CLINICA
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_historia;
DELIMITER $$
CREATE PROCEDURE sp_crear_historia(
    IN p_id_paciente INT,
    IN p_id_doctor INT,
    IN p_sintomas TEXT,
    IN p_tratamiento TEXT,
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error al registrar historia clínica';
    END;
    
    INSERT INTO historia_clinica (id_paciente, id_doctor, sintomas, tratamiento) VALUES (p_id_paciente, p_id_doctor, p_sintomas, p_tratamiento);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Historia clínica registrada con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_historia;
DELIMITER $$
CREATE PROCEDURE sp_leer_historia(IN p_id INT)
BEGIN
    SELECT h.id, h.id_paciente, p.nombre as paciente_nombre, h.id_doctor, d.nombre as doctor_nombre,
           h.sintomas, h.tratamiento, h.fecha_reg
    FROM historia_clinica h
    LEFT JOIN paciente p ON h.id_paciente = p.id
    LEFT JOIN doctor d ON h.id_doctor = d.id
    WHERE h.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todas_historias;
DELIMITER $$
CREATE PROCEDURE sp_leer_todas_historias(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT h.id, h.id_paciente, p.nombre as paciente_nombre, h.id_doctor, d.nombre as doctor_nombre,
                       h.sintomas, h.tratamiento, h.fecha_reg
                FROM historia_clinica h
                LEFT JOIN paciente p ON h.id_paciente = p.id
                LEFT JOIN doctor d ON h.id_doctor = d.id ORDER BY ';
    CASE p_order
        WHEN 'fecha_desc' THEN SET @sql = CONCAT(@sql, 'h.fecha_reg DESC');
        WHEN 'paciente' THEN SET @sql = CONCAT(@sql, 'p.nombre ASC');
        WHEN 'doctor' THEN SET @sql = CONCAT(@sql, 'd.nombre ASC');
        ELSE SET @sql = CONCAT(@sql, 'h.fecha_reg DESC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_historia;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_historia(
    IN p_id INT,
    IN p_id_paciente INT,
    IN p_id_doctor INT,
    IN p_sintomas TEXT,
    IN p_tratamiento TEXT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al actualizar historia clínica';
    END;
    
    UPDATE historia_clinica SET id_paciente = p_id_paciente, id_doctor = p_id_doctor,
                                sintomas = p_sintomas, tratamiento = p_tratamiento WHERE id = p_id;
    SET p_mensaje = 'Historia clínica actualizada correctamente';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_historia;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_historia(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error al eliminar historia clínica';
    END;
    
    DELETE FROM historia_clinica WHERE id = p_id;
    SET p_mensaje = 'Historia clínica eliminada correctamente';
END$$
DELIMITER ;

-- ============================================================
--  STORED PROCEDURES - PRACTICANTE
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_practicante;
DELIMITER $$
CREATE PROCEDURE sp_crear_practicante(
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_id_supervisor INT,
    IN p_especialidad VARCHAR(100),
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_id = -1;
        SET p_mensaje = 'Error: DNI duplicado o error de base de datos';
    END;
    
    INSERT INTO practicante (nombre, dni, id_supervisor, especialidad) VALUES (p_nombre, p_dni, p_id_supervisor, p_especialidad);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = CONCAT('Practicante registrado con ID: ', p_id);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_practicante;
DELIMITER $$
CREATE PROCEDURE sp_leer_practicante(IN p_id INT)
BEGIN
    SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, d.nombre as supervisor_nombre, pr.especialidad
    FROM practicante pr
    LEFT JOIN doctor d ON pr.id_supervisor = d.id
    WHERE pr.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todos_practicantes;
DELIMITER $$
CREATE PROCEDURE sp_leer_todos_practicantes(IN p_order VARCHAR(20))
BEGIN
    SET @sql = 'SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, d.nombre as supervisor_nombre, pr.especialidad
                FROM practicante pr
                LEFT JOIN doctor d ON pr.id_supervisor = d.id ORDER BY ';
    CASE p_order
        WHEN 'nombre_desc' THEN SET @sql = CONCAT(@sql, 'pr.nombre DESC');
        WHEN 'dni' THEN SET @sql = CONCAT(@sql, 'pr.dni ASC');
        WHEN 'supervisor' THEN SET @sql = CONCAT(@sql, 'd.nombre ASC');
        ELSE SET @sql = CONCAT(@sql, 'pr.nombre ASC');
    END CASE;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_practicante(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_id_supervisor INT,
    IN p_especialidad VARCHAR(100),
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_mensaje = 'Error: DNI duplicado o error al actualizar';
    END;
    
    UPDATE practicante SET nombre = p_nombre, dni = p_dni, id_supervisor = p_id_supervisor, especialidad = p_especialidad WHERE id = p_id;
    SET p_mensaje = 'Practicante actualizado correctamente';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_practicante(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
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
--  DATOS DE PRUEBA
-- ============================================================

INSERT INTO especialidad (nombre) VALUES 
    ('Medicina General'), ('Cardiología'), ('Pediatría'), 
    ('Dermatología'), ('Neurología'), ('Traumatología');

INSERT INTO paciente (nombre, dni, contacto) VALUES
    ('Juan Pérez', '12345678', '999111222'),
    ('María García', '87654321', '988777666'),
    ('Carlos López', '11223344', '977666555');

INSERT INTO doctor (nombre, dni, telefono, id_especialidad) VALUES
    ('Dr. Roberto Sánchez', '55667788', '955444333', 1),
    ('Dra. Ana Martínez', '66778899', '944333222', 2);

INSERT INTO consultorio (numero, id_especialidad) VALUES (101, 1), (102, 2), (103, 3);

INSERT INTO cita (id_paciente, id_consultorio, id_doctor, fecha, hora) VALUES
    (1, 1, 1, CURDATE(), '09:00:00'),
    (2, 2, 2, CURDATE(), '10:00:00');

INSERT INTO historia_clinica (id_paciente, id_doctor, sintomas, tratamiento) VALUES
    (1, 1, 'Dolor de cabeza', 'Paracetamol 500mg cada 8 horas'),
    (2, 2, 'Arritmia cardíaca', 'Betabloqueadores diarios');

INSERT INTO practicante (nombre, dni, id_supervisor, especialidad) VALUES
    ('Luis Fernández', '99887766', 1, 'Medicina General'),
    ('Patricia Ruiz', '88776655', 2, 'Cardiología');

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
