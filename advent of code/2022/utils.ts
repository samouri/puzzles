declare global {
  interface Number {
    times: (cb: (i: number) => void) => void
  }

  interface Array<T> {
    sortNumbersAsc: () => T[]
    sortNumbersDesc: () => T[]
    take: (size: number) => T[]
    sum: () => number
    product: () => number
    chunk: (size: number) => T[][]
    intersect: (other: Iterable<T>[]) => Array<T>
    toSet: () => Set<T>
    isUnique: () => boolean
    min: () => number
    max: () => number
    last(): T
    findIndex2d: (cb: (row: number, col: number) => boolean) => null | [number, number]
    forEach2d: (cb: (row: number, col: number) => any) => void
  }

  interface Set<T> {
    intersect: (other: Iterable<T>[]) => Set<T>
  }
}

Number.prototype.times = function (cb) {
  for (let i = 0; i < this; i++) {
    cb(i)
  }
}

Array.prototype.sortNumbersAsc = function () {
  return this.sort((a, b) => a - b)
}

Array.prototype.sortNumbersDesc = function () {
  return this.sort((a, b) => b - a)
}

Array.prototype.take = function (size) {
  return this.slice(0, size)
}

Array.prototype.isUnique = function () {
  return this.toSet().size == this.length
}

Array.prototype.toSet = function () {
  return new Set(this)
}

Array.prototype.last = function () {
  return this.at(-1)!
}

Array.prototype.min = function () {
  return Math.min(...this)
}

Array.prototype.sum = function () {
  return this.reduce((a, b) => b + a)
}

Array.prototype.product = function () {
  return this.reduce((a, b) => b * a)
}

Array.prototype.chunk = function (size) {
  const chunked = []
  for (let i = 0; i < this.length - size + 1; i += size) {
    chunked.push(this.slice(i, i + size))
  }
  return chunked
}

Array.prototype.intersect = function (other) {
  const thisSet = new Set(this)
  const combined = []
  for (const item of other) {
    if (thisSet.has(item)) {
      combined.push(item)
    }
  }
  return combined
}

Array.prototype.findIndex2d = function (cb) {
  const rowLength = this.length
  for (let row = 0; row < rowLength; row++) {
    const colLen = this[row].length
    for (let col = 0; col < colLen; col++) {
      if (cb(row, col)) {
        return [row, col]
      }
    }
  }
  return null
}

Array.prototype.forEach2d = function (cb) {
  this.findIndex2d((row, col) => cb(row, col) && false)
}

Set.prototype.intersect = function (other) {
  const combined = new Set()
  for (const item of other) {
    if (this.has(item)) {
      combined.add(item)
    }
  }
  return combined
}

export function identity<T>(x: T): T {
  return x
}

export function readInput(day: number, example = false) {
  return new TextDecoder().decode(Deno.readFileSync(`inputs/day${day}${example ? "-example" : ""}.txt`))
}
