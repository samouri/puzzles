#!/usr/bin/env -S deno run --allow-read

import "./utils.ts";

import { day1 } from "./day1.ts";
import { day4 } from "./day4.ts";
import { day5 } from "./day5.ts";
import { day6 } from "./day6.ts";

export const solvers: any = { day1, day4, day5, day6 };

if (Deno.args.length >= 0) {
  for (const arg of Deno.args) {
    const name = `day${arg}`;
    if (!(name in solvers)) {
      console.error(`Cannot find solver for day: ${arg}`);
      Deno.exit(1);
    }

    const [part1, part2] = solvers[`day${arg}`]();
    console.log(`Day ${arg}`);
    console.log(`–––––––––––––––––`);
    console.log(`  Part 1: ${part1}`);
    console.log(`  Part 2: ${part2}\n`);
  }
}
