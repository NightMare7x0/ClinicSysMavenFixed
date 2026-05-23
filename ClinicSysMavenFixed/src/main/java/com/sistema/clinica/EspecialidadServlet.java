package com.sistema.clinica;

import com.sistema.clinica.dao.EspecialidadDao;
import com.sistema.clinica.model.Especialidad;
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

@WebServlet(name = "EspecialidadServlet", urlPatterns = {"/especialidad"})
public class EspecialidadServlet extends HttpServlet {

    private EspecialidadDao dao;

    @Override
    public void init() throws ServletException {
        dao = new EspecialidadDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "*");

        String especialidad = request.getParameter("especialidad");

        if (especialidad == null || especialidad.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: El nombre de especialidad es obligatorio.");
            }
            return;
        }

        especialidad = especialidad.trim();
        Especialidad esp = new Especialidad(especialidad);
        int resultado = dao.create(esp);

        try (PrintWriter out = response.getWriter()) {
            if (resultado == -2) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                out.print("Error: Duplicate entry - Esta especialidad ya existe");
            } else if (resultado == -1) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("Error: No se pudo registrar la especialidad");
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
            List<Especialidad> lista;
            if (order != null) {
                lista = dao.readAllOrdered(order);
            } else {
                lista = dao.readAll();
            }

            JSONArray jsonArray = new JSONArray();
            for (Especialidad esp : lista) {
                JSONObject json = new JSONObject();
                json.put("id", esp.getId());
                json.put("nombre", esp.getNombre());
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
                    Especialidad esp = dao.readById(id);
                    if (esp != null) {
                        JSONObject json = new JSONObject();
                        json.put("id", esp.getId());
                        json.put("nombre", esp.getNombre());
                        try (PrintWriter out = response.getWriter()) {
                            out.print(json.toString());
                        }
                    } else {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        try (PrintWriter out = response.getWriter()) {
                            out.print("{\"error\": \"Especialidad no encontrada\"}");
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

        if (idParam == null || nombre == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            try (PrintWriter out = response.getWriter()) {
                out.print("Error: Se requiere ID y nombre");
            }
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            Especialidad esp = new Especialidad(id, nombre);
            boolean actualizado = dao.update(esp);

            try (PrintWriter out = response.getWriter()) {
                if (actualizado) {
                    out.print("Especialidad actualizada correctamente");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("Error: No se pudo actualizar la especialidad (puede haber duplicados)");
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
                    out.print("Especialidad eliminada correctamente");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("Error: No se pudo eliminar la especialidad (tiene registros relacionados)");
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
