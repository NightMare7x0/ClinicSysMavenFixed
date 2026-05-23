package com.sistema.clinica.model;

/**
 * Modelo para la entidad Consultorio
 */
public class Consultorio {
    private int id;
    private int numero;
    private int idEspecialidad;
    private String especialidadNombre;

    public Consultorio() {}

    public Consultorio(int id, int numero, int idEspecialidad, String especialidadNombre) {
        this.id = id;
        this.numero = numero;
        this.idEspecialidad = idEspecialidad;
        this.especialidadNombre = especialidadNombre;
    }

    public Consultorio(int numero, int idEspecialidad) {
        this.numero = numero;
        this.idEspecialidad = idEspecialidad;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getNumero() { return numero; }
    public void setNumero(int numero) { this.numero = numero; }
    public int getIdEspecialidad() { return idEspecialidad; }
    public void setIdEspecialidad(int idEspecialidad) { this.idEspecialidad = idEspecialidad; }
    public String getEspecialidadNombre() { return especialidadNombre; }
    public void setEspecialidadNombre(String especialidadNombre) { this.especialidadNombre = especialidadNombre; }
}
