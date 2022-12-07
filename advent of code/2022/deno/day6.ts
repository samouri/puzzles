import { readInput } from "./utils.ts"

export function day6(test = false) {
  const input = readInput(6, test).split("")

  const part1 = input.findIndex((_, i) => input.slice(i, i + 4).isUnique()) + 4
  const part2 = input.findIndex((_, i) => input.slice(i, i + 14).isUnique()) + 14
  return [part1, part2]
}
