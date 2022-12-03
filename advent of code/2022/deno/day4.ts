import { readInput } from "./utils.ts";

export function day4(test = false) {
  const input = readInput(4, test);

  const pairs = input.split("\n");
  let supersetCount = 0;
  for (const pair of pairs) {
    const [first, second] = pair.split(",").map((part) => part.split("-").map(Number));
    if ((first[0] <= second[0] && first[1] >= second[1]) || (second[0] <= first[0] && second[1] >= first[1])) {
      supersetCount++;
    }
  }

  let overlappingCount = 0;
  for (const pair of pairs) {
    const [first, second] = pair.split(",").map((part) => part.split("-").map(Number));
    if ((first[0] <= second[0] && first[1] >= second[0]) || (second[0] <= first[0] && second[1] >= first[0])) {
      overlappingCount++;
    }
  }

  return [supersetCount, overlappingCount];
}
