package com.sistema.clinica;

import com.sistema.clinica.dao.DoctorDao;
import com.sistema.clinica.model.Doctor;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "DoctorServlet", urlPatterns = {"/doctor"})
public class DoctorServlet extends HttpServlet {

    private DoctorDao dao;

    @Override
    public void init() throws ServletException {
        dao = new DoctorDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String nombre = request.getParameter("nombre");
        String dni = request.getParameter("dni");
        String telefono = request.getParameter("telefono");
        String idEspecialidadParam = request.getParameter("id_especialidad");

        if (nombre == null || dni == null || idEspecialidadParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Nombre, DNI y especialidad son obligatorios.");
            }
            return;
        }

        int idEspecialidad;
        try {
            idEspecialidad = Integer.parseInt(idEspecialidadParam);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: ID de especialidad inválido.");
            }
            return;
        }

        Doctor doctor = new Doctor(nombre, dni, telefono != null ? telefono : "", idEspecialidad);
        int resultado = dao.create(doctor);

        try (PrintWriter out = response.getWriter()) {
            if (resultado == -2) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("DUPLICADO");
            } else if (resultado == -1) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("ERROR");
            } else {
                out.print("ID:" + resultado);
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String action = request.getParameter("action");
        String order = request.getParameter("order");

        if ("list".equals(action)) {
            List<Doctor> lista;
            if (order != null) {
                lista = dao.readAllOrdered(order);
            } else {
                lista = dao.readAll();
            }

            JSONArray jsonArray = new JSONArray();
            for (Doctor doc : lista) {
                JSONObject json = new JSONObject();
                json.put("id", doc.getId());
                json.put("nombre", doc.getNombre());
                json.put("dni", doc.getDni());
                json.put("telefono", doc.getTelefono());
                json.put("id_especialidad", doc.getIdEspecialidad());
                json.put("especialidad_nombre", doc.getEspecialidadNombre() != null ? doc.getEspecialidadNombre() : "");
                jsonArray.put(json);
            }

            try (PrintWriter out = response.getWriter()) {
                out.print(jsonArray.toString());
            }
        } else if ("getById".equals(action)) {
            String idParam = request.getParameter("id");
            if (idParam != null) {
                try {
                    int id = Integer.parseInt(idParam);
                    Doctor doc = dao.readById(id);
                    if (doc != null) {
                        JSONObject json = new JSONObject();
                        json.put("id", doc.getId());
                        json.put("nombre", doc.getNombre());
                        json.put("dni", doc.getDni());
                        json.put("telefono", doc.getTelefono());
                        json.put("id_especialidad", doc.getIdEspecialidad());
                        json.put("especialidad_nombre", doc.getEspecialidadNombre() != null ? doc.getEspecialidadNombre() : "");
                        try (PrintWriter out = response.getWriter()) {
                            out.print(json.toString());
                        }
                    } else {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        try (PrintWriter out = response.getWriter()) {
                            out.print("{\"error\": \"Doctor no encontrado\"}");
                        }
                    }
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    try (PrintWriter out = response.getWriter()) {
                        out.print("{\"error\": \"ID inválido\"}");
                    }
                }
            }
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String idParam = request.getParameter("id");
        String nombre = request.getParameter("nombre");
        String dni = request.getParameter("dni");
        String telefono = request.getParameter("telefono");
        String idEspecialidadParam = request.getParameter("id_especialidad");

        if (idParam == null || nombre == null || dni == null || idEspecialidadParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Se requiere ID, nombre, DNI y especialidad");
            }
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            int idEspecialidad = Integer.parseInt(idEspecialidadParam);
            Doctor doctor = new Doctor(id, nombre, dni, telefono != null ? telefono : "", idEspecialidad, "");
            boolean actualizado = dao.update(doctor);

            try (PrintWriter out = response.getWriter()) {
                if (actualizado) {
                    out.print("EXITO");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("DUPLICADO");
                }
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: ID inválido");
            }
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String idParam = request.getParameter("id");

        if (idParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Se requiere ID");
            }
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            boolean eliminado = dao.delete(id);

            try (PrintWriter out = response.getWriter()) {
                if (eliminado) {
                    out.print("EXITO");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("ERROR_REFERENCIAS");
                }
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: ID inválido");
            }
        }
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setStatus(HttpServletResponse.SC_OK);
    }
}
