import { Map2d, readInput } from "./utils.ts"

export function day14(test = false) {
  const input: string = readInput(14, test).trim()
  const pointsList = input.split("\n").map((s) => s.split("-> ").map((s) => s.split(",").map(Number)))
  const linesList = pointsList.flatMap((points) => {
    return points.slice(1).map((_, i) => [points[i], points[i + 1]])
  })
  const rock = "#"
  const sand = "O"

  // Initialize map
  const map: Map2d<number, string> = new Map2d()
  for (const [[x1, y1], [x2, y2]] of linesList) {
    if (x1 === x2) {
      ascendingRange(y1, y2).forEach((y) => {
        map.set([x1, y], rock)
      })
    } else {
      ascendingRange(x1, x2).forEach((x) => {
        map.set([x, y1], rock)
      })
    }
  }

  // Start dropping sand.
  const sandPoint = [500, 0]

  return [0, 0]
}

function print(map: Map2d<number, string>) {
  for (let y = 0; y < 12; y++) {
    let line = `${y}: `.padStart(4)
    for (let x = 490; x <= 510; x++) {
      const v = map.get([x, y])
      line += v ?? "."
    }
    console.log(line)
  }
}

function ascendingRange(n1: number, n2: number): number[] {
  const min = Math.min(n1, n2)
  const max = Math.max(n1, n2)
  return range(min, max + 1)
}

function range(start: number, end: number) {
  const ret = []
  for (let i = start; i < end; i++) {
    ret.push(i)
  }
  return ret
}
