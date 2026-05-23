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

@WebServlet(name = "CitaServlet", urlPatterns = {"/cita"})
public class CitaServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String pacienteParam    = request.getParameter("paciente");
        String fecha            = request.getParameter("fecha");
        String hora             = request.getParameter("hora");
        String doctor           = request.getParameter("doctor");
        String consultorioParam = request.getParameter("consultorio");

        if (pacienteParam == null || fecha == null || hora == null ||
            pacienteParam.trim().isEmpty() || fecha.trim().isEmpty() || hora.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Paciente, fecha y hora son obligatorios.");
            }
            return;
        }

        int idPaciente;
        int idConsultorio = 0;
        try {
            idPaciente = Integer.parseInt(pacienteParam.trim());
            if (consultorioParam != null && !consultorioParam.trim().isEmpty()) {
                idConsultorio = Integer.parseInt(consultorioParam.trim());
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: IDs deben ser numéricos.");
            }
            return;
        }

        doctor = (doctor != null && !doctor.trim().isEmpty()) ? doctor.trim() : "No asignado";

        String sql = "INSERT INTO cita(id_paciente, id_consultorio, doctor, fecha, hora) VALUES (?, ?, ?, ?, ?)";

        try (Connection con = ConexionBD.obtenerConexion();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, idPaciente);
            ps.setInt(2, idConsultorio);
            ps.setString(3, doctor);
            ps.setString(4, fecha);
            ps.setString(5, hora);
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
