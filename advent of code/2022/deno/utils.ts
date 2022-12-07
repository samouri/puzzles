declare global {
  interface Array<T> {
    sortNumbersAsc: () => T[]
    sortNumbersDesc: () => T[]
    take: (size: number) => T[]
    sum: () => number
    chunk: (size: number) => T[][]
    intersect: (other: Iterable<T>[]) => Array<T>
    toSet: () => Set<T>
    isUnique: () => boolean
    min: () => number
    max: () => number
  }

  interface Set<T> {
    intersect: (other: Iterable<T>[]) => Set<T>
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

Array.prototype.max = function () {
  return Math.max(...this)
}

Array.prototype.min = function () {
  return Math.min(...this)
}

Array.prototype.sum = function () {
  return this.reduce((a, b) => b + a)
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

Set.prototype.intersect = function (other) {
  const combined = new Set()
  for (const item of other) {
    if (this.has(item)) {
      combined.add(item)
    }
  }
  return combined
}

export function readInput(day: number, example = false) {
  return new TextDecoder().decode(Deno.readFileSync(`../inputs/day${day}${example ? "-example" : ""}.txt`))
}
