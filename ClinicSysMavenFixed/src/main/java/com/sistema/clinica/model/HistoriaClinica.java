package com.sistema.clinica.model;

import java.sql.Timestamp;

/**
 * Modelo para la entidad Historia Clinica
 */
public class HistoriaClinica {
    private int id;
    private int idPaciente;
    private String pacienteNombre;
    private String sintomas;
    private String tratamiento;
    private Timestamp fechaReg;
    private String doctorNombre;  // Doctor asignado a la cita/historia

    public HistoriaClinica() {}

    public HistoriaClinica(int id, int idPaciente, String pacienteNombre, String sintomas, 
                           String tratamiento, Timestamp fechaReg, String doctorNombre) {
        this.id = id;
        this.idPaciente = idPaciente;
        this.pacienteNombre = pacienteNombre;
        this.sintomas = sintomas;
        this.tratamiento = tratamiento;
        this.fechaReg = fechaReg;
        this.doctorNombre = doctorNombre;
    }

    public HistoriaClinica(int idPaciente, String sintomas, String tratamiento) {
        this.idPaciente = idPaciente;
        this.sintomas = sintomas;
        this.tratamiento = tratamiento;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getIdPaciente() { return idPaciente; }
    public void setIdPaciente(int idPaciente) { this.idPaciente = idPaciente; }
    public String getPacienteNombre() { return pacienteNombre; }
    public void setPacienteNombre(String pacienteNombre) { this.pacienteNombre = pacienteNombre; }
    public String getSintomas() { return sintomas; }
    public void setSintomas(String sintomas) { this.sintomas = sintomas; }
    public String getTratamiento() { return tratamiento; }
    public void setTratamiento(String tratamiento) { this.tratamiento = tratamiento; }
    public Timestamp getFechaReg() { return fechaReg; }
    public void setFechaReg(Timestamp fechaReg) { this.fechaReg = fechaReg; }
    public String getDoctorNombre() { return doctorNombre; }
    public void setDoctorNombre(String doctorNombre) { this.doctorNombre = doctorNombre; }
}
