package com.sistema.clinica.model;

/**
 * Modelo para la entidad Practicante
 */
public class Practicante {
    private int id;
    private String nombre;
    private String dni;
    private String supervisor;  // Ahora será el ID del doctor supervisor
    private String especialidad;

    public Practicante() {}

    public Practicante(int id, String nombre, String dni, String supervisor, String especialidad) {
        this.id = id;
        this.nombre = nombre;
        this.dni = dni;
        this.supervisor = supervisor;
        this.especialidad = especialidad;
    }

    public Practicante(String nombre, String dni, String supervisor, String especialidad) {
        this.nombre = nombre;
        this.dni = dni;
        this.supervisor = supervisor;
        this.especialidad = especialidad;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    public String getSupervisor() { return supervisor; }
    public void setSupervisor(String supervisor) { this.supervisor = supervisor; }
    public String getEspecialidad() { return especialidad; }
    public void setEspecialidad(String especialidad) { this.especialidad = especialidad; }
}
