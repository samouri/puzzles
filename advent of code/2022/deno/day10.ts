import { readInput } from "./utils.ts"

export function day10(test = false) {
  const input = readInput(10, test).trim().split("\n")

  let curr = 1
  let cycle = 1
  const values: Map<number, number> = new Map([[cycle, curr]])

  for (const instruction of input) {
    const [type, rawNum] = instruction.split(" ")
    if (type === "addx") {
      const num = +rawNum
      values.set(cycle++, curr)
      values.set(cycle++, curr)
      curr += num
    } else if (type === "noop") {
      values.set(cycle++, curr)
    }
  }

  const getStrength = (x: number) => values.get(x)! * x
  const part1 = [20, 60, 100, 140, 180, 220].map(getStrength).sum()

  cycle = 1
  for (let row = 0; row < 6; row++) {
    let str = ""
    for (let col = 0; col <= 39; col++) {
      const currVal = values.get(cycle)!
      if ([currVal - 1, currVal, currVal + 1].includes(col)) {
        str += "#"
      } else {
        str += "."
      }
      cycle++
    }
    console.log(str)
  }

  return [part1, 0]
}
