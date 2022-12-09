import { readInput } from "./utils.ts"

export function day9(test = false) {
  const input = readInput(9, test).trim()
  const movements = input // Flatten movements
    .split("\n")
    .map((line) => line.split(" "))
    .flatMap(([dir, num]) => new Array(+num).fill(dir))

  const snake1: Pos[] = Array.from({ length: 2 }).map(() => [0, 0])
  const snake2: Pos[] = Array.from({ length: 10 }).map(() => [0, 0])
  const tail1Visited = new Set([snake1.last().join(",")])
  const tail2Visited = new Set([snake2.last().join(",")])

  for (const dir of movements) {
    move(snake1[0], getOffsetForMovements(dir))
    for (let i = 1; i < snake1.length; i++) {
      follow(snake1[i - 1], snake1[i])
    }
    tail1Visited.add(snake1.last().join(","))
  }

  for (const dir of movements) {
    move(snake2[0], getOffsetForMovements(dir))
    for (let i = 1; i < snake2.length; i++) {
      follow(snake2[i - 1], snake2[i])
    }
    tail2Visited.add(snake2.last().join(","))
  }

  return [tail1Visited.size, tail2Visited.size]
}

type Pos = [number, number]
function getDiff(pos1: Pos, pos2: Pos): [number, number] {
  return [pos1[0] - pos2[0], pos1[1] - pos2[1]]
}
function move(pos: Pos, offset: [number, number]) {
  pos[0] += offset[0]
  pos[1] += offset[1]
}

function getOffsetForMovements(dir: string): [number, number] {
  if (dir === "R") return [1, 0]
  if (dir === "L") return [-1, 0]
  if (dir === "U") return [0, 1]
  if (dir === "D") return [0, -1]

  throw new Error(`Unexpected dir: ${dir}`)
}

function follow(head: Pos, tail: Pos) {
  const [diffX, diffY] = getDiff(head, tail)
  // If they are in the same column row, only move if 2 away.
  if (diffX === 0 || diffY === 0) {
    move(tail, [Math.trunc(diffX / 2), Math.trunc(diffY / 2)])
  } else if (Math.abs(diffX) + Math.abs(diffY) > 2) {
    move(tail, [Math.sign(diffX), Math.sign(diffY)])
  }
}

function printSet(s: Set<string>) {
  for (let y = 8; y >= -5; y--) {
    let row = `${y.toFixed(0).padStart(2, "0")}: `
    for (let x = -15; x < 20; x++) {
      if (s.has([x, y].join(","))) {
        row += "x"
      } else {
        row += "."
      }
    }
    console.log(row)
  }
}
