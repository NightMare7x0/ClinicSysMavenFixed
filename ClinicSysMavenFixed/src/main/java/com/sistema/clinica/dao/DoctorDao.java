package com.sistema.clinica.dao;

import com.sistema.clinica.model.Doctor;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Doctor usando Stored Procedures
 */
public class DoctorDao implements IDao<Doctor> {

    @Override
    public int create(Doctor doctor) {
        String sql = "{CALL sp_registrar_doctor(?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, doctor.getNombre());
            cs.setString(2, doctor.getDni());
            cs.setString(3, doctor.getTelefono());
            cs.setInt(4, doctor.getIdEspecialidad());
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
            if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                return -2; // Código especial para duplicado
            }
            e.printStackTrace();
            return -1;
        }
    }

    @Override
    public Doctor readById(int id) {
        String sql = "SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre " +
                     "FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id WHERE d.id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Doctor doctor = new Doctor();
                doctor.setId(rs.getInt("id"));
                doctor.setNombre(rs.getString("nombre"));
                doctor.setDni(rs.getString("dni"));
                doctor.setTelefono(rs.getString("telefono"));
                doctor.setIdEspecialidad(rs.getInt("id_especialidad"));
                doctor.setEspecialidadNombre(rs.getString("especialidad_nombre"));
                return doctor;
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Doctor> readAll() {
        return readAllOrdered("nombre_asc");
    }

    public List<Doctor> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "nombre_desc":
                orderBy = "ORDER BY d.nombre DESC";
                break;
            case "telefono":
                orderBy = "ORDER BY d.telefono ASC";
                break;
            case "dni":
                orderBy = "ORDER BY d.dni ASC";
                break;
            default:
                orderBy = "ORDER BY d.nombre ASC";
        }

        String sql = "SELECT d.id, d.nombre, d.dni, d.telefono, d.id_especialidad, e.nombre as especialidad_nombre " +
                     "FROM doctor d LEFT JOIN especialidad e ON d.id_especialidad = e.id " + orderBy;
        List<Doctor> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Doctor doctor = new Doctor();
                doctor.setId(rs.getInt("id"));
                doctor.setNombre(rs.getString("nombre"));
                doctor.setDni(rs.getString("dni"));
                doctor.setTelefono(rs.getString("telefono"));
                doctor.setIdEspecialidad(rs.getInt("id_especialidad"));
                doctor.setEspecialidadNombre(rs.getString("especialidad_nombre"));
                lista.add(doctor);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(Doctor doctor) {
        String sql = "{CALL sp_actualizar_doctor(?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, doctor.getId());
            cs.setString(2, doctor.getNombre());
            cs.setString(3, doctor.getDni());
            cs.setString(4, doctor.getTelefono());
            cs.setInt(5, doctor.getIdEspecialidad());
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
        String sql = "{CALL sp_eliminar_doctor(?, ?)}";
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
