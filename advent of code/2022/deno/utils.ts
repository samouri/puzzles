declare global {
  interface Array<T> {
    sortNumbersAsc: () => T[];
    sortNumbersDesc: () => T[];
    sum: () => number;
  }
}

Array.prototype.sortNumbersAsc = function () {
  return this.sort((a, b) => a - b);
};

Array.prototype.sortNumbersDesc = function () {
  return this.sort((a, b) => b - a);
};

Array.prototype.sum = function () {
  return this.reduce((a, b) => b + a);
};

export function readInput(day: number, example = false) {
  return new TextDecoder().decode(Deno.readFileSync(`../inputs/day${day}${example ? "-example" : ""}.txt`));
}
