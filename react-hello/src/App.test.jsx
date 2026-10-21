import { render, screen } from "@testing-library/react";
import { expect, test } from "vitest";
import App from "./App";

test("shows the greeting", () => {
  render(<App />);
  expect(
    screen.getByRole("heading", { name: "Hello from React!" })
  ).toBeTruthy();
});
