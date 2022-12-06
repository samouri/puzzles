import { readInput } from "./utils.ts"

export function day6(test = false) {
  const input = readInput(6, test).split("")

  const isUnique = (arr: string[]) => new Set(arr).size === arr.length
  const part1 = input.findIndex((_, i) => isUnique(input.slice(i, i + 4))) + 4
  const part2 = input.findIndex((_, i) => isUnique(input.slice(i, i + 14))) + 14
  return [part1, part2]
}
