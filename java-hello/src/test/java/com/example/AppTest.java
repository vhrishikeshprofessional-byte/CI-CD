package com.example;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class AppTest {

  @Test
  void returnsGreeting() {
    assertEquals("Hello from Java!", App.greeting());
  }
}
