package com.example;

/**
 * Main application class providing greeting output.
 */
public class App {

  /**
   * Returns a greeting message.
   *
   * @return greeting string
   */
  public static String greeting() {
    return "Hello from Java!";
  }

  /**
   * Main entrypoint.
   *
   * @param args command line arguments
   */
  public static void main(String[] args) {
    System.out.println(greeting());
  }
}
