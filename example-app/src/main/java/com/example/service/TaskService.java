package com.example.service;

import com.example.dto.TaskRequest;
import com.example.dto.TaskResponse;
import java.util.List;

/**
 * Contract for Task CRUD operations.
 */
public interface TaskService {

    TaskResponse create(TaskRequest request);

    List<TaskResponse> findAll();

    TaskResponse findById(Long id);

    TaskResponse update(Long id, TaskRequest request);

    void delete(Long id);
}
