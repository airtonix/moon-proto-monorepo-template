import { describe, expect, it } from "vitest"
import { hello } from "./index"

describe("hello", () => {
  it("returns a greeting", () => {
    expect(hello("world")).toBe("hello, world")
  })
})
