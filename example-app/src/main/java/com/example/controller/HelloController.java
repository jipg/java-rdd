package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST controller exposing the hello endpoint.
 */
@RestController
public final class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello, World!";
    }
}
