package com.sistema.clinica.dao;

import com.sistema.clinica.model.Cita;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Cita usando Stored Procedures
 */
public class CitaDao implements IDao<Cita> {

    @Override
    public int create(Cita cita) {
        String sql = "{CALL sp_crear_cita(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, cita.getIdPaciente());
            cs.setInt(2, cita.getIdConsultorio());
            cs.setString(3, cita.getDoctor()); // ID del doctor como string
            cs.setDate(4, cita.getFecha());
            cs.setTime(5, cita.getHora());
            cs.registerOutParameter(6, Types.INTEGER);
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.execute();

            int id = cs.getInt(6);
            String mensaje = cs.getString(7);
            
            if (id == -1) {
                return -1;
            }
            return id;

        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }
    }

    @Override
    public Cita readById(int id) {
        String sql = "SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, c.id_consultorio, co.numero as consultorio_numero, " +
                     "c.id_doctor, d.nombre as doctor_nombre, c.fecha, c.hora " +
                     "FROM cita c " +
                     "LEFT JOIN paciente p ON c.id_paciente = p.id " +
                     "LEFT JOIN consultorio co ON c.id_consultorio = co.id " +
                     "LEFT JOIN doctor d ON c.id_doctor = d.id " +
                     "WHERE c.id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Cita cita = new Cita();
                cita.setId(rs.getInt("id"));
                cita.setIdPaciente(rs.getInt("id_paciente"));
                cita.setPacienteNombre(rs.getString("paciente_nombre"));
                cita.setIdConsultorio(rs.getInt("id_consultorio"));
                cita.setNumeroConsultorio(rs.getInt("consultorio_numero"));
                cita.setDoctor(rs.getString("doctor_nombre"));
                cita.setDoctorNombre(rs.getString("doctor_nombre"));
                cita.setFecha(rs.getDate("fecha"));
                cita.setHora(rs.getTime("hora"));
                return cita;
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Cita> readAll() {
        return readAllOrdered("fecha_asc");
    }

    public List<Cita> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "fecha_desc":
                orderBy = "ORDER BY c.fecha DESC, c.hora DESC";
                break;
            case "paciente":
                orderBy = "ORDER BY p.nombre ASC";
                break;
            case "doctor":
                orderBy = "ORDER BY d.nombre ASC";
                break;
            default:
                orderBy = "ORDER BY c.fecha ASC, c.hora ASC";
        }

        String sql = "SELECT c.id, c.id_paciente, p.nombre as paciente_nombre, c.id_consultorio, co.numero as consultorio_numero, " +
                     "c.id_doctor, d.nombre as doctor_nombre, c.fecha, c.hora " +
                     "FROM cita c " +
                     "LEFT JOIN paciente p ON c.id_paciente = p.id " +
                     "LEFT JOIN consultorio co ON c.id_consultorio = co.id " +
                     "LEFT JOIN doctor d ON c.id_doctor = d.id " + orderBy;
        List<Cita> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Cita cita = new Cita();
                cita.setId(rs.getInt("id"));
                cita.setIdPaciente(rs.getInt("id_paciente"));
                cita.setPacienteNombre(rs.getString("paciente_nombre"));
                cita.setIdConsultorio(rs.getInt("id_consultorio"));
                cita.setNumeroConsultorio(rs.getInt("consultorio_numero"));
                cita.setDoctor(rs.getString("doctor_nombre"));
                cita.setDoctorNombre(rs.getString("doctor_nombre"));
                cita.setFecha(rs.getDate("fecha"));
                cita.setHora(rs.getTime("hora"));
                lista.add(cita);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(Cita cita) {
        String sql = "{CALL sp_actualizar_cita(?, ?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, cita.getId());
            cs.setInt(2, cita.getIdPaciente());
            cs.setInt(3, cita.getIdConsultorio());
            cs.setString(4, cita.getDoctor());
            cs.setDate(5, cita.getFecha());
            cs.setTime(6, cita.getHora());
            cs.registerOutParameter(7, Types.VARCHAR);
            cs.execute();

            String mensaje = cs.getString(7);
            return mensaje != null && !mensaje.startsWith("Error");

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_eliminar_cita(?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, id);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();

            String mensaje = cs.getString(2);
            return mensaje != null && !mensaje.startsWith("Error");

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
