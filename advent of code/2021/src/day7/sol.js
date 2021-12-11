let example = `be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
  edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
  fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
  fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
  aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
  fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
  dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
  bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
  egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
  gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce`;

function getNums(signals) {
  let nums = {};
  let letters = {};
  let freq = { a: 0, b: 0, c: 0, d: 0, e: 0, f: 0, g: 0 };
  signals.forEach((s) => s.split("").forEach((c) => freq[c]++));

  nums[1] = signals.find((s) => s.length == 2);
  nums[7] = signals.find((s) => s.length == 3);
  nums[4] = signals.find((s) => s.length == 4);
  nums[8] = signals.find((s) => s.length == 7);

  let aChar = nums[7].split("").find((c) => !nums[1].includes(c));
  let bChar = Object.entries(freq).find(([k, v]) => v === 6)[0];
  let eChar = Object.entries(freq).find(([k, v]) => v === 4)[0];
  let fChar = Object.entries(freq).find(([k, v]) => v === 9)[0];

  letters[aChar] = "a";
  letters[bChar] = "b";
  letters[eChar] = "e";
  letters[fChar] = "f";

  let cChar = nums[1].split("").find((c) => c != fChar);
  letters[cChar] = "c";

  nums[0] = signals.find(
    (s) =>
      s.length === 6 &&
      [aChar, bChar, cChar, fChar, eChar].every((c) => s.includes(c))
  );
  let gChar = nums[0]
    .split("")
    .find((c) => ![aChar, bChar, cChar, fChar, eChar].includes(c));
  letters[gChar] = "g";

  let dChar = ["a", "b", "c", "d", "e", "f", "g"].find(
    (c) => !nums[0].includes(c)
  );
  letters[dChar] = "d";

  let twoLetters = "acdeg";
  let threeLetters = "acdfg";
  let fiveLetters = "abdfg";
  let nineLetters = "abcdfg";
  let sixLetters = "abdefg";

  let convertedSignals = signals.map((s) => [
    s,
    s
      .split("")
      .map((c) => letters[c])
      .sort()
      .join(""),
  ]);
  nums[2] = convertedSignals.find(([s, c]) => c === twoLetters)[0];
  nums[3] = convertedSignals.find(([s, c]) => c === threeLetters)[0];
  nums[5] = convertedSignals.find(([s, c]) => c === fiveLetters)[0];
  nums[5] = convertedSignals.find(([s, c]) => c === fiveLetters)[0];
  nums[6] = convertedSignals.find(([s, c]) => c === sixLetters)[0];
  nums[9] = convertedSignals.find(([s, c]) => c === nineLetters)[0];

  let conversions = {};
  Object.entries(nums).forEach(
    ([num, str]) => (conversions[str.split("").sort().join("")] = num)
  );

  return conversions;
}

example
  .split("\n")
  .map((l) => l.split("|"))
  .map(([signals, nums]) => {
    let conversions = getNums(signals.split(" "));
    nums = nums
      .trim()
      .split(" ")
      .map((s) => {
        return s.split("").sort().join("");
      });
    return +nums.map((n) => conversions[n]).join("");
  })
  .reduce((a, b) => a + b, 0);
