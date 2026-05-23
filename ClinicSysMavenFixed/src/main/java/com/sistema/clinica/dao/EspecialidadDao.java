package com.sistema.clinica.dao;

import com.sistema.clinica.model.Especialidad;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Especialidad usando Stored Procedures
 */
public class EspecialidadDao implements IDao<Especialidad> {

    @Override
    public int create(Especialidad especialidad) {
        String sql = "{CALL sp_registrar_especialidad(?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, especialidad.getNombre());
            cs.registerOutParameter(2, Types.INTEGER);
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.execute();

            int id = cs.getInt(2);
            String mensaje = cs.getString(3);
            
            if (id == -1) {
                // Verificar si es duplicado
                if (mensaje != null && mensaje.contains("duplic")) {
                    return -2; // Código especial para duplicado
                }
                return -1;
            }
            return id;

        } catch (SQLException e) {
            // Manejar error de duplicado
            if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                return -2;
            }
            e.printStackTrace();
            return -1;
        }
    }

    @Override
    public Especialidad readById(int id) {
        String sql = "SELECT id, nombre FROM especialidad WHERE id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new Especialidad(rs.getInt("id"), rs.getString("nombre"));
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Especialidad> readAll() {
        return readAllOrdered("nombre_asc");
    }

    public List<Especialidad> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "nombre_desc":
                orderBy = "ORDER BY nombre DESC";
                break;
            default:
                orderBy = "ORDER BY nombre ASC";
        }

        String sql = "SELECT id, nombre FROM especialidad " + orderBy;
        List<Especialidad> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                lista.add(new Especialidad(rs.getInt("id"), rs.getString("nombre")));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(Especialidad especialidad) {
        String sql = "{CALL sp_actualizar_especialidad(?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, especialidad.getId());
            cs.setString(2, especialidad.getNombre());
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.execute();

            String mensaje = cs.getString(3);
            return mensaje != null && !mensaje.startsWith("Error");

        } catch (SQLException e) {
            if (e.getMessage() != null && e.getMessage().contains("Duplicate entry")) {
                return false;
            }
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_eliminar_especialidad(?, ?)}";
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
