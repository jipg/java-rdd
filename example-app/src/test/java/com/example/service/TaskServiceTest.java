package com.example.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.example.dto.TaskRequest;
import com.example.dto.TaskResponse;
import com.example.model.Task;
import com.example.model.TaskStatus;
import com.example.repository.TaskRepository;
import com.example.service.TaskServiceImpl;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.server.ResponseStatusException;

/**
 * Unit tests for TaskService — repository and entities are mocked.
 */
@ExtendWith(MockitoExtension.class)
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @InjectMocks
    private TaskServiceImpl taskService;

    @Test
    void createSavesTaskAndReturnsResponse() {
        Task saved = stubbedTask(1L, "Buy milk", "2% please", TaskStatus.PENDING);
        when(taskRepository.save(any(Task.class))).thenReturn(saved);

        TaskResponse response = taskService.create(new TaskRequest("Buy milk", "2% please"));

        assertThat(response.id()).isEqualTo(1L);
        assertThat(response.title()).isEqualTo("Buy milk");
        assertThat(response.status()).isEqualTo(TaskStatus.PENDING);
    }

    @Test
    void findAllReturnsMappedResponses() {
        Task taskA = stubbedTask(1L, "Task A", null, TaskStatus.PENDING);
        Task taskB = stubbedTask(2L, "Task B", "desc", TaskStatus.DONE);
        when(taskRepository.findAll()).thenReturn(List.of(taskA, taskB));

        List<TaskResponse> responses = taskService.findAll();

        assertThat(responses).hasSize(2);
        assertThat(responses.get(0).title()).isEqualTo("Task A");
    }

    @Test
    void findByIdThrowsWhenNotFound() {
        when(taskRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> taskService.findById(99L))
            .isInstanceOf(ResponseStatusException.class);
    }

    @Test
    void updatePatchesTitleAndDescription() {
        Task existing = stubbedTask(1L, "Old title", "old desc", TaskStatus.PENDING);
        Task updated = stubbedTask(1L, "New title", "new desc", TaskStatus.PENDING);
        when(taskRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(taskRepository.save(existing)).thenReturn(updated);

        TaskResponse response = taskService.update(1L, new TaskRequest("New title", "new desc"));

        assertThat(response.title()).isEqualTo("New title");
    }

    @Test
    void deleteCallsRepositoryDeleteById() {
        Task task = mock(Task.class);
        when(taskRepository.findById(1L)).thenReturn(Optional.of(task));

        taskService.delete(1L);

        verify(taskRepository).deleteById(1L);
    }

    private Task stubbedTask(Long id, String title, String description, TaskStatus status) {
        Task task = mock(Task.class);
        lenient().when(task.getId()).thenReturn(id);
        lenient().when(task.getTitle()).thenReturn(title);
        lenient().when(task.getDescription()).thenReturn(description);
        lenient().when(task.getStatus()).thenReturn(status);
        lenient().when(task.getCreatedAt()).thenReturn(LocalDateTime.of(2026, 1, 1, 0, 0));
        return task;
    }
}
