import { describe, expect, it } from "vitest"
import { {{ exportName }} } from "./index"

describe("{{ exportName }}", () => {
  it("increments by 1", () => {
    expect({{ exportName }}(1)).toBe(2)
  })
})
