package com.sistema.clinica.model;

/**
 * Modelo para la entidad Paciente
 */
public class Paciente {
    private int id;
    private String nombre;
    private String dni;
    private String contacto;

    public Paciente() {}

    public Paciente(int id, String nombre, String dni, String contacto) {
        this.id = id;
        this.nombre = nombre;
        this.dni = dni;
        this.contacto = contacto;
    }

    public Paciente(String nombre, String dni, String contacto) {
        this.nombre = nombre;
        this.dni = dni;
        this.contacto = contacto;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    public String getContacto() { return contacto; }
    public void setContacto(String contacto) { this.contacto = contacto; }
}
