import { readInput } from "./utils.ts"

export function day9(test = false) {
  const input = readInput(9, test).trim()
  const dirs: any = { R: [1, 0], L: [-1, 0], U: [0, 1], D: [0, -1] }
  const movements: [number, number][] = input // Flatten movements to a series of 1-step vectors
    .split("\n")
    .map((line) => line.split(" "))
    .flatMap(([dir, num]) => new Array(+num).fill(dir))
    .map((dir) => dirs[dir])

  function run(knots: number) {
    const rope: Vec[] = Array.from({ length: knots }).map(() => [0, 0])
    const visited = new Set([rope.last().join(",")])
    for (const movement of movements) {
      move(rope[0], movement)
      rope.slice(1).forEach((_, i) => follow(rope[i], rope[i + 1]))
      visited.add(rope.last().join(","))
    }
    return visited.size
  }

  return [run(2), run(10)]
}

type Vec = [number, number]
function move(pos: Vec, offset: Vec) {
  pos[0] += offset[0]
  pos[1] += offset[1]
}

function follow(head: Vec, tail: Vec) {
  const [diffX, diffY] = [head[0] - tail[0], head[1] - tail[1]]
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
