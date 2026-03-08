import { describe, expect, it } from "vitest";
import { inc } from "./index";

describe("inc", () => {
  it("increments by 1", () => {
    expect(inc(1)).toBe(2);
  });
});
