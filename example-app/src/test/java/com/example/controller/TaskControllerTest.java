package com.example.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.example.dto.TaskRequest;
import com.example.dto.TaskResponse;
import com.example.model.TaskStatus;
import com.example.service.TaskService;
import tools.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

/**
 * Unit tests for TaskController — service is mocked, no Spring context.
 */
@ExtendWith(MockitoExtension.class)
class TaskControllerTest {

    @Mock
    private TaskService taskService;

    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(new TaskController(taskService)).build();
    }

    @Test
    void createReturns201WithBody() throws Exception {
        TaskResponse response = taskResponse(1L, "Buy milk", TaskStatus.PENDING);
        when(taskService.create(any(TaskRequest.class))).thenReturn(response);

        mockMvc.perform(post("/tasks")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(new TaskRequest("Buy milk", null))))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").value(1L))
            .andExpect(jsonPath("$.title").value("Buy milk"));
    }

    @Test
    void findAllReturns200WithList() throws Exception {
        when(taskService.findAll()).thenReturn(List.of(
            taskResponse(1L, "Task A", TaskStatus.PENDING),
            taskResponse(2L, "Task B", TaskStatus.DONE)
        ));

        mockMvc.perform(get("/tasks"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(2));
    }

    @Test
    void findByIdReturns200() throws Exception {
        when(taskService.findById(1L)).thenReturn(taskResponse(1L, "Task A", TaskStatus.PENDING));

        mockMvc.perform(get("/tasks/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Task A"));
    }

    @Test
    void updateReturns200() throws Exception {
        TaskResponse updated = taskResponse(1L, "Updated", TaskStatus.DONE);
        when(taskService.update(eq(1L), any(TaskRequest.class))).thenReturn(updated);

        mockMvc.perform(put("/tasks/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(new TaskRequest("Updated", null))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.title").value("Updated"));
    }

    @Test
    void deleteReturns204() throws Exception {
        doNothing().when(taskService).delete(1L);

        mockMvc.perform(delete("/tasks/1"))
            .andExpect(status().isNoContent());
    }

    private TaskResponse taskResponse(Long id, String title, TaskStatus status) {
        return new TaskResponse(id, title, null, status, LocalDateTime.of(2026, 1, 1, 0, 0));
    }
}
