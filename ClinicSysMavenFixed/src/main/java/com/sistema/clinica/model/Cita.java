package com.sistema.clinica.model;

import java.sql.Date;
import java.sql.Time;

/**
 * Modelo para la entidad Cita
 */
public class Cita {
    private int id;
    private int idPaciente;
    private String pacienteNombre;
    private int idConsultorio;
    private int numeroConsultorio;
    private String doctor;  // Ahora será ID del doctor
    private String doctorNombre;
    private Date fecha;
    private Time hora;

    public Cita() {}

    public Cita(int id, int idPaciente, String pacienteNombre, int idConsultorio, int numeroConsultorio, 
                String doctor, String doctorNombre, Date fecha, Time hora) {
        this.id = id;
        this.idPaciente = idPaciente;
        this.pacienteNombre = pacienteNombre;
        this.idConsultorio = idConsultorio;
        this.numeroConsultorio = numeroConsultorio;
        this.doctor = doctor;
        this.doctorNombre = doctorNombre;
        this.fecha = fecha;
        this.hora = hora;
    }

    public Cita(int idPaciente, int idConsultorio, String doctor, Date fecha, Time hora) {
        this.idPaciente = idPaciente;
        this.idConsultorio = idConsultorio;
        this.doctor = doctor;
        this.fecha = fecha;
        this.hora = hora;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getIdPaciente() { return idPaciente; }
    public void setIdPaciente(int idPaciente) { this.idPaciente = idPaciente; }
    public String getPacienteNombre() { return pacienteNombre; }
    public void setPacienteNombre(String pacienteNombre) { this.pacienteNombre = pacienteNombre; }
    public int getIdConsultorio() { return idConsultorio; }
    public void setIdConsultorio(int idConsultorio) { this.idConsultorio = idConsultorio; }
    public int getNumeroConsultorio() { return numeroConsultorio; }
    public void setNumeroConsultorio(int numeroConsultorio) { this.numeroConsultorio = numeroConsultorio; }
    public String getDoctor() { return doctor; }
    public void setDoctor(String doctor) { this.doctor = doctor; }
    public String getDoctorNombre() { return doctorNombre; }
    public void setDoctorNombre(String doctorNombre) { this.doctorNombre = doctorNombre; }
    public Date getFecha() { return fecha; }
    public void setFecha(Date fecha) { this.fecha = fecha; }
    public Time getHora() { return hora; }
    public void setHora(Time hora) { this.hora = hora; }
}
