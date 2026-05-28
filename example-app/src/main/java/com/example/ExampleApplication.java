package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Spring Boot entry point for the example application.
 */
@SpringBootApplication
public class ExampleApplication {

    ExampleApplication() { }

    public static void main(String[] args) {
        SpringApplication.run(ExampleApplication.class, args);
    }
}
