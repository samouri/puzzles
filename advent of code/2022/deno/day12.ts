import { readInput } from "./utils.ts"

export function day12(test = false) {
  const grid: string[][] = readInput(12, test)
    .trim()
    .split("\n")
    .map((l) => l.split(""))

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

  const start = grid.findIndex2d((row, col) => grid[row][col] === "S")!
  const end = grid.findIndex2d((row, col) => grid[row][col] === "E")!

  search(...start)
  const part1 = best.get(getKey(...end))

  grid.forEach2d((row, col) => {
    if (grid[row][col] === "a") search(row, col)
  })
  const part2 = best.get(getKey(...end))

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
