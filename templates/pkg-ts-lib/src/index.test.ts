import { describe, expect, it } from "vitest"
import { {{ exportName }} } from "./index"

describe("{{ exportName }}", () => {
  it("returns a greeting", () => {
    expect({{ exportName }}("world")).toBe("hello, world")
  })
})
