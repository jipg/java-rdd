package com.example;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

/**
 * Demonstrates JUnit 5 test patterns and AssertJ assertion syntax.
 * Replace these with real tests once production projects exist.
 */
final class SampleTest {

    @Test
    void addTwoPositiveNumbersReturnsSum() {
        // Arrange
        int a = 2;
        int b = 3;

        // Act
        int result = a + b;

        // Assert
        assertThat(result).isEqualTo(5);
    }

    @ParameterizedTest
    @CsvSource({
        "1, 1, 2",
        "0, 0, 0",
        "-1, 1, 0",
        "100, -50, 50"
    })
    void addVariousInputsReturnsExpectedSum(int a, int b, int expected) {
        int result = a + b;

        assertThat(result).isEqualTo(expected);
    }

    @Test
    void stringTrimRemovesLeadingAndTrailingWhitespace() {
        String input = "  hello world  ";

        String result = input.trim();

        assertThat(result).isEqualTo("hello world");
        assertThat(result).startsWith("hello");
        assertThat(result).isNotBlank();
    }

    @Test
    void listAddContainsNewElement() {
        List<String> list = new ArrayList<>(List.of("alpha", "bravo"));

        list.add("charlie");

        assertThat(list).hasSize(3);
        assertThat(list).contains("charlie");
        assertThat(list).isSorted();
    }
}
