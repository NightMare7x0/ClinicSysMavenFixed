package com.sistema.clinica.dao;

import com.sistema.clinica.model.HistoriaClinica;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Historia Clinica usando Stored Procedures
 */
public class HistoriaClinicaDao implements IDao<HistoriaClinica> {

    @Override
    public int create(HistoriaClinica historia) {
        String sql = "{CALL sp_crear_historia(?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, historia.getIdPaciente());
            cs.setString(2, historia.getDoctorNombre() != null ? historia.getDoctorNombre() : "");
            cs.setString(3, historia.getSintomas());
            cs.setString(4, historia.getTratamiento());
            cs.registerOutParameter(5, Types.INTEGER);
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.execute();

            int id = cs.getInt(5);
            String mensaje = cs.getString(6);
            
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
    public HistoriaClinica readById(int id) {
        String sql = "SELECT h.id, h.id_paciente, p.nombre as paciente_nombre, h.id_doctor, d.nombre as doctor_nombre, " +
                     "h.sintomas, h.tratamiento, h.fecha_reg " +
                     "FROM historia_clinica h " +
                     "LEFT JOIN paciente p ON h.id_paciente = p.id " +
                     "LEFT JOIN doctor d ON h.id_doctor = d.id " +
                     "WHERE h.id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HistoriaClinica historia = new HistoriaClinica();
                historia.setId(rs.getInt("id"));
                historia.setIdPaciente(rs.getInt("id_paciente"));
                historia.setPacienteNombre(rs.getString("paciente_nombre"));
                historia.setDoctorNombre(rs.getString("doctor_nombre"));
                historia.setSintomas(rs.getString("sintomas"));
                historia.setTratamiento(rs.getString("tratamiento"));
                historia.setFechaReg(rs.getTimestamp("fecha_reg"));
                return historia;
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<HistoriaClinica> readAll() {
        return readAllOrdered("fecha_desc");
    }

    public List<HistoriaClinica> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "fecha_asc":
                orderBy = "ORDER BY h.fecha_reg ASC";
                break;
            case "paciente":
                orderBy = "ORDER BY p.nombre ASC";
                break;
            case "doctor":
                orderBy = "ORDER BY d.nombre ASC";
                break;
            default:
                orderBy = "ORDER BY h.fecha_reg DESC";
        }

        String sql = "SELECT h.id, h.id_paciente, p.nombre as paciente_nombre, h.id_doctor, d.nombre as doctor_nombre, " +
                     "h.sintomas, h.tratamiento, h.fecha_reg " +
                     "FROM historia_clinica h " +
                     "LEFT JOIN paciente p ON h.id_paciente = p.id " +
                     "LEFT JOIN doctor d ON h.id_doctor = d.id " + orderBy;
        List<HistoriaClinica> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                HistoriaClinica historia = new HistoriaClinica();
                historia.setId(rs.getInt("id"));
                historia.setIdPaciente(rs.getInt("id_paciente"));
                historia.setPacienteNombre(rs.getString("paciente_nombre"));
                historia.setDoctorNombre(rs.getString("doctor_nombre"));
                historia.setSintomas(rs.getString("sintomas"));
                historia.setTratamiento(rs.getString("tratamiento"));
                historia.setFechaReg(rs.getTimestamp("fecha_reg"));
                lista.add(historia);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(HistoriaClinica historia) {
        String sql = "{CALL sp_actualizar_historia(?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, historia.getId());
            cs.setInt(2, historia.getIdPaciente());
            cs.setString(3, historia.getDoctorNombre() != null ? historia.getDoctorNombre() : "");
            cs.setString(4, historia.getSintomas());
            cs.setString(5, historia.getTratamiento());
            cs.registerOutParameter(6, Types.VARCHAR);
            cs.execute();

            String mensaje = cs.getString(6);
            return mensaje != null && !mensaje.startsWith("Error");

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_eliminar_historia(?, ?)}";
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
