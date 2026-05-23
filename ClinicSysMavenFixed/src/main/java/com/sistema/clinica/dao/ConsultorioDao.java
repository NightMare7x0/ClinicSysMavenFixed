package com.sistema.clinica.dao;

import com.sistema.clinica.model.Consultorio;
import com.sistema.clinica.ConexionBD;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para la entidad Consultorio usando Stored Procedures
 */
public class ConsultorioDao implements IDao<Consultorio> {

    @Override
    public int create(Consultorio consultorio) {
        String sql = "{CALL sp_crear_consultorio(?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, consultorio.getNumero());
            cs.setInt(2, consultorio.getIdEspecialidad());
            cs.registerOutParameter(3, Types.INTEGER);
            cs.registerOutParameter(4, Types.VARCHAR);
            cs.execute();

            int id = cs.getInt(3);
            String mensaje = cs.getString(4);
            
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
    public Consultorio readById(int id) {
        String sql = "SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre " +
                     "FROM consultorio c LEFT JOIN especialidad e ON c.id_especialidad = e.id WHERE c.id = ?";
        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Consultorio consultorio = new Consultorio();
                consultorio.setId(rs.getInt("id"));
                consultorio.setNumero(rs.getInt("numero"));
                consultorio.setIdEspecialidad(rs.getInt("id_especialidad"));
                consultorio.setEspecialidadNombre(rs.getString("especialidad_nombre"));
                return consultorio;
            }
            return null;

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public List<Consultorio> readAll() {
        return readAllOrdered("numero_asc");
    }

    public List<Consultorio> readAllOrdered(String orderType) {
        String orderBy = "";
        switch (orderType) {
            case "numero_desc":
                orderBy = "ORDER BY c.numero DESC";
                break;
            case "especialidad":
                orderBy = "ORDER BY e.nombre ASC";
                break;
            default:
                orderBy = "ORDER BY c.numero ASC";
        }

        String sql = "SELECT c.id, c.numero, c.id_especialidad, e.nombre as especialidad_nombre " +
                     "FROM consultorio c LEFT JOIN especialidad e ON c.id_especialidad = e.id " + orderBy;
        List<Consultorio> lista = new ArrayList<>();

        try (Connection con = ConexionBD.obtenerConexion();
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Consultorio consultorio = new Consultorio();
                consultorio.setId(rs.getInt("id"));
                consultorio.setNumero(rs.getInt("numero"));
                consultorio.setIdEspecialidad(rs.getInt("id_especialidad"));
                consultorio.setEspecialidadNombre(rs.getString("especialidad_nombre"));
                lista.add(consultorio);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    @Override
    public boolean update(Consultorio consultorio) {
        String sql = "{CALL sp_actualizar_consultorio(?, ?, ?, ?)}";
        try (Connection con = ConexionBD.obtenerConexion();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, consultorio.getId());
            cs.setInt(2, consultorio.getNumero());
            cs.setInt(3, consultorio.getIdEspecialidad());
            cs.registerOutParameter(4, Types.VARCHAR);
            cs.execute();

            String mensaje = cs.getString(4);
            return mensaje != null && !mensaje.startsWith("Error");

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "{CALL sp_eliminar_consultorio(?, ?)}";
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
