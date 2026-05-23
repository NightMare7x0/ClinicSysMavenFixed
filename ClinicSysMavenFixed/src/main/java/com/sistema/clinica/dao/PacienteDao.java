package com.sistema.clinica.dao;

import com.sistema.clinica.model.Paciente;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Paciente usando Stored Procedures
 */
public class PacienteDao implements IDao<Paciente> {

    @Override
    public int create(Paciente paciente) {
        String sql = "{CALL sp_registrar_paciente(?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, paciente.getNombre());
            cs.setString(2, paciente.getDni());
            cs.setString(3, paciente.getContacto());
            cs.registerOutParameter(4, Types.INTEGER);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.execute();

            int id = cs.getInt(4);
            if (id == -1) return -1;
            return id;

        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                return -2;
            }
            e.printStackTrace();
            return -1;
        }
    }

    @Override
    public Paciente readById(int id) {
        String sql = "SELECT id, nombre, dni, contacto FROM paciente WHERE id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new Paciente(rs.getInt("id"), rs.getString("nombre"), 
                                   rs.getString("dni"), rs.getString("contacto"));
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Paciente> readAll() {
        return readAllOrdered("nombre_asc");
    }

    public List<Paciente> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "nombre_desc":
                orderBy = "ORDER BY nombre DESC";
                break;
            case "telefono":
            case "contacto":
                orderBy = "ORDER BY contacto ASC";
                break;
            case "dni":
                orderBy = "ORDER BY dni ASC";
                break;
            default:
                orderBy = "ORDER BY nombre ASC";
        }

        String sql = "SELECT id, nombre, dni, contacto FROM paciente " + orderBy;
        List<Paciente> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(new Paciente(rs.getInt("id"), rs.getString("nombre"), 
                                      rs.getString("dni"), rs.getString("contacto")));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(Paciente paciente) {
        String sql = "{CALL sp_actualizar_paciente(?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, paciente.getId());
            cs.setString(2, paciente.getNombre());
            cs.setString(3, paciente.getDni());
            cs.setString(4, paciente.getContacto());
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.execute();

            String mensaje = cs.getString(5);
            return mensaje != null && !mensaje.startsWith("Error");

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_eliminar_paciente(?, ?)}";
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
