import { readInput } from "./utils.ts"

export function day13(test = false) {
  const input: number[][] = readInput(13, test)
    .trim()
    .split("\n\n")
    .map((packets) => packets.split("\n").map((p) => JSON.parse(p)))

  let part1 = 0
  for (let i = 0; i < input.length; i++) {
    const [p1, p2] = input[i]
    if (isInRightOrder(p1, p2)) {
      part1 += i + 1
    }
  }

  const dividerPackets = [[[2]], [[6]]] as any
  const part2 = [...input.flatMap((p) => p), ...dividerPackets].sort(isInRightOrderHelper)
  const key1 = part2.findIndex((p) => JSON.stringify(p) === "[[2]]") + 1
  const key2 = part2.findIndex((p) => JSON.stringify(p) === "[[6]]") + 1

  return [part1, key1 * key2]
}

function isInRightOrder(p1: number[] | number, p2: number[] | number): boolean {
  const cmpVal = isInRightOrderHelper(p1, p2)
  return cmpVal === -1 || cmpVal === 0
}

// Return: -1 if correct order, 0 if indeterminate, 1 if incorrect
function isInRightOrderHelper(p1: number[] | number, p2: number[] | number): number {
  // Both are numbers
  if (typeof p1 === "number" && typeof p2 === "number") {
    if (p1 === p2) {
      return 0
    } else if (p1 < p2) {
      return -1
    } else {
      return 1
    }
  }

  // One is number, one is list
  if ((Array.isArray(p1) && !Array.isArray(p2)) || (!Array.isArray(p1) && Array.isArray(p2))) {
    return isInRightOrderHelper(toArray(p1), toArray(p2))
  }

  // Both are lists
  if (!Array.isArray(p1) || !Array.isArray(p2)) {
    throw new Error("Impossible")
  }

  for (let i = 0; i < p2.length; i++) {
    // Left list runs out first
    if (!(i in p1)) {
      return -1
    }
    const cmpVal = isInRightOrderHelper(p1[i], p2[i])
    if (cmpVal === 0) {
      continue
    }
    return cmpVal
  }

  // See if right list ran out first
  return p1.length === p2.length ? 0 : 1
}

function toArray<T>(o: T | T[]): T[] {
  return Array.isArray(o) ? o : [o]
}
