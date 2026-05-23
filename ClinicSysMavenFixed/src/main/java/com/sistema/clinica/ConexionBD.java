package com.sistema.clinica;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Clase de utilidad para obtener conexiones a la base de datos MySQL.
 * Configuración: localhost:3306 / clinica_db / root
 */
public class ConexionBD {

    private static final String URL =
        "jdbc:mysql://localhost:3306/clinica_db"
        + "?useSSL=false"
        + "&allowPublicKeyRetrieval=true"
        + "&serverTimezone=UTC"
        + "&characterEncoding=UTF-8"
        + "&useUnicode=true";

    private static final String USER     = "root";
    private static final String PASSWORD = "anzu0172*";

    // Clase utilitaria — no instanciar
    private ConexionBD() {}

    /**
     * Devuelve una conexión abierta a clinica_db.
     * El llamador es responsable de cerrarla (try-with-resources).
     */
    public static Connection obtenerConexion() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "Error de configuración: Driver MySQL no encontrado. "
                + "Verifique la dependencia mysql-connector-j en pom.xml", e);
        }
    }

    /**
     * Comprueba si la base de datos responde correctamente.
     * Útil para diagnóstico; no se usa en producción.
     */
    public static boolean verificarConexion() {
        try (Connection test = obtenerConexion()) {
            return test != null && test.isValid(5);
        } catch (SQLException e) {
            System.err.println("Verificación de conexión fallida: " + e.getMessage());
            return false;
        }
    }
}
