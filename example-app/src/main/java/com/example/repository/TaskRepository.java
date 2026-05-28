package com.example.repository;

import com.example.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data repository for {@link Task} persistence.
 */
public interface TaskRepository extends JpaRepository<Task, Long> {
}
