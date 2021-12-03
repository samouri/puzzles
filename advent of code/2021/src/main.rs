use std::fs;

fn main() -> std::io::Result<()> {
  println!("Problem 1\n-----------");
  one().unwrap();

  println!("Problem 2\n-----------");
  two()
}

fn one() -> std::io::Result<()> {
  let path = "src/01/input.txt";
  let contents = fs::read_to_string(path).expect("Something went wrong reading the file");
  let lines = contents.lines();
  let nums: Vec<i32> = lines.map(|n| n.parse::<i32>().unwrap()).collect();

  // part 1
  let mut count = 0;
  for i in 1..nums.len() {
    if nums[i] > nums[i - 1] {
      count += 1
    }
  }
  println!("Part 1: {}", count);

  // part 2
  count = 0;
  for i in 3..nums.len() {
    let prev = nums[i - 3] + nums[i - 2] + nums[i - 1];
    let curr = nums[i - 2] + nums[i - 1] + nums[i];

    if curr > prev {
      count += 1
    }
  }
  println!("Part 2: {}\n", count);

  Ok(())
}

fn two() -> std::io::Result<()> {
  let path = "src/02/input.txt";
  let contents = fs::read_to_string(path).expect("Something went wrong reading the file");
  let instructions: Vec<(&str, i32)> = contents
    .lines()
    .map(|l| l.split_at(l.find(" ").unwrap()))
    .map(|(dir, count)| (dir.trim(), count.trim().parse::<i32>().unwrap()))
    .collect();

  // Part 1
  let mut depth = 0;
  let mut horizontal = 0;
  for (dir, count) in &instructions {
    if dir == &"down" {
      depth += count
    } else if dir == &"up" {
      depth -= count
    } else if dir == &"forward" {
      horizontal += count
    }
  }
  println!("Part 1: {}", depth * horizontal);

  // Part 2
  depth = 0;
  horizontal = 0;
  let mut aim = 0;
  for (dir, count) in &instructions {
    if dir == &"down" {
      aim += count
    } else if dir == &"up" {
      aim -= count
    } else if dir == &"forward" {
      horizontal += count;
      depth += aim * count;
    }
  }
  println!("Part 2: {}", depth * horizontal);

  Ok(())
}
