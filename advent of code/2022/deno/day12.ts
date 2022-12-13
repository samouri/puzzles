import { readInput } from "./utils.ts"

export function day12(test = false) {
  const grid: string[][] = readInput(12, test)
    .trim()
    .split("\n")
    .map((line) => line.split(""))

  const best: Map<string, number> = new Map()
  function search(row: number, col: number, count = 0) {
    const key = getKey(row, col)
    if (best.has(key) && best.get(key)! < count) {
      return
    }
    best.set(key, count)
    for (const [r, c] of reachableNeighbors(grid, row, col)) {
      const v = best.get(getKey(r, c)) ?? Infinity
      if (count + 1 < v) {
        search(r, c, count + 1)
      }
    }
  }

  let start = [0, 0]
  let end = [0, 0]
  for (let row = 0; row < grid.length; row++) {
    for (let col = 0; col < grid[row].length; col++) {
      if (grid[row][col] === "S") {
        start = [row, col]
      } else if (grid[row][col] === "E") {
        end = [row, col]
      }
    }
  }

  search(start[0], start[1])

  const part1 = best.get(getKey(end[0], end[1]))

  for (let row = 0; row < grid.length; row++) {
    for (let col = 0; col < grid[row].length; col++) {
      if (grid[row][col] === "a") {
        search(row, col)
      }
    }
  }
  const part2 = best.get(getKey(end[0], end[1]))
  return [part1, part2]
}

function getKey(row: number, col: number) {
  return [row, col].join(",")
}

function reachableNeighbors(grid: string[][], row: number, col: number) {
  const code = (str: string) => {
    return str === "S" ? "a".charCodeAt(0) : str === "E" ? "z".charCodeAt(0) : str.charCodeAt(0)
  }
  const currHeight = code(grid[row][col])
  return [
    [row - 1, col],
    [row + 1, col],
    [row, col - 1],
    [row, col + 1],
  ].filter(([r, c]) => {
    const exists = r in grid && c in grid[r]
    if (!exists) return false

    const newHeight = code(grid[r][c])
    return newHeight - currHeight <= 1
  })
}
