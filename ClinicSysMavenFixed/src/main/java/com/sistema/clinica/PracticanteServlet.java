package com.sistema.clinica;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "PracticanteServlet", urlPatterns = {"/practicante"})
public class PracticanteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String nombre      = request.getParameter("nombre");
        String dni         = request.getParameter("dni");
        String supervisor  = request.getParameter("supervisor");
        String especialidad = request.getParameter("especialidad");

        if (nombre == null || dni == null ||
            nombre.trim().isEmpty() || dni.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Nombre y DNI son obligatorios.");
            }
            return;
        }

        nombre      = nombre.trim();
        dni         = dni.trim();
        supervisor  = (supervisor  != null && !supervisor.trim().isEmpty())  ? supervisor.trim()  : "No asignado";
        especialidad = (especialidad != null && !especialidad.trim().isEmpty()) ? especialidad.trim() : "General";

        String sql = "INSERT INTO practicante(nombre, dni, supervisor, especialidad) VALUES (?, ?, ?, ?)";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, nombre);
            ps.setString(2, dni);
            ps.setString(3, supervisor);
            ps.setString(4, especialidad);
            ps.executeUpdate();

            int idGenerado = -1;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) idGenerado = rs.getInt(1);
            }

            try (PrintWriter out = response.getWriter()) {
                out.print("ID:" + idGenerado);
            }

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: " + e.getMessage());
            }
        }
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
}
