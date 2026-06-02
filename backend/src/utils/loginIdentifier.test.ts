import { describe, expect, it } from "vitest";
import { loginIdentifierSchema, normalizeLoginIdentifier } from "./loginIdentifier.js";

describe("loginIdentifier", () => {
  it("acepta documento numérico", () => {
    expect(loginIdentifierSchema.parse("1020304050")).toBe("1020304050");
  });

  it("rechaza correo", () => {
    expect(() => loginIdentifierSchema.parse("user@mail.com")).toThrow();
  });

  it("normaliza espacios", () => {
    expect(normalizeLoginIdentifier(" 300 123 4567 ")).toBe("3001234567");
  });
});
