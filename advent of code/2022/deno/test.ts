#!/usr/bin/env -S deno run --allow-read

import { assertEquals } from "https://deno.land/std@0.167.0/testing/asserts.ts"
import { solvers } from "./index.ts"

const solutions = {
  1: [24000, 45000],
  2: [15, 12],
  3: [157, 70],
  4: [2, 4],
  5: ["CMZ", "MCD"],
  6: [7, 19],
  7: [95437, 24933642],
  8: [21, 8],
  9: [88, 36],
  10: [13140, 0],
  11: [10605, 2713310158]
}
for (const [day, solution] of Object.entries(solutions)) {
  const name = `day${day}`
  Deno.test(name, () => {
    const [part1, part2] = solvers[name](true)
    assertEquals(part1, solution[0])
    assertEquals(part2, solution[1])
  })
}
