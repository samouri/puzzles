import { readInput } from "./utils.ts"

export function day3(test = false) {
  const input = readInput(3, test)
    .split("\n")
    .map((l) => l.split(""))

  const code = (letter: string) => letter.charCodeAt(0)
  const priority = (letter: string) => {
    if (letter === letter.toUpperCase()) {
      return code(letter) - code("A") + 27
    }
    return code(letter) - code("a") + 1
  }

  const part1 = input
    .map((line) => {
      const mid = line.length / 2
      return line.slice(0, mid).intersect(line.slice(mid))[0]
    })
    .map(priority)
    .sum()

  const part2 = input
    .chunk(3)
    .map(([elf1, elf2, elf3]) => elf1.intersect(elf2).intersect(elf3)[0])
    .map(priority)
    .sum()

  return [part1, part2]
}
