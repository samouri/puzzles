import { identity } from "./utils.ts"

const getTestMonkeys = () => [
  monkey([79, 98], (old) => old * 19, [23, 2, 3]),
  monkey([54, 65, 75, 74], (old) => old + 6, [19, 2, 0]),
  monkey([79, 60, 97], (old) => old * old, [13, 1, 3]),
  monkey([74], (old) => old + 3, [17, 0, 1]),
]

const getRealMonkeys = () => [
  monkey([72, 97], (old) => old * 13, [19, 5, 6]),
  monkey([55, 70, 90, 74, 95], (old) => old * old, [7, 5, 0]),
  monkey([74, 97, 66, 57], (old) => old + 6, [17, 1, 0]),
  monkey([86, 54, 53], (old) => old + 2, [13, 1, 2]),
  monkey([50, 65, 78, 50, 62, 99], (old) => old + 3, [11, 3, 7]),
  monkey([90], (old) => old + 4, [2, 4, 6]),
  monkey([88, 92, 63, 94, 96, 82, 53, 53], (old) => old + 8, [5, 4, 7]),
  monkey([70, 60, 71, 69, 77, 70, 98], (old) => old * 7, [3, 2, 3]),
]

export function day11(test = false) {
  const doBusiness = (rounds: number, reduce?: (n: number) => number) => {
    const monkeys = test ? getTestMonkeys() : getRealMonkeys()
    Number(rounds).times(() => round(monkeys, reduce ?? identity))
    return monkeys
      .map((m) => m.inspections)
      .sortNumbersDesc()
      .slice(0, 2)
      .product()
  }

  const part1 = doBusiness(20, (n) => Math.floor(n / 3))
  const part2 = doBusiness(10_000)
  return [part1, part2]
}

function round(monkeys: Monkey[], reduce?: (n: number) => number) {
  for (const monkey of monkeys) {
    turn(monkey, monkeys, reduce)
  }
}

function turn(m: Monkey, monkeys: Monkey[], reduce: (n: number) => number = (n) => n) {
  const lcm = monkeys.map((m) => m.test[0]).product()
  for (const item of m.items) {
    const worry = reduce(m.op(item)) % lcm
    const [mod, dst1, dst2] = m.test
    const dst = worry % mod === 0 ? dst1 : dst2
    monkeys[dst].items.push(worry)
    m.inspections++
  }
  m.items = []
}

type Monkey = { items: number[]; op: (n: number) => number; test: [number, number, number]; inspections: number }
function monkey(items: number[], op: (n: number) => number, test: [number, number, number]): Monkey {
  return { items, op, test, inspections: 0 }
}
