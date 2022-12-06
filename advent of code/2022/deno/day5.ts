import { readInput } from "./utils.ts"

export function day5(test = false) {
  const input = readInput(5, test)
  const [rawInitialStacks, rawProcedures] = input.split("\n\n").map((part) => part.split("\n"))

  const initialStacks = rawInitialStacks
    .reverse()
    .slice(1) // skip footer row
    .map((row) => {
      return row
        .replace(/[\[\]]*/g, "") // remove square brackets
        .replace(/\W{4}/g, " ") // collapse 4-spaces into a single space
        .split(" ")
    })

  const procedures: any = rawProcedures.map((row) => {
    return Array.from(row.matchAll(/\d+/g)).flat()
  })

  const stacks1: string[][] = []
  for (const row of initialStacks) {
    row.forEach((col, i) => {
      stacks1[i + 1] ??= []
      if (col !== "") {
        stacks1[i + 1].push(col)
      }
    })
  }
  const stacks2: string[][] = structuredClone(stacks1)

  for (const [num, src, dst] of procedures) {
    for (let i = 0; i < num; i++) {
      stacks1[dst].push(stacks1[src].pop()!)
    }
    const removed = stacks2[src].splice(stacks2[src].length - num, num)
    stacks2[dst].push(...removed)
  }

  return [stacks1.map((a) => a.at(-1)).join(""), stacks2.map((a) => a.at(-1)).join("")]
}
