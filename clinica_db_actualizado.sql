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
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(150) NOT NULL,
    dni           VARCHAR(20)  NOT NULL UNIQUE,
    id_supervisor INT,
    id_especialidad INT,
    FOREIGN KEY (id_supervisor) REFERENCES doctor(id) ON DELETE SET NULL,
    FOREIGN KEY (id_especialidad) REFERENCES especialidad(id) ON DELETE SET NULL
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
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM especialidad WHERE LOWER(nombre) = LOWER(p_nombre);
    
    IF v_existe > 0 THEN
        SET p_id = -2;
        SET p_mensaje = 'DUPLICADO';
    ELSE
        INSERT INTO especialidad (nombre) VALUES (p_nombre);
        SET p_id = LAST_INSERT_ID();
        SET p_mensaje = 'EXITO';
    END IF;
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
    IF p_order = 'nombre_desc' THEN
        SELECT id, nombre FROM especialidad ORDER BY nombre DESC;
    ELSE
        SELECT id, nombre FROM especialidad ORDER BY nombre ASC;
    END IF;
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
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM especialidad WHERE LOWER(nombre) = LOWER(p_nombre) AND id != p_id;
    
    IF v_existe > 0 THEN
        SET p_mensaje = 'DUPLICADO';
    ELSE
        UPDATE especialidad SET nombre = p_nombre WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_especialidad;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_especialidad(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_referencias INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_referencias FROM doctor WHERE id_especialidad = p_id;
    SELECT v_referencias INTO v_referencias FROM (SELECT COUNT(*) as cnt FROM consultorio WHERE id_especialidad = p_id) t;
    
    IF v_referencias > 0 THEN
        SET p_mensaje = 'ERROR_REFERENCIAS';
    ELSE
        DELETE FROM especialidad WHERE id = p_id;
        SET p_mensaje = 'EXITO';
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
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM paciente WHERE dni = p_dni;
    
    IF v_existe > 0 THEN
        SET p_id = -2;
        SET p_mensaje = 'DUPLICADO';
    ELSE
        INSERT INTO paciente (nombre, dni, contacto) VALUES (p_nombre, p_dni, p_contacto);
        SET p_id = LAST_INSERT_ID();
        SET p_mensaje = 'EXITO';
    END IF;
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
CREATE PROCEDURE sp_leer_todos_pacientes(IN p_order VARCHAR(30))
BEGIN
    CASE p_order
        WHEN 'nombre_desc' THEN
            SELECT id, nombre, dni, contacto FROM paciente ORDER BY nombre DESC;
        WHEN 'telefono' THEN
            SELECT id, nombre, dni, contacto FROM paciente ORDER BY contacto;
        WHEN 'dni' THEN
            SELECT id, nombre, dni, contacto FROM paciente ORDER BY dni;
        ELSE
            SELECT id, nombre, dni, contacto FROM paciente ORDER BY nombre ASC;
    END CASE;
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
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM paciente WHERE dni = p_dni AND id != p_id;
    
    IF v_existe > 0 THEN
        SET p_mensaje = 'DUPLICADO';
    ELSE
        UPDATE paciente SET nombre = p_nombre, dni = p_dni, contacto = p_contacto WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_paciente;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_paciente(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_referencias INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_referencias FROM cita WHERE id_paciente = p_id;
    SELECT v_referencias INTO v_referencias FROM (SELECT COUNT(*) as cnt FROM historia_clinica WHERE id_paciente = p_id) t;
    
    IF v_referencias > 0 THEN
        SET p_mensaje = 'ERROR_REFERENCIAS';
    ELSE
        DELETE FROM paciente WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
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
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM doctor WHERE dni = p_dni;
    
    IF v_existe > 0 THEN
        SET p_id = -2;
        SET p_mensaje = 'DUPLICADO';
    ELSE
        INSERT INTO doctor (nombre, dni, telefono, id_especialidad) VALUES (p_nombre, p_dni, p_telefono, p_id_especialidad);
        SET p_id = LAST_INSERT_ID();
        SET p_mensaje = 'EXITO';
    END IF;
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
CREATE PROCEDURE sp_leer_todos_doctores(IN p_order VARCHAR(30))
BEGIN
    CASE p_order
        WHEN 'nombre_desc' THEN
            SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre
            FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id
            ORDER BY d.nombre DESC;
        WHEN 'telefono' THEN
            SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre
            FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id
            ORDER BY d.telefono;
        WHEN 'dni' THEN
            SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre
            FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id
            ORDER BY d.dni;
        ELSE
            SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre
            FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id
            ORDER BY d.nombre ASC;
    END CASE;
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
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM doctor WHERE dni = p_dni AND id != p_id;
    
    IF v_existe > 0 THEN
        SET p_mensaje = 'DUPLICADO';
    ELSE
        UPDATE doctor SET nombre = p_nombre, dni = p_dni, telefono = p_telefono, id_especialidad = p_id_especialidad WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_doctor;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_doctor(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_referencias INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_referencias FROM cita WHERE id_doctor = p_id;
    SELECT v_referencias INTO v_referencias FROM (SELECT COUNT(*) as cnt FROM historia_clinica WHERE id_doctor = p_id) t;
    SELECT v_referencias INTO v_referencias FROM (SELECT COUNT(*) as cnt FROM practicante WHERE id_supervisor = p_id) t;
    
    IF v_referencias > 0 THEN
        SET p_mensaje = 'ERROR_REFERENCIAS';
    ELSE
        DELETE FROM doctor WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
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
    INSERT INTO consultorio (numero, id_especialidad) VALUES (p_numero, p_id_especialidad);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_leer_consultorio(IN p_id INT)
BEGIN
    SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre
    FROM consultorio c
    INNER JOIN especialidad e ON c.id_especialidad = e.id
    WHERE c.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todos_consultorios;
DELIMITER $$
CREATE PROCEDURE sp_leer_todos_consultorios(IN p_order VARCHAR(30))
BEGIN
    CASE p_order
        WHEN 'especialidad' THEN
            SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre
            FROM consultorio c INNER JOIN especialidad e ON c.id_especialidad = e.id
            ORDER BY e.nombre;
        ELSE
            SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre
            FROM consultorio c INNER JOIN especialidad e ON c.id_especialidad = e.id
            ORDER BY c.numero ASC;
    END CASE;
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
    UPDATE consultorio SET numero = p_numero, id_especialidad = p_id_especialidad WHERE id = p_id;
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_consultorio;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_consultorio(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_referencias INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_referencias FROM cita WHERE id_consultorio = p_id;
    
    IF v_referencias > 0 THEN
        SET p_mensaje = 'ERROR_REFERENCIAS';
    ELSE
        DELETE FROM consultorio WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
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
    INSERT INTO cita (id_paciente, id_consultorio, id_doctor, fecha, hora) 
    VALUES (p_id_paciente, p_id_consultorio, p_id_doctor, p_fecha, p_hora);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_cita;
DELIMITER $$
CREATE PROCEDURE sp_leer_cita(IN p_id INT)
BEGIN
    SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, 
           c.id_consultorio, co.numero as consultorio_numero,
           c.id_doctor, d.nombre as doctor_nombre,
           c.fecha, c.hora
    FROM cita c
    INNER JOIN paciente p ON c.id_paciente = p.id
    LEFT JOIN consultorio co ON c.id_consultorio = co.id
    LEFT JOIN doctor d ON c.id_doctor = d.id
    WHERE c.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todas_citas;
DELIMITER $$
CREATE PROCEDURE sp_leer_todas_citas(IN p_order VARCHAR(30))
BEGIN
    CASE p_order
        WHEN 'fecha_desc' THEN
            SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, 
                   c.id_consultorio, co.numero as consultorio_numero,
                   c.id_doctor, d.nombre as doctor_nombre,
                   c.fecha, c.hora
            FROM cita c
            INNER JOIN paciente p ON c.id_paciente = p.id
            LEFT JOIN consultorio co ON c.id_consultorio = co.id
            LEFT JOIN doctor d ON c.id_doctor = d.id
            ORDER BY c.fecha DESC, c.hora DESC;
        WHEN 'paciente' THEN
            SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, 
                   c.id_consultorio, co.numero as consultorio_numero,
                   c.id_doctor, d.nombre as doctor_nombre,
                   c.fecha, c.hora
            FROM cita c
            INNER JOIN paciente p ON c.id_paciente = p.id
            LEFT JOIN consultorio co ON c.id_consultorio = co.id
            LEFT JOIN doctor d ON c.id_doctor = d.id
            ORDER BY p.nombre;
        ELSE
            SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, 
                   c.id_consultorio, co.numero as consultorio_numero,
                   c.id_doctor, d.nombre as doctor_nombre,
                   c.fecha, c.hora
            FROM cita c
            INNER JOIN paciente p ON c.id_paciente = p.id
            LEFT JOIN consultorio co ON c.id_consultorio = co.id
            LEFT JOIN doctor d ON c.id_doctor = d.id
            ORDER BY c.fecha ASC, c.hora ASC;
    END CASE;
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
    UPDATE cita SET id_paciente = p_id_paciente, id_consultorio = p_id_consultorio, 
                    id_doctor = p_id_doctor, fecha = p_fecha, hora = p_hora 
    WHERE id = p_id;
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_cita;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_cita(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DELETE FROM cita WHERE id = p_id;
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

-- ============================================================
--  STORED PROCEDURES - HISTORIA CLINICA
-- ============================================================

DROP PROCEDURE IF EXISTS sp_crear_historia_clinica;
DELIMITER $$
CREATE PROCEDURE sp_crear_historia_clinica(
    IN p_id_paciente INT,
    IN p_id_doctor INT,
    IN p_sintomas TEXT,
    IN p_tratamiento TEXT,
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    INSERT INTO historia_clinica (id_paciente, id_doctor, sintomas, tratamiento) 
    VALUES (p_id_paciente, p_id_doctor, p_sintomas, p_tratamiento);
    SET p_id = LAST_INSERT_ID();
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_historia_clinica;
DELIMITER $$
CREATE PROCEDURE sp_leer_historia_clinica(IN p_id INT)
BEGIN
    SELECT h.id, h.id_paciente, p.nombre as paciente_nombre,
           h.id_doctor, d.nombre as doctor_nombre,
           h.sintomas, h.tratamiento, h.fecha_reg
    FROM historia_clinica h
    INNER JOIN paciente p ON h.id_paciente = p.id
    LEFT JOIN doctor d ON h.id_doctor = d.id
    WHERE h.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todas_historias;
DELIMITER $$
CREATE PROCEDURE sp_leer_todas_historias(IN p_order VARCHAR(30))
BEGIN
    CASE p_order
        WHEN 'fecha_desc' THEN
            SELECT h.id, h.id_paciente, p.nombre as paciente_nombre,
                   h.id_doctor, d.nombre as doctor_nombre,
                   h.sintomas, h.tratamiento, h.fecha_reg
            FROM historia_clinica h
            INNER JOIN paciente p ON h.id_paciente = p.id
            LEFT JOIN doctor d ON h.id_doctor = d.id
            ORDER BY h.fecha_reg DESC;
        WHEN 'paciente' THEN
            SELECT h.id, h.id_paciente, p.nombre as paciente_nombre,
                   h.id_doctor, d.nombre as doctor_nombre,
                   h.sintomas, h.tratamiento, h.fecha_reg
            FROM historia_clinica h
            INNER JOIN paciente p ON h.id_paciente = p.id
            LEFT JOIN doctor d ON h.id_doctor = d.id
            ORDER BY p.nombre;
        ELSE
            SELECT h.id, h.id_paciente, p.nombre as paciente_nombre,
                   h.id_doctor, d.nombre as doctor_nombre,
                   h.sintomas, h.tratamiento, h.fecha_reg
            FROM historia_clinica h
            INNER JOIN paciente p ON h.id_paciente = p.id
            LEFT JOIN doctor d ON h.id_doctor = d.id
            ORDER BY h.fecha_reg ASC;
    END CASE;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_historia_clinica;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_historia_clinica(
    IN p_id INT,
    IN p_id_paciente INT,
    IN p_id_doctor INT,
    IN p_sintomas TEXT,
    IN p_tratamiento TEXT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    UPDATE historia_clinica SET id_paciente = p_id_paciente, id_doctor = p_id_doctor,
                                sintomas = p_sintomas, tratamiento = p_tratamiento
    WHERE id = p_id;
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_historia_clinica;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_historia_clinica(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DELETE FROM historia_clinica WHERE id = p_id;
    SET p_mensaje = 'EXITO';
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
    IN p_id_especialidad INT,
    OUT p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM practicante WHERE dni = p_dni;
    
    IF v_existe > 0 THEN
        SET p_id = -2;
        SET p_mensaje = 'DUPLICADO';
    ELSE
        INSERT INTO practicante (nombre, dni, id_supervisor, id_especialidad) 
        VALUES (p_nombre, p_dni, p_id_supervisor, p_id_especialidad);
        SET p_id = LAST_INSERT_ID();
        SET p_mensaje = 'EXITO';
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_practicante;
DELIMITER $$
CREATE PROCEDURE sp_leer_practicante(IN p_id INT)
BEGIN
    SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, dr.nombre as supervisor_nombre,
           pr.id_especialidad, e.nombre as especialidad_nombre
    FROM practicante pr
    LEFT JOIN doctor dr ON pr.id_supervisor = dr.id
    LEFT JOIN especialidad e ON pr.id_especialidad = e.id
    WHERE pr.id = p_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_leer_todos_practicantes;
DELIMITER $$
CREATE PROCEDURE sp_leer_todos_practicantes(IN p_order VARCHAR(30))
BEGIN
    CASE p_order
        WHEN 'nombre_desc' THEN
            SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, dr.nombre as supervisor_nombre,
                   pr.id_especialidad, e.nombre as especialidad_nombre
            FROM practicante pr
            LEFT JOIN doctor dr ON pr.id_supervisor = dr.id
            LEFT JOIN especialidad e ON pr.id_especialidad = e.id
            ORDER BY pr.nombre DESC;
        WHEN 'dni' THEN
            SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, dr.nombre as supervisor_nombre,
                   pr.id_especialidad, e.nombre as especialidad_nombre
            FROM practicante pr
            LEFT JOIN doctor dr ON pr.id_supervisor = dr.id
            LEFT JOIN especialidad e ON pr.id_especialidad = e.id
            ORDER BY pr.dni;
        ELSE
            SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, dr.nombre as supervisor_nombre,
                   pr.id_especialidad, e.nombre as especialidad_nombre
            FROM practicante pr
            LEFT JOIN doctor dr ON pr.id_supervisor = dr.id
            LEFT JOIN especialidad e ON pr.id_especialidad = e.id
            ORDER BY pr.nombre ASC;
    END CASE;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_actualizar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_practicante(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_dni VARCHAR(20),
    IN p_id_supervisor INT,
    IN p_id_especialidad INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;
    
    SELECT COUNT(*) INTO v_existe FROM practicante WHERE dni = p_dni AND id != p_id;
    
    IF v_existe > 0 THEN
        SET p_mensaje = 'DUPLICADO';
    ELSE
        UPDATE practicante SET nombre = p_nombre, dni = p_dni, 
                               id_supervisor = p_id_supervisor, id_especialidad = p_id_especialidad
        WHERE id = p_id;
        SET p_mensaje = 'EXITO';
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_eliminar_practicante;
DELIMITER $$
CREATE PROCEDURE sp_eliminar_practicante(
    IN p_id INT,
    OUT p_mensaje VARCHAR(255)
)
BEGIN
    DELETE FROM practicante WHERE id = p_id;
    SET p_mensaje = 'EXITO';
END$$
DELIMITER ;

-- ============================================================
--  DATOS DE PRUEBA
-- ============================================================

INSERT INTO especialidad (nombre) VALUES 
('Medicina General'), ('Cardiología'), ('Pediatría'), ('Dermatología');

INSERT INTO doctor (nombre, dni, telefono, id_especialidad) VALUES
('Dr. Juan Pérez', '12345678', '987654321', 1),
('Dra. María López', '87654321', '912345678', 2);

INSERT INTO paciente (nombre, dni, contacto) VALUES
('Carlos Ruiz', '11111111', '999111222'),
('Ana García', '22222222', '999333444');

INSERT INTO consultorio (numero, id_especialidad) VALUES (101, 1), (102, 2);

INSERT INTO cita (id_paciente, id_consultorio, id_doctor, fecha, hora) VALUES
(1, 1, 1, '2025-01-15', '10:00:00');

INSERT INTO historia_clinica (id_paciente, id_doctor, sintomas, tratamiento) VALUES
(1, 1, 'Fiebre y dolor de cabeza', 'Paracetamol 500mg cada 8 horas');

INSERT INTO practicante (nombre, dni, id_supervisor, id_especialidad) VALUES
('Luis Torres', '33333333', 1, 1);
