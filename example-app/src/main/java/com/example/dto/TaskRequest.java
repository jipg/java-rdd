package com.example.dto;

/**
 * Payload for creating or updating a Task.
 */
public record TaskRequest(String title, String description) {
}
