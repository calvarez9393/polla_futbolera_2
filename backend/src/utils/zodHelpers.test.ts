import { describe, expect, it } from "vitest";
import { z } from "zod";
import { optionalTeamId } from "./zodHelpers.js";

const schema = z.object({ teamId: optionalTeamId });

describe("optionalTeamId", () => {
  it("acepta null, vacío y 0 como ausencia", () => {
    expect(schema.parse({ teamId: null }).teamId).toBeNull();
    expect(schema.parse({ teamId: "" }).teamId).toBeNull();
    expect(schema.parse({ teamId: 0 }).teamId).toBeNull();
    expect(schema.parse({}).teamId).toBeUndefined();
  });

  it("acepta id positivo", () => {
    expect(schema.parse({ teamId: 42 }).teamId).toBe(42);
    expect(schema.parse({ teamId: "42" }).teamId).toBe(42);
  });
});
