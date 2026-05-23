package com.sistema.clinica.dao;

import java.util.List;

/**
 * Interfaz genérica para operaciones CRUD
 * @param <T> Tipo de entidad
 */
public interface IDao<T> {
    int create(T entity);           // Retorna el ID generado o -1 si hay error
    T readById(int id);             // Lee una entidad por su ID
    List<T> readAll();              // Lee todas las entidades
    boolean update(T entity);       // Actualiza una entidad
    boolean delete(int id);         // Elimina una entidad por ID
}
