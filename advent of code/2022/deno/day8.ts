import { readInput } from "./utils.ts"

export function day8(test = false) {
  const grid = readInput(8, test)
    .trim()
    .split("\n")
    .map((line) => line.split("").map(Number))

  const visible = new Set()
  const getKey = (row: number, col: number) => [row, col].join(",")
  const rowCount = grid.length
  const colCount = grid[0].length

  // Row by row
  for (let row = 0; row < rowCount; row++) {
    let max1 = -Infinity
    let max2 = -Infinity
    // Left to right --> col1
    // Right to left --> col2
    for (let col = 0; col < colCount; col++) {
      const col2 = colCount - col - 1

      const val1 = grid[row][col]
      const val2 = grid[row][col2]
      if (val1 > max1) {
        max1 = val1
        visible.add(getKey(row, col))
      }
      if (val2 > max2) {
        max2 = val2
        visible.add(getKey(row, col2))
      }
    }
  }

  // Column by column
  for (let col = 0; col < colCount; col++) {
    // Top to bottom --> row1
    // Bottom to top --> row2
    let max1 = -Infinity
    let max2 = -Infinity
    for (let row1 = 0; row1 < rowCount; row1++) {
      const row2 = rowCount - row1 - 1
      const val1 = grid[row1][col]
      const val2 = grid[row2][col]
      if (val1 > max1) {
        max1 = val1
        visible.add(getKey(row1, col))
      }
      if (val2 > max2) {
        max2 = val2
        visible.add(getKey(row2, col))
      }
    }
  }

  let mostScenic = -Infinity
  for (let row = 0; row < rowCount; row++) {
    for (let col = 0; col < colCount; col++) {
      const scenicism = getScenicScore(grid, row, col)
      mostScenic = Math.max(mostScenic, scenicism)
    }
  }

  return [visible.size, mostScenic]
}

function getScenicScore(grid: number[][], startRow: number, startCol: number) {
  const startVal = grid[startRow][startCol]

  const rowCount = grid.length
  const colCount = grid[0].length

  let right = 0
  for (let col = startCol + 1; col < colCount; col++) {
    right++
    if (grid[startRow][col] >= startVal) break
  }

  let left = 0
  for (let col = startCol - 1; 0 <= col; col--) {
    left++
    if (grid[startRow][col] >= startVal) break
  }

  let up = 0
  for (let row = startRow - 1; row >= 0; row--) {
    up++
    if (grid[row][startCol] >= startVal) break
  }

  let down = 0
  for (let row = startRow + 1; row < rowCount; row++) {
    down++
    if (grid[row][startCol] >= startVal) break
  }

  return up * down * left * right
}
