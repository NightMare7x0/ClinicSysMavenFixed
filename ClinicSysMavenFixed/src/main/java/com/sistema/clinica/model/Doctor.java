package com.sistema.clinica.model;

/**
 * Modelo para la entidad Doctor
 */
public class Doctor {
    private int id;
    private String nombre;
    private String dni;
    private String telefono;
    private int idEspecialidad;
    private String especialidadNombre;

    public Doctor() {}

    public Doctor(int id, String nombre, String dni, String telefono, int idEspecialidad, String especialidadNombre) {
        this.id = id;
        this.nombre = nombre;
        this.dni = dni;
        this.telefono = telefono;
        this.idEspecialidad = idEspecialidad;
        this.especialidadNombre = especialidadNombre;
    }

    public Doctor(String nombre, String dni, String telefono, int idEspecialidad) {
        this.nombre = nombre;
        this.dni = dni;
        this.telefono = telefono;
        this.idEspecialidad = idEspecialidad;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public int getIdEspecialidad() { return idEspecialidad; }
    public void setIdEspecialidad(int idEspecialidad) { this.idEspecialidad = idEspecialidad; }
    public String getEspecialidadNombre() { return especialidadNombre; }
    public void setEspecialidadNombre(String especialidadNombre) { this.especialidadNombre = especialidadNombre; }
}
