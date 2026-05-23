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

@WebServlet(name = "ConsultorioServlet", urlPatterns = {"/consultorio"})
public class ConsultorioServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String especialidadParam = request.getParameter("especialidad");
        String numeroParam       = request.getParameter("numero");

        if (especialidadParam == null || numeroParam == null ||
            especialidadParam.trim().isEmpty() || numeroParam.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Faltan parámetros de especialidad o número.");
            }
            return;
        }

        int idEspecialidad;
        int numero;
        try {
            // BUG CORREGIDO: ambos campos son INT en la BD — parsear antes de setInt()
            idEspecialidad = Integer.parseInt(especialidadParam.trim());
            numero         = Integer.parseInt(numeroParam.trim());
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Especialidad y número deben ser IDs numéricos.");
            }
            return;
        }

        String sql = "INSERT INTO consultorio(numero, id_especialidad) VALUES (?, ?)";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            // BUG CORREGIDO: usar setInt(), no setString(), para columna INT
            ps.setInt(1, numero);
            ps.setInt(2, idEspecialidad);
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
