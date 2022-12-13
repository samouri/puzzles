#!/usr/bin/env -S deno run --allow-read

import "./utils.ts"

import { day1 } from "./day1.ts"
import { day2 } from "./day2.ts"
import { day3 } from "./day3.ts"
import { day4 } from "./day4.ts"
import { day5 } from "./day5.ts"
import { day6 } from "./day6.ts"
import { day7 } from "./day7.ts"
import { day8 } from "./day8.ts"
import { day9 } from "./day9.ts"
import { day10 } from "./day10.ts"
import { day11 } from "./day11.ts"
import { day12 } from "./day12.ts"

export const solvers: any = { day1, day2, day3, day4, day5, day6, day7, day8, day9, day10, day11, day12 }

if (Deno.args.length >= 0) {
  for (const arg of Deno.args) {
    const name = `day${arg}`
    if (!(name in solvers)) {
      console.error(`Cannot find solver for day: ${arg}`)
      Deno.exit(1)
    }

    const [part1, part2] = solvers[`day${arg}`]()
    console.log(`Day ${arg}`)
    console.log(`–––––––––––––––––`)
    console.log(`  Part 1: ${part1}`)
    console.log(`  Part 2: ${part2}\n`)
  }
}
