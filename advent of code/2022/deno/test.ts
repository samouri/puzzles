#!/usr/bin/env -S deno run --allow-read

import { assertEquals } from "https://deno.land/std@0.167.0/testing/asserts.ts";
import { solvers } from "./index.ts";

const solutions = {
  1: [24000, 45000],
  4: [2, 4],
  5: ["CMZ", "MCD"],
};
for (const [day, solution] of Object.entries(solutions)) {
  const name = `day${day}`;
  Deno.test(name, () => {
    const [part1, part2] = solvers[name](true);
    assertEquals(part1, solution[0]);
    assertEquals(part2, solution[1]);
  });
}
