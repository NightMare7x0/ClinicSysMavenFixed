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

@WebServlet(name = "HistoriaServlet", urlPatterns = {"/historia"})
public class HistoriaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String pacienteParam = request.getParameter("paciente");
        String sintomas      = request.getParameter("sintomas");
        String tratamiento   = request.getParameter("tratamiento");

        if (pacienteParam == null || pacienteParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Se requiere el ID del paciente.");
            }
            return;
        }

        int idPaciente;
        try {
            idPaciente = Integer.parseInt(pacienteParam.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: ID de paciente debe ser numérico.");
            }
            return;
        }

        sintomas    = (sintomas    != null) ? sintomas.trim()    : null;
        tratamiento = (tratamiento != null) ? tratamiento.trim() : null;

        String sql = "INSERT INTO historia(id_paciente, sintomas, tratamiento) VALUES (?, ?, ?)";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, idPaciente);
            ps.setString(2, sintomas);
            ps.setString(3, tratamiento);
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
