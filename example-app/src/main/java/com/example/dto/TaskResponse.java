package com.example.dto;

import com.example.model.TaskStatus;
import java.time.LocalDateTime;

/**
 * Read-only view of a Task returned by the API.
 */
public record TaskResponse(Long id, String title, String description,
                           TaskStatus status, LocalDateTime createdAt) {
}
