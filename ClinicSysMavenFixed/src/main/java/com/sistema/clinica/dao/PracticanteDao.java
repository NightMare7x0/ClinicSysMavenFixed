package com.sistema.clinica.dao;

import com.sistema.clinica.model.Pacticante;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Practicante usando Stored Procedures
 */
public class PracticanteDao implements IDao<Practicante> {

    @Override
    public int create(Practicante practicante) {
        String sql = "{CALL sp_crear_practicante(?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, practicante.getNombre());
            cs.setString(2, practicante.getDni());
            cs.setString(3, practicante.getSupervisor());
            cs.setString(4, practicante.getEspecialidad());
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
                return -2;
            }
            e.printStackTrace();
            return -1;
        }
    }

    @Override
    public Practicante readById(int id) {
        String sql = "SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, d.nombre as supervisor_nombre, pr.especialidad " +
                     "FROM practicante pr " +
                     "LEFT JOIN doctor d ON pr.id_supervisor = d.id " +
                     "WHERE pr.id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Practicante practicante = new Practicante();
                practicante.setId(rs.getInt("id"));
                practicante.setNombre(rs.getString("nombre"));
                practicante.setDni(rs.getString("dni"));
                practicante.setSupervisor(rs.getString("supervisor_nombre"));
                practicante.setEspecialidad(rs.getString("especialidad"));
                return practicante;
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Practicante> readAll() {
        return readAllOrdered("nombre_asc");
    }

    public List<Practicante> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "nombre_desc":
                orderBy = "ORDER BY pr.nombre DESC";
                break;
            case "dni":
                orderBy = "ORDER BY pr.dni ASC";
                break;
            case "supervisor":
                orderBy = "ORDER BY d.nombre ASC";
                break;
            default:
                orderBy = "ORDER BY pr.nombre ASC";
        }

        String sql = "SELECT pr.id, pr.nombre, pr.dni, pr.id_supervisor, d.nombre as supervisor_nombre, pr.especialidad " +
                     "FROM practicante pr " +
                     "LEFT JOIN doctor d ON pr.id_supervisor = d.id " + orderBy;
        List<Practicante> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Practicante practicante = new Practicante();
                practicante.setId(rs.getInt("id"));
                practicante.setNombre(rs.getString("nombre"));
                practicante.setDni(rs.getString("dni"));
                practicante.setSupervisor(rs.getString("supervisor_nombre"));
                practicante.setEspecialidad(rs.getString("especialidad"));
                lista.add(practicante);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(Practicante practicante) {
        String sql = "{CALL sp_actualizar_practicante(?, ?, ?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, practicante.getId());
            cs.setString(2, practicante.getNombre());
            cs.setString(3, practicante.getDni());
            cs.setString(4, practicante.getSupervisor());
            cs.setString(5, practicante.getEspecialidad());
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
        String sql = "{CALL sp_eliminar_practicante(?, ?)}";
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
