package com.example.service;

import com.example.dto.TaskRequest;
import com.example.dto.TaskResponse;
import com.example.model.Task;
import com.example.repository.TaskRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

/**
 * Default implementation of {@link TaskService}.
 */
@Service
public class TaskServiceImpl implements TaskService {

    private final TaskRepository taskRepository;

    public TaskServiceImpl(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    @Override
    public TaskResponse create(TaskRequest request) {
        Task task = new Task(request.title(), request.description());
        return toResponse(taskRepository.save(task));
    }

    @Override
    public List<TaskResponse> findAll() {
        return taskRepository.findAll().stream()
            .map(this::toResponse)
            .toList();
    }

    @Override
    public TaskResponse findById(Long id) {
        return toResponse(requireTask(id));
    }

    @Override
    public TaskResponse update(Long id, TaskRequest request) {
        Task task = requireTask(id);
        task.setTitle(request.title());
        task.setDescription(request.description());
        return toResponse(taskRepository.save(task));
    }

    @Override
    public void delete(Long id) {
        requireTask(id);
        taskRepository.deleteById(id);
    }

    private Task requireTask(Long id) {
        return taskRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(
                HttpStatus.NOT_FOUND, "Task not found: " + id));
    }

    private TaskResponse toResponse(Task task) {
        return new TaskResponse(
            task.getId(),
            task.getTitle(),
            task.getDescription(),
            task.getStatus(),
            task.getCreatedAt()
        );
    }
}
