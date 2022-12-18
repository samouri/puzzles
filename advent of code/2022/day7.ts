import { readInput } from "./utils.ts"

export function day7(test = false) {
  const input = readInput(7, test)
  const root = parseInput(input)

  const part1 = allDirs(root).map(getSize).filter((size) => size <= 100000).sum()

  const toFree = 30000000 - (70000000 - getSize(root))
  const part2 = allDirs(root).map(getSize).filter(size => size >= toFree).min()

  return [part1, part2]
}

type File = number
type Dir = { [filename: string]: File | Dir }
type Path = string[]

function isFile(dir: number | Dir): dir is number {
  return typeof dir === "number"
}

function allDirs(root: Dir, dirs: Dir[] = []): Dir[] {
  for (const entry of Object.values(root)) {
    if (!isFile(entry)) {
      dirs.push(entry)
      allDirs(entry, dirs)
    }
  }
  return dirs
}

function getSize(dir: Dir | number): number {
  if (isFile(dir)) return dir
  return Object.values(dir).reduce((acc: number, d) => acc + getSize(d), 0)
}

function parseInput(input: string) {
  const root = {}
  const cwd: Path = []

  const lines = input.split("\n")
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i]
    if (line === "$ ls") {
      while (i < lines.length - 1 && !lines[i + 1].startsWith("$")) {
        line = lines[++i]
        const [size, filename] = line.split(" ")
        insert(root, [...cwd, filename], size === "dir" ? {} : +size)
      }
    } else if (line.startsWith("$ cd")) {
      const path = line.split(" ").slice(2)[0]
      path === ".." ? cwd.pop() : cwd.push(path)
    }
  }
  return root
}

function insert(root: Dir, path: Path, value: Dir | number) {
  let curr = root
  const dirPath = path.slice(0, path.length - 1)
  for (const p of dirPath) {
    curr[p] ??= {}
    curr = curr[p] as Dir
  }
  curr[path.at(-1)!] = value
}
