import { readInput } from "./utils.ts"

export function day1(test = false) {
  const input = readInput(1, test)
  const elves = input.split("\n\n").map((elf) => elf.split("\n").map(Number))
  const answer = elves.map((elf) => elf.sum()).sortNumbersDesc()

  return [answer[0], answer.take(3).sum()]
}
