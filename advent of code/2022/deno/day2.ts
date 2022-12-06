import { readInput } from "./utils.ts"

export function day2(test = false) {
  const input = readInput(2, test).split("\n")
  const score1: any = {
    "A Z": 3, "B X": 1, "C Y": 2, // Losses
    "A X": 4, "B Y": 5, "C Z": 6, // Ties
    "A Y": 8, "B Z": 9, "C X": 7, // Wins
  }
  const score2: any = {
    "A Y": 4, "B X": 1, "C Z": 7, // Rock
    "A Z": 8, "B Y": 5, "C X": 2, // Paper
    "A X": 3, "B Z": 9, "C Y": 6, // Scissor
  }
  const part1 = input.map((row) => score1[row]).sum()
  const part2 = input.map((row) => score2[row]).sum()
  return [part1, part2]
}
